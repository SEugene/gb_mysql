-- Задание 1.1
START TRANSACTION;
insert sample.users select * from shop.users where shop.users.id = 1;
savepoint sample_1;
delete from shop.users where shop.users.id = 1;
COMMIT;
rollback to savepoint sample_1;    -- тестировал откат к точке восстановления rollback запускается вместо commit


-- Задание 1.2

create or replace view name_cat   -- Представление, которое выводит все продукты с привязанными к ним каталогами
	as select p.name as 'products', c.name as 'catalogs' from products as p 
	join 
	catalogs as c on p.catalog_id = c.id;
	
create or replace view name_cat   -- Представление, которое выводит только один продукт по его id с привязкой каталога
	as select p.name as 'products', c.name as 'catalogs' from products as p 
	join 
	catalogs as c on p.catalog_id = c.id where p.id = 4;
	
select * from name_cat;


-- Задание 3.1.

drop procedure if exists hello;

CREATE PROCEDURE hello ()
BEGIN
	declare cur_t time default CURRENT_TIME();
	if (cur_t between time('6:00') and time('12:00')) then
		select 'Доброе утро';
	elseif (cur_t between time('12:00') and time('18:00')) then
		select 'Добрый день';
	else select 'Доброй ночи';
	end if;
end;

call hello();


-- Задание 3.2.

create trigger nonull before insert on products
for each row
begin
	if (new.product is null and new.description is null) then
		signal sqlstate '45000' set message_text = 'NULL for both columns is prohibited';
	end if;
end;

-- Задание 3.3.

drop function if exists FIBONACCI;

CREATE function FIBONACCI (num INT)
returns INT DETERMINISTIC
BEGIN
	declare iter INT default 2;
	declare res INT default 0;
	declare prev1 INT default 0;
	declare prev2 INT default 0;
	create temporary table fib (id INT, fib_num INT);
	insert into fib values 
		(0, 0),
		(1, 1);
	if num > 1 then
		while iter <= num + 1 do
			set prev1 = (select fib_num from fib where id = iter - 2);
			set prev2 = (select fib_num from fib where id = iter - 1);
			insert into fib values (iter, prev1 + prev2);
			set iter = iter + 1;
		end while;
	end if;	
	
	set res = (select fib_num from fib where id = num);
	return res;
end;

drop table if exists fib;
select FIBONACCI(10);


