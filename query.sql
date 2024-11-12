--Eliminación por precaución, en cascada y si existen
/*
-- Eliminar vistas
DROP VIEW IF EXISTS view_lista_peliculas CASCADE;
DROP VIEW IF EXISTS view_informacion_actores CASCADE;
DROP VIEW IF EXISTS view_ventas_totales_por_tienda CASCADE;
DROP VIEW IF EXISTS view_ventas_totales_por_categoria CASCADE;
-- Eliminar tablas
DROP TABLE IF EXISTS registro_inserciones_pelicula CASCADE;
DROP TABLE IF EXISTS eliminar_registro_pelicula CASCADE;
-- Eliminar trigger y funciones
DROP TRIGGER IF EXISTS disparador_inserciones_pelicula ON FILM;
DROP FUNCTION IF EXISTS funcion_inserciones_pelicula();
DROP TRIGGER IF EXISTS disparador_eliminar_pelicula ON FILM;
DROP FUNCTION IF EXISTS funcion_eliminar_pelicula();
-- Eliminar restricciones
ALTER TABLE FILM DROP CONSTRAINT IF EXISTS coste_pelicula_mayor_cero CASCADE;
ALTER TABLE PAYMENT DROP CONSTRAINT IF EXISTS coste_pagos_mayor_igual_cero CASCADE;
ALTER TABLE RENTAL DROP CONSTRAINT IF EXISTS duracion_menor_fecha_devolucion CASCADE;
ALTER TABLE CUSTOMER DROP CONSTRAINT IF EXISTS email_valido_cliente CASCADE;
ALTER TABLE STAFF DROP CONSTRAINT IF EXISTS email_valido_empleado CASCADE;
*/

