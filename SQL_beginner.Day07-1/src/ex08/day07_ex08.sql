select p.address, piz.name, count(*) as count_of_orders
from person_order po
join person p on p.id = po.person_id
join menu m on m.id = po.menu_id
join pizzeria piz on piz.id = m.pizzeria_id
group by piz.name, address
order by address, piz.name;