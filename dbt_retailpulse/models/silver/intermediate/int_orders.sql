with orders as (
    select * from {{ ref('stg_orders') }}
),

cleaned_data as (
    select
        cast(order_id as integer) as order_id,
        cast(customer_id as integer) as customer_id,
        cast(product_id as integer) as product_id,
        cast(quantity as integer) as quantity,
        cast(amount as decimal(10,2)) as amount,
        to_date(order_date, 'yyyy-MM-dd') as order_date
        -- Omitting '_rescued_data' implicitly drops it
    from orders
),

deduplicated as (
    -- Replicates dropDuplicates(["order_id"]) by selecting the first record per ID
    select * from (
        select *,
            row_number() over (partition by order_id order by order_date desc) as row_num
        from cleaned_data
    )
    where row_num = 1
)

select 
    -- Drop the helper row number column before saving to Silver
    * except (row_num)
from deduplicated