<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.IDServices.*" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.*"%>
<%
	if (request.getParameter("id") == null) {
		request.setAttribute("script","<script>document.getElementById(\"requireLogin\").innerHTML=\"Please login using your username and password first!\";</script>");
		request.getRequestDispatcher("../login/login.jsp").forward(request,response);
	}
	int id = Integer.parseInt(request.getParameter("id"));
	Cookie cookies[] = request.getCookies();
	int j = 0;
	boolean exist = false;
	while (!exist && j<cookies.length) {
		if ("token".equals(cookies[j].getName())) {
			exist = true;
		} else {
			j++;
		}
	}
	if (!exist) {
		request.setAttribute("script","<script>document.getElementById(\"requireLogin\").innerHTML=\"Please login using your username and password first!\";</script>");
		request.getRequestDispatcher("../login/login.jsp").forward(request,response);
	} else {
		URL ipChecker = new URL("http://checkip.amazonaws.com");
		BufferedReader reader = new BufferedReader(new InputStreamReader(ipChecker.openStream()));
		String ipAddress = reader.readLine();
		String userAgent = request.getHeader("User-Agent");

		String token = cookies[j].getValue();
		String address = "http://localhost:8080/Olride/IDServices/IdentityService";
		URL urlAddress = new URL(address);
		HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
		httpPost.setRequestMethod("POST");
		httpPost.setDoOutput(true);
		DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
		writer.writeBytes("action=validateAccess&id="+id+"&token="+token+"&agent="+userAgent+"&ip="+ipAddress);
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
		String msg = res.toString();
		if ("forbidden".equals(msg)) {
			response.sendRedirect("../IDServices/Logout?action=forbid&id="+id);
		}
	}
%>
<html>
<head>
    <title>Order Chatroom</title>
    <link rel="stylesheet" type="text/css" href="../css/new_style.css">
	<link rel="stylesheet" type="text/css" href="../css/new_chat.css">
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.6/angular.min.js"></script>
	<link rel="manifest" href="/Olride/script/manifest.json">
	<script src="https://code.jquery.com/jquery-3.2.1.min.js" integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4=" crossorigin="anonymous"></script>

	<%
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

	<%
		int driverId = Integer.parseInt(request.getParameter("selected_driver"));
	%>

</head>
<body>
    <div class="container">
        <%@include file="../template/new_header.jsp"%>
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
					<li ng-repeat="message in messages" ng-class="message.sender == <%out.println(id);%> ? 'right' : 'left'">
                        <div>
                            <p>{{message.text}}</p>
                        </div>
                    </li>
                </ul>
            </div>
            <div class="col-6" style="outline: 1px solid black; height:49px">
                <div class="row">
                    <div class="col-5">
                        <textarea id="chat-textarea" rows="3" cols="70" placeholder="Ketik pesanmu disini ..." style="resize:none;outline: 1px solid #ffffff00;box-sizing:border-box"></textarea>
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
			<a id="btn-cancel" href="../order/order.jsp?id=<%out.println(user.getId());%>" onclick="return confirm('Apakah kamu yakin ingin membatalkan pesanan?');" class="btn red" style="width:150px; color:white; font-size:larger; padding: 10px 25px">CLOSE</a>
		</div>

		<br>
        <br>

    </div>
    
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-app.js"></script>
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-messaging.js"></script>
	<script src="https://cdn.firebase.com/libs/angularfire/2.3.0/angularfire.min.js"></script>

	<script>
		var myId = <%out.println(id);%>;
		var otherId = <%out.println(driverId);%>;

		// Preparing Angular ---------------------------------------------------------
		var chatData = {
			id: 1,
			participants: [1,3],
			messages: []
		};
	
		var app =  angular.module('chatApp', ['firebase']);
		app.controller('chatController', function($scope,$firebaseObject){
			$scope.messages = chatData.messages;
			scrollDown();
		});

		// Preparing FCM -----------------------------------------------------------------
		var fcmToken = null;
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
				fcmToken = currentToken;
			})
			.catch(function(err) {
				console.log('Error occured.', err);
			});

		});

		messaging.onMessage(function(payload) {
			var scope = angular.element($("#driver-order-chat")).scope();
    		scope.$apply(function() {
				scope.messages.push({
					sender: otherId,
					text: payload.notification.body
				});
				scrollDown();
    		})
		});

		// Handle user click in Send button
		$('#btn-send-message').click(function() {
			sendMessage(1);
		});

		// Handle user click enter in chat textarea
		$("#chat-textarea").keypress(function (e) {
			if(e.which == 13) {
				sendMessage(1);
			}
    	});

		function sendMessage(uid) {
			var msg = $('#chat-textarea').val().trim();
			if (msg) {
				$.ajax({
					type: 'POST',
					url: 'http://localhost:8123/message/send/' + uid,
					data: {
						token: fcmToken,
						text: msg
					},
					success: function(responseData, textStatus, jqXHR) {
						var value = responseData.someKey;
						var scope = angular.element($("#driver-order-chat")).scope();
						scope.$apply(function() {
							scope.messages.push({
								sender: myId,
								text: msg
							});
							$('#chat-textarea').val('');
							scrollDown();
						})
					},
					error: function (responseData, textStatus, errorThrown) {
						alert('POST failed.');
					},
				});
			} else {
				alert('Message is empty!');
			}
		}

		function scrollDown() {
			setTimeout(function() {
				$('#chatarea').scrollTop($('#chatarea')[0].scrollHeight);
			}, 30);
		}

	</script>

</body>
</html>
