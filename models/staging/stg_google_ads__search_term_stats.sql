{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'search_term_stats') }}
),

renamed as (
    select
        -- Primary Keys
        customer_id as account_id,
        campaign_id,
        ad_group_id,
        date as stat_date,
        _fivetran_id,
        
        -- Search Term Information
        resource_name,
        search_term,
        search_term_match_type,
        status as search_term_status,
        
        -- Dimensions
        cast(null as string) as ad_network_type,  -- Not available in search_term_stats
        cast(null as string) as device,  -- Not available in search_term_stats
        cast(null as string) as interaction_event_types,  -- Not available in search_term_stats
        
        -- Metrics - Impressions & Clicks
        impressions,
        clicks,
        0 as interactions,  -- Not available in search_term_stats
        
        -- Metrics - Position
        absolute_top_impression_percentage,
        top_impression_percentage,
        
        -- Metrics - Conversions
        conversions,
        cast(null as float64) as conversions_value,  -- Not available in search_term_stats source
        view_through_conversions,
        conversions_from_interactions_rate,
        conversions_from_interactions_value_per_interaction,
        
        -- Metrics - Costs & Performance
        cost_micros,
        average_cpc,
        ctr,
        
        -- Metadata
        _fivetran_synced
        
    from source
)

select * from renamed
