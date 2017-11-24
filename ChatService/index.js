// ========================== OLRIDE Chat Service =======================
const express        = require('express');
const requestLib     = require('request');
const MongoClient    = require('mongodb').MongoClient;
const bodyParser     = require('body-parser');
const port           = 8123;
const app            = express();
app.use(bodyParser.json());         // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
    extended: true
})); 

app.use(function(req, res, next) {
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Origin', '*');
    next();
});

// Menyimpan identitas (token FCM) dari masing-masing pengguna yang sedang online
// Menerima request dari user A untuk chat ke user B, lalu membuat request ke FCM untuk pengiriman pesan ke token FCM user B.
// Menyimpan ke basis data history chat dari seorang pemesan dan seorang driver. Misalkan A pernah memesan driver B. Jika suatu saat A akan memesan lagi ke driver B, maka kotak chat menampilkan chat yang dilakukan pada pemesanan sebelumnya.

app.get('/', function(request, response) {
    response.send("Olride!");
});

// Menyimpan token_fcm dan username yang diberikan oleh client
app.post('/token/register', function(request, response) {

});

// Memberikan daftar driver yang sedang mencari pesanan
app.get('/driver/online', function(request, response) {
    response.json(
        [
            {
                token: 'asdasdasdasdasdasdasd',
                token_fcm: 'asdasdasdasdasdasd'
            },
            {
                token: 'asdasasdasdasdasdasd',
                token_fcm: 'asdasdasdasdasdasd'
            },
            {
                token: 'asdasdasdasdasdasdasd',
                token_fcm: 'asdasdasdasdasdasd'
            }
        ]
    );
});

// Menerima request untuk mengirimkan pesan ke :target, awalnya perlu dilakukan
// pencarian token_fcm milik akun :target, kemudian biat request ke fcm
app.post('/message/send/:target', function(request, response) {
    var target = request.params.target;

    // Search destination token
    var targetToken = 'e0l50GH8TEU:APA91bG0VKYBu3OW5F5Lgmd64PzL0iJ0MdzaO4O4Ny33N_lYtUJzpT9MV1my6WwGKiLWrujfFC1T7oTBgzJqqGfEL9VbvLJbqcjaPv2LbqP_ZG9DCyMxGFJ8iWZf85mSO_8tQfO-fxLr';
    console.log('Sending ' + request.body.text + ' to ' + targetToken);

    // Send message to FCM
    var options = {
        url: 'https://fcm.googleapis.com/fcm/send',
        method: 'POST',
        headers: {
            'Content-Type'  : 'application/json',
            'Authorization' : 'key=AAAAnjx6yDc:APA91bGzkbzuYmRCbZWNVh923dCIQ0KNkB4hbPwb-324AeG4JPeNj4Izt6j0svRf6QtM2uEwSeidqH2Vf2S8T82X_H0UvIkWLhWsz_mE9Aga6lCknA2YtJxEhEscL_eiRTka4mr0t0aP'
        },
        body: JSON.stringify({
            'to': targetToken, 
            'notification': {
                'title' : "New Message",
                'body' : request.body.text
            }
        })
    }
    

    // Start the request
    requestLib(options, function (error, resp, body) {
        if (!error && resp.statusCode == 200) {
            console.log(resp)
            response.send("receiving " + JSON.stringify(request.body));
        }
    })
});


app.listen(port, () => {
    console.log('Olride Chat Service is active on ' + port);
});