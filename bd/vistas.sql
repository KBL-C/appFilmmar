-- vista de nota media con left join
CREATE VIEW averagemovierating AS
SELECT * FROM movie
	left join averagerating
    on movie.id = averagerating.movieid;
    
-- vista de comentarios y peliculas --
CREATE VIEW moviecomment AS
SELECT * FROM movie
	left join usercommentsmovie
    on movie.id = usercommentsmovie.movieid;
    
-- vista de join usuario conmoviecomments--
CREATE VIEW usercomments AS
SELECT * FROM user
 	left join usercommentsmovie
    on user.id = usercommentsmovie.userid;
    
-- movie join fav--