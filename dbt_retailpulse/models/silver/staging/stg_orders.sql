with source as (
  select * from {{ source('retailpulse_bronze', 'orders') }}
)

select
  order_id,
  customer_id,
  product_id,
  quantity,
  amount,
  order_date,
  status
from source
