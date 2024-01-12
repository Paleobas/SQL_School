select distinct p.name 
from person p
join person_order po on po.person_id = p.id
order by name;