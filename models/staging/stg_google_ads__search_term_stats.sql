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
        
        -- Metrics - Impressions & Clicks
        impressions,
        clicks,
        
        -- Metrics - Position
        absolute_top_impression_percentage,
        top_impression_percentage,
        
        -- Metrics - Conversions
        conversions,
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
