// ========================== OLRIDE Chat Service =======================

const express        = require('express');
const requestLib     = require('request');
const MongoClient    = require('mongodb').MongoClient;
var url = "mongodb://localhost:27017/olride_ChatServices";
const express        = require('express');
const bodyParser     = require('body-parser');
const port           = 8123;
const app            = express();

// Membuat chatroom baru dengan anggota participant1 dan participant2
function createChatroom(participant1,participant2) {
    var chatroom = {"participants": [participant1,participant2], "messages": []};
    db.collection("chatrooms").insertOne(chatroom, function(err, res) {
        if (err) throw err;
        console.log("Created new chatroom with participants ["participant1+","+participant2"]");
        db.close();
    });
}
// Menyimpan chat baru yang dikirim pengguna dengan id senderId dan isi pesan berupa content
function pushToChatroom(chatId,senderId,content) {
    var message = {"sender": senderId,"content":content};
    MongoClient.connect(url, function(err, db) {
        db.collection("chatrooms").update(
            { _id: chatId },
            { $push: { messages : message }}
        )
        console.log("Inserted new message :" + JSON.stringify(message,null,1) + " to chatroom with id: "+chatId);
    })
}
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
// Pemanggilan prosedur createChatroom melalui ajax request
app.post('/chatroom/create', function(request, response) {
    var participant1 = parseInt(request.body.participant1,10);
    var participant2 = parseInt(request.body.participant2,10);
    createChatroom(participant1,participant2);
    response.send("sending tp " + target);
});
// Mendapatkan seluruh data history chat dengan partisipan 1 dan 2
app.post('/chatroom/fetch', function(request, response) {
    var participant1 = parseInt(request.body.participant1,10);
    var participant2 = parseInt(request.body.participant2,10);
    var query = { participants: [participant1,participant2] };
    console.log("Fetch chatroom with participants: ["+participant1+","+participant2+"]");
    MongoClient.connect(url, function(err, db) {
        db.collection("chatrooms").findOne(query,function(err, res) {
            if (err) console.error(err);
            console.log(res);
            response.send(JSON.stringify(res));
            db.close();
        })
    });
});
// Pemanggilan prosedur pushToChatroom melalui ajax request
app.post('/chatroom/push', function(request, response) {
    var chatId = parseInt(request.body.chatId,10);
    var senderId = parseInt(request.body.senderId,10);
    var content = request.body.content;
    pushToChatroom(chatId,senderId,content);
});


// Menerima request untuk mengirimkan pesan ke :target, awalnya perlu dilakukan
// pencarian token_fcm milik akun :target, kemudian buat request ke fcm
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
            console.log(body)
            response.send("receiving " + JSON.stringify(request.body));
        }
    });
    
});

app.listen(port, () => {
    console.log('Olride Chat Service is active on ' + port);
});