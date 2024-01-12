create index idx_person_name on person(upper(name));
SET enable_seqscan TO OFF;
explain analyze
select * from person
	where upper(name) = 'ANNA';
	
	
	