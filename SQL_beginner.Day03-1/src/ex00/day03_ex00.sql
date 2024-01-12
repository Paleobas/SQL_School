select m.pizza_name, m.price, piz.name as pizzeria_name, pv.visit_date 
from menu m 
join pizzeria piz on piz.id = m.pizzeria_id 
join person_visits pv on pv.pizzeria_id = piz.id 
join person p on p.id = pv.person_id 
where (p.name = 'Kate' and m.price between 800 and 1000)
order by pizza_name, price, pizzeria_name