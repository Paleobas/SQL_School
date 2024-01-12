select COALESCE(p.name, '-') as person_name,
        d.visit_date,
        COALESCE(piz.name, '-') AS pizzeria_name
from
(SELECT *
     FROM person_visits
     WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-03') as d
full join person p on p.id = d.person_id
full join pizzeria piz on piz.id = d.pizzeria_id
order by 1, 2, 3;

