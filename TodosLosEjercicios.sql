/* Crea un procedimiento que muestre nombre completo y el nombre del mes de la fecha 
de creación de los clientes de sakila cuyo año se pasa como parámetro */

DELIMITER $$
DROP PROCEDURE IF EXISTS clientesSakila $$
CREATE PROCEDURE clientesSakila(IN anio INT)
BEGIN
    SELECT CONCAT(first_name, ' ', last_name, ' ', creation_date)
    FROM customer
    WHERE YEAR(creation_date) = anio
END;
DELIMITER ;
CALL clientesSakila('2000');

/* Escribe un procedimiento que reciba una letra y visualice el apellido de 
todos los clientes sakila cuyo nombre comience con esa letra. Puedes usar 
las funciones left o substring. */

DELIMITER $$
DROP PROCEDURE IF EXISTS letraInicial $$
CREATE PROCEDURE letraInicial(IN letra CHAR(1))
BEGIN
SELECT first_name, last_name
FROM customer
WHERE LEFT(last_name, 1) = letra;
END;

/* Crea un procedimiento que visualice los nombres de las ciudades 
de los países pertenecientes a un continente cuyo nombre introduciremos como parámetro. 
Añade un parámetro de salida que obtenga el número de ciudades que se han mostrado. */

DELIMITER $$
DROP PROCEDURE IF EXISTS visualizarNombres $$
CREATE PROCEDURE visualizarNombres(IN nombreContinente ENUM('Asia', 'Europe', 'North America', 'Africa', 'Oceania', 'Antartica', 'South America'), OUT nTotal INT)
BEGIN
    SELECT COUNT(*) 
    INTO nTotal
    FROM city
    WHERE countrycode IN (SELECT code
                          FROM country
                          WHERE continent = nombreContinente);
END $$

/* Clasificar países por población */
USE WORLD;
DELIMITER $$
DROP PROCEDURE IF EXISTS paisesPoblacion $$
CREATE PROCEDURE paisesPoblacion()
BEGIN
    SELECT name, population
    FROM country
    ORDER BY population DESC;
END$$
DELIMITER ;
CALL paisesPoblacion;

/* Crea una función ClasificarPais que reciba como parámetro el nombre 
de un país y devuelva una clasificación basada en su población:
"Pequeño" si tiene menos de 10 millones de habitantes.
"Mediano" si tiene entre 10 y 50 millones.
"Grande" si tiene más de 50 millones. */
USE WORLD;
DELIMITER $$
DROP FUNCTION IF EXISTS clasificarPais $$
CREATE FUNCTION clasificarPais(nombrePais VARCHAR(30))
RETURNS VARCHAR(255)
DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE cantidadPoblacion INT;
    DECLARE resultado VARCHAR(255);

    SELECT population
    INTO cantidadPoblacion
    FROM country
    WHERE name = nombrePais;

    IF cantidadPoblacion > 50000000
        THEN SET resultado = CONCAT('El pais ', nombrePais, ' es de tamaño grande');
    ELSEIF cantidadPoblacion BETWEEN 10000000 AND 50000000
        THEN SET resultado = CONCAT('El pais ', nombrePais, ' es de tamaño mediano');
    ELSEIF cantidadPoblacion < 10000000
        THEN SET resultado = CONCAT('El pais ', nombrePais, ' es de tamaño pequeño');
    END IF;

    RETURN resultado;
END $$
DELIMITER ;
SELECT clasificarPais('Spain');

/* Crea un procedimiento CalcularPoblacionContinente que reciba el nombre de un 
continente y devuelva la población total. Usa un bucle WHILE para sumar la población 
de cada país en el continente. Usa una estructura condicional para excluir países cuya población sea NULL. */
USE WORLD;
DELIMITER $$
DROP PROCEDURE IF EXISTS calcularPoblacionContinente $$
CREATE PROCEDURE calcularPoblacionContinente(IN nombreContinente ENUM('Asia', 'Europe', 'North America', 'Africa', 'Oceania', 'Antarctica', 'South America'), OUT poblacionTotal BIGINT)
BEGIN
    SELECT SUM(population)
    INTO poblacionTotal
    FROM country
    WHERE continent = nombreContinente AND continent IS NOT NULL;
