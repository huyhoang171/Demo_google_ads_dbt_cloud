{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'user_list') }}
),

renamed as (
    select
        -- Primary Keys
        id as user_list_id,
        
        -- User List Information
        name as user_list_name,
        description,
        type as user_list_type,
        
        -- Access & Status
        access_reason,
        account_user_list_status,
        membership_status,
        closing_reason,
        
        -- Eligibility
        eligible_for_display as is_eligible_for_display,
        eligible_for_search as is_eligible_for_search,
        
        -- Size Metrics
        size_for_display,
        size_for_search,
        size_range_for_display,
        size_range_for_search,
        
        -- Flags
        read_only as is_read_only,
        
        -- Metadata
        _fivetran_synced
        
    from source
)

select * from renamed
