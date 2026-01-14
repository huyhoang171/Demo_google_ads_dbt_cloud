{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'geo_target') }}
),

renamed as (
    select
        -- Primary Keys
        id as geo_target_id,
        parent_geo_target_id,
        
        -- Geographic Information
        canonical_name,
        name as geo_target_name,
        country_code,
        target_type,
        
        -- Status
        status as geo_target_status,
        
        -- Metadata
        _fivetran_synced
        
    from source
)

select * from renamed
