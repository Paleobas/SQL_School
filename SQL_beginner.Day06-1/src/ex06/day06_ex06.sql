create sequence seq_person_discounts start 1;
alter table person_discounts alter column id set default nextval('seq_person_discounts');

/*select * from person_discounts;*/