-- REPASO EXAMEN RECUPERACIÓN: FUNCIONES, PROCEDIMIENTOS Y CURSORES
-- Fuente: ProgramaciónBD_I.pdf (IES Virrey Morcillo, Curso 2024-2025)

-- Ejemplo 1: Procedimiento hola_mundo
DELIMITER $$
DROP PROCEDURE IF EXISTS hola_mundo$$
CREATE PROCEDURE test.hola_mundo()
BEGIN
SELECT 'hola mundo';
END$$
CALL hola_mundo();

-- Ejemplo 2: Procedimiento fecha
-- DELIMITER $$
-- CREATE PROCEDURE fecha ()
-- LANGUAGE SQL
-- NOT DETERMINISTIC
-- COMMENT "A PROCEDURE"
-- SELECT CURDATE(), RAND() $$
-- CALL fecha();

-- Ejemplo 3: Función colores
-- DELIMITER $$
-- DROP FUNCTION IF EXISTS colores$$
-- CREATE FUNCTION colores(a CHAR)
-- RETURNS VARCHAR(20)
-- DETERMINISTIC NO SQL
-- BEGIN
--   DECLARE color VARCHAR(20);
--   IF a="A" THEN
--     SET color="azul";
--   ELSEIF a="V" THEN
--     SET color="verde";
--   ELSEIF a="R" THEN
--     SET color="rojo";
--   ELSE
--     SET color = "Nada";
--   END IF;
--   RETURN color;
-- END$$
-- SELECT colores('A'), colores('R'),colores('V'), colores('J');

-- Ejemplo 4: Función esimpar
-- DELIMITER $$
-- CREATE FUNCTION esimpar (numero int)
-- RETURNS int
-- DETERMINISTIC NO SQL
-- BEGIN
--   DECLARE impar int;
--   IF MOD(numero,2)=0 THEN SET impar=0;
--   ELSE SET impar=1;
--   END IF;
--   RETURN impar;
-- END;$$

-- Ejercicio 1:
-- Modifica la función anterior y llámala esImparV2 para que si el número es impar devuelva la cadena “impar” y si es par devuelva la cadena “par”.
-- Modifica la función anterior y llámala esImparV3 para que si el número es impar devuelva verdadero y si es par devuelva falso.

-- Ejemplo 5: Llamar funciones desde procedimientos
-- DELIMITER $$
-- DROP PROCEDURE IF EXISTS muestra_estado$$
-- CREATE PROCEDURE muestra_estado(in numero int)
-- BEGIN
--   IF (esimpar(numero)) THEN
--     SELECT CONCAT(numero," esimpar");
--   ELSE
--     SELECT CONCAT(numero," es par");
--   END IF;
-- END;$$

-- Ejemplo 6: Uso de variables y parámetros
-- -- Crear tabla t antes de ejecutar el procedimiento
-- -- CREATE TABLE t (a INT, b INT);
-- DELIMITER $$
-- DROP PROCEDURE IF EXISTS proc1 $$
-- CREATE PROCEDURE proc1  (IN parametro1 INT)
-- BEGIN
--   DECLARE variable1 INT;
--   DECLARE variable2 INT;
--   IF parametro1=17 THEN
--     SET variable1=parametro1;
--     SET variable2=10;
--   ELSE
--     SET variable1=10;
--     SET variable2=30;
--   END IF;
--   INSERT INTO t (a,b) VALUES  (variable1,variable2);
-- END$$

-- Ejemplo IN
-- DELIMITER $$
-- CREATE PROCEDURE proc2 (IN P int)  SET @x=p $$

-- Ejemplo OUT
-- DELIMITER $$
-- CREATE PROCEDURE proc3 (OUT p INT) SET P=-5 $$

-- Ejemplo INOUT
-- DELIMITER $$
-- CREATE PROCEDURE proc4(INOUT p INT) SET p=p-5 $$

-- Ejemplo de alcance de variables
-- DELIMITER $$
-- CREATE PROCEDURE proc5 ()
-- BEGIN
--   DECLARE x1 char(6) DEFAULT "fuera";
--   BEGIN
--     DECLARE x1 CHAR(6) DEFAULT "dentro";
--     SELECT x1;
--   END;
--   SELECT x1;
-- END;$$

-- Continúa añadiendo aquí más ejemplos o ejercicios del PDF si lo necesitas.

-- Ejercicios de repaso sobre funciones, procedimientos y variables

/* 1. Crear un procedimiento llamado hola_mundo que muestre el texto 'hola mundo' por pantalla. */

/* 2. Crear un procedimiento llamado fecha que muestre la fecha actual y un número aleatorio. */

/* 3. Crear una función llamada colores que reciba un carácter ('A', 'V', 'R') y devuelva el color correspondiente ('azul', 'verde', 'rojo') o 'Nada' si no es ninguno de esos valores. */

/* 4. Crear una función llamada esimpar que reciba un número y devuelva 1 si es impar y 0 si es par. */

/* 5. Modificar la función anterior y llamarla esImparV2 para que devuelva la cadena 'impar' si el número es impar y 'par' si es par. */

/* 6. Modificar la función anterior y llamarla esImparV3 para que devuelva verdadero si el número es impar y falso si es par. */

/* 7. Crear un procedimiento llamado muestra_estado que reciba un número y muestre un mensaje indicando si es par o impar usando la función esimpar. */

/* 8. Crear una tabla t con dos campos enteros (a y b) y un procedimiento proc1 que inserte valores en la tabla según el valor de un parámetro de entrada. */

/* 9. Crear un procedimiento proc2 que reciba un parámetro de entrada y lo asigne a una variable de sesión. */

/* 10. Crear un procedimiento proc3 que reciba un parámetro de salida y le asigne el valor -5. */

/* 11. Crear un procedimiento proc4 que reciba un parámetro de entrada/salida y le reste 5. */

/* 12. Crear un procedimiento proc5 que demuestre el alcance de las variables declaradas dentro de bloques BEGIN/END. */