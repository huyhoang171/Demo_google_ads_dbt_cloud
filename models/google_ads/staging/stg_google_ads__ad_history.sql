{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'ad_history') }}
),

renamed as (
    select
        -- Primary Keys
        ad_group_id,
        id as ad_id,
        
        -- Timestamps
        updated_at,
        _fivetran_synced,
        _fivetran_start,
        _fivetran_end,
        
        -- Ad Information
        name as ad_name,
        type as ad_type,
        display_url,
        
        -- URLs
        final_urls,
        final_mobile_urls,
        final_app_urls,
        final_url_suffix,
        tracking_url_template,
        url_collections,
        
        -- Status & Policy
        status as ad_status,
        policy_summary_approval_status,
        policy_summary_review_status,
        
        -- Flags
        _fivetran_active as is_active,
        added_by_google_ads as is_added_by_google_ads,
        
        -- Other
        ad_strength,
        action_items,
        device_preference,
        system_managed_resource_source
        
    from source
)

select * from renamed
