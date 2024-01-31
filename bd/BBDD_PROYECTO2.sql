-- Borramos el esquema si existe
DROP SCHEMA IF EXISTS myfilmaffinity;

-- Creamos nuevo schema (database) myfilmaffinity
CREATE SCHEMA IF NOT EXISTS myfilmaffinity;

USE myfilmaffinity; -- Usamos el schema myfilmaffinity

-- Creamos la tabla usuario
CREATE TABLE user (
	id INT(11) NOT NULL AUTO_INCREMENT, -- Clave primaria, id numérico (int) autoincremental
    nick VARCHAR(15) NOT NULL UNIQUE, -- Nick del usuario, tipo varchar máximo 15, no puede ser null y debe ser único
    avatarURL VARCHAR(300) DEFAULT "https://miro.medium.com/max/720/1*W35QUSvGpcLuxPo3SRTH4w.png", -- URl del avatar (foto usuario), tipo varchar máximo 100, tiene valor por defecto
    email VARCHAR(100) NOT NULL UNIQUE, -- Email del usuario, tipo varchar máximo 100, no puede ser null y debe ser único
    PRIMARY KEY (id)
    
);

-- Creamos la tabla pelicula
CREATE TABLE movie (
	id INT(11) NOT NULL AUTO_INCREMENT, -- Clave primaria, id numérico (int) autoincremental
    publicid VARCHAR(60) NOT NULL UNIQUE, -- Clave pública, tipo varchar máximo 60, no puede ser null y debe ser único
    name VARCHAR(100) NOT NULL, -- Nombre de la película, tipo varchar máximo 100, no puede ser null
    synopsis VARCHAR(300) NOT NULL, -- Sinopsis de la película, tipo varchar máximo 1000, no puede ser null
    releaseyear INT(11) NOT NULL, -- Año de estreno de la película, tipo int, no puede ser null y debe estar entre 1800 y 2100
    directorname VARCHAR(100) NOT NULL, -- Nombre del director de la película, tipo varchar máximo 100, no puede ser null
    posterurl VARCHAR(400) DEFAULT "https://pics.filmaffinity.com/Metr_polis-434117468-large.jpg", -- URl del cartel (foto pelicula), tipo varchar máximo 100, tiene valor por defecto
    PRIMARY KEY (id),
	CONSTRAINT checkreleaseyear CHECK (releaseyear >= 1800 and releaseyear <=2100) 
);

-- Creamos la tabla comentarios de pelicula
CREATE TABLE usercommentsmovie (
  id INT(11) NOT NULL AUTO_INCREMENT, -- Clave primaria, id numérico (int) autoincremental, no puede ser null
  userid INT(11) NOT NULL, -- Clave externa: usuario que comenta, no puede ser null
  movieid INT(11) NOT NULL, -- Clave externa: pelicula comentada, no puede ser null
  comment VARCHAR(200) NOT NULL, -- Comentario, tipo varchar máximo 200, no puede ser null
  commentdate datetime DEFAULT CURRENT_TIMESTAMP, -- Fecha del comentario, se usa la fecha de la BBDD
  PRIMARY KEY (id),
  FOREIGN KEY (userid) REFERENCES user(id) ON DELETE CASCADE,
  FOREIGN KEY (movieid) REFERENCES movie(id) ON DELETE CASCADE
);

-- Creamos la tabla puntuaciones
CREATE TABLE userratesmovie (
  userid INT(11) NOT NULL, -- Clave externa: usuario que puntúa, no puede ser null
  movieid INT(11) NOT NULL, -- Clave externa: pelicula puntuada, no puede ser null
  rating INT(11) NOT NULL, -- Nota que el usuario pone a la película, no puede ser null y debe estar entre 1 y 5
  UNIQUE (userid, movieid), -- La dupla usuario-película debe ser única
  FOREIGN KEY (userid) REFERENCES user(id) ON DELETE CASCADE,
  FOREIGN KEY (movieid) REFERENCES movie(id) ON DELETE CASCADE,
  CONSTRAINT checkrating CHECK (rating >= 1 and rating <=5)
);

-- Creamos la tabla favoritos
CREATE TABLE userfavmovie (
  userid INT(11) NOT NULL, -- Clave externa: usuario que añade a favoritos, no puede ser null
  movieid INT(11) NOT NULL, -- Clave externa: pelicula que se añade a favoritos, no puede ser null
  UNIQUE (userid, movieid), -- La dupla usuario-película debe ser única
  FOREIGN KEY (userid) REFERENCES user(id) ON DELETE CASCADE,
  FOREIGN KEY (movieid) REFERENCES movie(id) ON DELETE CASCADE
);

