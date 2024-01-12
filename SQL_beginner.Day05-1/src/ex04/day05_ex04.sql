create unique index idx_menu_unique on menu(pizzeria_id, pizza_name);
set enable_seqscan to off;
explain analyze
	SELECT pizzeria_id, pizza_name
    	FROM menu
    	WHERE pizza_name = 'supreme_pizza' AND pizzeria_id = 3;