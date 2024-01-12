select distinct gd.generated_date as missing_days
from v_generated_dates gd
except 
select pv.visit_date
from person_visits pv
order by missing_days;
