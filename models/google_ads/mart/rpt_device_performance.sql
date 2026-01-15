{{
    config(
        materialized='table',
        description='Performance metrics aggregated by device type across all campaigns'
    )
}}

with campaign_performance as (
    select * from {{ ref('fct_campaign_performance') }}
),

final as (
    select
        device,
        
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
        
        -- Last Update
        max(last_synced_at) as last_synced_at
        
    from campaign_performance
    where device is not null
    group by device
)

select * from final
order by total_cost desc
