insert into menu (id, pizzeria_id, pizza_name, price)
values (
	(select max(id) + 1 from menu),
	(select id from pizzeria piz where piz.name = 'Dominos'),
	'sicilian pizza',
	900
)

/*  select * from menu m 