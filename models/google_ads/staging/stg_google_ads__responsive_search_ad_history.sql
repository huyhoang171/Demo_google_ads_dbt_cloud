{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'responsive_search_ad_history') }}
),

renamed as (
    select
        -- Primary Keys
        ad_group_id,
        ad_id,
        
        -- Timestamps
        updated_at,
        _fivetran_synced,
        _fivetran_start,
        _fivetran_end,
        
        -- Ad Content
        headlines,
        descriptions,
        path_1,
        path_2,
        
        -- Flags
        _fivetran_active as is_active
        
    from source
)

select * from renamed
