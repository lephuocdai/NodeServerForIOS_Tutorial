
var http = require('http'),
	express = require('express'),
	path = require('path');

// Setting app
var app = express();
app.set('port', process.env.PORT || 3000);
app.use(express.static(path.join(__dirname, 'public')));

// Create request handler
app.get('/', function (req, res) {
  res.send('<html><body><h1>Hello World</h1></body></html>');
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