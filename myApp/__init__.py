#Fichero enecesario en la misca carpeta del proyecto para que funcione el import

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
#para qeu la barra final de la url no sea necearia
app.url_map.strict_slashes = False
#enlace de la BD
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root@localhost/myfilmaffinity'
#formato utf-8
app.config['JSON_AS_ASCII'] = False

db = SQLAlchemy(app)

import myApp.controllers