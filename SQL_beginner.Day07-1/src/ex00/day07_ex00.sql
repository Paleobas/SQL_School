select person_id, count(*) as count_of_visits
from person_visits pv
group by person_id
order by 2 desc, 1 asc;