-- Creamos la vista nota media
CREATE VIEW averagerating AS
SELECT movieid, sum(rating)/count(*) AS averagerating -- Averagerating es la nota media de la película con id movieid
FROM userratesmovie 
GROUP BY movieid;

-- vista de nota media con left join
CREATE VIEW averagemovierating AS
SELECT * FROM movie
	left join averagerating
    on movie.id = averagerating.movieid;
    
-- vista de usario para obtener el numero de pelis favoritas del usuario --
CREATE OR REPLACE VIEW userfavs AS
SELECT userfavmovie.userid, count(userfavmovie.movieid) AS favMovies, user.id, user.nick, user.avatarURL, user.email
FROM  userfavmovie
right join user on userfavmovie.userid = user.id
group by user.nick;
-- --
CREATE OR REPLACE VIEW usuario1 AS
SELECT * FROM 
(SELECT m.posterurl, m.name, ratedfavs.userid, ratedfavs.rating FROM 
	(SELECT f.*, r.rating 
    FROM userfavmovie f 
    left join userratesmovie r 
    on f.userid = r.userid and f.movieid = r.movieid)
    ratedfavs
    join movie m 
    on ratedfavs.movieid = m.id
    ) a
    left join user on a.userid = user.id;
    
-- vista para sacar comentarios de peli --
CREATE OR REPLACE VIEW moviecomments AS
SELECT user.nick, user.avatarURL, usercommentsmovie.id, usercommentsmovie.comment, usercommentsmovie.commentdate, movie.publicid
FROM usercommentsmovie
left join user on usercommentsmovie.userid = user.id
right join movie on usercommentsmovie.movieid = movie.id
GROUP BY usercommentsmovie.id;

-- Insertamos datos de películas
INSERT INTO movie
(publicid, name, synopsis, releaseyear, directorname, posterurl)
VALUES
("oldboy","Oldboy","Oh Dae-su (Choi Min-sik) is an ordinary Seoul businessman with a wife and little daughter who, after a drunken night on the town, is locked up in a strange, private prison. No one will tell him why he's there or who his jailer is. The imprisonment last for 15 years until one day when Dae-su finds himself unexpectedly deposited on a grass-covered high-rise roof, determined to discover the mysterious enemy who had him locked up.","2005","Chan-wook Park","https://m.media-amazon.com/images/I/51U+G+ZgGgL._AC_SY450_.jpg"),
("wall-e","WALL-E","After hundreds of lonely years of doing what he was built for, Wall-E discovers a new purpose in life when he meets a sleek search robot named EVE.","2008","Andrew Stanton","https://m.media-amazon.com/images/I/51RoZRgIHtL._AC_.jpg"),
("alien-1979","Alien","After a space merchant vessel receives an unknown transmission as a distress call, one of the crew is attacked by a mysterious life form and they soon realize that its life cycle has merely begun.","1979","Ridley Scott","https://m.media-amazon.com/images/I/81lrPEEJ2WL._AC_SY741_.jpg"),
("spider-man-into-the-spider-verse","Spider-Man: Into the Spider-Verse","Spider-Man: Into the Spider-Verse introduces Brooklyn teen Miles Morales, and the limitless possibilities of the Spider-Verse, where more than one can wear the mask.","2018","Bob Persichetti","https://m.media-amazon.com/images/I/71woXNTh5jL._AC_SY679_.jpg"),
("the-iron-giant","The Iron Giant","A giant metal machine falls to Earth in 1950s Maine, frightening townspeople. However, the robot befriends a nine-year-old boy named Hogarth who must save it from the predjudices of the townspeople and from a government agent intent on destroying the robot.","1999","Brad Bird","https://m.media-amazon.com/images/I/614IXzrb5JL._AC_SY741_.jpg"),
("blade-runner","Blade Runner","In a future of high-tech possibility soured by urban and social decay, detective Rick Deckard hunts for fugitive, murderous replicants—and is drawn to a mystery woman whose secrets may undermine his soul.","1982","Ridley Scott","https://m.media-amazon.com/images/I/51qNge1o-+L._AC_.jpg"),
("the-terminator","The Terminator","A cyborg (Arnold Schwarzenegger) is sent from the 21st century to present-day Los Angeles to assassinate a seemingly innocent women whose child will play an important part in the world from which the killer came.","1984","James Cameron","https://m.media-amazon.com/images/I/7124A8OOL6L._AC_SY879_.jpg"),
("mr-nobody","Mr. Nobody","A young boy stands on a station platform. The train is about to leave. Should he go with his mother or stay with his father? An infinity of possibilities rise from this decision. As long as he doesn't choose, anything is possible. Every life deserves to be lived.","2013","Jaco Van Dormael","https://m.media-amazon.com/images/I/513dSb7A7nL._AC_.jpg"),
("total-recall","Total Recall","Doug Quaid (Schwarzenegger), a construction worker with a beautiful wife (Stone) and home in in the year 2084, decides to take a virtual vacation to Mars as a secret agent. When things go wrong during the aritificial memory implantation process, Quaid becomes reacts violently and must figure out if his life as Quaid or as the secret agent is his true life.","1990","Paul Verhoeven","https://m.media-amazon.com/images/I/916f8sLVwML._AC_SY679_.jpg"),
("gran-torino","Gran Torino","Retired auto worker Walt Kowalski fills his days with home repair, beer and monthly trips to the barber. The people he once called his neighbors have all moved or passed away, replaced by Hmong immigrants, from Southeast Asia, he despises. Resentful of virtually everything he sees--Walt is just waiting out the rest of his life. Until the night someone tries to steal his `72 Gran Torino. The Gran Torino brings his shy teenaged neighbor Thao into his life when Hmong gangbangers pressure the boy into trying to steal it. But Walt stands in the way of both the heist and the gang, making him the reluctant hero of the neighborhood--especially to Thao's mother and older sister, Sue, who insist that Thao work for Walt as a way to make amends. Though he initially wants nothing to do with these people, Walt eventually gives in and puts the boy to work fixing up the neighborhood, setting into motion an unlikely friendship that will change both their lives. ","2008","Clint Eastwood","https://m.media-amazon.com/images/I/41CIWx2Fd2L._AC_.jpg");

