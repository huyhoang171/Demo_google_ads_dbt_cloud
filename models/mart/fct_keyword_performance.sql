{{
    config(
        materialized='table',
        description='Daily keyword performance metrics with campaign and ad group context'
    )
}}

with keyword_stats as (
    select * from {{ ref('stg_google_ads__keyword_stats') }}
),

keyword_history as (
    select 
        criterion_id,
        ad_group_id,
        campaign_id,
        keyword_text,
        keyword_match_type,
        criterion_status,
        is_active
    from {{ ref('stg_google_ads__ad_group_criterion_history') }}
    where is_active = true
),

ad_group_history as (
    select 
        ad_group_id,
        campaign_id,
        ad_group_name,
        ad_group_status
    from {{ ref('stg_google_ads__ad_group_history') }}
    where is_active = true
),

campaign_history as (
    select 
        campaign_id,
        account_id,
        campaign_name,
        advertising_channel_type,
        campaign_status
    from {{ ref('stg_google_ads__campaign_history') }}
    where is_active = true
),

final as (
    select
        -- Primary Keys & Dimensions
        ks.account_id,
        ks.campaign_id,
        ch.campaign_name,
        ks.ad_group_id,
        agh.ad_group_name,
        ks.criterion_id,
        kh.keyword_text,
        kh.keyword_match_type,
        ks.stat_date,
        
        -- Campaign Details
        ch.advertising_channel_type,
        ch.campaign_status,
        
        -- Ad Group Details
        agh.ad_group_status,
        
        -- Keyword Details
        kh.criterion_status as keyword_status,
        ks.ad_network_type,
        ks.device,
        
        -- Impressions & Clicks
        ks.impressions,
        ks.clicks,
        ks.interactions,
        
        -- Costs (converting from micros to actual currency)
        round(ks.cost_micros / 1000000.0, 2) as cost,
        
        -- Conversions
        ks.conversions,
        round(ks.conversions_value, 2) as conversions_value,
        ks.view_through_conversions,
        
        -- Calculated Metrics
        case 
            when ks.impressions > 0 
            then round(ks.clicks * 100.0 / ks.impressions, 2)
            else 0 
        end as ctr,
        
        case 
            when ks.clicks > 0 
            then round(ks.cost_micros / 1000000.0 / ks.clicks, 2)
            else 0 
        end as cpc,
        
        case 
            when ks.impressions > 0 
            then round(ks.cost_micros / 1000000.0 / ks.impressions * 1000, 2)
            else 0 
        end as cpm,
        
        case 
            when ks.conversions > 0 
            then round(ks.cost_micros / 1000000.0 / ks.conversions, 2)
            else 0 
        end as cost_per_conversion,
        
        case 
            when ks.clicks > 0 
            then round(ks.conversions * 100.0 / ks.clicks, 2)
            else 0 
        end as conversion_rate,
        
        case 
            when ks.conversions > 0 
            then round(ks.conversions_value / ks.conversions, 2)
            else 0 
        end as avg_conversion_value,
        
        case 
            when ks.cost_micros > 0 
            then round((ks.conversions_value - ks.cost_micros / 1000000.0) / (ks.cost_micros / 1000000.0) * 100, 2)
            else 0 
        end as roas_percentage,
        
        -- Quality Score Metrics (if available in keyword history)
        null as quality_score,  -- Add from keyword_history if available
        
        -- Active View Metrics
        ks.active_view_impressions,
        ks.active_view_measurable_impressions,
        round(ks.active_view_measurable_cost_micros / 1000000.0, 2) as active_view_measurable_cost,
        round(ks.active_view_viewability * 100, 2) as active_view_viewability_pct,
        round(ks.active_view_measurability * 100, 2) as active_view_measurability_pct,
        
        -- Metadata
        ks._fivetran_synced as last_synced_at
        
    from keyword_stats ks
    left join keyword_history kh
        on ks.criterion_id = kh.criterion_id
        and ks.ad_group_id = kh.ad_group_id
        and ks.campaign_id = kh.campaign_id
    left join ad_group_history agh
        on ks.ad_group_id = agh.ad_group_id
        and ks.campaign_id = agh.campaign_id
    left join campaign_history ch
        on ks.campaign_id = ch.campaign_id
        and ks.account_id = ch.account_id
)

select * from final
