CREATE view v_persons_female as
	select * from person p
		where p.gender = 'female';
		
CREATE view v_persons_male as
	select * from person p
		where p.gender = 'male';
		
/*  select * from person;	
select * from v_persons_female; 
select * from v_persons_male; */
	