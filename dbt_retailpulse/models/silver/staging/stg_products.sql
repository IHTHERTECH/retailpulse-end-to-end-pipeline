with source as (
  select * from {{ source('retailpulse_bronze', 'products') }}
)

select
  product_id,
  name as product_name,
  category,
  price,
  stock_qty
from source
