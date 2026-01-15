{{
    config(
        materialized='incremental',
        unique_key=['account_id', 'campaign_id', 'ad_group_id', 'ad_id', 'stat_date', 'ad_network_type', 'device'],
        incremental_strategy='merge',
        description='Daily ad performance metrics with full hierarchy (campaign, ad group, ad)'
    )
}}

with ad_stats as (
    select * from {{ ref('stg_google_ads__ad_stats') }}
    {% if is_incremental() %}
        -- Only process recent data to capture any late-arriving data
        -- Configurable via dbt_project.yml: vars (supports days/hours/minutes)
        where {{ get_incremental_lookback_filter() }}
    {% endif %}
),

ad_history as (
    select 
        ad_id,
        ad_group_id,
        ad_name,
        ad_type,
        ad_status,
        is_active
    from {{ ref('stg_google_ads__ad_history') }}
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
        ads.account_id,
        ads.campaign_id,
        ch.campaign_name,
        ads.ad_group_id,
        agh.ad_group_name,
        ads.ad_id,
        ah.ad_name,
        ads.stat_date,
        
        -- Campaign Details
        ch.advertising_channel_type,
        ch.campaign_status,
        
        -- Ad Group Details
        agh.ad_group_status,
        
        -- Ad Details
        ah.ad_type,
        ah.ad_status,
        ads.ad_network_type,
        ads.device,
        
        -- Impressions & Clicks
        ads.impressions,
        ads.clicks,
        ads.interactions,
        
        -- Costs (converting from micros to actual currency)
        round(ads.cost_micros / 1000000.0, 2) as cost,
        
        -- Conversions
        ads.conversions,
        round(ads.conversions_value, 2) as conversions_value,
        ads.view_through_conversions,
        ads.cost_per_conversion as cost_per_conversion_raw,
        
        -- Video Metrics
        ads.video_trueview_views,
        
        -- Calculated Metrics
        case 
            when ads.impressions > 0 
            then round(ads.clicks * 100.0 / ads.impressions, 2)
            else 0 
        end as ctr,
        
        case 
            when ads.clicks > 0 
            then round(ads.cost_micros / 1000000.0 / ads.clicks, 2)
            else 0 
        end as cpc,
        
        case 
            when ads.impressions > 0 
            then round(ads.cost_micros / 1000000.0 / ads.impressions * 1000, 2)
            else 0 
        end as cpm,
        
        case 
            when ads.conversions > 0 
            then round(ads.cost_micros / 1000000.0 / ads.conversions, 2)
            else 0 
        end as cost_per_conversion,
        
        case 
            when ads.clicks > 0 
            then round(ads.conversions * 100.0 / ads.clicks, 2)
            else 0 
        end as conversion_rate,
        
        case 
            when ads.conversions > 0 
            then round(ads.conversions_value / ads.conversions, 2)
            else 0 
        end as avg_conversion_value,
        
        case 
            when ads.cost_micros > 0 
            then round((ads.conversions_value - ads.cost_micros / 1000000.0) / (ads.cost_micros / 1000000.0) * 100, 2)
            else 0 
        end as roas_percentage,
        
        case
            when ads.impressions > 0 and ads.video_trueview_views is not null
            then round(ads.video_trueview_views * 100.0 / ads.impressions, 2)
            else 0
        end as view_rate,
        
        -- Active View Metrics
        ads.active_view_impressions,
        ads.active_view_measurable_impressions,
        round(ads.active_view_measurable_cost_micros / 1000000.0, 2) as active_view_measurable_cost,
        round(ads.active_view_viewability * 100, 2) as active_view_viewability_pct,
        round(ads.active_view_measurability * 100, 2) as active_view_measurability_pct,
        
        -- Metadata
        ads._fivetran_synced as last_synced_at
        
    from ad_stats ads
    left join ad_history ah
        on ads.ad_id = ah.ad_id
        and ads.ad_group_id = ah.ad_group_id
    left join ad_group_history agh
        on ads.ad_group_id = agh.ad_group_id
        and ads.campaign_id = agh.campaign_id
    left join campaign_history ch
        on ads.campaign_id = ch.campaign_id
        and ads.account_id = ch.account_id
)

select * from final
