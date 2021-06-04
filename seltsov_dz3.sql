USE vk;

ALTER TABLE `profiles` ADD COLUMN pref_id INT UNSIGNED NOT NULL;
ALTER TABLE `profiles` ADD COLUMN fp_id INT UNSIGNED NOT NULL;

DROP TABLE IF EXISTS preferences_types;
CREATE TABLE preferences_types (
-- таблица с типами предпочтений - книги, музыка, кино, спорт...--
    id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    type_name VARCHAR (20),
    
    INDEX pref_types_idx (type_name)
);

DROP TABLE IF EXISTS preferences;
CREATE TABLE preferences (
-- таблица предпочтений - тип (книги, музыка, кино, спорт...) и вид (любимая группа, любимый фильм, любимая книга...)--
    id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    name VARCHAR (100),
    preferences_type_id INT UNSIGNED NOT NULL UNIQUE,
    
    FOREIGN KEY (preferences_type_id) REFERENCES preferences_types (id)
);

DROP TABLE IF EXISTS favorite_places;
CREATE TABLE favorite_places (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
    name VARCHAR (100)
 );   


ALTER TABLE `profiles` ADD CONSTRAINT fk_pref
    FOREIGN KEY (pref_id) REFERENCES preferences (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;



ALTER TABLE `profiles` ADD CONSTRAINT fk_fp
    FOREIGN KEY (fp_id) REFERENCES favorite_places (id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;