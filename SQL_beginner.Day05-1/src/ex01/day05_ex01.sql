SET enable_seqscan TO OFF;
explain analyze
select m.pizza_name, piz.name as pizzeria_name
from 
menu m
join 
pizzeria piz on m.pizzeria_id = piz.id;