END $$
DELIMITER ;
CALL calcularPoblacionContinente('Asia', @total);
SELECT @total;

/* Hacer una función que retorne la suma de los términos 1/n  con “n” entre 1 y “m”, es decir 
1+½+1/3+….1/m, siendo  “m” el parámetro de entrada. Tener  en cuenta que  “m”  no puede ser cero. */
DELIMITER $$
DROP FUNCTION IF EXISTS sumaRara $$
CREATE FUNCTION sumaRara(pValor INT)
RETURNS DOUBLE
DETERMINISTIC NO SQL
BEGIN
    DECLARE mValor INT DEFAULT 0;
    DECLARE suma DOUBLE DEFAULT 0;

    IF pValor > 0 
        THEN WHILE mValor < pValor DO
            SET mValor = mValor + 1;
            SET suma = suma + 1/mValor;
        END WHILE;
    ELSE 
        RETURN ('Introduce un valor por encima de 0');
    END IF;
    RETURN suma;
END$$
DELIMITER ;
SELECT sumaRara(8);

/* Desarrolla un procedimiento que obtenga la media de la población de las ciudades de un código de país que entra 
como parámetro. Con este valor de población, actualiza las ciudades de ese país que estén por debajo de esa media 
aumentando la población un 20%. */

DELIMITER $$
DROP PROCEDURE IF EXISTS calcularMediaPoblacion $$
CREATE PROCEDURE calcularMediaPoblacion(IN codPais CHAR(3))
BEGIN
    DECLARE mediaPoblacion INT DEFAULT 0;

    SELECT AVG(population)
    INTO mediaPoblacion
    FROM city
    WHERE countrycode = codPais;

    UPDATE city SET population = population * 1.20
        WHERE countrycode = codPais AND population < mediaPoblacion;
END $$
DELIMITER ;
CALL calcularMediaPoblacion('ESP');

/* Desarrolla un procedimiento llamado personasPaisContinente que obtenga los distintos continentes que hay en la tabla país. 
Para cada uno de estos continentes, realiza una consulta sobre la tabla país, que obtenga el total de población del continente 
y el número de países. Con esta información, muestra por pantalla el texto: "En el continente X vive Y personas en Z países diferentes". */
USE WORLD;
DELIMITER $$
DROP PROCEDURE IF EXISTS personasPaisContinente;
CREATE PROCEDURE personasPaisContinente()
BEGIN
    DECLARE vContinente VARCHAR(20);
    DECLARE vPoblacion DOUBLE DEFAULT 0;
    DECLARE vPaises INT DEFAULT 0;
    DECLARE textoConcadenado VARCHAR(255);
    DECLARE terminado BOOLEAN DEFAULT FALSE;

    DECLARE micursor1 CURSOR FOR SELECT DISTINCT continent FROM country;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET terminado = TRUE;

    OPEN micursor1;
        leerLoop: LOOP
        FETCH micursor1 INTO vContinente;
        IF terminado THEN
            LEAVE leerLoop;
        END IF;

        SELECT SUM(population)
        INTO vPoblacion
        FROM country
        WHERE continent = vContinente;

        SELECT COUNT(*)
        INTO vPaises
        FROM country
        WHERE continent = vContinente;

        SET textoConcadenado = CONCAT('En el continente ', vContinente, ' viven ', vPoblacion, ' personas en ', vPaises, ' países diferentes');

        SELECT textoConcadenado;
    END LOOP;

    CLOSE micursor1;
END$$
DELIMITER ;
CALL personasPaisContinente();

/* Implementa un procedimiento llamado poblacionCapitales que obtenga los nombres de país y el id de capital 
(solo de los países que tienen la capital informada) del continente que se pasa como parámetro de entrada al 
procedimiento. Después, a través de un cursor, para cada capital de cada país, que realice una consulta a la 
tabla City y muestre la siguiente información: "La capital de España es Madrid, y viven 9876543 personas". */

