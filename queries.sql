select count(customer_id) as customers_count
from customers;
/* данный запрос считает общее количество покупателей */

select
	concat(e.first_name, ' ', e.last_name) as name,
	count(s.sales_id) as operations,
	floor(sum(p.price * s.quantity)) as income
from sales s
join employees e on s.sales_person_id = e.employee_id
join products p on s.product_id = p.product_id
group by concat(e.first_name, ' ', e.last_name)
order by income desc
limit 10;
--Запрос находит топ 10 продавцов по выручке, показывая количество сделок и суммарный доход.

WITH avg_sales AS (
    select
	    AVG(p.price*s.quantity)AS avg_income,
	    s.sales_person_id 
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    group by s.sales_person_id
)
select
	concat(e.first_name, ' ', e.last_name) AS name,
	ROUND(AVG(s.quantity * p.price)) AS average_income
FROM sales s
JOIN employees e ON s.sales_person_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
CROSS JOIN avg_sales a
GROUP BY e.first_name, e.last_name
HAVING ROUND(AVG(avg_income)) > ROUND(AVG(s.quantity * p.price))
ORDER BY average_income;
--Запрос находит продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.


WITH tab AS (
    SELECT
        CONCAT(e.first_name, ' ', e.last_name) AS name,
        extract(isodow from s.sale_date) as weekday,
        ROUND(SUM(s.quantity * p.price)) AS inc
    FROM sales s
    join employees e ON s.sales_person_id = e.employee_id
    join products p ON s.product_id = p.product_id
    GROUP BY 1, 2
    order by weekday
 )
SELECT
    name,
    (case
	    when weekday = 1 then 'Monday   '
	    when weekday = 2 then 'tuesday  '
	    when weekday = 3 then 'wednesday'
	    when weekday = 4 then 'thursday '
	    when weekday = 5 then 'friday   '
	    when weekday = 6 then 'saturday '
	    when weekday = 7 then 'sunday   '
    end) as weekday,
    SUM(inc) AS income
FROM tab
GROUP BY 1, 2, tab.weekday
order by tab.weekday, name;
--запрос содержит информацию о выручке по дням недели для каждогопродавца.



select
case
when 25 >= age and age >= 16 then '16-25'
when 40 >= age and age >= 26 then '26-40'
else '40+'
end as age_category,
COUNT(age)
from customers c
group by 1
order by 1;
--количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
select
to_char(s.sale_date, 'YYYY-MM') as date,
count(distinct c.customer_id) as total_customers,
floor(SUM(p.price*s.quantity)) as income
from customers c
join sales s on s.customer_id = c.customer_id
join products p on p.product_id = s.product_id
group by 1
order by 1 asc;
--данные по количеству уникальных покупателей и выручке, которую они принесли.

WITH FirstPurchase AS (
    select distinct
        customer_id,
        MIN(sale_date) AS first_purchase_date
    from public.sales
    GROUP by customer_id
)
select distinct
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    s.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
from sales s
join customers c ON s.customer_id = c.customer_id
join employees e ON s.sales_person_id = e.employee_id
join FirstPurchase fp ON s.customer_id = fp.customer_id
where s.sale_date = fp.first_purchase_date
    AND EXISTS (
        SELECT 1
        FROM public.products
        WHERE s.product_id = public.products.product_id
        AND public.products.price = 0
);
--отчет о покупателях, первая покупка которых была в ходе проведения акций.
