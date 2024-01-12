with days_CTE (missing_date)
as
(select days::date as missing_date
from generate_series('2022-01-01', '2022-01-10', interval '1 day') as days)
select missing_date from days_CTE
full join
(select * 
from person_visits pv2 
where person_id = '1' or person_id = '2' 
and visit_date between '2022-01-01' and '2022-01-10') as d
on missing_date = d.visit_date
where d.person_id is null 
order by missing_date;
