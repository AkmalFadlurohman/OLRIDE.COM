// ========================== OLRIDE Chat Service =======================

const express        = require('express');
const requestLib     = require('request');
const MongoClient    = require('mongodb').MongoClient;
var ObjectId = require('mongodb').ObjectID;
var url = "mongodb://localhost:27017/olride_ChatServices";
const bodyParser     = require('body-parser');
const port           = 8123;
const app            = express();
var cors = require('cors')

app.use(bodyParser.json());         // to support JSON-encoded bodies
app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
    extended: true
})); 
app.use(cors());

// Membuat chatroom baru dengan anggota participant1 dan participant2
function createChatroom(participant1,participant2) {
    var chatroom = {"participants": [participant1,participant2], "messages": []};
    MongoClient.connect(url, function(err, db) {
        db.collection("chatrooms").insertOne(chatroom, function(err, res) {
            if (err) throw err;
            console.log("Created new chatroom with participants ["+participant1+","+participant2+"]");
            db.close();
        });
    })   
}
// Menyimpan ke basis data history chat dari seorang pemesan dan seorang driver. Misalkan A pernah memesan driver B. Jika suatu saat A akan memesan lagi ke driver B, maka kotak chat menampilkan chat yang dilakukan pada pemesanan sebelumnya.
function pushToChatroom(chatId,senderId,content) {
    var message = {"sender": senderId,"content":content};
    MongoClient.connect(url, function(err, db) {
        db.collection("chatrooms").update(
            { "_id": ObjectId(chatId) },
            { $push: { messages : message }}
        )
        console.log("Inserted new message :" + JSON.stringify(message,null,1) + " to chatroom with id: "+chatId);
    })
}
// Menyimpan identitas (token FCM) dari masing-masing pengguna yang sedang online
function registerToken(userId,fcmToken) {
    var query = {user: userId};
    MongoClient.connect(url, function(err, db) {
        db.collection("tokenOwners").findOne(query, function(err, result) {
            if (err) throw err;
            //Token already exist
            if (result) {
                console.log(result);
                var updateQuery = {$set: {token: fcmToken}};
                db.collection("tokenOwners").update(query,updateQuery, {multi: true},function(err, res) {
                    if (err) throw err;
                    console.log(res.result.nModified + " document(s) updated");
                    if (res.result.nModified > 0) {
                        console.log("Updated user "+ userId +" token to a new value: "+fcmToken);
                    }
                    db.close();
                });
            } else {
                var tokenOwner = {"user": userId,"token":fcmToken};
                db.collection("tokenOwners").insertOne(tokenOwner, function(err, res) {
                    if (err) throw err;
                    console.log("Registered user "+userId+" with FCM token "+fcmToken);
                    db.close();
                });
            }
        })
    })
}


app.get('/', function(request, response) {
    response.send("Olride!");
});

// Menyimpan token_fcm dan id yang diberikan oleh client
app.post('/token/register', function(request, response) {
    var userId = parseInt(request.body.user,10);
    var fcmToken = request.body.token;
    var query = { user: userId };
    MongoClient.connect(url, function(err, db) {
        db.collection("tokenOwners").findOne(query, function(err, res) {
            var reply;
            if (err) throw err;
            if (res && (res.token === fcmToken)) {
                reply = "User "+ userId+ " with FCM token "+ fcmToken  +" already registered";
                console.log("User "+ userId+ " with FCM token "+ fcmToken  +" already registered");
            } else {
                reply = "Registered user "+userId+" with FCM token "+fcmToken;
                registerToken(userId,fcmToken);
            }
            response.send(reply);
            db.close();
        });
    })
});

