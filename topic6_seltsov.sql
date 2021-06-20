-- «адание 1.
-- улучшение - использовать в подобных запросах переменную, чтобы избежать "копипасты"
set @u_id = 1110;

SELECT 
	firstname, 
	lastname, 
	(SELECT hometown FROM profiles WHERE user_id = @u_id) AS city,
	(SELECT filename FROM media WHERE id = 
	    (SELECT photo_id FROM profiles WHERE user_id = @u_id)
	) AS main_photo
FROM users 
WHERE id = @u_id;

-- улучшение - использовать регул€рку при поиске медиа с типом "фото", добавить в запрос id пользовател€
SELECT user_id, filename FROM media 
  WHERE user_id = 1001
    AND media_type_id = (
      SELECT id FROM media_types WHERE name LIKE '%oto'
    ); 

   -- улучшение - добавить в запрос id пользовател€ и переименовать колонку с расчетом, чтобы было пон€тно, какие данные выведены
 SELECT user_id, COUNT(*) as 'amount of photos' FROM media 
	WHERE user_id = 1005
  AND media_type_id = (
    SELECT id FROM media_types WHERE name LIKE 'photo'
);

-- улучшение - отсортировать полученный массив по убыванию количества новостей
SELECT COUNT(id) AS news_count, user_id
  FROM media
  GROUP BY user_id
 order by news_count desc;

-- «адание 2.
-- —оздал два запроса - id пользовател€ отправившего / получившего запросы от заданного пользовател€ и количество сообщений
-- „ерез union all получил итоговую таблицу 't', в которой дл€ каждого id указано количество полученных / отправленных сообщений, 
-- просуммировал полученные и отправленные по одному id
-- »тог сгруппировал по id, отсортировал по убыванию, вывел только 1-е значение. Ёто и есть ответ.
set @tu_id = 1004;

select t.id, sum(num) as 'all talks' from (
	(select from_user_id as 'id', count(*) as 'num' from messages where to_user_id = @tu_id group by from_user_id)
	union all
	(select to_user_id as 'id', count(*) as 'num' from messages where from_user_id = @tu_id group by to_user_id)
) as t group by id order by sum(num) desc limit 1;

-- «адание 3.
-- Ѕез доп.запроса MySql выдавал ошибку.
select count(*) as 'amount of likes' from likes where user_id in 
	(select user_id from 
		(select user_id from profiles order by date(birthday) desc limit 10) as subtable);

-- «адание 4.
select case (select gender from profiles where user_id = likes.user_id) 
         WHEN 'm' THEN 'male'
         WHEN 'f' THEN 'female'
    END AS 'gender', count(*) 		
from likes group by gender order by count(*) desc limit 1;

-- «адание 5.
-- ƒл€ анализа выбрал активности: количество лайков, отправленные запросы в друзь€, медиа, отправленные сообщени€, участие в сообществах
-- ѕолученные запросы в друзь€ и сообщени€ не анализировал - они не характеризуют активность пользовател€
select 
	t.user_id as 'user_id',
	(select firstname from users where id = t.user_id) as 'firstname', 
	(select lastname from users where id = t.user_id) as 'lastname', 
	sum(activities) as 'activities' from (
		(select user_id as user_id, count(*) as 'activities' from likes group by user_id)
			union all
		(select initiator_user_id as user_id, count(*) as 'activities' from friend_requests group by initiator_user_id)
			union all
		(select user_id as user_id, count(*) as 'activities' from media group by user_id)
			union all
		(select from_user_id as user_id, count(*) as 'activities' from messages group by from_user_id)
			union all
		(select user_id as user_id, count(*) as 'activities' from users_communities group by user_id)
) as t group by user_id order by sum(activities) limit 10;
	


