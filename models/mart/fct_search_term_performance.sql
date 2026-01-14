{{
    config(
        materialized='table',
        description='Daily search term performance metrics showing actual search queries that triggered ads'
    )
}}

with search_term_stats as (
    select * from {{ ref('stg_google_ads__search_term_stats') }}
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
        sts.account_id,
        sts.campaign_id,
        ch.campaign_name,
        sts.ad_group_id,
        agh.ad_group_name,
        sts.search_term,
        sts.stat_date,
        
        -- Campaign Details
        ch.advertising_channel_type,
        ch.campaign_status,
        
        -- Ad Group Details
        agh.ad_group_status,
        
        -- Search Term Details
        sts.ad_network_type,
        sts.device,
        
        -- Impressions & Clicks
        sts.impressions,
        sts.clicks,
        sts.interactions,
        
        -- Costs (converting from micros to actual currency)
        round(sts.cost_micros / 1000000.0, 2) as cost,
        
        -- Conversions
        sts.conversions,
        round(sts.conversions_value, 2) as conversions_value,
        sts.view_through_conversions,
        
        -- Calculated Metrics
        case 
            when sts.impressions > 0 
            then round(sts.clicks * 100.0 / sts.impressions, 2)
            else 0 
        end as ctr,
        
        case 
            when sts.clicks > 0 
            then round(sts.cost_micros / 1000000.0 / sts.clicks, 2)
            else 0 
        end as cpc,
        
        case 
            when sts.impressions > 0 
            then round(sts.cost_micros / 1000000.0 / sts.impressions * 1000, 2)
            else 0 
        end as cpm,
        
        case 
            when sts.conversions > 0 
            then round(sts.cost_micros / 1000000.0 / sts.conversions, 2)
            else 0 
        end as cost_per_conversion,
        
        case 
            when sts.clicks > 0 
            then round(sts.conversions * 100.0 / sts.clicks, 2)
            else 0 
        end as conversion_rate,
        
        case 
            when sts.conversions > 0 
            then round(sts.conversions_value / sts.conversions, 2)
            else 0 
        end as avg_conversion_value,
        
        case 
            when sts.cost_micros > 0 
            then round((sts.conversions_value - sts.cost_micros / 1000000.0) / (sts.cost_micros / 1000000.0) * 100, 2)
            else 0 
        end as roas_percentage,
        
        -- Metadata
        sts._fivetran_synced as last_synced_at
        
    from search_term_stats sts
    left join ad_group_history agh
        on sts.ad_group_id = agh.ad_group_id
        and sts.campaign_id = agh.campaign_id
    left join campaign_history ch
        on sts.campaign_id = ch.campaign_id
        and sts.account_id = ch.account_id
)

select * from final
