-- �������������, ������� �������� ���������� � ��������� �� 3 ������
CREATE OR REPLACE VIEW complex_product AS 
SELECT p.author, p.album, p.album_year, m.media_type, m.box_type, m.description, g.genre, p.price
	FROM product p JOIN media m JOIN genre g WHERE p.media_id = m.id AND p.genre_id = g.id;

-- ����� ���� �������� ���������� ������ �� ������� Iron Maiden
SELECT * FROM complex_product
	WHERE author LIKE 'iron Maiden' ORDER BY album_year, album;
	
-- ����� ���� �������� ���������� ������ �� ������� Iron Maiden �� ���������� �������� - CD
SELECT * FROM complex_product WHERE author LIKE 'iron Maiden' AND media_type LIKE 'CD%'
	ORDER BY album_year, album;
	
-- ����� ���� �������� � ����� hard rock �� ������
SELECT * FROM complex_product WHERE genre LIKE 'hard%' AND media_type LIKE 'Vinyl%'
	ORDER BY author, album_year, album;
	
-- ����� � ��������� ���������� ��������� � ������������ �� ������� � ���������
SELECT p.author, m.media_type, count(*) FROM product p, media m WHERE p.media_id = m.id GROUP BY m.media_type, p.author ORDER BY p.author, m.media_type;

-- ����� �� ����������� ���������� �� 3 ������ � �������������� ��������� ��������
set @u_id = 10;
SELECT id, firstname, lastname, email, phone, 
	(SELECT gender FROM profiles WHERE user_id = @u_id) AS gender,
	CONCAT(
	(SELECT zip_code FROM address WHERE id = (SELECT address_id FROM profiles WHERE user_id = @u_id)), ', ',
	(SELECT city FROM address WHERE id = (SELECT address_id FROM profiles WHERE user_id = @u_id)), ', ',
	(SELECT street FROM address WHERE id = (SELECT address_id FROM profiles WHERE user_id = @u_id)), ', ',
	(SELECT building FROM address WHERE id = (SELECT address_id FROM profiles WHERE user_id = @u_id)), ' - ',
	(SELECT appartment FROM address WHERE id = (SELECT address_id FROM profiles WHERE user_id = @u_id))
	) AS 'address'
		FROM users WHERE id = @u_id;

-- �������������, ������� �������� ���������� � ����������� �� 3 ������
CREATE OR REPLACE VIEW complex_user AS
SELECT firstname, lastname, email, phone, city FROM users u JOIN profiles p JOIN address a WHERE p.user_id = u.id AND a.id = p.address_id;

-- ����� ���������� � ����������� �� ����������� ������
SELECT * FROM complex_user WHERE city = '�����';
	
-- ���������� ������� � ��������� �� ������� ���������� ������� � ������������ ����������: ��������� ������������ ���������� �������, 
-- ������� ��� ����� (���������� product_id + warehouse_id) �������� �� ���� product_id (1000), ������� ����� ��������� �� ���������� �������

DROP PROCEDURE IF EXISTS random_filling;
CREATE PROCEDURE random_filling (product_limit INT, warehouse_limit INT, stock_limit INT)
BEGIN
	DECLARE rand_product INT DEFAULT 850;
	DECLARE rand_warehouse INT DEFAULT 3;
	DECLARE rand_stock INT DEFAULT 20;
	DECLARE iter INT DEFAULT 0;
	WHILE iter < product_limit DO
		SET rand_product = ROUND (1+RAND()*product_limit);
		SET rand_warehouse = ROUND (1+RAND()*(warehouse_limit-1));
		SET rand_stock = ROUND (1+RAND()*stock_limit);
		INSERT INTO stocks (product_id, warehouse_id, stock) values (rand_product, rand_warehouse, rand_stock);
		SET iter = iter + 1;
	END WHILE;
END;

DROP TRIGGER IF EXISTS no_doubles;
CREATE TRIGGER no_doubles BEFORE INSERT ON stocks
	FOR EACH ROW 
		BEGIN 
			IF ((SELECT stock FROM stocks WHERE product_id = new.product_id AND warehouse_id = new.warehouse_id) IS NOT NULL) THEN 
				SET new.product_id = 1000;
			END IF;
		END;

CALL random_filling (999, 3, 20);
DELETE FROM stocks WHERE product_id = 1000;

-- ������ �������� � ���� � ����������� �� ������ ������������ ������ ���������� � ����� � ������ ������� (������ �����������)
DROP FUNCTION IF EXISTS price_calc;
CREATE FUNCTION price_calc (userid INT, productid INT)
RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE cum DECIMAL DEFAULT 0;
	DECLARE moment DATE DEFAULT CURDATE();
	DECLARE res FLOAT DEFAULT 0;
	DECLARE res2 FLOAT DEFAULT 0;
	SET cum = (SELECT sum(oc.total_sum) from orders_content oc JOIN orders o JOIN users u WHERE oc.order_id = o.id AND o.user_id = u.id AND u.id = userid); 
	CASE
		WHEN (cum IS NULL) THEN SET res = 0;
		WHEN (cum BETWEEN (SELECT min_sum FROM loyality WHERE id = 1) AND (SELECT max_sum FROM loyality WHERE id = 1)) THEN SET res = (SELECT loyality FROM loyality WHERE id = 1);
		WHEN (cum BETWEEN (SELECT min_sum FROM loyality WHERE id = 2) AND (SELECT max_sum FROM loyality WHERE id = 2)) THEN SET res = (SELECT loyality FROM loyality WHERE id = 2);
		WHEN (cum BETWEEN (SELECT min_sum FROM loyality WHERE id = 3) AND (SELECT max_sum FROM loyality WHERE id = 3)) THEN SET res = (SELECT loyality FROM loyality WHERE id = 3);
		WHEN (cum BETWEEN (SELECT min_sum FROM loyality WHERE id = 4) AND (SELECT max_sum FROM loyality WHERE id = 4)) THEN SET res = (SELECT loyality FROM loyality WHERE id = 4);
		ELSE SET res = (SELECT loyality FROM loyality WHERE id = 5);
	END CASE;
	SET moment = CURDATE();
 IF (moment BETWEEN (SELECT started_at FROM discounts WHERE product_id = productid) AND (SELECT finished_at FROM discounts WHERE product_id = productid)) 
	 THEN SET res2 = (SELECT discount FROM discounts WHERE product_id = productid);
	 ELSE SET res2 = 0;
	 END IF;
	RETURN (1 - (res + res2));
