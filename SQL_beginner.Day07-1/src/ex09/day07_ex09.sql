select p.address, 
	round(max(p.age::numeric) - min(p.age::numeric)/max(p.age::numeric), 2) as formula, 
	round(avg(age::numeric), 2) as average,
	(select 
	case 
		when max(p.age::numeric) - min(p.age::numeric)/max(p.age::numeric) > avg(age::numeric)
		then 
			true
		else 
			false
		end) as comparison
from person p
group by p.address
order by address;