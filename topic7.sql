-- «адание 1.
-- ¬ывел количество заказов, которые сделал каждый пользователь
select u.name, count(o.user_id) as 'num of orders made' from users as u join orders as o on u.id = o.user_id group by u.id order by count(o.user_id);

-- ƒл€ тренироваки вывел список всех пользователей с указанием количества заказов, которые сделал каждый пользователь
-- ¬идно, что јлександр не сделал ни одного заказа
select o.user_id, u.name, count(o.user_id) as 'num of orders made' from users as u left join orders as o on u.id = o.user_id group by u.id order by o.user_id;


-- «адание 2.
select p.name as 'product name', c.name as 'catalog' from products as p join catalogs as c on p.catalog_id = c.id;

-- «адание 3.
select id, c.name as 'from', ct.name as 'to' from flights as f join cities as c join cities as ct on f.from = c.label and f.to = ct.label order by id;
