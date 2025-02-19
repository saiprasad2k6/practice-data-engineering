

USE `farmers_market`;

## Get a list of customers who made purchases on each market date
select customer_id, market_date from customer_purchases group by market_date;

## Filter out the vendors who brought at least 100 items to the farmer's marke over the 
## period 2019-05-02 and 2019-05-16

select vendor_id, sum(quantity) as items from vendor_inventory where market_date 
between '2019-05-02' and '2019-05-16' group by vendor_id having items >=100;


## Date time functions
select min(market_date), max(market_date) from market_date_info;

select market_date, 
extract(year from market_date) as year,
extract(month from market_date) as mo


 from market_date_info;
