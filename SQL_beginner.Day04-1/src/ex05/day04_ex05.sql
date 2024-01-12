create view v_price_with_discount as
( 
	select 
		p.name,
		m.pizza_name,
		m.price, 
		cast(m.price - m.price * 0.1 as integer) as discount_price
	from
		person p
		join person_order po on po.person_id = p.id 
		join menu m on po.menu_id = m.id
	order by name, pizza_name
);

/* select * from v_price_with_discount; */