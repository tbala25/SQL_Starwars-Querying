USE starwarsfinalBALAT;

#######################
# Question 1
# Procedure to print all scenes that the given character appears in


DROP PROCEDURE IF EXISTS track_character;

-- Change statement delimiter to double front slash
DELIMITER //

CREATE PROCEDURE track_character
(char_name varchar(80))
BEGIN
	Select timetable.character_name, timetable.planet_name, movies.title, (timetable.departure - timetable.arrival)
    FROM timetable JOIN movies ON timetable.movie_id = movies.movie_id
	WHERE timetable.character_name = char_name;
END//

-- Change statement delimiter to semicolon
DELIMITER ;
CALL track_character("Darth Vader");
CALL track_character("Yoda");

########################################
# Question 2
# Procedure to print count of characters that appear on given planet for each movie

DROP PROCEDURE IF EXISTS track_planet;

-- Change statement delimiter to double front slash
DELIMITER //

CREATE PROCEDURE track_planet
(plan_name varchar(80))
BEGIN
	Select timetable.planet_name, movies.title, COUNT(*)
    FROM timetable JOIN movies ON timetable.movie_id = movies.movie_id
	WHERE timetable.planet_name = plan_name
    GROUP BY timetable.planet_name, movies.title;
END//

-- Change statement delimiter to semicolon
DELIMITER ;

CALL track_planet("Bespin");
CALL track_planet("Death Star");

#############################################################
#Question 3
# Function returns number of planets the given character has appeared on

DROP FUNCTION IF EXISTS planet_hopping;

-- Change statement delimiter to double front slash
DELIMITER //

CREATE FUNCTION planet_hopping (char_name varchar(80)) RETURNS INT
BEGIN
	DECLARE char_planet_count INT;

	SELECT COUNT(distinct planet_name)
    INTO char_planet_count
	FROM timetable
	WHERE character_name = char_name;
    
    RETURN char_planet_count;
END//
-- Change statement delimiter to semicolon
DELIMITER ;

SELECT 
    character_name, PLANET_HOPPING('Darth Vader')
FROM
    timetable
WHERE
    character_name = 'Darth Vader'
GROUP BY character_name;


SELECT PLANET_HOPPING('Darth Vader');


SELECT 
    character_name, PLANET_HOPPING('Yoda')
FROM
    timetable
WHERE
    character_name = 'Yoda'
GROUP BY character_name;

#####################################################################################
#Question 4
#Function that returns name of planet that given character visited most

DROP FUNCTION IF EXISTS planet_most_visited;

-- Change statement delimiter to double front slash
DELIMITER //

CREATE FUNCTION planet_most_visited (char_name varchar(80)) RETURNS varchar(80)
BEGIN
	DECLARE char_planet_name varchar(80);
    
	SELECT planet_name 
    INTO char_planet_name
	FROM timetable
	WHERE character_name = char_name
    GROUP BY planet_name
    ORDER BY COUNT(planet_name) desc
    Limit 1;
    
    RETURN char_planet_name;
END//
-- Change statement delimiter to semicolon
DELIMITER ;

SELECT PLANET_MOST_VISITED('Yoda');
SELECT PLANET_MOST_VISITED('Darth Vader');

#####################################################################################
#Question 5
#Function that returns TRUE if given character has same affiliation as their homeworld
# FALSE if affiliation is different, NULL if affiliation is unknown

DROP FUNCTION IF EXISTS home_affiliation_same;

-- Change statement delimiter to double front slash
DELIMITER //

CREATE FUNCTION home_affiliation_same (char_name varchar(80)) RETURNS boolean
BEGIN

	DECLARE hw varchar(80);
    DECLARE ca varchar(80);
    DECLARE pa varchar(80);

	SELECT characters.homeworld as hw, characters.affiliation AS ca, planets.affiliation AS pa
    INTO hw, ca, pa
	FROM characters, planets
	WHERE character_name = char_name AND characters.homeworld = planets.planet_name;
    
    IF hw = 'unknown' THEN
		RETURN NULL;
	END IF;
        
	IF ca != pa THEN
		RETURN FALSE;
	END IF;
        
	IF ca = pa THEN
		RETURN TRUE;
	END IF;
    
END//
-- Change statement delimiter to semicolon
DELIMITER ;

SELECT HOME_AFFILIATION_SAME('Han Solo');
SELECT HOME_AFFILIATION_SAME('Darth Vader');

#####################################################################################
#Question 6
#Function that returns the number of movies that the given planet is in

DROP FUNCTION IF EXISTS planet_in_num_movies;

-- Change statement delimiter to double front slash
DELIMITER //

CREATE FUNCTION planet_in_num_movies (plan_name varchar(80)) RETURNS INT
BEGIN
	DECLARE planet_movie_count INT;

	SELECT COUNT(*)
    INTO planet_movie_count
	FROM timetable
	WHERE planet_name = plan_name
    GROUP BY planet_name;
    
    RETURN planet_movie_count;
END//
-- Change statement delimiter to semicolon
DELIMITER ;

SELECT 
    planet_name, PLANET_IN_NUM_MOVIES('Bespin')
FROM
    timetable
WHERE
    planet_name = 'Bespin'
GROUP BY planet_name;

SELECT 
    planet_name, PLANET_IN_NUM_MOVIES('Death Star')
FROM
    timetable
WHERE
    planet_name = 'Death Star'
GROUP BY planet_name;

########################################
# Question 7
# Procedure to print all records of characters with given affiliation

DROP PROCEDURE IF EXISTS character_with_affiliation;

-- Change statement delimiter to double front slash
DELIMITER //

CREATE PROCEDURE character_with_affiliation
(aff_name varchar(80))
BEGIN
	Select *
    FROM characters
	WHERE affiliation = aff_name;
END//

-- Change statement delimiter to semicolon
DELIMITER ;

CALL character_with_affiliation('rebels');
CALL character_with_affiliation('empire');

##############################################
# Question 8
# Trigger to update scenes_in_db field on every insert

DROP TRIGGER timetable_after_insert;

-- Change statement delimiter to double front slash
DELIMITER //

CREATE TRIGGER timetable_after_insert 
	AFTER INSERT ON timetable
	FOR EACH ROW
BEGIN
	UPDATE movies SET scenes_in_db = MAX(timetable.departure)
	WHERE timetable.movie_id = movies.movie_id;
END//

-- Change statement delimiter to semicolon
DELIMITER ;

INSERT INTO timetable (character_name, movie_id,arrival,departure)
VALUES('Princess Leia',3,11,12);
INSERT INTO timetable (character_name, movie_id,arrival,departure)
VALUES('Endor',3,11,12);
INSERT INTO timetable (character_name, movie_id,arrival,departure)
VALUES('Chewbacca',3,11,12);

SELECT 
    *
FROM
    timetable;
SELECT 
    *
FROM
    movies;


######################################################
#Question 9
#Prepared statement to call track_character with session variable
SET @nineVar = 'Princess Leia';

PREPARE stmtNine FROM 'CALL track_character(?)';
EXECUTE stmtNine USING @nineVar;

######################################################
#Question 10
#Prepared statement to call planet_in_num_movies with session variable
SET @tenVar = 'Bespin';

PREPARE stmtTen FROM 'SELECT 
    planet_name, PLANET_IN_NUM_MOVIES(?)
FROM
    timetable
WHERE
    planet_name = ?
GROUP BY planet_name;';
EXECUTE stmtTen USING @tenVar, @tenVar;

