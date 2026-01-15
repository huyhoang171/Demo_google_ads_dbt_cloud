{{
    config(
        materialized='incremental',
        unique_key=['account_id', 'campaign_id', 'stat_date', 'ad_network_type', 'device'],
        incremental_strategy='merge',
        description='Daily campaign performance metrics with historical campaign information'
    )
}}

with campaign_stats as (
    select * from {{ ref('stg_google_ads__campaign_stats') }}
    {% if is_incremental() %}
        -- Only process recent data to capture any late-arriving data
        -- Configurable via dbt_project.yml: vars (supports days/hours/minutes)
        where {{ get_incremental_lookback_filter() }}
    {% endif %}
),

campaign_history as (
    select 
        campaign_id,
        account_id,
        campaign_name,
        advertising_channel_type,
        advertising_channel_subtype,
        campaign_status,
        serving_status,
        start_date,
        end_date,
        is_active
    from {{ ref('stg_google_ads__campaign_history') }}
    where is_active = true
),

campaign_budget as (
    select 
        campaign_id,
        budget_id,
        budget_name,
        amount_micros as budget_amount_micros,
        budget_period,
        budget_type,
        delivery_method,
        is_explicitly_shared,
        has_recommended_budget,
        recommended_budget_amount_micros
    from {{ ref('stg_google_ads__campaign_budget_history') }}
    where is_active = true
),

final as (
    select
        -- Primary Keys & Dimensions
        cs.account_id,
        cs.campaign_id,
        ch.campaign_name,
        cs.stat_date,
        ch.advertising_channel_type,
        ch.advertising_channel_subtype,
        ch.campaign_status,
        ch.serving_status,
        cs.ad_network_type,
        cs.device,
        
        -- Campaign Timeline
        ch.start_date as campaign_start_date,
        ch.end_date as campaign_end_date,
        
        -- Budget Information
        cb.budget_id,
        cb.budget_name,
        cb.budget_period,
        cb.budget_type,
        cb.delivery_method,
        round(cb.budget_amount_micros / 1000000.0, 2) as daily_budget,
        case
            when cb.has_recommended_budget = true
            then round(cb.recommended_budget_amount_micros / 1000000.0, 2)
            else null
        end as recommended_daily_budget,
        cb.is_explicitly_shared as is_shared_budget,
        
        -- Impressions & Clicks
        cs.impressions,
        cs.clicks,
        cs.interactions,
        
        -- Costs (converting from micros to actual currency)
        round(cs.cost_micros / 1000000.0, 2) as cost,
        
        -- Conversions
        cs.conversions,
        round(cs.conversions_value, 2) as conversions_value,
        cs.view_through_conversions,
        
        -- Calculated Metrics
        case 
            when cs.impressions > 0 
            then round(cs.clicks * 100.0 / cs.impressions, 2)
            else 0 
        end as ctr,
        
        case 
            when cs.clicks > 0 
            then round(cs.cost_micros / 1000000.0 / cs.clicks, 2)
            else 0 
        end as cpc,
        
        case 
            when cs.impressions > 0 
            then round(cs.cost_micros / 1000000.0 / cs.impressions * 1000, 2)
            else 0 
        end as cpm,
        
        case 
            when cs.conversions > 0 
            then round(cs.cost_micros / 1000000.0 / cs.conversions, 2)
            else 0 
        end as cost_per_conversion,
        
        case 
            when cs.clicks > 0 
            then round(cs.conversions * 100.0 / cs.clicks, 2)
            else 0 
        end as conversion_rate,
        
        case 
            when cs.conversions > 0 
            then round(cs.conversions_value / cs.conversions, 2)
            else 0 
        end as avg_conversion_value,
        
        case 
            when cs.cost_micros > 0 
            then round((cs.conversions_value - cs.cost_micros / 1000000.0) / (cs.cost_micros / 1000000.0) * 100, 2)
            else 0 
        end as roas_percentage,
        
        -- Budget Utilization (daily)
        case
            when cb.budget_amount_micros > 0
            then round((cs.cost_micros / 1000000.0) / (cb.budget_amount_micros / 1000000.0) * 100, 2)
            else 0
        end as daily_budget_spend_pct,
        
        case
            when cb.budget_amount_micros > 0
            then round((cb.budget_amount_micros / 1000000.0) - (cs.cost_micros / 1000000.0), 2)
            else 0
        end as daily_budget_remaining,
        
        -- Active View Metrics
        cs.active_view_impressions,
        cs.active_view_measurable_impressions,
        round(cs.active_view_measurable_cost_micros / 1000000.0, 2) as active_view_measurable_cost,
        round(cs.active_view_viewability * 100, 2) as active_view_viewability_pct,
        round(cs.active_view_measurability * 100, 2) as active_view_measurability_pct,
        
        -- Metadata
        cs._fivetran_synced as last_synced_at
        
    from campaign_stats cs
    left join campaign_history ch
        on cs.campaign_id = ch.campaign_id
        and cs.account_id = ch.account_id
    left join campaign_budget cb
        on cs.campaign_id = cb.campaign_id
)

select * from final
