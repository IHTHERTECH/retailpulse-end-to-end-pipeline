with source as (
  select * from {{ source('retailpulse_bronze', 'customers') }}
)
 
select
  customer_id,
  name as customer_name,
  city,
  country,
  signup_date
from source
