with
cte_orders as
(	
	select piz.name, count(*) as count
	from person_order po
	join menu m on m.id = po.menu_id
	join pizzeria piz on piz.id = m.pizzeria_id
	group by piz.name
),

cte_visits as
(
	select piz.name, count(*) as count
	from person_visits pv
	join pizzeria piz on piz.id = pv.pizzeria_id
	group by piz.name
)

SELECT
        pizzeria.name,
        COALESCE(cte_visits.count, 0) + COALESCE(cte_orders.count, 0) AS total_count
FROM pizzeria
FULL JOIN cte_orders ON cte_orders.name = pizzeria.name
FULL JOIN cte_visits ON cte_visits.name = pizzeria.name
ORDER BY total_count DESC, name;
