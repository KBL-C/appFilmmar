from sqlalchemy import ForeignKey
from myApp import app, db

#=== userfavmovies asosciation table:
association_table = db.Table('userfavmovie', db.metadata,
    db.Column('userid', db.Integer, db.ForeignKey('user.id'), primary_key=True),
    db.Column('movieid', db.Integer, db.ForeignKey('movie.id'), primary_key=True)
)
#association_table2 = Table('userfavmovie')

#=== user comments movie association table:


#=== User model ===#
class User(db.Model):
    #==================================#
    __tablename__='user'
    #id = Column(Integer, primary_key=True)
    favMovies = db.relationship("Movie",
                    secondary=association_table, lazy='select', passive_deletes=True)

    id =  db.Column(db.Integer, primary_key = True)
    nick = db.Column(db.String(45))
    avatarURL = db.Column(db.String(300))
    email = db.Column(db.String(100))

    
    
    
    def __init__(self, nick, avatarURL, email):
        self.nick = nick
        self.avatarURL = avatarURL
        self.email = email

    def asdict(self):
        return {"nick" : self.nick,
                "avatarURL" : self.avatarURL,
                "email" : self.email}



#=== Movie model ===#
class Movie(db.Model):
    #lista de comentarios
    __tablename__='movie'

    id = db.Column(db.Integer, primary_key = True)
    publicid = db.Column(db.String(60))
    name = db.Column(db.String(100))
    synopsis = db.Column(db.String(300))
    releaseyear = db.Column(db.Integer())
    directorname = db.Column(db.String(100))
    posterurl = db.Column(db.String(400))

    #rating = db.relationship('Userratesmovie', backref='movie', lazy=True)
    averagerating = db.relationship('Averagerating', uselist=False, lazy=True, passive_deletes=True)

    comments = db.relationship('Comment', lazy=True, passive_deletes=True)#lazy true, me saca los cometarios solo cuando quiero

    def __init__(self, publicid, name, synopsis, releaseyear, directorname, posterurl):
        self.publicid = publicid
        self.name = name
        self.synopsis = synopsis
        self.releaseyear =  releaseyear
        self.directorname = directorname
        self.posterurl = posterurl

    def asdict(self):
        if(self.averagerating is None):
            averagerating = 0
        else:
            averagerating = self.averagerating.averagerating
        
        return {"publicid" : self.publicid,
                "name" : self.name,
                "synopsis" : self.synopsis,
                "releaseyear" : self.releaseyear,
                "directorname" : self.directorname,
                "posterurl" : self.posterurl,
                "averagerating" : averagerating}


#=====Comment============#
class Comment(db.Model):
    __tablename__='usercommentsmovie'
    id = db.Column(db.Integer, primary_key = True)

    userid = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    movieid = db.Column(db.Integer, db.ForeignKey('movie.id'), nullable=False)
    comment = db.Column(db.String(200), nullable=False)
    commentdate = db.Column(db.DateTime(), server_default='true')

    user = db.relationship('User', uselist=False, lazy=False, passive_deletes=True)


    def __init__(self, userid, movieid, comment):
        self.userid = userid
        self.movieid = movieid
        self.comment = comment

    def asdict(self):
        return {'comment' : self.comment,
                'commentdate': self.commentdate,
                'user': self.user.asdict()}



#=====Average rating ============#
class Averagerating(db.Model):
    __tablename__='averagerating'

    #id = db.Column(db.Integer, primary_key = True)
    movieid = db.Column(db.Integer, db.ForeignKey('movie.id'), primary_key = True)
    averagerating = db.Column(db.Float)

    #movie = db.relationship('Movie', backref='averagerating', uselist=False, lazy=False)


#=====Average rating ============#

class Userratesmovie(db.Model):
    __tablename__='userratesmovie'

    #id = db.Column(db.Integer, primary_key = True)

    userid = db.Column(db.Integer, db.ForeignKey('user.id'), primary_key = True, nullable=False)
    movieid = db.Column(db.Integer, db.ForeignKey('movie.id'), primary_key = True, nullable=False)
    rating = db.Column(db.Integer)

    user = db.relationship('User', uselist=False, lazy=False, passive_deletes=True)
    movie = db.relationship('Movie', uselist=False, lazy=False, passive_deletes=True)

    def __init__(self, userid, movieid, rating):
        self.userid = userid
        self.movieid = movieid
        self.rating = rating

    def asdict(self):
        return {'rating' : self.rating,
                'movie': self.movie.asdict(),
                'user': self.user.asdict()}



#cambiar la puntuación


#=====FUNCIONES===========#
#@app.route('/user/getObject/<string:nick>', methods=['GET'])
def userByNickObject(nick):
    user = User.query.filter_by(nick=nick).first()
    return user
#getmovie by publicid
#@app.route('/movie/getObject/<string:publicid>', methods=['GET'])
def movieByPublicidObject(publicid):
    movie = Movie.query.filter_by(publicid=publicid).first()
    return movie

#getuserid by user nick
#@app.route('/user/getid/<string:nick>', methods=['GET'])
def userIdByNick(nick):
    user = User.query.filter_by(nick=nick).first()
    userid = user.id
    #id = request.form['id']
    #userid = User.query.get(nick)
    return userid

#get movieid by publicid:
#@app.route('/movie/getid/<string:publicid>', methods=['GET'])
def movieIdByPublicid(publicid):
    movie = Movie.query.filter_by(publicid=publicid).first()
    movieid = movie.id
    #id = request.form['id']
    #userid = User.query.get(nick)
    return movieid
