# https://drive.google.com/drive/u/0/folders/10Expv2znmvjwxQT4PqW8pr-1G6JqVY9C

use employees;
select * from employees e;
select * from departments d;



## General Querries
use farmers_market;

select customer_first_name, customer_last_name, 
concat( lower(substring(customer_first_name,1,1)), upper(substring(customer_first_name,2)))
 as new_name from farmers_market.customer;
 
 ### Print a report of everything customer_id 4 has ever purchased at the farmer’s market, sorted by market date, vendor ID, and product ID.
 select market_date, customer_id, vendor_id, product_id, quantity, quantity* cost_to_customer_per_qty as price
 from customer_purchases where customer_id = 4 order by market_date, vendor_id, product_id;
 
 ### Play with NULL, coalesce
 select *, ifnull(product_size, "Not Present") as product_type,
 coalesce(product_size,product_qty_type,product_name) as coal_prod_size
 from product;
 
 ### Analyse the purchases made at the farmer market when it rained.
 
 select *, round(quantity* cost_to_customer_per_qty,2) as price from customer_purchases where market_date IN (select market_date from market_date_info where market_rain_flag = 1);

### Use of SELECT CASE
select * ,
CASE
when round(cost_to_customer_per_qty*quantity ,2) < 5.00 then 'under $ 5.00'
when round(cost_to_customer_per_qty*quantity ,2) between  5.00 and 9.99 then '5.00–9.99'
when round(cost_to_customer_per_qty*quantity ,2) between  10.00 and 19.99 then '10.00-19.99'
else '$20.00 and over'
end as cost_bin
from farmers_market.customer_purchases;


### Classify categories as Fresh and Not Fresh
select *, if(lower(vendor_type) like '%fresh%', "Fresh Category Vendor", "Others") as vendor_category from vendor;

## Joins
### Get details of all vendors selling products along with the name of each product they sell and the quantity of that product present in their inventory?
use farmers_market;
select v.vendor_name, v.vendor_type, p.product_name, sum(vi.quantity) from vendor v 
join vendor_inventory vi on v.vendor_id = vi.vendor_id
join product p on vi.product_id = p.product_id group by v.vendor_name,p.product_name;

select v.vendor_name, v.vendor_type,  sum(vi.quantity) from vendor v 
join vendor_inventory vi on v.vendor_id = vi.vendor_id
join product p on vi.product_id = p.product_id group by v.vendor_name;


### List all the products along with their product category name.
select p.product_name, pc.product_category_name from product p 
join product_category pc on p.product_category_id = pc.product_category_id;

### Get a list of customers' zip codes for customers who made a purchase on 2019-04-06.
select distinct(c.customer_zip) from customer c
inner join customer_purchases cp using(customer_id) where cp.market_date = '2019-04-06';

### Get all the customers who haven’t purchased anything from the market yet.
select * from customer c
left join customer_purchases cp on c.customer_id = cp.customer_id where cp.customer_id is NULL;

### Get all the customers who have deleted their account from the market.
select cp.customer_id from customer c right join customer_purchases cp using(customer_id) where c.customer_id is NULL;

select c.customer_id , "New Customer" as customer_type from customer c
left join customer_purchases cp using(customer_id) where cp.customer_id is NULL
union distinct(
select cp.customer_id, "Deleted Customer" as customer_type from customer c
right join customer_purchases cp using(customer_id) where c.customer_id is NULL
);


## Left Join
select * from employees e LEFT JOIN departments d ON e.department_id = d.department_id ORDER BY  e.employee_id;

USE `employees`;
## Coorelated Subquerries 
#select * from employees e where exists (select * from departments d where d.department_id = e.department_id);
 
## Aggregation Functions
### Min/Max/Sum/Count/Average

### Count
select count(0),count(1),count(true),count(first_name),count(department_id), 
count(salary > 90000.00) as salary_count, count(distinct department_id) from employees e;

### SUM
select sum(salary),sum(salary>90000.00) from employees e; # behaves like a count for salary condition

### GROUP_BY
USE `farmers_market`;

