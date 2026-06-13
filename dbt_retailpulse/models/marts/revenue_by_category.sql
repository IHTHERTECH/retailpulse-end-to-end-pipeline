with orders as (
    select * from {{ ref('stg_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
)

select
    p.category,
    count(o.order_id)       as total_orders,
    round(sum(o.amount), 2) as total_revenue
from orders o
join products p on o.product_id = p.product_id
group by p.category
order by total_revenue desc
