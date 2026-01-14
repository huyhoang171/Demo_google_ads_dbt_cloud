{{
    config(
        materialized='table',
        description='Campaign-level summary aggregating all-time performance metrics'
    )
}}

with campaign_performance as (
    select * from {{ ref('fct_campaign_performance') }}
),

final as (
    select
        account_id,
        campaign_id,
        campaign_name,
        advertising_channel_type,
        advertising_channel_subtype,
        campaign_status,
        serving_status,
        campaign_start_date,
        campaign_end_date,
        
        -- Budget Information
        max(budget_id) as budget_id,
        max(budget_name) as budget_name,
        max(budget_period) as budget_period,
        max(budget_type) as budget_type,
        max(delivery_method) as delivery_method,
        max(daily_budget) as daily_budget,
        max(is_shared_budget) as is_shared_budget,
        max(recommended_daily_budget) as recommended_daily_budget,
        
        -- Budget Totals
        sum(daily_budget) as total_budget_allocated,
        
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
        
        -- Budget Utilization
        case
            when sum(daily_budget) > 0
            then round(sum(cost) / sum(daily_budget) * 100, 2)
            else 0
        end as overall_budget_spend_pct,
        
        case
            when sum(daily_budget) > 0
            then round(sum(daily_budget) - sum(cost), 2)
            else 0
        end as total_budget_remaining,
        
        case
            when sum(daily_budget) > 0
            then round(sum(cost) / sum(daily_budget), 4)
            else 0
        end as budget_utilization_ratio,
        
        -- Budget Status Flag
        case
            when sum(cost) >= sum(daily_budget) then 'Over Budget'
            when sum(cost) >= sum(daily_budget) * 0.9 then 'Near Budget Limit'
            when sum(cost) >= sum(daily_budget) * 0.7 then 'On Track'
            when sum(daily_budget) > 0 then 'Under Utilized'
            else 'No Budget Set'
        end as budget_status,
        
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
        account_id,
        campaign_id,
        campaign_name,
        advertising_channel_type,
        advertising_channel_subtype,
        campaign_status,
        serving_status,
        campaign_start_date,
        campaign_end_date
)

select * from final
order by total_cost desc
