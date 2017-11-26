<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson" %>
<%@ page import="java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.IDServices.*" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.*"%>
<html>
<head>
	<% 
		if (request.getParameter("id") == null) {
			request.setAttribute("script","<script>document.getElementById(\"requireLogin\").innerHTML=\"Please login using your username and password first!\";</script>");
			request.getRequestDispatcher("../login/login.jsp").forward(request,response);
		}
		int id = Integer.parseInt(request.getParameter("id"));

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
		if (!"driver".equals(user.getStatus())) {
			response.sendRedirect("select_location.jsp?id="+id);
		}
		String action = request.getParameter("action");
		Driver driver = new Driver();
		if ("setDriverStatusOff".equals(action)) {
			httpPost = (HttpURLConnection) urlAddress.openConnection();
            httpPost.setRequestMethod("POST");
            httpPost.setDoOutput(true);
            writer = new DataOutputStream(httpPost.getOutputStream());
            writer.writeBytes("action=setDriverStatusOff&id="+user.getId());
            writer.flush();
            writer.close();
            buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
            res = new StringBuilder();
            while ((inputLine = buffer.readLine()) != null) {
                res.append(inputLine);
            }
            String dJson = res.toString();
            driver = new Gson().fromJson(dJson,Driver.class);
        }
	%>
	<title>Finding Order</title>
	<link rel="stylesheet" type="text/css" href="../css/new_style.css">
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.6/angular.min.js"></script>
	<link rel="manifest" href="/Olride/script/manifest.json">
	<script src="https://code.jquery.com/jquery-3.2.1.min.js" integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4=" crossorigin="anonymous"></script>
</head>
<body>
	<div class="container">
        <%@include file="../template/new_header.jsp"%>
		<script>
				var menu = document.getElementById("order_link");
        		menu.setAttribute("class", menu.getAttribute("class")+" active");
        </script>
        <div class="row">
            <div class="col-6"><h1>LOOKING FOR AN ORDER</h1></div>
		</div>
		<div id="driver-order-start" class="row">
            <br>
            <br>
            <br>
            <br>
            <br>
            <br>
            <br>
            <br>
            <div class="col-6 text-center">
                <a id="btn-find-order" href="/Olride/order/order_waiting.jsp?id=<%out.print(id);%>" class="btn green" style="padding: 15px 25px" >Find Order</a>
            </div>
        </div>
	</div>
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-app.js"></script>
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-messaging.js"></script>
	
	<script type="text/javascript">
		var myId = <%out.println(id);%>;
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
				console.log('Messaging permission granted.');
				return messaging.getToken();
			})
			.then(function(currentToken) {
				console.log(currentToken);
				fcmToken = currentToken;
				registerToken(myId,fcmToken);
			})
			.catch(function(err) {
				console.log('Error occured.', err);
			});

		});
		$('#btn-find-order').click(function() {
			
		});
		function registerToken(userId,fcmToken) {
			$.ajax({
				type: 'POST',
				url: 'http://localhost:8123/token/register',
				data: {
					user: userId,
					token: fcmToken
				},
				success: function(responseData, textStatus, jqXHR) {
					var value = responseData.someKey;
				},
				error: function (responseData, textStatus, errorThrown) {
					alert('POST failed.');
				},
			});
		}
	</script>
</body>
</html>
