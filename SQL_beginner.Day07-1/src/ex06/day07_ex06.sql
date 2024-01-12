select piz.name, count(*) as count_of_orders, round(avg(m.price), 2) as average_price,
	max(m.price) as max_price, min(m.price) as min_price
from person_order po
join menu m on m.id = po.menu_id
join pizzeria piz on piz.id = m.pizzeria_id
group by name
order by piz.name;