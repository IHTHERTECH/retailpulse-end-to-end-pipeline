with source as (
  select * from {{ source('retailpulse_bronze', 'products') }}
)

select
  cast(product_id as integer) as product_id,
  name as product_name,
  category,
  cast(price as decimal(10, 2)) as price,
  cast(stock_qty as integer) as stock_qty
from source