## Get a list of customers who made purchases on each market date
select customer_id, market_date from customer_purchases group by market_date;

## Filter out the vendors who brought at least 100 items to the farmer's marke over the 
## period 2019-05-02 and 2019-05-16

select vendor_id, sum(quantity) as items from vendor_inventory where market_date 
between '2019-05-02' and '2019-05-16' group by vendor_id having items >=100;



# WINDOW FUNCTIONS (Aggregations performed at group level, but displayed at row level)

## get me total salary that a company xyz pays 
USE `employees`;
select sum(salary),department_id from employees group by department_id;

## show me total department wise salary across employees

select *, (select sum(salary) from employees) as total_sal from employees;
select sum(salary) over() as total_sal from employees;

select employee_id, salary, department_id,
sum(salary) over() as tot_salary,
sum(salary) over(partition by department_id) as dept_wise_salary
from employees; 

 
# get me average department wise salary , across every row, sorted by first name

select employee_id, first_name, salary, department_id,
round(avg(salary) over(partition by department_id order by first_name	),2) as average_salary
from employees;


# get me the 13th highest salary

select * from 
(select employee_id, first_name, salary, department_id,
row_number() over(order by salary) as rwn,
rank() over(order by salary) as rnk,
dense_rank() over(order by salary) as dn_rnk
from employees) t 
where t.dn_rnk = 13;

## Ranking and Analytical Querries, Get the nth high salary


select * from (select
employee_id, first_name, department_id, salary,
row_number() over(order by salary desc) as rw_number,
rank() over(order by salary desc) as rnk,
dense_rank() over(order by salary desc) as dense_rnk
from employees) t
where t.dense_rnk = 7;


# get the running sum of sales for last 3 days including today
drop database windows;
create database windows;
use windows;
CREATE TABLE sales(employee VARCHAR(50), date DATE, sale INT);
 
 
insert into sales values('odin','2017-03-01',200) ;
insert into sales values('odin','2017-04-01',300) ;
insert into sales values('odin','2017-05-01',300) ;
insert into sales values('thor','2017-03-01',400) ;
insert into sales values('thor','2017-04-01',300) ;
insert into sales values('thor','2017-05-01',500) ;

select * from sales;

select * , sum(sale) over(partition by employee) as partbyemp
from sales;

select * , 
sum(sale) over(partition by employee) as partbyemp,
sum(sale) over(partition by employee order by date) as partorderbydate
from sales;


select * , sum(sale) over(partition by employee order by date desc
RANGE BETWEEN unbounded preceding and current row) as asofdate
from sales;
select *, sum(sale) over(partition by employee order by date desc 
ROWS BETWEEN unbounded preceding and current row)
from sales;



## get me the next highest salary for every employee and then the difference between them
use employees;

select employee_id, first_name,job_id, department_id, salary,
lead(salary,1) over(order by salary) as next_highest_salary
from employees;

select *, (t.next_highest_salary - t.salary) as difference from (select employee_id, first_name,job_id, department_id, salary,
lead(salary,1) over(order by salary ) as next_highest_salary
from employees)t;


## Get the ntile groupings of the salaries
select employee_id, salary, ntile(10) over() as tiles from employees;
select employee_id, first_name, hire_date, job_id, salary,
last_value(salary) over(order by salary desc
RANGE BETWEEN current row and unbounded following) as decile_demo 
from employees;

## Get the 4th highest salary across the entire employes

select * from (select employee_id, first_name, hire_date, job_id, salary,
dense_rank() over(order by salary desc) as highest_sal 
from employees) t where t.highest_sal=4; #karen

select employee_id, first_name, hire_date, job_id, salary,
nth_value(salary, 1) over(order by salary desc) as highest_sal 
from employees;

select employee_id, first_name, hire_date, job_id, salary,
first_value(salary) over(order by salary desc) as highest_sal 
from employees; 

select employee_id, first_name, hire_date, job_id, salary,
last_value(salary) 
over(order by salary desc) as last_sal 
from employees;

