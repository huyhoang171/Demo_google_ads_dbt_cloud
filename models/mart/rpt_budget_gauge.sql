{{
    config(
        materialized='table',
        description='Simplified budget gauge metrics - Perfect for Gauge chart visualization (Ad Spend vs Budget)'
    )
}}

with budget_tracking as (
    select * from {{ ref('rpt_budget_tracking') }}
),

-- Overall account-level gauge
account_gauge as (
    select
        'ACCOUNT_TOTAL' as metric_level,
        'All Campaigns' as metric_name,
        
        sum(total_budget_allocated) as total_budget,
        sum(total_spent) as total_spent,
        sum(budget_remaining) as budget_remaining,
        
        case
            when sum(total_budget_allocated) > 0
            then round(sum(total_spent) / sum(total_budget_allocated) * 100, 2)
            else 0
        end as spend_percentage,
        
        case
            when sum(total_spent) >= sum(total_budget_allocated) then 'OVER_BUDGET'
            when sum(total_spent) >= sum(total_budget_allocated) * 0.95 then 'AT_BUDGET'
            when sum(total_spent) >= sum(total_budget_allocated) * 0.7 then 'ON_TRACK'
            else 'UNDER_PACING'
        end as status,
        
        sum(days_tracked) as total_days_tracked
        
    from budget_tracking
),

-- Campaign-level gauges
campaign_gauges as (
    select
        'CAMPAIGN' as metric_level,
        campaign_name as metric_name,
        
        total_budget_allocated as total_budget,
        total_spent,
        budget_remaining,
        budget_spent_pct as spend_percentage,
        budget_status as status,
        days_tracked as total_days_tracked
        
    from budget_tracking
),

-- Channel-level gauges
channel_gauges as (
    select
        'CHANNEL' as metric_level,
        advertising_channel_type as metric_name,
        
        sum(total_budget_allocated) as total_budget,
        sum(total_spent) as total_spent,
        sum(budget_remaining) as budget_remaining,
        
        case
            when sum(total_budget_allocated) > 0
            then round(sum(total_spent) / sum(total_budget_allocated) * 100, 2)
            else 0
        end as spend_percentage,
        
        case
            when sum(total_spent) >= sum(total_budget_allocated) then 'OVER_BUDGET'
            when sum(total_spent) >= sum(total_budget_allocated) * 0.95 then 'AT_BUDGET'
            when sum(total_spent) >= sum(total_budget_allocated) * 0.7 then 'ON_TRACK'
            else 'UNDER_PACING'
        end as status,
        
        sum(days_tracked) as total_days_tracked
        
    from budget_tracking
    group by advertising_channel_type
),

-- Status-level summary
status_summary as (
    select
        'STATUS' as metric_level,
        budget_status as metric_name,
        
        sum(total_budget_allocated) as total_budget,
        sum(total_spent) as total_spent,
        sum(budget_remaining) as budget_remaining,
        
        case
            when sum(total_budget_allocated) > 0
            then round(sum(total_spent) / sum(total_budget_allocated) * 100, 2)
            else 0
        end as spend_percentage,
        
        budget_status as status,
        sum(days_tracked) as total_days_tracked
        
    from budget_tracking
    group by budget_status
),

final as (
    select * from account_gauge
    union all
    select * from campaign_gauges
    union all
    select * from channel_gauges
    union all
    select * from status_summary
)

select 
    metric_level,
    metric_name,
    round(total_budget, 2) as total_budget,
    round(total_spent, 2) as total_spent,
    round(budget_remaining, 2) as budget_remaining,
    spend_percentage,
    
    -- Gauge color indicator
    case
        when spend_percentage >= 100 then 'RED'
        when spend_percentage >= 95 then 'ORANGE'
        when spend_percentage >= 70 then 'GREEN'
        when spend_percentage >= 50 then 'YELLOW'
        else 'GRAY'
    end as gauge_color,
    
    status,
    total_days_tracked
    
from final
order by 
    case metric_level
        when 'ACCOUNT_TOTAL' then 1
        when 'CHANNEL' then 2
        when 'CAMPAIGN' then 3
        when 'STATUS' then 4
    end,
    total_spent desc
