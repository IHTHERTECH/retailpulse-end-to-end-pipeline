with source as (
  select * from {{ source('retailpulse_bronze', 'customers') }}
)
 
select
  cast(customer_id as integer) as customer_id,
  name as customer_name,
  city,
  country,
  to_date(signup_date, 'yyyy-MM-dd') as signup_date
from source
