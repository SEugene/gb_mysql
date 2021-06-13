select * from users where id > 500;

select * from media where id > 4990;

select * from friend_requests where initiator_user_id <> target_user_id;

select * from friend_requests;

delete from friend_requests where initiator_user_id = target_user_id; 

select id from users order by id;

update users set lastname = 'Zorg', firstname = 'Jean Emmanuel Batist'
where id = 1699;

insert into users values('1010', 'Bruce', 'Dickinson', 'bruce@ironmaiden.com', 'ba300b16ec99080f3377a93c916e8c429f52bf0b','5384452251');

insert into friend_requests values
('1699','1010','requested','2021-02-08 09:48:02','2021-02-08 09:50:02'),
('1001','1016','approved','2015-02-05 04:48:02','2020-02-07 09:50:02'),
('1999','1723','declined','2001-11-11 11:48:02','2002-03-03 11:50:02');

insert into friend_requests
set
initiator_user_id = 1020,
target_user_id = 1025,
status = 'approved',
requested_at = '2017-07-30 20:26:10',
updated_at = '2006-03-24 16:21:10';
