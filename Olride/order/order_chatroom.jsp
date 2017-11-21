<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.IDServices.*" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.*"%>
<html>
<head>
	<title>Order Chatroom</title>
	<link rel="stylesheet" type="text/css" href="../css/default_style.css">
	<link rel="stylesheet" type="text/css" href="../css/order.css">
	<link rel="stylesheet" type="text/css" href="../css/header.css">
	<link rel="manifest" href="manifest.json">
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase.js"></script>
	<script src="https://cdn.firebase.com/js/client/2.3.2/firebase.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.6.6/angular.min.js"></script>
	<script src="https://cdn.firebase.com/libs/angularfire/2.3.0/angularfire.min.js"></script>
</head>
<body>
	<div class="frame">
		<div class="header">
			<%
				int id = 1;
				String address = "http://localhost:8080/Olride/IDServices/IdentityService";
				URL urlAddress = new URL(address);
				HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
				httpPost.setRequestMethod("POST");
				httpPost.setDoOutput(true);
				DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
				writer.writeBytes("action=getUser&id="+id);
				writer.flush();
				writer.close();
				BufferedReader buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
				String inputLine;
				StringBuilder res = new StringBuilder();
				int respCode = httpPost.getResponseCode();
				String respMsg = httpPost.getResponseMessage();
				while ((inputLine = buffer.readLine()) != null) {
					res.append(inputLine);
				}
				buffer.close();
				String uJson = res.toString();
				User user = new Gson().fromJson(uJson,User.class);
				Driver driver = new Driver();
				String dJson = null;
				if ("driver".equals(user.getStatus())) {
					httpPost = (HttpURLConnection) urlAddress.openConnection();
					httpPost.setRequestMethod("POST");
					httpPost.setDoOutput(true);
					writer = new DataOutputStream(httpPost.getOutputStream());
					writer.writeBytes("action=getDriver&id="+user.getId());
					writer.flush();
					writer.close();
					buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
					res = new StringBuilder();
					while ((inputLine = buffer.readLine()) != null) {
						res.append(inputLine);
					}
					dJson = res.toString();
					driver = new Gson().fromJson(dJson,Driver.class);
				}
			%>
			<%@include file="../template/header.jsp"%>
		</div>
		<div class="menu_container">
			<%@include file="../template/menu.jsp"%>
		</div>
		<script>
			document.getElementById("order_link").setAttribute("class", "menu menu_active");
		</script>
		<div class="order_container">
			<div class="subheader">
				<div class="title"><h1>Make an Order</h1></div>
			</div>
			<div class="submenu_container">
				<div class="submenu">
					<div class="step_num">
						<p>1</p>
					</div>
					<div class="step_name">
						<p>Select Destination</p>
					</div>
				</div>

				<div class="submenu">
					<div class="step_num">
						<p>2</p>
					</div>
					<div class="step_name">
						<p>Select a Driver</p>
					</div>
				</div>

				<div class="submenu  submenu_active">
					<div class="step_num">
						<p>3</p>
					</div>
					<div class="step_name">
						<p>Chat Driver</p>
					</div>
				</div>

				<div class="submenu">
					<div class="step_num">
						<p>4</p>
					</div>
					<div class="step_name">
						<p>Complete Order</p>
					</div>
				</div>
			</div>
			<div ng-app="chatApp" ng-controller="chatController">
				{{"AngularJS Loaded"}}
				<p> Firebase message:  </p>
				<p>{{messages.sent}} </p>
				<p>{{messages.reply}}</p>
			</div>
		</div>
	</div>
</body>
<script>
	var config = {
    	apiKey: "AIzaSyB0KWompT2YoRR99caQcanuxSr-ag5Z6-k",
    	authDomain: "olride-69182.firebaseapp.com",
    	databaseURL: "https://olride-69182.firebaseio.com",
    	storageBucket: "olride-69182.appspot.com",
    	messagingSenderId: "679619512375"
  	};
  	firebase.initializeApp(config);
  	const messaging = firebase.messaging();
  	messaging.requestPermission()
		.then(function() {
  			console.log('Notification permission granted.');
  			// TODO(developer): Retrieve an Instance ID token for use with FCM.
  			// ...
			})
		.catch(function(err) {
  			console.log('Unable to get permission to notify.', err);
		});


	var app =  angular.module('chatApp',["firebase"]);
	app.controller('chatController', function($scope,$firebaseObject){
  		var ref = firebase.database().ref().child("messages");
  		var syncObject = $firebaseObject(ref);
 		syncObject.$bindTo($scope, "messages");
 	});
</script>
</html>
