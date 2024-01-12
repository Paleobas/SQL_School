create table person_audit(
	created timestamptz not null default current_timestamp, 
	type_event char(1) not null default 'I',
	row_id bigint not null,
  	name varchar not null,
  	age integer not null default 10,
  	gender varchar default 'female' not null ,
  	address varchar,
  	constraint ch_type_event check (type_event in ('I', 'D', 'U'))
);

CREATE OR REPLACE FUNCTION fnc_trg_person_insert_audit() returns trigger as $person_audit$
	begin
		IF (TG_OP = 'INSERT') THEN
            INSERT INTO person_audit 
            		SELECT
                         current_timestamp,
                         'I',
                         new.id, new.name, new.age, new.gender, new.address;
		END IF;
		RETURN NULL;
	end;
$person_audit$ 	LANGUAGE plpgsql;
	

create trigger trg_person_insert_audit after insert on person
	for each row execute procedure fnc_trg_person_insert_audit();

INSERT INTO person values (10,'Damir', 22, 'male', 'Irkutsk');

/*select * from person;
select * from person_audit;*/