USE WORLD;
DELIMITER $$
DROP PROCEDURE IF EXISTS poblacionCapitales;
CREATE PROCEDURE poblacionCapitales(IN nombreContinente VARCHAR(30))
BEGIN
    DECLARE vPais VARCHAR(30);
    DECLARE vId INT;
    DECLARE vCapital VARCHAR(50);
    DECLARE vPoblacion DOUBLE;
    DECLARE finDatos BOOLEAN DEFAULT FALSE;
    DECLARE textoConcadenado VARCHAR(255);

    DECLARE micursor CURSOR FOR 
        SELECT name, capital 
        FROM country 
        WHERE continent = nombreContinente AND capital IS NOT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;

    OPEN micursor;
    leerLoop: LOOP
        FETCH micursor INTO vPais, vId;
        IF finDatos = TRUE THEN
            LEAVE leerLoop;
        END IF;

        SELECT name, population
        INTO vCapital, vPoblacion
        FROM city
        WHERE id = vId;

        SET textoConcadenado = CONCAT('La capital de ', vPais, ' es ', vCapital, ', y viven ', vPoblacion, ' personas');
        SELECT textoConcadenado;
    END LOOP;

    CLOSE micursor;
END$$
DELIMITER ;
CALL poblacionCapitales('Europe');

/* Desarrolla un procedimiento llamado exodoInverso que en base a la región de un país que entra como parámetro, 
obtenga las ciudades de los países de esa region. Con cada una de estas ciudades, aumentaremos o disminuiremos 
la población de cada ciudad en función de lo siguientes parámetros:

Las ciudades con más de un 1.000.000 de habitantes disminuyen su población en un 10%
Las ciudades entre 500.000 y 999.999 habitantes disminuyen su población en un 5%.
Las ciudades de entre 250.000 y 499.999 habitantes aumentan la población un 10%.
Las ciudades de menos de 250.000 aumentan la población un 20%. */

DELIMITER $$
DROP PROCEDURE IF EXISTS exodoInverso $$
CREATE PROCEDURE exodoInverso(IN vRegion VARCHAR(100))
BEGIN
    DECLARE vPoblacion DOUBLE;
    DECLARE vCiudad VARCHAR(50);
    DECLARE vDistricto VARCHAR(100);
    DECLARE finDatos BOOLEAN DEFAULT FALSE;

    DECLARE micursor CURSOR FOR 
        SELECT district, population, name
        FROM city 
        WHERE district = vRegion;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;

    OPEN micursor;

    leerBucle: LOOP
        FETCH micursor INTO vDistricto, vPoblacion, vCiudad;
        IF finDatos = TRUE THEN
            LEAVE leerBucle;
        END IF;

        IF vPoblacion > 1000000 THEN
            UPDATE city SET population = population * 0.90 WHERE name = vCiudad AND district = vDistricto;
        ELSEIF vPoblacion BETWEEN 500000 AND 999999 THEN
            UPDATE city SET population = population * 0.95 WHERE name = vCiudad AND district = vDistricto;
        ELSEIF vPoblacion BETWEEN 250000 AND 499999 THEN
            UPDATE city SET population = population * 1.10 WHERE name = vCiudad AND district = vDistricto;
        ELSEIF vPoblacion < 250000 THEN
            UPDATE city SET population = population * 1.20 WHERE name = vCiudad AND district = vDistricto;
        END IF;
    END LOOP;

    CLOSE micursor;
END$$

CALL exodoInverso();

/* Crea una tabla llamada infoCalculada, con las siguientes columnas: id (auto incrementado), 
característica (cadena 30 posiciones, no nulo), cualitativo (cadena 30 posiciones), cuantitativo 
(decimal 10,2), observaciones (cadena 255 posiciones, nula) y auditoria (TIMESTAMP DEFAULT CURRENT_TIMESTAMP()). 

Desarrolla un procedimiento llamado registroDensidad, que tenga de entrada dos valores de PIB 
(PIBMinimo y PIBMaximo), que obtenga los países que hay entre esos valores de PIB (GNP), y para cada 
uno de ellos, inserta un registro en la tabla infoCalculada con la siguiente información:
ID autogenerado.
Característica: "DensidadPoblación".
Cuantitativo: Resultado operación población/superficie del país.
Cualitativo y observaciones: En funciónd e la densidad, se detalla en la siguiente tabla: */
USE WORLD;
DELIMITER $$
CREATE TABLE infoCalculada (
	id INT PRIMARY KEY AUTO_INCREMENT,
    caracteristica VARCHAR(30) NOT NULL,
    cualitativo VARCHAR(30),
    cuantitativo DECIMAL(10,2),
    observaciones VARCHAR(255),
    auditoria TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)$$
