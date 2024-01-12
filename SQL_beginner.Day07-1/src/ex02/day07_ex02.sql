(select piz.name, count(*) as count, 'order' as action_type
from person_order po
join menu m on m.id = po.menu_id
join pizzeria piz on piz.id = m.pizzeria_id
group by piz.name
order by count desc
limit 3)
union
(select piz.name, count(*) as count, 'visit' as action_type
from person_visits pv
join pizzeria piz on piz.id = pv.pizzeria_id
group by piz.name
order by count desc
limit 3)
order by action_type, count desc;