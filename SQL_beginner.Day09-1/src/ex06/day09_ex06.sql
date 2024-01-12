CREATE OR REPLACE FUNCTION fnc_person_visits_and_eats_on_date(IN pperson varchar DEFAULT 'Dmitriy', IN pprice numeric DEFAULT 500, IN pdate date = '2022-01-08')
RETURNS TABLE (
        name varchar
) AS $$
	BEGIN
		RETURN QUERY
			SELECT DISTINCT piz.name
		        FROM person_visits pv
		       	join person p on pv.person_id = p.id 
		       	join pizzeria piz on piz.id = pv.pizzeria_id 
		       	join menu m on piz.id = m.pizzeria_id 
		        WHERE p.name = pperson AND m.price < pprice AND pv.visit_date = pdate;
	END;
$$ LANGUAGE plpgsql;

select *
from fnc_person_visits_and_eats_on_date(pprice := 800);

select *
from fnc_person_visits_and_eats_on_date(pperson := 'Anna',pprice := 1300,pdate := '2022-01-01');