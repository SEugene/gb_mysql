-- Задание 1.1
update users set created_at=now(), updated_at=now();

-- Задание 1.2
update users
SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %h:%i'),
    updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %h:%i');
alter table users modify column created_at datetime null, modify column updated_at datetime null;

-- Задание 1.3
select * from storehouses_products order by (1/value) desc;

-- Задание 1.4
select * from users where monthname(birthday_at) = 'May' or monthname(birthday_at) = 'August';
-- если требуется извлечь только имена пользователей, вместо * указываем наименование столбца 'names'

-- Задание 1.5
SELECT * FROM catalogs WHERE id IN (5, 1, 2) order by field(id, 5, 1, 2);


-- Задание 2.1
select avg(year(now()) - year(birthday_at)) - ((month(now())*30+day(now()) - month(birthday_at)*30-day(birthday_at)) < 0) as Average_age from users;

-- Задание 2.2
select 
	dayofweek(concat('2021-', right(birthday_at,5))) as Week_day,
	count(*) as Num_of_users
	from users 
group by Week_day
order by Week_day;





