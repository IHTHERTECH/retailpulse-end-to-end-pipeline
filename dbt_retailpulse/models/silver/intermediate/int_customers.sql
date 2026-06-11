with customers as (
    select * from {{ ref('stg_customers') }}
),

cleaned_data as (
    select
        customer_id,
        -- Cast name to first and last name
        split_part(customer_name, ' ', 1) as first_name,
        split_part(customer_name, ' ', 2) as last_name,
        city,
        country,
        signup_date
        -- Omitting '_rescued_data' implicitly drops it
    from customers
),

deduplicated as (
    -- Replicates dropDuplicates(["customer_id"]) by picking the first record per ID
    select * from (
        select *,
            row_number() over (partition by customer_id order by signup_date desc) as row_num
        from cleaned_data
    )
    where row_num = 1
)

select 
    -- Drop the helper row number column before saving to Silver
    * except (row_num)
from deduplicated
