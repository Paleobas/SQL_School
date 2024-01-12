insert into person_discounts
select
	row_number() over (order by po.person_id, m.pizzeria_id) as id,
	po.person_id,
	m.pizzeria_id,
	case 
		when count(po.person_id) = 1
		then 10.5
		when count(po.person_id) = 2
		then 22
		else 30
	end as discount
	from menu m
	join 
	person_order po on po.menu_id = m.id
	group by 2, 3;

	
/*select * from person_discounts;*/