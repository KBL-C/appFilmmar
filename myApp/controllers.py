from urllib import response
from myApp import app, db
from flask import jsonify, request
import myApp.models as m
#from myApp.functions import userByNickObject
# ==== User Api ==== #

#get all users
@app.route('/users/all', methods=['GET'])
def allUsers():
    users = m.User.query.all()
    #return jsonify(allUsers=[user.asdict() for user in users])
    response = jsonify([user.asdict() for user in users])
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response
    

#get users by id:
@app.route('/user/get', methods=['POST'])
def userById():
    id = request.form['id']
    user = m.User.query.get(id)
    #return jsonify(user.asdict())
    response = jsonify(user.asdict())
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

#select user by nick:
@app.route('/user/get/nick/<nick>', methods=['GET'])
def userByNick(nick):
    user = m.User.query.filter_by(nick=nick).first()
    #return jsonify(user.asdict())
    response = jsonify(user.asdict())
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response


#select userfavmovies
@app.route('/user/favMovies/<nick>', methods=['GET'])
def favMovies(nick):
    fMovies = m.userByNickObject(nick).favMovies
    #return jsonify(fMovies=[movie.asdict() for movie in fMovies])
    response = jsonify(fMovies=[movie.asdict() for movie in fMovies])
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

#add user
#sentencia para añadir persona:
#@CrossOrigin
@app.route('/user/add', methods=['POST'])
def insertUser():
    
    nick = request.form['nick']
    avatarURL = request.form['avatarURL']
    email = request.form['email'] 

    user = m.User(nick, avatarURL, email)
    
    db.session.add(user)
    db.session.commit()
    
    response = jsonify(user.asdict())
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

#insertar pelicula favorita por nick del usuario
@app.route('/favMovie/put', methods=['POST'])
def insertfavMovie():
    nick = request.form['nick']
    publicid = request.form['publicid']
    user = m.userByNickObject(nick)
    movie = m.movieByPublicidObject(publicid)
    user.favMovies.append(movie)
    db.session.commit()
    #gestionar error

    return jsonify(movie.asdict())

#eliminar d favoritos
@app.route('/favMovie/del', methods=['POST'])
def removefavMovie():
    nick = request.form['nick']
    publicid = request.form['publicid']
    user = m.userByNickObject(nick)
    movie = m.movieByPublicidObject(publicid)
    user.favMovies.remove(movie)
    db.session.commit()
    #gestionar error

    return jsonify(movie.asdict())


#delete user by id:
@app.route('/user/del', methods=['POST'])
def deleteUser():
    nick = request.form['nick']
    user = m.userByNickObject(nick)
    
    db.session.delete(user)
    db.session.commit()

    return jsonify(user.asdict())




# ==== Movie Api ==== #

#Get all movies
@app.route('/movies/all', methods=['GET'])
def allMovies():
    movies = m.Movie.query.all()
    #return jsonify(allMovies=[movie.asdict() for movie in movies])
    response = jsonify([movie.asdict() for movie in movies])
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

#select movie by id
@app.route('/movie/get', methods=['POST'])
def movieById():
    id = request.form['id']
    movie = m.Movie.query.get(id)
    #return jsonify(movie.asdict())
    response = jsonify(movie.asdict())
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response

#select movie by publicid:
@app.route('/movie/get/<publicid>', methods=['GET'])
def movieByPublicid(publicid):
    movie = m.Movie.query.filter_by(publicid=publicid).first()
    response = jsonify(movie.asdict())
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response
    

#search movie by name
@app.route('/movie/name/<string:name>', methods=['GET'])
def searchMovieByName(name):
    search = "%{}%".format(name)
    movies = m.Movie.query.filter(m.Movie.name.like(search)).all()

    #return jsonify(allMovies=[movie.asdict() for movie in movies])
    response = jsonify(allMovies=[movie.asdict() for movie in movies])
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response



#add movie:
#sentencia para añadir peli:
@app.route('/movie/add', methods=['POST'])
def insertMovie():
    publicid = request.form['publicid']
    name = request.form['name']
    synopsis = request.form['synopsis']
    releaseyear = request.form['releaseyear']
    directorname = request.form['directorname']
    posterurl = request.form['posterurl']


    movie = m.Movie(publicid, name, synopsis, releaseyear, directorname, posterurl)
    db.session.add(movie)
    db.session.commit()
    response = jsonify(movie.asdict())
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response


#delete movie by id
@app.route('/movie/del', methods=['POST'])
def deleteMovie():
    publicid = request.form['publicid']
    movie = m.movieByPublicidObject(publicid)
    db.session.delete(movie)
    db.session.commit()

    return (True)


# ==== Comment Api ==== #
#get movie comment
@app.route('/comment/get/<string:publicid>', methods=['GET'])
def commentByMoviePublicid(publicid):
    movie = m.movieByPublicidObject(publicid)
    commentList = movie.comments
    #return jsonify(commentList=[comment.asdict() for comment in commentList])
    response = jsonify(commentList=[comment.asdict() for comment in commentList])
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response


#add user comment:
@app.route('/comment/put', methods=['POST'])
def insertMovieComment():
    nick = request.form['nick']
    publicid = request.form['publicid']
    
    userid = m.userIdByNick(nick)
    movieid = m.movieIdByPublicid(publicid)

    comment = request.form['comment']
    

    movieComment = m.Comment(userid, movieid, comment)
    db.session.add(movieComment)
    db.session.commit()
    #gestionar error
    return jsonify(movieComment.asdict())
    
# get movie average rating:
@app.route('/movie/averageRating/get/<string:publicid>', methods=['GET'])
def selectAverageRating(publicid):
    movie = m.movieByPublicidObject(publicid)
    averagerating = movie.averagerating.averagerating

    #return str(averagerating)
    response = str(averagerating)
    response.headers.add('Access-Control-Allow-Origin', '*')
    return response
    


#===========================

#===== User rates movie Api =====

#rate movie:

@app.route('/rating/put', methods=['POST'])
def insertRating():
    nick = request.form['nick']
    publicid = request.form['publicid']
    
    userid = m.userIdByNick(nick)
    movieid = m.movieIdByPublicid(publicid)

    rating = request.form['rating']
    

    movieRating = m.Userratesmovie(userid, movieid, rating)
    db.session.add(movieRating)
    db.session.commit()
    #gestionar error
    return jsonify(movieRating.asdict())


#buscador. like

'''
objeto rating con user, movie y float(nota)
clase comment con usuario peli y comentario

rating: relación 1 a 1 con movie y averagerating
'''

'''
al igual que movie en el comment, en movie añadimos rating
creamos una clase nueva movierating
'''

'''
quitar las películas de fvoritos (buscar en la lista y eliminarlos)

cambiar la puntuacón de las películas:

'''