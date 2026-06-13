with source as (
  select * from {{ source('retailpulse_silver', 'customers') }}
)
 
select
  customer_id,
  customer_name,
  city,
  country,
  signup_date
from source
