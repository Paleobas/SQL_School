select po.order_date, concat(p.name, ' (age:', p.age, ')') as person_information
from 
person_order po join person p on p.id = po.person_id 
order by order_date, name