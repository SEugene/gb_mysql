-- Задание 1.1.

USE shop;

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
	table_name VARCHAR (50),
	created_at DATETIME,
	table_id BIGINT,
	name VARCHAR (100)) ENGINE=ARCHIVE;

SELECT * FROM logs;
SELECT * FROM catalogs;
SELECT * FROM products;
SELECT * FROM users;
SELECT * FROM user_names;

DROP TRIGGER IF EXISTS writing_to_log_catalogs;
CREATE TRIGGER writing_to_log_catalogs AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
  INSERT INTO logs VALUES (
 	'catalogs', 
 	CURRENT_TIMESTAMP(), 
 	(SELECT id FROM catalogs WHERE id = new.id),
 	(SELECT name FROM catalogs WHERE name = new.name));
END;

INSERT INTO catalogs (name) VALUES ('Мониторы');

DROP TRIGGER IF EXISTS writing_to_log_products;
CREATE TRIGGER writing_to_log_products AFTER INSERT ON products
FOR EACH ROW
BEGIN
  INSERT INTO logs VALUES (
 	'products', 
 	CURRENT_TIMESTAMP(), 
 	(SELECT id FROM products WHERE id = new.id),
 	(SELECT name FROM products WHERE name = new.name));
END;

INSERT INTO products (name, description, price, catalog_id) VALUES ('SAMSUNG C24RG50FQI 23.5"', 'Монитор игровой SAMSUNG C24RG50FQI 23.5" черный', 8970, 6);

DROP TRIGGER IF EXISTS writing_to_log_users;
CREATE TRIGGER writing_to_log_users AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO logs VALUES (
 	'users', 
 	CURRENT_TIMESTAMP(), 
 	(SELECT id FROM users WHERE id = new.id),
 	(SELECT name FROM users WHERE name = new.name));
END;

INSERT INTO users (name, birthday_at) VALUES ('Евгений', '1980-07-15');




