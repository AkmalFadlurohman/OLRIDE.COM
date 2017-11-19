// ========================== OLRIDE Chat Service =======================
const express        = require('express');
const MongoClient    = require('mongodb').MongoClient;
const bodyParser     = require('body-parser');
const port           = 8123;
const app            = express();

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
    response.send("sending tp " + target);
});


app.listen(port, () => {
    console.log('Olride Chat Service is active on ' + port);
});