create materialized view mv_dmitriy_visits_and_eats as
(select piz.name as pizzeria_name
	from pizzeria piz
		join menu m on m.pizzeria_id = piz.id 
		join person_visits pv on pv.pizzeria_id  = piz.id 
		join person p on p.id = pv.person_id 
	where (p.name = 'Dmitriy' and pv.visit_date = '2022-01-08' and m.price < 800)
);

/* select * from mv_dmitriy_visits_and_eats; */