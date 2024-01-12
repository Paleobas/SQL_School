select name
from person p 
where (p.age > 25 and gender = 'female')
group by name;