DROP PROCEDURE IF EXISTS registroDensidad $$
CREATE PROCEDURE registroDensidad(IN pibMinimo DOUBLE, IN pibMaximo DOUBLE)
BEGIN
    DECLARE vPoblacion DOUBLE;
    DECLARE vPais VARCHAR(50);
    DECLARE vCuantitativo DOUBLE DEFAULT 0;
    DECLARE vSuperficie DOUBLE;
    DECLARE vGNP DOUBLE;
    DECLARE finDatos BOOLEAN DEFAULT FALSE;

    DECLARE micursor CURSOR FOR 
        SELECT Population, SurfaceArea, Name, GNP
        FROM country
        WHERE GNP BETWEEN pibMinimo AND pibMaximo;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;

    OPEN micursor;
    leerBucle: LOOP
    FETCH micursor INTO vPoblacion, vSuperficie, vPais, vGNP;
        IF finDatos = TRUE
            THEN LEAVE leerBucle;
        END IF;

    IF vGNP > 1000 THEN 
        SET cualitativo = ('Muy Alta'); 
        SET observaciones = CONCAT('Alta concentración de población en ', vPais, ', (', vCuantitativo, ')');
    ELSEIF vGNP BETWEEN 300 AND 1000 THEN
        SET cualitativo = ('Alta');
        SET observaciones = CONCAT('En ', vPais, ' está densamente poblado,', ' (', vCuantitativo, ')');
    ELSEIF vGNP BETWEEN 50 AND 299 THEN
        SET cualitativo = ('Media');
        SET observaciones = CONCAT(vPais, ' tiene una población moderada', ', (', vCuantitativo, ')');
    ELSEIF vGNP < 50 THEN
        SET cualitativo = ('Baja');
        SET observaciones = CONCAT(vPais, ' tiene regiones rural poco habitadas, desiertos y/o montañas ', ', (', vCuantitativo, ')');
        
    INSERT INTO infoCalculada (caracteristica, cualitativo, cuantitativo, observaciones)
    VALUES ('DensidadPoblación', vCualitativo, vCuantitativo, vObservaciones);    

    SET vCuantitativo = vPoblacion / vSuperficie;

    END LOOP;
    CLOSE micursor;
END$$

/* (Recorrer dos cursores a la vez) Desarrolla un procedimiento que obtenga por un lado la siguiente información del país: código, 
nombre, población. Por otro lado, que obtenga las lenguas que se hablan en cada país: idioma, código de país y porcentaje. Después, 
recorre los registros de cada país: para cada país, recorre los idiomas que se hablan en ese país, y forma la siguiente cadena: 
En Spain se habla Spanish (X personas), Catalan (Y personas), Basque (Z personas), Galecian (A personas). Si el país no tienen 
ningún idioma: NombrePais no tiene ningún idioma registrado. El número de personas de cada idioma se calculará multiplicando el 
porcentaje de habla por la población del país (será un número entero). Es muy importante que el orden de la consulta de países 
sea el mismo que el orden de la consulta de idiomas para que se puedan recorrer correctamente. Se insertará un registro para cada 
país en infoCalculada en base a:

ID autogenerado.
Característica: "IdiomasPais".
Cuantitativo: Número de idiomas hablados.
Cualitativo: nulo.
Observaciones: cadena formada.
Auditoría: fecha y hora actual. */

DELIMITER $$
DROP PROCEDURE IF EXISTS dosCursores $$
CREATE PROCEDURE dosCursores(IN codigoPais CHAR(3), IN idioma VARCHAR(20))
BEGIN
    DECLARE vCodigo CHAR(3);
    DECLARE vPais VARCHAR(50);
    DECLARE vPoblacion INT;
    DECLARE vIdioma VARCHAR(25);
    DECLARE 


END $$

