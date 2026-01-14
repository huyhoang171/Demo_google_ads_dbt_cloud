{{
    config(
        materialized='table',
        description='Monthly performance trends aggregated across all campaigns'
    )
}}

with campaign_performance as (
    select * from {{ ref('fct_campaign_performance') }}
),

final as (
    select
        date_trunc(stat_date, month) as month_start_date,
        format_date('%Y-%m', stat_date) as year_month,
        
        -- Distinct Counts
        count(distinct account_id) as num_accounts,
        count(distinct campaign_id) as num_campaigns,
        count(distinct stat_date) as num_days,
        
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
        
    from campaign_performance
    group by 
        date_trunc(stat_date, month),
        format_date('%Y-%m', stat_date)
)

select * from final
order by month_start_date desc
