{{config(materialized = 'view',
partition_by = {
      "field": "sales_date",
      "data_type": "timestamp",
      "granularity": "month"
    })}}
select
    invoice_line_no,
    cast(date as timestamp) as sales_date,
    lower(name) as store_name,
    address,
    city,
    zipcode,
    store_location,
    county,
    lower(category_name) as category_name,
    lower(vendor_name) as vendor_name,
    itemno,
    im_desc,
    cast(pack as integer) as pack,
    cast(bottle_volume_ml as numeric) as bottle_volume_ml,
    cast(state_bottle_cost as numeric) as state_bottle_cost,
    cast(sale_bottles as integer) as sale_bottles,
    cast(sale_dollars as numeric) as sale_dollars,
    cast(sale_liters as numeric) as sale_liters,
    cast(sale_gallons as numeric) as sale_gallons



from {{source('iowa_prod','raw_data')}}
-- {% if var('is_test_run',default=true)%}
--     limit 100
-- {% endif %}