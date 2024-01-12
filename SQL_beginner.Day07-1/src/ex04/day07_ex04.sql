select 
	p.name,
	coalesce(count(pv.person_id), 0) as count_of_visits
from person p 
join person_visits pv on pv.person_id = p.id
group by name
having count(name) > 3;