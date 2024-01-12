/* даты посещения */ 
(select piz.name as pizzeria_name
from pizzeria piz
join person_visits pv on pv.pizzeria_id = piz.id 
join person p on p.id = pv.person_id 
where (p.name = 'Andrey')
) except 
/*даты заказа */
(select piz.name as pizzeria_name
from pizzeria piz
join menu m on m.pizzeria_id = piz.id 
join person_order po on po.menu_id = m.id 
join person p on p.id = po.person_id 
where (p.name = 'Andrey'))
order by pizzeria_name 
