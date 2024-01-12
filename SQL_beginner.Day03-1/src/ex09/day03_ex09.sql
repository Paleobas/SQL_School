insert into person_visits (id, person_id, pizzeria_id, visit_date)
values (
	(select max(id) + 1 from person_visits),
	(select id from person p where p.name = 'Denis'),
	(select id from pizzeria piz where piz.name = 'Dominos'),
	'2022-02-24'
);

insert into person_visits (id, person_id, pizzeria_id, visit_date)
values (
	(select max(id) + 1 from person_visits),
	(select id from person p where p.name = 'Irina'),
	(select id from pizzeria piz where piz.name = 'Dominos'),
	'2022-02-24'
);

/*  select * from person_visits pv 