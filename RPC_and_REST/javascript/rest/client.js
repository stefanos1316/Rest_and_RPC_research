var request = require('request');
request('http://localhost:3000/', function (error, response, body) {
    if (!error && response.statusCode == 200) {
        console.log('STATUS: ' + response.statusCode) // Print the google web page.
     }
})
