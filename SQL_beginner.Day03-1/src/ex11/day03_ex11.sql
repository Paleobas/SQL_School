update menu m 
set price = price - 0.1 * price
where m.pizza_name = 'greek pizza';

/*   select * from menu