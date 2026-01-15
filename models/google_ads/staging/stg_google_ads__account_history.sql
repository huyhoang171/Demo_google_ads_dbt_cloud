{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'account_history') }}
),

renamed as (
    select
        -- Primary Keys
        id as account_id,
        
        -- Timestamps
        updated_at,
        _fivetran_synced,
        _fivetran_start,
        _fivetran_end,
        
        -- Account Information
        manager_customer_id,
        descriptive_name as account_name,
        currency_code,
        time_zone,
        
        -- Settings
        auto_tagging_enabled,
        final_url_suffix,
        tracking_url_template,
        
        -- Flags
        hidden as is_hidden,
        manager as is_manager,
        test_account as is_test_account,
        _fivetran_active as is_active,
        
        -- Metrics
        optimization_score,
        
        -- Other
        pay_per_conversion_eligibility_failure_reasons
        
    from source
)

select * from renamed
