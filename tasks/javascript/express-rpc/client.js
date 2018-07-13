var request = require('request');

for (var i = 0; i < 20000; i++) { 
request('http://195.251.251.27:3000/', function (error, response, body) {
    if (!error && response.statusCode == 200) {
        console.log('STATUS: ' + response.statusCode) // Print the google web page.
     }
})
}
