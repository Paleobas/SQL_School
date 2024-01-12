CREATE OR REPLACE FUNCTION fnc_trg_person_delete_audit() RETURNS trigger AS $person_audit$
	BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO person_audit VALUES(
           			current_timestamp,
                    'D',
                     old.id, old.name, old.age, old.gender, old.address);
		END IF;
		RETURN NULL;
	END;
$person_audit$ 	LANGUAGE plpgsql;
	

CREATE TRIGGER trg_person_delete_audit AFTER DELETE 
	ON person
	FOR EACH ROW EXECUTE PROCEDURE fnc_trg_person_delete_audit();

DELETE FROM person WHERE id = 10;
/*select * from person;
select * from person_audit;*/
