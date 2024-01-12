select distinct p.name
from person p
join person_order po on po.person_id = p.id
join menu m on m.id  = po.menu_id 
where (p.gender = 'male' and p.address in ('Moscow', 'Samara') and m.pizza_name in ('pepperoni pizza', 'mushroom pizza'))
order by name desc 
