{% macro get_incremental_lookback_filter() %}
    {#
        Macro to generate flexible lookback filter for incremental models
        Supports days, hours, or minutes based on dbt_project.yml configuration
        
        Usage in models:
        {% if is_incremental() %}
            where {{ get_incremental_lookback_filter() }}
        {% endif %}
        
        Configuration (dbt_project.yml):
        vars:
          incremental_lookback_days: 3        # OR
          incremental_lookback_hours: 12      # OR
          incremental_lookback_minutes: 30
    #}
    
    {%- set lookback_minutes = var('incremental_lookback_minutes', none) -%}
    {%- set lookback_hours = var('incremental_lookback_hours', none) -%}
    {%- set lookback_days = var('incremental_lookback_days', 3) -%}
    
    {%- if lookback_minutes is not none -%}
        {# Priority 1: Minutes (most granular) #}
        stat_date >= timestamp_sub(current_timestamp(), interval {{ lookback_minutes }} minute)
        
    {%- elif lookback_hours is not none -%}
        {# Priority 2: Hours #}
        stat_date >= timestamp_sub(current_timestamp(), interval {{ lookback_hours }} hour)
        
    {%- else -%}
        {# Priority 3: Days (default) #}
        stat_date >= date_sub(current_date(), interval {{ lookback_days }} day)
        
    {%- endif -%}
    
{% endmacro %}
