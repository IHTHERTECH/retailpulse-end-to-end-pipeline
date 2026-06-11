with products as (
    select * from {{ ref('stg_products') }}
),

cleaned_data as (
    select
        cast(product_id as integer) as product_id,
        cast(price as decimal(10,2)) as price,
        cast(stock_qty as integer) as stock_qty,
        product_name,
        category
        -- Omitting '_rescued_data' implicitly drops it
    from products
),

deduplicated as (
    -- Replicates dropDuplicates(["product_id"]) by selecting the first record per ID
    select * from (
        select *,
            row_number() over (partition by product_id order by product_id) as row_num
        from cleaned_data
    )
    where row_num = 1
)

select 
    -- Drop the helper row number column before saving to Silver
    * except (row_num)
from deduplicated

