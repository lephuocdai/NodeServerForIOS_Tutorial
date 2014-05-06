
var http = require('http'),
	express = require('express'),
	path = require('path'),
	MongoClient = require('mongodb').MongoClient,
	Server = require('mongodb').Server,
	CollectionDriver = require('./CollectionDriver').CollectionDriver;

// Setting app
var app = express();
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

var mongoHost = 'localHost';
var mongoPort = 27017;
var collectionDriver;

var mongoClient = new MongoClient(new Server(mongoHost, mongoPort));
mongoClient.open(function (err, mongoClient) {
	if (!mongoClient) {
		console.error("Error! Exitting... Must start MongoDb first");
		process.exit(1);
	}
	var db = mongoClient.db("MyDatabase");
	collectionDriver = new CollectionDriver(db);
});

app.use(express.static(path.join(__dirname, 'public')));

// Create request handler
app.get('/:collection', function (req, res) {
	var params = req.params;
	collectionDriver.findAll(req.params.collection, function (error, objs) {
		if (error) { res.send(400, error);} 
		else {
			if (req.accepts('html')) {
				res.render('data', {objects: objs, collection: req.params.collection});
			} else {
				res.set('Content-Type', 'application/json');
				res.send(200, objs);
			}
		}
	});
});

app.get('/:collection/:entity', function (req, res) {
	var params = req.params;
	var entity = params.entity;
	var collection = params.collection;
	if (entity) {
		collectionDriver.get(collection, entity, function (error, objs) {
			if (error) { res.send(400, error); }
			else { res.send(200, objs); }
		});
	} else {
		res.send(400, {error: 'bad url', url: req.url});
	}
});


/* This is for test
app.get('/', function (req, res) {
  res.send('<html><body><h1>Hello World</h1></body></html>');
});
app.get('/:a?/:b?/:c?', function (req, res){
	res.send(req.params.a + ' ' + req.params.b + ' ' + req.params.c);
});
*/

app.use(function (req, res){
	res.render('404', {url:req.url});
});

// Create server
http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
 




//2 
// http.createServer(function (req, res) {
//   res.writeHead(200, {'Content-Type': 'text/html'});
//   res.end('<html><body><h1>Hello World</h1></body></html>');
// }).listen(3000);
 
// console.log('Server running on port 3000.');