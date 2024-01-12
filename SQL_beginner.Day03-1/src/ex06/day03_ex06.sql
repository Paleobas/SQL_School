select m1.pizza_name, piz1.name as pizzeria_name_1, piz2.name as pizzeria_name_2, m1.price
from
menu m1
join pizzeria piz1 on piz1.id = m1.pizzeria_id 
join menu m2 on m2.pizza_name  = m1.pizza_name  
join pizzeria piz2 on piz2.id = m2.pizzeria_id 
where (m1.price = m2.price and piz1.id > piz2.id)
order by pizza_name 
