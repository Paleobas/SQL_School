create view v_symmetric_union as (
(select pv.person_id from person_visits pv 
	where pv.visit_date = '2022-01-02'
 except 
 select pv.person_id from person_visits pv 
	where pv.visit_date = '2022-01-06')
union 
(select pv.person_id from person_visits pv 
	where pv.visit_date = '2022-01-06'
 except 
 select pv.person_id from person_visits pv 
	where pv.visit_date = '2022-01-02')
order by person_id
);

/*  select * from v_symmetric_union  */ 
