{{
    config(
        materialized='table',
        description='Daily ad group performance metrics with campaign and ad group details'
    )
}}

with ad_group_stats as (
    select * from {{ ref('stg_google_ads__ad_group_stats') }}
),

ad_group_history as (
    select 
        ad_group_id,
        campaign_id,
        ad_group_name,
        campaign_name,
        ad_group_type,
        ad_group_status,
        is_active
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
        ags.account_id,
        ags.campaign_id,
        ch.campaign_name,
        ags.ad_group_id,
        agh.ad_group_name,
        ags.stat_date,
        
        -- Campaign Details
        ch.advertising_channel_type,
        ch.campaign_status,
        
        -- Ad Group Details
        agh.ad_group_type,
        agh.ad_group_status,
        ags.ad_network_type,
        ags.device,
        
        -- Impressions & Clicks
        ags.impressions,
        ags.clicks,
        ags.interactions,
        
        -- Costs (converting from micros to actual currency)
        round(ags.cost_micros / 1000000.0, 2) as cost,
        
        -- Conversions
        ags.conversions,
        round(ags.conversions_value, 2) as conversions_value,
        ags.view_through_conversions,
        ags.cost_per_conversion as cost_per_conversion_raw,
        
        -- Calculated Metrics
        case 
            when ags.impressions > 0 
            then round(ags.clicks * 100.0 / ags.impressions, 2)
            else 0 
        end as ctr,
        
        case 
            when ags.clicks > 0 
            then round(ags.cost_micros / 1000000.0 / ags.clicks, 2)
            else 0 
        end as cpc,
        
        case 
            when ags.impressions > 0 
            then round(ags.cost_micros / 1000000.0 / ags.impressions * 1000, 2)
            else 0 
        end as cpm,
        
        case 
            when ags.conversions > 0 
            then round(ags.cost_micros / 1000000.0 / ags.conversions, 2)
            else 0 
        end as cost_per_conversion,
        
        case 
            when ags.clicks > 0 
            then round(ags.conversions * 100.0 / ags.clicks, 2)
            else 0 
        end as conversion_rate,
        
        case 
            when ags.conversions > 0 
            then round(ags.conversions_value / ags.conversions, 2)
            else 0 
        end as avg_conversion_value,
        
        case 
            when ags.cost_micros > 0 
            then round((ags.conversions_value - ags.cost_micros / 1000000.0) / (ags.cost_micros / 1000000.0) * 100, 2)
            else 0 
        end as roas_percentage,
        
        -- Active View Metrics
        ags.active_view_impressions,
        ags.active_view_measurable_impressions,
        round(ags.active_view_measurable_cost_micros / 1000000.0, 2) as active_view_measurable_cost,
        round(ags.active_view_viewability * 100, 2) as active_view_viewability_pct,
        round(ags.active_view_measurability * 100, 2) as active_view_measurability_pct,
        
        -- Metadata
        ags._fivetran_synced as last_synced_at
        
    from ad_group_stats ags
    left join ad_group_history agh
        on ags.ad_group_id = agh.ad_group_id
        and ags.campaign_id = agh.campaign_id
    left join campaign_history ch
        on ags.campaign_id = ch.campaign_id
        and ags.account_id = ch.account_id
)

select * from final
