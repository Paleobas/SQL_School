with ex_1(id) as 
(select m.id as menu_id
from menu m 
where m.id not in 
(select menu_id from person_order po)
)
select m.pizza_name, m.price, piz.name as pizzeria_name 
from menu m 
join ex_1 on ex_1.id = m.id 
join pizzeria piz on piz.id = m.pizzeria_id 
order by pizza_name, price;