select employee_id, first_name, hire_date, job_id, salary,
last_value(salary) 
over(order by salary desc
RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) as last_sal 
from employees;

#####################################################
# Date Functions

use farmer_market_big_query;
SELECT * FROM farmer_market_big_query.market_schedule;

select min(extract(year from market_date)), max(extract(year from market_date)) from market_schedule;

SELECT market_start_datetime,
EXTRACT(year from market_start_datetime) as year_no,
EXTRACT(quarter from market_start_datetime) as q_no,
EXTRACT(month from market_start_datetime) as month_no,
EXTRACT(week from market_start_datetime) as week_no,
EXTRACT(day from market_start_datetime) as day_no,
EXTRACT(hour from market_start_datetime) as hr,
EXTRACT(minute from market_start_datetime) as minute,
EXTRACT(second from market_start_datetime) as second
FROM market_schedule;

## formatting date (format_date in big query)
SELECT market_start_datetime,
monthname(market_start_datetime), dayname(market_start_datetime)
FROM market_schedule;

## traversing date (date_add, date_sub)
SELECT market_start_datetime,
date_add(market_start_datetime, INTERVAL 30 Minute ) as dr_strange,
date_sub(market_start_datetime, INTERVAL 30 Minute ) as dr_strange
FROM market_schedule;

## find the number of day between the first market date and last market date
select (t.end_year-t.start_year) from
(select
min(market_date) as start_year,
max(market_date) as end_year
FROM market_schedule) t;

select datediff(t.end_year,t.start_year) from
(select
min(market_date) as start_year,
max(market_date) as end_year
FROM market_schedule) t;


## lets say 	we wanted to get a profile of each farmer market customer's habbits over time
## First Purchase Date
## Last Purchase Date
## Count of distinct purchases
use farmers_market;
select customer_id,
min(market_date) as first_purchase,
max(market_date) as last_purchase,
count(distinct market_date) as count_of_purchase_date,
datediff(max(market_date),min(market_date)) as days_between_first_and_last_purchases
from customer_purchases
group by customer_id;


### If we wanted to also know how long it’s been since the customer last made a purchase?
select customer_id,
min(market_date) as first_purchase,
max(market_date) as last_purchase,
count(distinct market_date) as count_of_purchase_date,
datediff(max(market_date),min(market_date)) as days_between_first_and_last_purchases,
datediff(current_date(),max(market_date)) as days_since_last_purchase
from customer_purchases
group by customer_id;

### Write a query that gives us the days between each purchase a customer makes.
SELECT customer_id,
market_date,
LAG(market_date,1) OVER (PARTITION BY customer_id ORDER BY market_date) AS
last_purchase
FROM farmers_market.customer_purchases
order by 1;


# VIEWS AND CTE

### get the information from employees, if they have commission values,
### then add that in salary if not then give them 10% salary hike

use employees;

select employee_id, concat(first_name, ' ', last_name) as full_name, department_id, commission_pct, salary, d.average_salary from employees e
inner join (select department_id, round(avg(salary),2) as average_salary from employees group by department_id) d using(department_id)
where d.average_salary > 1500;

###### without CTE
select* from (select employee_id, concat(first_name, ' ', last_name) as full_name, department_id, commission_pct, salary, 
round(case
	when commission_pct is not null then salary+salary*commission_pct
    else salary*1.10
end,2) as new_salary from employees e) t where t.new_salary > 10000;

###### with CTE
with q1 as
(select employee_id, concat(first_name, ' ', last_name) as full_name, department_id, commission_pct, salary, 
round(case
	when commission_pct is not null then salary+salary*commission_pct
    else salary*1.10
end,2)
 as new_salary from employees e) 
 
 select * from q1 where new_salary > 10000;
 
 
 ##get me the list of employees who earn more than the average salary of their department.
 
select employee_id, concat(first_name, ' ', last_name) as full_name, department_id, commission_pct, salary, d.average_salary from employees e
inner join 
(select department_id, round(avg(salary),2) as average_salary from employees group by department_id) d using(department_id)
where e.salary > d.average_salary;

 
 

