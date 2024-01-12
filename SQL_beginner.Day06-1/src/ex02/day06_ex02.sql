select p.name, m.pizza_name, m.price, (m.price - m.price * pd.discount/100) as discount_price, piz.name as pizzeria_name
from person_order po
join person p on p.id = po.person_id
join menu m on m.id = po.menu_id
join pizzeria piz on piz.id = m.pizzeria_id
join person_discounts pd on pd.person_id = p.id and pd.pizzeria_id = piz.id
order by 1,2;