/* A partir del nombre de un continente recibido como parámetro, el procedimiento actualizará el campo GNP (Producto Nacional 
Bruto) de los países de ese continente según los siguientes criterios:

Si el GNP es mayor de 500.000, se reduce un 5% (impuestos por ajuste fiscal).
Si el GNP está entre 100.000 y 500.000, se reduce un 2%.
Si el GNP es menor de 100.000, se aumenta un 3% (incentivos económicos).
En todos los casos, el GNP actual del país, guárdalo en la columna GNP_OLD
Se insertará en infoCalculada una fila con la característica SubidaImpuestos, y en cuantitativo el número de países a los 
que se les ha subido. En observaciones incluye el número de países a los que se les ha reducido.
Objetivo: Uso de cursor para recorrer países por continente y modificar datos numéricos con condicionales. */

DELIMITER $$
DROP PROCEDURE IF EXISTS continenteRecibido $$
CREATE PROCEDURE continenteRecibido(IN nombreContinente VARCHAR(30))
BEGIN
    DECLARE vGNP DOUBLE;
    DECLARE vPais VARCHAR(30);
    DECLARE gnpOld DOUBLE DEFAULT 0;
    DECLARE finDatos BOOLEAN DEFAULT FALSE;

    DECLARE micursor CURSOR FOR 
    SELECT gnp, name
    FROM country
    WHERE continent = nombreContinente;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;

    OPEN micursor;

    miBucle: LOOP
    FETCH micursor INTO vGNP, vPais;
    IF finDatos = TRUE
        THEN LEAVE miBucle;
    END IF;

    IF vGNP > 500000 THEN
        SET gnpOld = vGNP;
        UPDATE country SET gnp = gnp * 0.95;
    ELSEIF vGNP BETWEEN 100000 AND 500000 THEN
        SET gnpOld = vGNP;
        UPDATE country SET gnp = gnp * 0.98;
    ELSEIF vGNP < 100000 THEN
        SET gnpOld = vGNP;
        UPDATE country SET gnp = gnp * 1.03;

    CLOSE micursor;
END $$

/* Recorrer todos los países de una región pasada como parámetro. Para cada país, contar cuántos idiomas oficiales tiene (IsOfficial = 'T') 
y almacenar ese número en una tabla auxiliar llamada infoCalculada: característica = "IdiomasOficiales", cuantitativa = número de idiomas, 
Observaciones: Se escribirá el nombre del país más si tiene 3 idiomas oficiales = "País multicultural". Si tiene menos = "Pocos idiomas", 
Si tiene más = "Demasiados idiomas".

Objetivo: Cursores con conteo por fila, condicionales y manipulación de tablas auxiliares. */

DELIMITER $$
DROP PROCEDURE IF EXISTS recuentoIdiomasOficiales $$
CREATE PROCEDURE recuentoIdiomasOficiales(IN nombreRegion VARCHAR(50))
BEGIN

    DECLARE vPais VARCHAR(25);
    DECLARE vObservacion VARCHAR(200);
    DECLARE vCuantitativa INT DEFAULT 0;
    DECLARE finDatos BOOLEAN DEFAULT FALSE;

    DECLARE micursor CURSOR FOR 
        SELECT name
        FROM country
        WHERE region = nombreRegion;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;

    OPEN micursor;

    leerBucle: LOOP
    FETCH micursor INTO vPais;
    IF finDatos = TRUE THEN
        LEAVE leerBucle;
    END IF;
    
    SET vCuantitativa = (
    SELECT COUNT(*)
    FROM countrylanguage
    WHERE countryCode = (SELECT code 
                            FROM country
                            WHERE NAME = vPais)
    AND ifofficial = TRUE);

    IF vCuantitativa = 3 THEN
        SET vObservacion = ('País multicultural');
    ELSEIF vCuantitativa < 3 THEN
        SET vObservacion = ('Pocos idiomas');
    ELSEIF vCuantitativa > 3 THEN
        SET vObservacion = ('Demasiados idiomas');
    END IF;

    INSERT INTO infoCalculada (caracteristica, cuantitativo, observaciones)
    VALUES ('IdiomasOficiales', vCuantitativa, CONCAT(vPais, ': ', vObservacion));

    END LOOP;
    CLOSE micursor;
END $$
DELIMITER ;
CALL recuentoIdiomasOficiales('Caribbean');

