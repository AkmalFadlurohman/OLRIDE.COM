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
		if ("expired".equals(msg)) {
			response.sendRedirect("../IDServices/Logout?action=expire&id="+id);
		} else if ("forbidden".equals(msg)) {
			response.sendRedirect("../IDServices/Logout?action=forbid&id="+id);
		}
	}
%>
<html>
<head>
    <title>Customer Chatroom</title>
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
		String pickLoc = request.getParameter("pickLoc");
		String destLoc = request.getParameter("destLoc");
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
        <div id="driver-order-chat" class="row" ng-app="chatApp" ng-controller="chatController" data-ng-init="initChatroom(myId,driverId)">
            <div class="col-6 chatarea" id="chatarea">
                <ul class="chatlist">
					<li ng-repeat="message in chatRoom.messages" ng-class="message.sender == <%out.println(id);%> ? 'right' : 'left'">
                        <div>
                            <p>{{message.content}}</p>
                        </div>
                    </li>
                </ul>
            </div>
            <div class="col-6" style="outline: 1px solid black; height:57px">
                <div class="row">
                    <div class="col-5">
                        <textarea id="chat-textarea" rows="4" cols="70" placeholder="Type your message here ..." style="resize:none;outline: 1px solid #ffffff00;box-sizing:border-box"></textarea>
                    </div>
                    <div class="col-1" style="padding-top:10px;box-sizing: border-box;">
                        <input id="btn-send-message" class="btn green" type="submit" value="Send" style="width:110px">
                    </div>
                </div>
            </div>
        </div>
		<br>
        <br>

		<div class="row text-center">
			<form method="post"  action="complete_order.jsp">
				<input type="hidden" name="id" value=<%out.print(user.getId()); %>>
				<input type="hidden" name="pickLoc" value=<%out.print(pickLoc);%>>
				<input type="hidden" name="destLoc" value=<%out.print(destLoc);%>>
				<input type="hidden" name="selected_driver" value=<%out.print(driverId);%>>
				<input id="btn-cancel" class="btn red" type="submit" value="CLOSE" onclick="return confirm('Are you sure you want to finish chatting with your driver?');" style="width:150px; color:white; font-size:larger; padding: 10px 25px">
			</form>
		</div>

		<br>
        <br>

    </div>
    
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-app.js"></script>
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-messaging.js"></script>
	<script src="https://cdn.firebase.com/libs/angularfire/2.3.0/angularfire.min.js"></script>

	<script>
		var myId = <%out.println(id);%>;
		var driverId = <%out.println(driverId);%>;

		// Preparing Angular ---------------------------------------------------------
	
		var app =  angular.module('chatApp', ['firebase']);
		app.controller('chatController', function($scope,$firebaseObject,$http){
			$scope.myId = <%out.println(id);%>;
			$scope.driverId = <%out.println(driverId);%>;
			$scope.message = null;
			$scope.chatRoom = null;

			$scope.initChatroom = function (participant1,participant2) {
				var data = {
					participant1: participant1,
					participant2: participant2
				};
				$http.post('http://localhost:8123/chatroom/fetch', JSON.stringify(data)).then(
				function (response) {
					if (response.data === "Not available") {
						createChatroom(participant1,participant2);
					} else {
						$scope.chatRoom = response.data;
					}
				});
			};
			var createChatroom = function (participant1,participant2) {
				var data = {
					participant1: participant1,
					participant2: participant2
				};
				$http.post('http://localhost:8123/chatroom/create', JSON.stringify(data)).then(
				function (response) {
					if (response.data) {
						$scope.chatRoom = response.data;
					}
				});
			};
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
				scope.chatRoom.messages.push({
                    sender: driverId,
                    content: payload.notification.body
                });
                scrollDown();
    		})
		});

		// Handle user click in Send button
		$('#btn-send-message').click(function() {
			sendMessage(driverId);
		});

		// Handle user click enter in chat textarea
		$("#chat-textarea").keypress(function (e) {
			if(e.which == 13) {
				sendMessage(driverId);
			}
    	});

		function sendMessage(uid) {
			var msg = $('#chat-textarea').val().trim();
			if (msg) {
				var scope = angular.element($("#driver-order-chat")).scope();
				$.ajax({
					type: 'POST',
					url: 'http://localhost:8123/message/send/' + uid,
					data: {
						token: fcmToken,
						text: msg
					},
					success: function(responseData, textStatus, jqXHR) {
						var value = responseData.someKey;
					},
					error: function (responseData, textStatus, errorThrown) {
						alert('POST failed.');
					},
				});
				$.ajax({
					type: 'POST',
					url: 'http://localhost:8123/chatroom/push',
					data: {
						chatId: scope.chatRoom._id,
						sender: myId,
						content: msg
					},
					success: function(responseData, textStatus, jqXHR) {
						var value = responseData.someKey;
						scope.$apply(function() {
							scope.chatRoom.messages.push({
								sender: myId,
								content: msg
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
