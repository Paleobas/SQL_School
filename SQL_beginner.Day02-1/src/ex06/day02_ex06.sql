select m.pizza_name, piz.name as pizzeria_name
from 
menu m
join pizzeria piz on (piz.id = m.pizzeria_id)
join person_order po2 on po2.menu_id = m.id 
join person p on p.id = po2.person_id 
where (p.name = 'Denis' or p.name = 'Anna')
order by pizza_name, pizzeria_name;