/* 8. Procedimiento ajusteEsperanzaVida
Descripción:
Recorrer los países que hay entre dos superficies (superficie minima y máxima) con un cursor, y modificar su esperanza de 
vida (LifeExpectancy) según su población (Population):

Si el país tiene más de 100 millones de habitantes, reducir la esperanza de vida en 3 años.
Entre 50 y 100 millones: reducir en 1 año.
Menos de 10 millones: aumentar en 2 años.
Se ignoran los países con LifeExpectancy nulo.

Al final, incluye un registro en infocalculada, con los siguientes valores: caracteristica: "esperanzaModificada", 
cuantitativa: años que se han aumentado, observaciones: años que se han disminuido. En cualitativa, null.
Objetivo: Uso de cursores con condiciones y actualizaciones selectivas sobre campos con posibles valores nulos.
*/
DELIMITER $$
DROP PROCEDURE IF EXISTS ajusteEsperanzaVida;
CREATE PROCEDURE ajusteEsperanzaVida(IN superficieMin INT, IN superficieMax INT)
BEGIN
    DECLARE vSuperficie DOUBLE;
    DECLARE vMin INT;
    DECLARE vMax INT;
    DECLARE vCodigo CHAR(3);
    DECLARE vPoblacion DOUBLE;
    DECLARE vCaracteristica VARCHAR(100);
    DECLARE vCuantitativa INT;
    DECLARE vObservaciones INT;
    DECLARE finDatos BOOLEAN DEFAULT FALSE;

    DECLARE micursor CURSOR FOR 
        SELECT surfacearea, code, population
        FROM country
        WHERE surfacearea BETWEEN superficieMin AND superficieMax
        AND lifeexpectancy IS NOT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;

    OPEN micursor;

    leerBucle: LOOP
    FETCH micursor INTO vSuperficie, vCodigo, vPoblacion;
    IF finDatos = TRUE 
        THEN LEAVE leerBucle;
    

    IF vPoblacion > 100000000 THEN
        UPDATE country SET lifeexpectancy = lifeexpentancy - 3 WHERE code = vCodigo;
    ELSEIF vPoblacion BETWEEN 50000000 AND 100000000 THEN
        UPDATE country SET lifeexpectancy = lifeexpentancy - 1 WHERE code = vCodigo;
    ELSEIF vPoblacion < 10000000 THEN
        UPDATE country SET lifeexpectancy = lifeexpentancy + 3 WHERE code = vCodigo;
    END IF;

    INSERT INTO infocalculada (caracteristica, cuantitativa, cualitativa)
    VALUES ('esperanzaModificada', lifeexpectancy, NULL);

    END LOOP;
    CLOSE micursor;
END$$

/* 9. Procedimiento promocionTurismo
Descripción:
Dado un continente como parámetro, recorrer las ciudades capitales (ID = Capital en la tabla country) de ese 
continente y aumentar su población artificialmente (simulando crecimiento por turismo):

Aumentar un 15% si la ciudad tiene menos de 500.000 habitantes.
Aumentar un 5% si tiene entre 500.000 y 2 millones.
No cambiar si tiene más de 2 millones.

Objetivo: Cursores que hacen uso de JOIN (entre country y city), con lógica basada en población. */
USE world;
DELIMITER $$
DROP PROCEDURE IF EXISTS promocionTurismo $$
CREATE PROCEDURE promocionTurismo(IN nombreContinente VARCHAR(30))
BEGIN
    DECLARE vCiudad VARCHAR(50);
    DECLARE vId INT;
    DECLARE vCodigo CHAR(3);
    DECLARE vPoblacion INT;
    DECLARE finDatos BOOLEAN DEFAULT FALSE;

    DECLARE micursor CURSOR FOR 
        SELECT c.code, ct.id, ct.population
        FROM country c
        JOIN city ct ON c.capital = ct.id
        WHERE LOWER(c.continent) = LOWER(nombreContinente);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;

    OPEN micursor;
    leerBucle: LOOP
    FETCH micursor INTO vCodigo, vId, vPoblacion;
    IF finDatos = TRUE THEN
        LEAVE leerBucle;
    END IF;

    IF vPoblacion < 500000 THEN
        UPDATE city SET population = population * 1.15 WHERE id = vId;
    ELSEIF vPoblacion BETWEEN 500000 AND 2000000 THEN
        UPDATE city SET population = population * 1.05 WHERE id = vId;
    END IF;
    END LOOP;
    CLOSE micursor;
END$$
DELIMITER ;
CALL promocionTurismo('Europe');

