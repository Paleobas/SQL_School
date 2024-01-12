select p.name, p.rating 
from pizzeria p 
full join
person_visits pv on (pv.pizzeria_id = p.id)
where visit_date is null