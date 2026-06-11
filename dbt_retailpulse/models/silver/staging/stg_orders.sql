with source as (
  select * from {{ source('retailpulse_bronze', 'orders') }}
)

select
  cast(order_id as integer) as order_id,
  cast(customer_id as integer) as customer_id,
  cast(product_id as integer) as product_id,
  cast(quantity as integer) as quantity,
  cast(amount as decimal(10, 2)) as amount,
  to_date(order_date, 'yyyy-MM-dd') as order_date,
  status
from source