// Mengirimkan pesan data ke FCM agar driver diarahkan ke chat
app.post('/driver/start', function(request, response) {
    var driverId = parseInt(request.body.driverId,10);
    var customerId = parseInt(request.body.customerId,10);
    var query = { user: driverId };
    var targetToken;

    MongoClient.connect(url, function(err, db) {
        db.collection("tokenOwners").findOne(query, function(err, res) {
            if (err) throw err;
            console.log("Finding FCM token for user "+ driverId);
            console.log(query);
            if (res) {
                targetToken = res.token;
                console.log("Found user's "+ driverId +" token "+ targetToken);

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
                            'title' : "You got a new order from customer",
                            'body' : customerId
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
                console.log('Initialize driver with id ' +  driverId + ' to open chatroom');

            } else {
                console.log("Can not find token for user "+ driverId);
            }
            db.close();
        });
    });
});


// Mengirimkan pesan data ke FCM agar status order menjadi selesai
app.post('/driver/finish', function(request, response) {
    var driverId = parseInt(request.body.driverId,10);
    var query = { user: driverId };
    var targetToken;

    MongoClient.connect(url, function(err, db) {
        db.collection("tokenOwners").findOne(query, function(err, res) {
            if (err) throw err;
            console.log("Finding FCM token for user "+ target);
            console.log(query);
            if (res) {
                targetToken = res.token;
                console.log("Found user's "+ driverId +" token "+ targetToken);

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
                            'title' : "Your customer has given you a new rating",
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
                console.log('Finish driver with id' +  driverId + ' chatroom session');
            } else {
                console.log("Can not find token for user "+ driverId);
            }
            db.close();
        });
    });

});


// Pemanggilan prosedur createChatroom melalui ajax request
app.post('/chatroom/create', function(request, response) {
    var participant1 = parseInt(request.body.participant1,10);
    var participant2 = parseInt(request.body.participant2,10);
    createChatroom(participant1,participant2);
    var query = { participants: [participant1,participant2] };
    MongoClient.connect(url, function(err, db) {
        db.collection("chatrooms").findOne(query,function(err, res) {
            if (err) console.error(err);
            console.log(res);
            response.send(JSON.stringify(res));
            db.close();
        })
    });
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
            var reply;
            if (res) {
                reply = JSON.stringify(res); 
            } else {
                reply = "Not available";
            }
            console.log(reply);
            response.send(reply);
            db.close();
        })
    });
});

// Handle pushing new message to database
app.post('/chatroom/push', function(request, response) {
    var chatId = request.body.chatId;
    var senderId = parseInt(request.body.sender,10);
    var content = request.body.content;
    pushToChatroom(chatId,senderId,content);
    response.send("receiving " + JSON.stringify(request.body));
});

// Menerima request untuk mengirimkan pesan ke :target, awalnya perlu dilakukan
// pencarian token_fcm milik akun :target, kemudian buat request ke fcm
app.post('/message/send/:target', function(request, response) {
    var target = parseInt(request.params.target);
    var query = { user: target };
    var targetToken;
    // Search destination token
    MongoClient.connect(url, function(err, db) {
        db.collection("tokenOwners").findOne(query, function(err, res) {
            if (err) throw err;
            console.log("Finding FCM token for user "+ target);
            console.log(query);
            if (res) {
                targetToken = res.token;
                console.log("Found user's "+ target +" token "+ targetToken);
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
            } else {
                console.log("Can not find token for user "+ target);
            }
            db.close();
        });
    })
    //targetToken = 'e0l50GH8TEU:APA91bG0VKYBu3OW5F5Lgmd64PzL0iJ0MdzaO4O4Ny33N_lYtUJzpT9MV1my6WwGKiLWrujfFC1T7oTBgzJqqGfEL9VbvLJbqcjaPv2LbqP_ZG9DCyMxGFJ8iWZf85mSO_8tQfO-fxLr';
    
});

app.listen(port, () => {
    console.log('Olride Chat Service is active on ' + port);
    MongoClient.connect(url, function(err, db) {
        if (err) throw err;
        db.createCollection("chatrooms", function(err, res) {
            if (err) throw err;
            console.log("chatrooms collection created!");
            
        });
        db.createCollection("tokenOwners", function(err, res) {
            if (err) throw err;
            console.log("tokenOwners collection created!");
            db.close();
        });
    }) 
});