/* EXAMEN */

/* Hacer una función que retorne la suma de los términos 1/n  con “n” entre 1 y “m”, es decir 1+½+1/3+….1/m, 
siendo  “m” el parámetro de entrada. Tener  en cuenta que  “m”  no puede ser cero. */

/* Hacer una función que retorne la suma de los términos 1/n  con “n” entre 1 y “m”, es decir 1+½+1/3+….1/m, 
siendo  “m” el parámetro de entrada. Tener  en cuenta que  “m”  no puede ser cero. */
DELIMITER $$
DROP FUNCTION IF EXISTS sumaTerminos $$
CREATE FUNCTION sumaTerminos(vNumero INT)
RETURNS DOUBLE
DETERMINISTIC NO SQL
BEGIN
	DECLARE vN2 INT DEFAULT 1;
    DECLARE vResultado DOUBLE DEFAULT 0;
    
    WHILE vN2 <= vNumero DO 
        SET vResultado = 1/vN2 + vResultado;
        SET vN2 = vN2 + 1;
    END WHILE;
END $$
DELIMITER ;
SELECT sumaTerminos(9);

/* 6. Procedimiento subidaImpuestos
Descripción:
A partir del nombre de un continente recibido como parámetro, el procedimiento actualizará el campo GNP 
(Producto Nacional Bruto) de los países de ese continente según los siguientes criterios:

Si el GNP es mayor de 500.000, se reduce un 5% (impuestos por ajuste fiscal).
Si el GNP está entre 100.000 y 500.000, se reduce un 2%.
Si el GNP es menor de 100.000, se aumenta un 3% (incentivos económicos).

En todos los casos, el GNP actual del país, guárdalo en la columna GNP_OLD

Se insertará en infoCalculada una fila con la característica SubidaImpuestos, y en cuantitativo el número 
de países a los que se les ha subido. En observaciones incluye el número de países a los que se les ha reducido.

Objetivo: Uso de cursor para recorrer países por continente y modificar datos numéricos con condicionales. */

DELIMITER $$
DROP PROCEDURE IF EXISTS subidaImpuestos $$
CREATE PROCEDURE subidaImpuestos(IN nombreContinente VARCHAR(50))
BEGIN
	DECLARE vGNP DOUBLE;
    DECLARE vContinente VARCHAR(50);
    DECLARE vGNPOLD DOUBLE;
    DECLARE vCuantitativo INT DEFAULT 0;
    DECLARE vObservacion INT DEFAULT 0;
    DECLARE vCaracteristica VARCHAR(100);
    DECLARE finDatos BOOLEAN DEFAULT FALSE;
    
    DECLARE micursor CURSOR FOR
    	SELECT continent, gnp
        FROM country
        WHERE continent = nombreContinente;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finDatos = TRUE;
    
    OPEN micursor;
    leerBucle: LOOP
    	FETCH micursor INTO vContinente, vGNP;
        IF finDatos = TRUE THEN
        	LEAVE leerBucle;
        END IF;
        
        IF vGNP > 500000 THEN
        	vGNP = vGNPOLD;
            SET vCaracteristica = ('Impuesto por ajuste fiscal');
        	UPDATE country SET gnp = gnp * 0.95 WHERE name = vContinente;
            SET vObservacion = vObservacion + 1;
        ELSEIF vGNP BETWEEN 100000 AND 500000 THEN
        	vGNP = vGNPOLD;
            SET vCaracteristica = ('Impuestos básicos');
        	UPDATE country SET gnp = gnp * 0.98 WHERE name = vContinente;
            SET vObservacion = vObservacion + 1;
        ELSEIF vGNP < 100000 THEN
        	vGNP = vGNPOLD;
            SET vCaracteristica = ('Incentivos Economicos');
        	UPDATE country SET gnp = gnp * 1.03 WHERE name = vContinente;
            SET vCuantitativo = vCuantitativo + 1;
        END IF;
        END LOOP;
        
         INSERT INTO infoCalculada (característica, cuantitativo, observaciones) 
        VALUES (vCaracteristica, CONCAT('Número de paises aumentados: ',vCuantitativo), CONCAT('Número de paises reducidos: ', vObservacion));
        
    CLOSE micursor;
END $$


