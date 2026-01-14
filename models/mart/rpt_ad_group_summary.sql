{{
    config(
        materialized='table',
        description='Ad group-level summary aggregating all-time performance metrics'
    )
}}

with ad_group_performance as (
    select * from {{ ref('fct_ad_group_performance') }}
),

final as (
    select
        account_id,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        advertising_channel_type,
        campaign_status,
        ad_group_type,
        ad_group_status,
        
        -- Time Periods
        min(stat_date) as first_stat_date,
        max(stat_date) as last_stat_date,
        count(distinct stat_date) as days_active,
        
        -- Total Metrics
        sum(impressions) as total_impressions,
        sum(clicks) as total_clicks,
        sum(interactions) as total_interactions,
        round(sum(cost), 2) as total_cost,
        
        -- Conversion Metrics
        sum(conversions) as total_conversions,
        round(sum(conversions_value), 2) as total_conversions_value,
        sum(view_through_conversions) as total_view_through_conversions,
        
        -- Aggregated Calculated Metrics
        case 
            when sum(impressions) > 0 
            then round(sum(clicks) * 100.0 / sum(impressions), 2)
            else 0 
        end as overall_ctr,
        
        case 
            when sum(clicks) > 0 
            then round(sum(cost) / sum(clicks), 2)
            else 0 
        end as overall_cpc,
        
        case 
            when sum(impressions) > 0 
            then round(sum(cost) / sum(impressions) * 1000, 2)
            else 0 
        end as overall_cpm,
        
        case 
            when sum(conversions) > 0 
            then round(sum(cost) / sum(conversions), 2)
            else 0 
        end as overall_cost_per_conversion,
        
        case 
            when sum(clicks) > 0 
            then round(sum(conversions) * 100.0 / sum(clicks), 2)
            else 0 
        end as overall_conversion_rate,
        
        case 
            when sum(conversions) > 0 
            then round(sum(conversions_value) / sum(conversions), 2)
            else 0 
        end as overall_avg_conversion_value,
        
        case 
            when sum(cost) > 0 
            then round((sum(conversions_value) - sum(cost)) / sum(cost) * 100, 2)
            else 0 
        end as overall_roas_percentage,
        
        -- Active View Metrics
        sum(active_view_impressions) as total_active_view_impressions,
        sum(active_view_measurable_impressions) as total_active_view_measurable_impressions,
        
        case
            when sum(active_view_measurable_impressions) > 0
            then round(sum(active_view_impressions) * 100.0 / sum(active_view_measurable_impressions), 2)
            else 0
        end as overall_viewability_rate,
        
        -- Last Update
        max(last_synced_at) as last_synced_at
        
    from ad_group_performance
    group by 
        account_id,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        advertising_channel_type,
        campaign_status,
        ad_group_type,
        ad_group_status
)

select * from final
order by total_cost desc
