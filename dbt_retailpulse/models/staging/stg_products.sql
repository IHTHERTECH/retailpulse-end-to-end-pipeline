with source as (
  select * from {{ source('retailpulse_silver', 'products') }}
)

select
  product_id,
  product_name,
  category,
  price,
  stock_qty
from source
