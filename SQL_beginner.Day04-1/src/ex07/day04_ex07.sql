insert into person_visits (id, person_id, pizzeria_id, visit_date)
values (
(select (max(id) + 1) from person_visits),
(select p.id from person p where p.name = 'Dmitriy'),
(select piz.id 
	from pizzeria piz
		join menu m on m.pizzeria_id = piz.id
	where m.price < 800
except 
(select id 
from mv_dmitriy_visits_and_eats mv
join pizzeria piz on piz.name = mv.pizzeria_name)
limit 1),
'2022-01-08'
);
/*select * from mv_dmitriy_visits_and_eats;*/
refresh materialized view mv_dmitriy_visits_and_eats;
/*select * from mv_dmitriy_visits_and_eats;*/
