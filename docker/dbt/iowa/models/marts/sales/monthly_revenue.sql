{{config(materialized = 'incremental'
)}}
select date_trunc(sales_date, month) as month,
    sum(sale_dollars) as monthly_revenue_dollar ,
    count(invoice_line_no) as orders,
    count(Distinct store_name) as total_stores,
    count(Distinct vendor_name) as total_vendors,
    count(Distinct itemno) as total_items,
    count(Distinct category_name) as total_categories,
    Round(AVG(sale_bottles)) as average_no_of_bottles,
    Round(AVG(sale_liters)) as average_litres
    from {{ref('general_facts')}} 
    group by 1