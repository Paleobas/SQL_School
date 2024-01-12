select m.pizza_name, piz.name as pizzeria_name, m.price
from menu m
join 
pizzeria piz on piz.id = m.pizzeria_id
where (m.pizza_name = 'mushroom pizza' or m.pizza_name = 'pepperoni pizza')
order by pizza_name, pizzeria_name;
