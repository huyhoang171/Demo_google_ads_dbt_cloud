{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'ad_group_history') }}
),

renamed as (
    select
        -- Primary Keys
        id as ad_group_id,
        campaign_id,
        base_ad_group_id,
        
        -- Timestamps
        updated_at,
        _fivetran_synced,
        _fivetran_start,
        _fivetran_end,
        
        -- Ad Group Information
        name as ad_group_name,
        campaign_name,
        type as ad_group_type,
        
        -- Settings
        ad_rotation_mode,
        final_url_suffix,
        tracking_url_template,
        target_restrictions,
        display_custom_bid_dimension,
        
        -- Status
        status as ad_group_status,
        
        -- Flags
        _fivetran_active as is_active,
        explorer_auto_optimizer_setting_opt_in as auto_optimizer_enabled
        
    from source
)

select * from renamed