END;

-- �������� ������ � ��������� ������������� ���������� ������ �� ���� ������� � �������� ���� � ������ ������������ ������ � ����������� �����
CREATE OR REPLACE VIEW product_stocks AS 
SELECT p.id AS product_code, sum(s.stock) AS total_stock
	FROM product p JOIN stocks s WHERE p.id = s.product_id group by p.id;

DROP PROCEDURE IF EXISTS ordering_goods;
CREATE PROCEDURE ordering_goods (orderid INT, productid INT, quantity INT)
BEGIN
	IF ((SELECT total_stock FROM product_stocks WHERE product_code = productid) < quantity) THEN 
		SET quantity = (SELECT total_stock FROM product_stocks WHERE product_code = productid);
	END IF;	
INSERT INTO orders_content values
	(orderid, productid, quantity, (SELECT price FROM product WHERE id = productid)*product_quantity*(SELECT price_calc ((SELECT user_id FROM orders WHERE id = orderid), productid)));
END;

CALL ordering_goods(5, 32, 1);
CALL ordering_goods(5, 851, 3);   -- �������� �� ��, ��� � ������ ���������� 3, ��� ����������� �� 1 (�������� ������� �� ������� ������ �� ���� �������)
CALL ordering_goods(4, 1144, 2);  -- �� ����� ����� ���, ���� ������������ ������ ����������, ���� ��������� �� 10%
CALL ordering_goods(6, 79, 15);

-- ������������ ������������ ������ � ������� users �� ������ ������ ������� ����������
DROP PROCEDURE IF EXISTS actual_loyality;
CREATE PROCEDURE actual_loyality ()
BEGIN
	DECLARE cum DECIMAL DEFAULT 0;
	DECLARE loyality_lvl INT;
	DECLARE iter INT DEFAULT 1;
	WHILE iter < (SELECT id FROM users ORDER BY id desc LIMIT 1) DO
	SET cum = (SELECT sum(oc.total_sum) from orders_content oc JOIN orders o JOIN users u WHERE oc.order_id = o.id AND o.user_id = u.id AND u.id = iter); 
	CASE
		WHEN (cum IS NULL) THEN SET loyality_lvl = 1;
		WHEN (cum BETWEEN (SELECT min_sum FROM loyality WHERE id = 1) AND (SELECT max_sum FROM loyality WHERE id = 1)) THEN SET loyality_lvl = 1;
		WHEN (cum BETWEEN (SELECT min_sum FROM loyality WHERE id = 2) AND (SELECT max_sum FROM loyality WHERE id = 2)) THEN SET loyality_lvl = 2;
		WHEN (cum BETWEEN (SELECT min_sum FROM loyality WHERE id = 3) AND (SELECT max_sum FROM loyality WHERE id = 3)) THEN SET loyality_lvl = 3;
		WHEN (cum BETWEEN (SELECT min_sum FROM loyality WHERE id = 4) AND (SELECT max_sum FROM loyality WHERE id = 4)) THEN SET loyality_lvl = 4;
		ELSE SET loyality_lvl = 5;
	END CASE;
	UPDATE users SET loyality_id = loyality_lvl WHERE id = iter;
	SET iter = iter + 1;
	END WHILE;
END;

CALL actual_loyality; -- �������� - ��������: ����� ���������� ������ � ���������� � id 6 ����� ����� 52500, ������� ������ ��������� �� 5


-- ����� ������� ����������� ����������
CREATE OR REPLACE VIEW user_orders AS
SELECT CONCAT(u.lastname, ' ', u.firstname) AS buyer, u.email AS user_email, u.phone AS user_phone, oc.order_id AS order_code, oc.total_sum AS summary, u.id AS users_id,
	l.loyality AS personal_discount
	FROM orders o JOIN orders_content oc JOIN users u JOIN loyality l WHERE oc.order_id = o.id AND o.user_id =u.id AND l.id = u.loyality_id ;

-- ����� ����� �������, �������� ������������ ������, ���, ������� � email ���������� ���������� 
SELECT buyer, user_email, user_phone, order_code, personal_discount, sum(summary) FROM user_orders WHERE users_id = 1 group by buyer; 

-- ������ ������� � ��������� ������� ������� �� ���������� ����������
SELECT buyer, user_email, user_phone, order_code, sum(summary) FROM user_orders WHERE users_id = 1 group by order_code;
	

 


