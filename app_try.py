# one: create spreadsheet with ____ within max. radius of one of those addresses with corret info and save it
# two: procedure to add to, not overwrite, spreadsheet with range of all those addresses, same key, for one entering of the key
# three: remove duplicates from spreadsheet and check 

#LATER:
## app (flask + heroku?)
## options for information..

########

from make_csv import OnePartCSV
from flask import Flask

app = Flask(__name__)


@app.route("/")
def home():
    newinst = OnePartCSV("third_test.csv")
    newinst.make_csv()
    s = open(newinst.csv, 'r').read()
    return s
    # internal server error (server overloaded or other problem) -- 
    # also, interaction remains in console this way which is a problem too


if __name__ == '__main__':
    app.run()