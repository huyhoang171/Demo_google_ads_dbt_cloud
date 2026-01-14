{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'campaign_history') }}
),

renamed as (
    select
        -- Primary Keys
        id as campaign_id,
        customer_id as account_id,
        base_campaign_id,
        
        -- Timestamps
        updated_at,
        _fivetran_synced,
        _fivetran_start,
        _fivetran_end,
        
        -- Campaign Information
        name as campaign_name,
        advertising_channel_type,
        advertising_channel_subtype,
        
        -- Settings
        start_date,
        end_date,
        final_url_suffix,
        tracking_url_template,
        frequency_caps,
        
        -- Status & Serving
        status as campaign_status,
        serving_status,
        ad_serving_optimization_status,
        
        -- Flags
        _fivetran_active as is_active,
        
        -- Experiment
        experiment_type,
        
        -- Metrics
        optimization_score,
        
        -- Other Settings
        payment_mode,
        vanity_pharma_display_url_mode,
        vanity_pharma_text,
        video_brand_safety_suitability
        
    from source
)

select * from renamed
