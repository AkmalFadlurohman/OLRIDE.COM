// ========================== OLRIDE Chat Service =======================
const MongoClient    = require('mongodb').MongoClient;
var url = "mongodb://localhost:27017/olride_ChatServices";
const express        = require('express');
const bodyParser     = require('body-parser');
const port           = 8123;
const app            = express();

// Menyimpan identitas (token FCM) dari masing-masing pengguna yang sedang online
// Menerima request dari user A untuk chat ke user B, lalu membuat request ke FCM untuk pengiriman pesan ke token FCM user B.
// Menyimpan ke basis data history chat dari seorang pemesan dan seorang driver. Misalkan A pernah memesan driver B. Jika suatu saat A akan memesan lagi ke driver B, maka kotak chat menampilkan chat yang dilakukan pada pemesanan sebelumnya.

app.get('/', function(request, response) {
    response.send("Olride!");
    var sender = 1;
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
// pencarian token_fcm milik akun :target, kemudian buat request ke fcm
app.post('/message/send/:target', function(request, response) {
    var target = request.params.target;
    response.send("sending tp " + target);
});

MongoClient.connect(url, function(err, db) {
    if (err) throw err;
    /*db.createCollection("chatrooms", function(err, res) {
        if (err) throw err;
        console.log("Collection created!");
    });*/
    /*var chatroom = {_id: 1, "participants": [1,2], "messages": [
                            { "sender": 1, "content": 'Hello'},
                            { "sender": 2, "content": 'Yes?'},
                            { "sender": 1, "content": 'Can you pick me at ITB?'}
                    ]};
    db.collection("chatrooms").insertOne(chatroom, function(err, res) {
        if (err) throw err;
        console.log(res);
        db.close();
    });*/
});
function createChatroom(id,participant1,participant2) {
    var chatroom = {_id: id, "participants": [participant1,participant2], "messages": []};
    db.collection("chatrooms").insertOne(chatroom, function(err, res) {
        if (err) throw err;
        console.log(res);
        db.close();
    });
}
function pushToChatroom(id,senderId,content) {
    var message = {"sender": senderId,"content":content};
    MongoClient.connect(url, function(err, db) {
        db.collection("chatrooms").update(
            { _id: id },
            { $push: { messages : message }}
        )
    })
}
app.listen(port, () => {
    console.log('Olride Chat Service is active on ' + port);
    //pushToChatroom(1,2,"Sure");
});