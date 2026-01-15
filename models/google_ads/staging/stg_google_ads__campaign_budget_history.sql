{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'campaign_budget_history') }}
),

renamed as (
    select
        -- Primary Keys
        campaign_id,
        id as budget_id,
        
        -- Timestamps
        updated_at,
        _fivetran_synced,
        _fivetran_start,
        _fivetran_end,
        
        -- Budget Information
        name as budget_name,
        amount_micros,
        total_amount_micros,
        recommended_budget_amount_micros,
        
        -- Settings
        delivery_method,
        period as budget_period,
        type as budget_type,
        
        -- Status
        status as budget_status,
        
        -- Flags
        _fivetran_active as is_active,
        explicitly_shared as is_explicitly_shared,
        has_recommended_budget,
        
        -- Other
        reference_count
        
    from source
)

select * from renamed
