{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'keyword_stats') }}
),

renamed as (
    select
        -- Primary Keys
        customer_id as account_id,
        campaign_id,
        ad_group_id,
        ad_group_criterion_criterion_id as criterion_id,
        date as stat_date,
        _fivetran_id,
        
        -- Dimensions
        campaign_base_campaign,
        ad_group_base_ad_group,
        ad_network_type,
        device,
        interaction_event_types,
        
        -- Metrics - Impressions & Clicks
        impressions,
        clicks,
        interactions,
        
        -- Metrics - Conversions
        conversions,
        conversions_value,
        view_through_conversions,
        
        -- Metrics - Costs (in micros)
        cost_micros,
        
        -- Metrics - Active View
        active_view_impressions,
        active_view_measurable_impressions,
        active_view_measurable_cost_micros,
        active_view_viewability,
        active_view_measurability,
        
        -- Metadata
        _fivetran_synced
        
    from source
)

select * from renamed
