select distinct po.order_date as action_date, p.name as person_name 
from person_order po
join person p on p.id = po.person_id
join person_visits pv on po.order_date = pv.visit_date
order by action_date, person_name desc 