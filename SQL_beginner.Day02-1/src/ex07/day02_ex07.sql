select piz.name
from pizzeria piz 
join person_visits pv on piz.id = pv.pizzeria_id 
join person p on p.id = pv.person_id 
join menu m on m.pizzeria_id = piz.id
where (pv.visit_date = '2022-01-08' and p.name  = 'Dmitriy' and m.price < 800)
