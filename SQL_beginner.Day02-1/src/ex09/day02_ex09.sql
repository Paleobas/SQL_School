with 
pep_pizza_cte(name) as(
(select p.name
from person p
join person_order po on po.person_id = p.id
join menu m on m.id  = po.menu_id 
where p.gender = 'female' and m.pizza_name = 'pepperoni pizza')
),

ch_pizza_cte(name) as(
(select p.name
from person p
join person_order po on po.person_id = p.id
join menu m on m.id  = po.menu_id 
where p.gender = 'female' and m.pizza_name = 'cheese pizza')
)

select name
from pep_pizza_cte
natural join 
ch_pizza_cte
order by name