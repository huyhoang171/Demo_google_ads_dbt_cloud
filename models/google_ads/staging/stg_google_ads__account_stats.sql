{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'account_stats') }}
),

renamed as (
    select
        -- Primary Keys
        customer_id as account_id,
        date as stat_date,
        _fivetran_id,
        
        -- Dimensions
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
        
        -- Metrics - Costs (in micros, divide by 1,000,000 for actual amount)
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
