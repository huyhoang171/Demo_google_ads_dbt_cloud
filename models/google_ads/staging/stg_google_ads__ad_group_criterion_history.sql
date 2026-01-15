{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ source('google_ads', 'ad_group_criterion_history') }}
),

renamed as (
    select
        -- Primary Keys
        ad_group_id,
        id as criterion_id,
        
        -- Timestamps
        updated_at,
        _fivetran_synced,
        _fivetran_start,
        _fivetran_end,
        
        -- Criterion Information
        type as criterion_type,
        display_name,
        
        -- Keyword Information
        keyword_text,
        keyword_match_type,
        
        -- Bidding
        cpc_bid_micros,
        cpm_bid_micros,
        cpv_bid_micros,
        bid_modifier,
        
        -- Quality Score
        quality_info_score as quality_score,
        quality_info_creative_score as creative_quality_score,
        quality_info_post_click_score as post_click_quality_score,
        quality_info_search_predicted_ctr as search_predicted_ctr,
        
        -- First Page Estimates
        first_page_cpc_micros,
        first_position_cpc_micros,
        top_of_page_cpc_micros,
        
        -- URLs
        final_urls,
        final_mobile_urls,
        final_url_suffix,
        tracking_url_template,
        
        -- Status
        status as criterion_status,
        approval_status,
        system_serving_status,
        
        -- Flags
        _fivetran_active as is_active,
        negative as is_negative,
        
        -- Targeting Dimensions
        age_range_type,
        gender_type,
        income_range_type,
        parental_status_type,
        placement_url,
        topic_constant_id,
        user_interest_id,
        user_list_id,
        audience_id,
        combined_audience_id,
        custom_affinity_id,
        custom_audience_id,
        custom_intent_id,
        youtube_channel_id,
        youtube_video_id,
        mobile_app_category_constant_id,
        mobile_app_category_constant_name,
        mobile_application_app_id,
        mobile_application_name,
        app_payment_model_type,
        webpage_conditions,
        parent_ad_group_criterion_id,
        disapproval_reasons
        
    from source
)

select * from renamed
