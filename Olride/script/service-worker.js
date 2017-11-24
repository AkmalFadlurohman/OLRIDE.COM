importScripts('https://www.gstatic.com/firebasejs/4.1.3/firebase-app.js')
importScripts('https://www.gstatic.com/firebasejs/4.1.3/firebase-messaging.js')

var config = {
    apiKey: "AIzaSyB0KWompT2YoRR99caQcanuxSr-ag5Z6-k",
    authDomain: "olride-69182.firebaseapp.com",
    databaseURL: "https://olride-69182.firebaseio.com",
    projectId: "olride-69182",
    storageBucket: "olride-69182.appspot.com",
    messagingSenderId: "679619512375"
};
firebase.initializeApp(config);

const messaging = firebase.messaging();