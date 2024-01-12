select m.id as menu_id
from menu m 
where m.id not in 
(select menu_id from person_order po)
order by id;
