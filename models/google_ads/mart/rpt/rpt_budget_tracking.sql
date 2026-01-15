{{
    config(
        materialized='table',
        description='Budget tracking report optimized for Gauge charts - Ad Spend vs Budget comparison'
    )
}}

with campaign_performance as (
    select * from {{ ref('fct_campaign_performance') }}
),

daily_aggregation as (
    select
        campaign_id,
        campaign_name,
        advertising_channel_type,
        campaign_status,
        budget_id,
        budget_name,
        budget_period,
        budget_type,
        delivery_method,
        is_shared_budget,
        stat_date,
        
        -- Daily metrics
        daily_budget,
        sum(cost) as daily_cost,
        
        case
            when daily_budget > 0
            then round(sum(cost) / daily_budget * 100, 2)
            else 0
        end as daily_budget_pct
        
    from campaign_performance
    where daily_budget is not null
    group by 
        campaign_id,
        campaign_name,
        advertising_channel_type,
        campaign_status,
        budget_id,
        budget_name,
        budget_period,
        budget_type,
        delivery_method,
        is_shared_budget,
        stat_date,
        daily_budget
),

campaign_summary as (
    select
        campaign_id,
        campaign_name,
        advertising_channel_type,
        campaign_status,
        budget_id,
        budget_name,
        budget_period,
        budget_type,
        delivery_method,
        is_shared_budget,
        
        -- Time range
        min(stat_date) as first_date,
        max(stat_date) as last_date,
        count(distinct stat_date) as days_tracked,
        
        -- Budget totals
        max(daily_budget) as daily_budget,
        sum(daily_budget) as total_budget_allocated,
        
        -- Spend totals
        sum(daily_cost) as total_spent,
        round(avg(daily_cost), 2) as avg_daily_spend,
        round(max(daily_cost), 2) as max_daily_spend,
        round(min(daily_cost), 2) as min_daily_spend,
        
        -- Budget utilization
        case
            when sum(daily_budget) > 0
            then round(sum(daily_cost) / sum(daily_budget) * 100, 2)
            else 0
        end as budget_spent_pct,
        
        case
            when sum(daily_budget) > 0
            then round(sum(daily_budget) - sum(daily_cost), 2)
            else 0
        end as budget_remaining,
        
        -- Pacing metrics
        case
            when count(distinct stat_date) > 0 and max(daily_budget) > 0
            then round(avg(daily_cost) / max(daily_budget) * 100, 2)
            else 0
        end as avg_daily_pacing_pct,
        
        -- Days metrics
        count(case when daily_budget_pct >= 100 then 1 end) as days_over_budget,
        count(case when daily_budget_pct >= 90 and daily_budget_pct < 100 then 1 end) as days_near_budget,
        count(case when daily_budget_pct < 50 then 1 end) as days_under_utilized,
        
        -- Status flags
        case
            when sum(daily_cost) >= sum(daily_budget) then 'OVER_BUDGET'
            when sum(daily_cost) >= sum(daily_budget) * 0.95 then 'AT_BUDGET'
            when sum(daily_cost) >= sum(daily_budget) * 0.7 then 'ON_TRACK'
            when sum(daily_cost) >= sum(daily_budget) * 0.5 then 'UNDER_PACING'
            else 'SIGNIFICANTLY_UNDER'
        end as budget_status,
        
        case
            when max(daily_budget) > 0 and avg(daily_cost) / max(daily_budget) >= 1.1 then 'OVERSPENDING'
            when max(daily_budget) > 0 and avg(daily_cost) / max(daily_budget) >= 0.9 then 'OPTIMAL'
            when max(daily_budget) > 0 and avg(daily_cost) / max(daily_budget) >= 0.7 then 'ACCEPTABLE'
            when max(daily_budget) > 0 then 'UNDERSPENDING'
            else 'NO_BUDGET'
        end as pacing_status
        
    from daily_aggregation
    group by 
        campaign_id,
        campaign_name,
        advertising_channel_type,
        campaign_status,
        budget_id,
        budget_name,
        budget_period,
        budget_type,
        delivery_method,
        is_shared_budget
)

select * from campaign_summary
order by total_spent desc
