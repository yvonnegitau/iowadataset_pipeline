{{config(materialized = 'incremental',
 unique_key = "invoice_line_no",
partition_by = {
      "field": "sales_date",
      "data_type": "timestamp",
      "granularity": "month"
     
    },
    cluster_by = "county",)}}
select
    invoice_line_no,
    sales_date,
    store_name,
    address,
    city,
    zipcode,
    store_location,
    county,
    category_name,
    vendor_name,
    itemno,
    im_desc,
    pack,
    bottle_volume_ml,
    state_bottle_cost,
    sale_bottles,
    sale_dollars,
    sale_liters,
    sale_gallons



from {{ref('staging_sales')}}
-- {% if var('is_test_run',default=true)%}
--     limit 100
-- {% endif %}