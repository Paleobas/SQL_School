select po.order_date, concat(name, ' (age:', age, ')') as person_information
from 
person_order po 
natural join 
(select id as person_id, name, age from person) as temp_person
order by order_date, person_information