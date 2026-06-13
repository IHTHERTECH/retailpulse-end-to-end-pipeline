with orders as (
  select * from {{ ref('stg_orders') }}
)

select
  order_date,
  count(order_id) as total_orders,
  round(sum(amount), 2) as total_revenue
from orders
group by order_date
order by order_date