-- Eliminar y recrear las 18 claves foráneas con ON DELETE CASCADE para que los TRIGGER funcionen correctamente
-- Clave foránea en film_actor
ALTER TABLE film_actor DROP CONSTRAINT IF EXISTS film_actor_actor_id_fkey;
ALTER TABLE film_actor ADD CONSTRAINT film_actor_actor_id_fkey 
FOREIGN KEY (actor_id) REFERENCES actor(actor_id) ON DELETE CASCADE;
ALTER TABLE film_actor DROP CONSTRAINT IF EXISTS film_actor_film_id_fkey;
ALTER TABLE film_actor ADD CONSTRAINT film_actor_film_id_fkey 
FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE CASCADE;
-- Clave foránea en film_category
ALTER TABLE film_category DROP CONSTRAINT IF EXISTS film_category_category_id_fkey;
ALTER TABLE film_category ADD CONSTRAINT film_category_category_id_fkey 
FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE CASCADE;
ALTER TABLE film_category DROP CONSTRAINT IF EXISTS film_category_film_id_fkey;
ALTER TABLE film_category ADD CONSTRAINT film_category_film_id_fkey 
FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE CASCADE;
-- Clave foránea en film
ALTER TABLE film DROP CONSTRAINT IF EXISTS film_language_id_fkey;
ALTER TABLE film ADD CONSTRAINT film_language_id_fkey 
FOREIGN KEY (language_id) REFERENCES language(language_id) ON DELETE CASCADE;
-- Clave foránea en address
ALTER TABLE address DROP CONSTRAINT IF EXISTS fk_address_city;
ALTER TABLE address ADD CONSTRAINT fk_address_city 
FOREIGN KEY (city_id) REFERENCES city(city_id) ON DELETE CASCADE;
-- Clave foránea en city
ALTER TABLE city DROP CONSTRAINT IF EXISTS fk_city;
ALTER TABLE city ADD CONSTRAINT fk_city 
FOREIGN KEY (country_id) REFERENCES country(country_id) ON DELETE CASCADE;
-- Clave foránea en inventory
ALTER TABLE inventory DROP CONSTRAINT IF EXISTS inventory_film_id_fkey;
ALTER TABLE inventory ADD CONSTRAINT inventory_film_id_fkey 
FOREIGN KEY (film_id) REFERENCES film(film_id) ON DELETE CASCADE;
-- Clave foránea en payment
ALTER TABLE payment DROP CONSTRAINT IF EXISTS payment_customer_id_fkey;
ALTER TABLE payment ADD CONSTRAINT payment_customer_id_fkey 
FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE;
ALTER TABLE payment DROP CONSTRAINT IF EXISTS payment_rental_id_fkey;
ALTER TABLE payment ADD CONSTRAINT payment_rental_id_fkey 
FOREIGN KEY (rental_id) REFERENCES rental(rental_id) ON DELETE CASCADE;
ALTER TABLE payment DROP CONSTRAINT IF EXISTS payment_staff_id_fkey;
ALTER TABLE payment ADD CONSTRAINT payment_staff_id_fkey 
FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE;
-- Clave foránea en rental
ALTER TABLE rental DROP CONSTRAINT IF EXISTS rental_customer_id_fkey;
ALTER TABLE rental ADD CONSTRAINT rental_customer_id_fkey 
FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE;
ALTER TABLE rental DROP CONSTRAINT IF EXISTS rental_inventory_id_fkey;
ALTER TABLE rental ADD CONSTRAINT rental_inventory_id_fkey 
FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id) ON DELETE CASCADE;
ALTER TABLE rental DROP CONSTRAINT IF EXISTS rental_staff_id_key;
ALTER TABLE rental ADD CONSTRAINT rental_staff_id_key 
FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE;
-- Clave foránea en staff
ALTER TABLE staff DROP CONSTRAINT IF EXISTS staff_address_id_fkey;
ALTER TABLE staff ADD CONSTRAINT staff_address_id_fkey 
FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE CASCADE;
-- Clave foránea en store
ALTER TABLE store DROP CONSTRAINT IF EXISTS store_address_id_fkey;
ALTER TABLE store ADD CONSTRAINT store_address_id_fkey 
FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE CASCADE;
ALTER TABLE store DROP CONSTRAINT IF EXISTS store_manager_staff_id_fkey;
ALTER TABLE store ADD CONSTRAINT store_manager_staff_id_fkey 
FOREIGN KEY (manager_staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE;
-- Clave foránea en customer
ALTER TABLE customer DROP CONSTRAINT IF EXISTS customer_address_id_fkey;
ALTER TABLE customer ADD CONSTRAINT customer_address_id_fkey 
FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE CASCADE;

-- 4a
SELECT CATEGORY.name AS CATEGORIA, COUNT(*) AS TOTAL_VENTAS
FROM PAYMENT
INNER JOIN RENTAL ON PAYMENT.rental_id = RENTAL.rental_id
INNER JOIN INVENTORY ON INVENTORY.inventory_id = RENTAL.inventory_id
INNER JOIN FILM ON FILM.film_id = inventory.film_id
INNER JOIN FILM_CATEGORY ON FILM_CATEGORY.film_id = film.film_id
INNER JOIN CATEGORY ON CATEGORY.category_id = film_category.category_id
GROUP BY CATEGORY.category_id
ORDER BY TOTAL_VENTAS DESC;

-- 4b﻿
SELECT STORE.store_id, CITY.city || ', ' || COUNTRY.country AS LOCALIZACION, STAFF.first_name AS ENCARGADO ,COUNT(*) AS VENTAS_TOTALES
FROM STORE
INNER JOIN INVENTORY ON STORE.store_id = INVENTORY.store_id
INNER JOIN RENTAL ON RENTAL.inventory_id = INVENTORY.inventory_id
INNER JOIN PAYMENT ON PAYMENT.rental_id = RENTAL.rental_id
INNER JOIN ADDRESS ON ADDRESS.address_id = STORE.address_id
INNER JOIN CITY ON CITY.city_id = ADDRESS.city_id
INNER JOIN COUNTRY ON COUNTRY.country_id = CITY.country_id
INNER JOIN STAFF ON STAFF.staff_id = STORE.manager_staff_id
GROUP BY STORE.store_id, CITY.city_id, COUNTRY.country_id, STAFF.staff_id;

-- 4c
SELECT FILM.film_id, title, description, CATEGORY.name AS CATEGORY, replacement_cost AS COST, rating, ACTOR.first_name || ' ' || ACTOR.last_name AS ACTOR_NAME
FROM FILM 
INNER JOIN FILM_CATEGORY ON FILM.film_id = FILM_CATEGORY.film_id
INNER JOIN CATEGORY ON CATEGORY.category_id = FILM_CATEGORY.category_id
INNER JOIN FILM_ACTOR ON FILM_ACTOR.film_id = FILM.film_id
INNER JOIN ACTOR ON ACTOR.actor_id = FILM_ACTOR.actor_id;

-- 4d
SELECT first_name, last_name, STRING_AGG(FILM.title || ', ' || CATEGORY.NAME,' : ')
FROM FILM
INNER JOIN FILM_CATEGORY ON FILM.film_id = FILM_CATEGORY.film_id
INNER JOIN CATEGORY ON CATEGORY.category_id = FILM_CATEGORY.category_id
INNER JOIN FILM_ACTOR ON FILM_ACTOR.film_id = FILM.film_id
INNER JOIN ACTOR ON ACTOR.actor_id = FILM_ACTOR.actor_id
GROUP BY ACTOR.actor_id;

-- 5a
CREATE VIEW view_ventas_totales_por_categoria AS
SELECT CATEGORY.name AS CATEGORIA, COUNT(*) AS TOTAL_VENTAS
FROM PAYMENT
INNER JOIN RENTAL ON PAYMENT.rental_id = RENTAL.rental_id
INNER JOIN INVENTORY ON INVENTORY.inventory_id = RENTAL.inventory_id
INNER JOIN FILM ON FILM.film_id = INVENTORY.film_id
INNER JOIN FILM_CATEGORY ON FILM_CATEGORY.film_id = FILM.film_id
INNER JOIN CATEGORY ON CATEGORY.category_id = FILM_CATEGORY.category_id
GROUP BY CATEGORY.category_id
ORDER BY TOTAL_VENTAS DESC;

-- 5b
CREATE VIEW view_ventas_totales_por_tienda AS
SELECT STORE.store_id, CITY.city || ', ' || COUNTRY.country AS LOCALIZACION, 
       STAFF.first_name AS ENCARGADO, COUNT(*) AS VENTAS_TOTALES
FROM STORE
INNER JOIN INVENTORY ON STORE.store_id = INVENTORY.store_id
INNER JOIN RENTAL ON RENTAL.inventory_id = INVENTORY.inventory_id
INNER JOIN PAYMENT ON PAYMENT.rental_id = RENTAL.rental_id
INNER JOIN ADDRESS ON ADDRESS.address_id = STORE.address_id
INNER JOIN CITY ON CITY.city_id = ADDRESS.city_id
INNER JOIN COUNTRY ON COUNTRY.country_id = CITY.country_id
INNER JOIN STAFF ON STAFF.staff_id = STORE.manager_staff_id
GROUP BY STORE.store_id, CITY.city_id, COUNTRY.country_id, STAFF.staff_id;

-- 5c
CREATE VIEW view_informacion_actores AS
SELECT FILM.film_id, title, description, CATEGORY.name AS CATEGORY, 
       replacement_cost AS COST, rating, 
       ACTOR.first_name || ' ' || ACTOR.last_name AS ACTOR_NAME
FROM FILM
INNER JOIN FILM_CATEGORY ON FILM.film_id = FILM_CATEGORY.film_id
INNER JOIN CATEGORY ON CATEGORY.category_id = FILM_CATEGORY.category_id
INNER JOIN FILM_ACTOR ON FILM_ACTOR.film_id = FILM.film_id
INNER JOIN ACTOR ON ACTOR.actor_id = FILM_ACTOR.actor_id;

-- 5d
CREATE VIEW view_lista_peliculas AS
SELECT first_name, last_name, 
       STRING_AGG(FILM.title || ', ' || CATEGORY.NAME, ' : ') AS FILM_LIST
FROM FILM
INNER JOIN FILM_CATEGORY ON FILM.film_id = FILM_CATEGORY.film_id
INNER JOIN CATEGORY ON CATEGORY.category_id = FILM_CATEGORY.category_id
INNER JOIN FILM_ACTOR ON FILM_ACTOR.film_id = FILM.film_id
INNER JOIN ACTOR ON ACTOR.actor_id = FILM_ACTOR.actor_id
GROUP BY ACTOR.actor_id;

-- 6
ALTER TABLE FILM
ADD CONSTRAINT coste_pelicula_mayor_cero CHECK (replacement_cost > 0);

ALTER TABLE PAYMENT
ADD CONSTRAINT coste_pagos_mayor_igual_cero CHECK (amount >= 0);

ALTER TABLE RENTAL
ADD CONSTRAINT duracion_menor_fecha_devolucion CHECK (rental_date < return_date);

ALTER TABLE CUSTOMER
ADD CONSTRAINT email_valido_cliente CHECK (email ~* '^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE STAFF
ADD CONSTRAINT email_valido_empleado CHECK (email ~* '^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- 7
CREATE TABLE registro_inserciones_pelicula (
  log_id SERIAL PRIMARY KEY, 
  film_id INT,
  insert_date TIMESTAMP
);

CREATE OR REPLACE FUNCTION funcion_inserciones_pelicula() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO registro_inserciones_pelicula(film_id, insert_date)
  VALUES (NEW.film_id, CURRENT_TIMESTAMP);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER disparador_inserciones_pelicula
AFTER INSERT ON FILM
FOR EACH ROW EXECUTE FUNCTION funcion_inserciones_pelicula();

-- 8
CREATE TABLE eliminar_registro_pelicula (
  log_id SERIAL PRIMARY KEY,
  film_id INT,
  delete_date TIMESTAMP
);

CREATE OR REPLACE FUNCTION funcion_eliminar_pelicula()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO eliminar_registro_pelicula(film_id, delete_date)
  VALUES (OLD.film_id, CURRENT_TIMESTAMP);
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER disparador_eliminar_pelicula
AFTER DELETE ON FILM
FOR EACH ROW EXECUTE FUNCTION funcion_eliminar_pelicula();

