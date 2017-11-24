<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.IDServices.*" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.*"%>

<html>
<head>
    <title>Order Chatroom</title>
    <link rel="stylesheet" type="text/css" href="css/new_style.css">
	<link rel="stylesheet" type="text/css" href="css/new_chat.css">
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.6/angular.min.js"></script>
	<link rel="manifest" href="/Olride/script/manifest.json">
	<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha256-k2WSCIexGzOj3Euiig+TlR8gA0EmPjuc79OEeY5L45g=" crossorigin="anonymous"></script>

</head>
<body>
    <div class="container">
		<script>
				var menu = document.getElementById("order_link");
        		menu.setAttribute("class", menu.getAttribute("class")+" active");
        </script>
        <div class="row">
            <div class="col-6"><h1>MAKE AN ORDER</h1></div>
        </div>
        <div class="row">
        <div style="width:25%; float:left">
                <div id="page-tab-location" class="page-tab">
                    <div class="page-tab-image">
                        <div class="circle">1</div>
                    </div>
                    <div class="page-tab-content">
                        Select Destination
                    </div>
                </div>
            </div>
            <div style="width:25%; float:left">
                <div id="page-tab-driver" class="page-tab">
                    <div class="page-tab-image">
                        <div class="circle">2</div>
                    </div>
                    <div class="page-tab-content">
                        Select a Driver
                    </div>
                </div>
            </div>
            <div style="width:25%; float:left">
                <div id="page-tab-finish" class="page-tab selected">
                    <div class="page-tab-image">
                        <div class="circle">3</div>
                    </div>
                    <div class="page-tab-content">
                        Chat Driver
                    </div>
                </div>
            </div>
            <div style="width:25%; float:left">
                <div id="page-tab-finish" class="page-tab">
                    <div class="page-tab-image">
                        <div class="circle">4</div>
                    </div>
                    <div class="page-tab-content">
                        Complete your order
                    </div>
                </div>
            </div>
        </div>
        <br>
        <br>
        
        <div id="driver-order-chat" class="row" ng-app="chatApp" ng-controller="chatController">
            <div class="col-6 chatarea" id="chatarea">
                <ul class="chatlist">
					<li ng-repeat="message in messages" ng-class="message.sender == 1 ? 'right' : 'left'">
                        <div>
                            <p>{{message.text}}</p>
                        </div>
                    </li>
                </ul>
            </div>
            <div class="col-6" style="outline: 1px solid black; height:49px">
                <div class="row">
                    <div class="col-5">
                        <textarea rows="3" cols="70" placeholder="Ketik pesanmu disini ..." style="resize:none;outline: 1px solid #ffffff00;box-sizing:border-box"></textarea>
                    </div>
                    <div class="col-1" style="padding-top:10px;box-sizing: border-box;">
                        <input id="btn-send-message" class="btn green" type="submit" value="Kirim" style="width:110px">
                    </div>
                </div>
            </div>
        </div>

		<br>
        <br>

		<div class="row text-center">
			<a id="btn-cancel" href="../order/order.jsp?id=1" onclick="return confirm('Apakah kamu yakin ingin membatalkan pesanan?');" class="btn red" style="width:150px; color:white; font-size:larger; padding: 10px 25px">CLOSE</a>
		</div>

		<br>
        <br>

    </div>
    
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-app.js"></script>
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-messaging.js"></script>
	<script src="https://cdn.firebase.com/libs/angularfire/2.3.0/angularfire.min.js"></script>
	<script>

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
		navigator.serviceWorker.register("/Olride/script/service-worker.js")
			.then((registration) => {
  			messaging.useServiceWorker(registration);
			messaging.requestPermission()
			.then(function() {
				console.log('Notification permission granted.');
				return messaging.getToken();
			})
			.then(function(currentToken) {
				console.log(currentToken);
			})
			.catch(function(err) {
				console.log('Error occured.', err);
			});

		});

		messaging.onMessage(function(payload) {
			console.log('onMessage :', payload);
		});

		var chatData = {
			id: 1,
			participants: [1,3],
			messages: [
				{
					sender : 1,
					text: "Hallo apa kabar!"
				},
				{
					sender : 3,
					text: "Iya kabar baik, ini siapa ya?"
				},
				{
					sender : 3,
					text: "Kamu user 1 bukan? kayaknya aku inget deh"
				},
				{
					sender : 1,
					text: "Iya kamu benar! sudah lama kita tidak berjumpa. Terakhir 1 bulan yang lalu sepertinya."
				},
			]
		};
	
		var app =  angular.module('chatApp',["firebase"]);
		app.controller('chatController', function($scope,$firebaseObject){
			// var ref = firebase.database().ref().child("messages");
			// var syncObject = $firebaseObject(ref);
			// syncObject.$bindTo($scope, "messages");

			$scope.messages = chatData.messages;

			// $('#chatarea').scrollTop($('#chatarea')[0].scrollHeight);
		});
	</script>

</body>
</html>
