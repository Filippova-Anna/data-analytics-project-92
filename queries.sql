select count(customer_id) as customers_count
from customers;
/* данный запрос считает общее количество покупателей */

select
	concat(e.first_name, ' ', e.last_name) as name,
	sum(s.quantity) as operations,
	sum(p.price * s.quantity) as income
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
        TO_CHAR(s.sale_date, 'day') AS weekday,
        ROUND(SUM(s.quantity * p.price)) AS inc
    FROM 
        sales s
    JOIN 
        employees e ON s.sales_person_id = e.employee_id
    JOIN 
        products p ON s.product_id = p.product_id
    GROUP BY 
        1, 2
)
SELECT
    name,
    weekday,
    SUM(inc) AS total_income
FROM 
    tab
GROUP BY 
    1, 2
ORDER BY 
    CASE 
        WHEN weekday = 'Monday' THEN 1
        WHEN weekday = 'Tuesday' THEN 2
        WHEN weekday = 'Wednesday' THEN 3
        WHEN weekday = 'Thursday' THEN 4
        WHEN weekday = 'Friday' THEN 5
        WHEN weekday = 'Saturday' THEN 6
        WHEN weekday = 'Sunday' THEN 7
    END, 
    name;
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
count(distinct c.customer_id) as total_customer,
round(SUM(p.price*s.quantity)) as income
from customers c
join sales s on s.customer_id = c.customer_id
join products p on p.product_id = s.product_id
group by 1
order by 1 asc;
--данные по количеству уникальных покупателей и выручке, которую они принесли.

with tab as (
select
CONCAT(c.first_name , ' ', c.last_name) AS customer,
min(s.sale_date) as first_purchase,
p.price as product_price,
s.sales_person_id
from sales s
join products p on p.product_id = s.product_id
join customers c on c.customer_id =s.customer_id
where p.price = 0
group by 1, 3, 4, c.customer_id
order by c.customer_id
)
select
customer,
first_purchase as sale_date,
CONCAT(e.first_name , ' ', e.last_name) as seller
from tab
join employees e on e.employee_id = tab.sales_person_id;
--отчет о покупателях, первая покупка которых была в ходе проведения акций.
