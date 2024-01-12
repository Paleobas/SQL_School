select order_date as action_date, person_id from person_order po 
intersect 
select visit_date as action_date, person_id from person_visits pv 
order by action_date, person_id desc 