-- Insertamos datos de usuarios
INSERT INTO user
(nick, email)
VALUES
("oletenapen", "oletenapen@correo.com"),
("iageadertl", "iageadertl@correo.com"),
("ragnar", "ragnesenti@correo.com"),
("lymplaholo", "lymplaholo@correo.com"),
("trontagesc", "trontagesc@correo.com"),
("mardiardis", "mardiardis@correo.com"),
("ustiocefed", "ustiocefed@correo.com"),
("ighoncerib", "ighoncerib@correo.com"),
("ngeneteoru", "ngeneteoru@correo.com"),
("gabalterie", "gabalterie@correo.com");

-- Insertamos datos de favoritos
INSERT INTO userfavmovie
(userid, movieid)
VALUES
(2, 5),
(5, 2),
(6, 3),
(10, 1),
(3, 9),
(4, 7),
(5, 1),
(2, 7),
(9, 5),
(4, 3),
(6, 1),
(3, 1),
(4, 2),
(3, 6),
(10, 2),
(2, 6),
(8, 7),
(10, 10),
(3, 8),
(3, 7),
(9, 9),
(4, 5),
(9, 2),
(4, 1),
(3, 3);

-- Insertamos datos de puntuación
INSERT INTO userratesmovie
(userid, movieid, rating)
VALUES
(2, 5, 1),
(5, 2, 2),
(6, 3, 3),
(10, 1, 4),
(3, 9, 5),
(4, 7, 1),
(5, 1, 2),
(2, 7, 3),
(9, 5, 4),
(4, 3, 5),
(6, 1, 3),
(3, 1, 2),
(4, 2, 1),
(3, 6, 5),
(10, 2, 4),
(2, 6, 3),
(8, 7, 2),
(10, 10, 1),
(3, 8, 5),
(3, 7, 4),
(9, 9, 3),
(4, 5, 2),
(9, 2, 5),
(4, 1, 5),
(3, 3, 4);

-- Insertamos datos de comentarios
INSERT INTO usercommentsmovie
(userid, movieid, comment)
VALUES
(5, 7, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(6, 3, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(10, 2, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(6, 2, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(3, 2, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(6, 8, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(1, 3, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(6, 10, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(4, 6, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(3, 3, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(8, 1, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(9, 10, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(8, 9, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(9, 5, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(10, 10, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(9, 1, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(3, 3, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(1, 6, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(3, 6, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(2, 8, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(10, 4, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(5, 10, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(3, 2, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(4, 4, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor."),
(6, 8, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris blandit metus dui. Aliquam efficitur urna in nisi eleifend, sed dictum mauris porttitor.");

-- Cambiamos el avatar del usuario 3
UPDATE user SET avatarURL = "https://avatarfiles.alphacoders.com/267/thumb-267328.jpg" WHERE id = 3;

select * from movie;

