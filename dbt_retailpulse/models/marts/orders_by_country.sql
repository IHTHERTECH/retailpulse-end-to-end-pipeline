with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
)

select
    c.country,
    count(o.order_id)       as total_orders,
    round(sum(o.amount), 2) as total_revenue
from orders o
join customers c on o.customer_id = c.customer_id
group by c.country
order by total_revenue desc
