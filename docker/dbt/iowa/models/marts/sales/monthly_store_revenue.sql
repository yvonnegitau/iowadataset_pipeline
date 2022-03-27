{{config(materialized = 'incremental'
)}}
select date_trunc(sales_date, month) as month,
    store_name,
    sum(sale_dollars) as monthly_revenue_dollar ,
    count(invoice_line_no) as total_orders,
    count(Distinct vendor_name) as total_vendors,
    count(Distinct itemno) as total_items,
    count(Distinct category_name) as total_categories,
    Round(AVG(sale_bottles)) as average_no_of_bottles,
    Round(AVG(sale_liters)) as average_litres
    from {{ref('general_facts')}} 
    group by 1,2