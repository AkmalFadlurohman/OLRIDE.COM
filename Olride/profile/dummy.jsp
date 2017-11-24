<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.OjolServices.LocationManagerInterface" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.HttpURLConnection,java.net.URL"%>
<html>
<head>
    <title>Profile</title>
    <link rel="stylesheet" type="text/css" href="../css/default_style.css">
    <link rel="stylesheet" type="text/css" href="../css/profile.css">
    <link rel="stylesheet" type="text/css" href="../css/header.css">
    <script src="https://www.gstatic.com/firebasejs/4.6.2/firebase.js"></script>
	<script src="https://cdn.firebase.com/js/client/2.3.2/firebase.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.6.6/angular.min.js"></script>
	<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha256-k2WSCIexGzOj3Euiig+TlR8gA0EmPjuc79OEeY5L45g=" crossorigin="anonymous"></script>
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
            <script>
                document.getElementById("profile_link").setAttribute("class", "menu menu_active");
            </script>
        </div>
    	<div class="profile_container">
    		<div ng-app="chatApp" ng-controller="chatController">
    			<div>
					First Participant : <input ng-model="participant1" /><br/><br/>
					Second Participant : <input ng-model="participant2" /><br/><br/>
					<input type="button" value="Send" ng-click="fetch(participant1, participant2)" />
				</div>
       			<p>Output Message : {{msg}}</p>
       		</div>
        </div>
        <script>
			var app =  angular.module('chatApp',[]);
			app.controller('chatController', function($scope,$http){
				$scope.participant1 = null;
				$scope.participant2 = null;
				$scope.chatId = null;
				$scope.fetch = function (participant1,participant2) {
					var data = {
						participant1: participant1,
						participant2: participant2
					};
					$http.post('http://localhost:8123/chatroom/fetch', JSON.stringify(data)).then(
					function (response) {
						if (response.data) $scope.msg = response.data;
					}, function (response) {
						$scope.msg = "Service not Exists";
					});
				};
				$scope.create = function (participant1,participant2) {
					var data = {
						participant1: participant1,
						participant2: participant2
					};
					$http.post('http://localhost:8123/chatroom/create', JSON.stringify(data)).then(
					function (response) {
						if (response.data) $scope.msg = response.data;
					}, function (response) {
						$scope.msg = "Service not Exists";
					});
				};
				$scope.push = function (chatId,senderId,content) {
					var data = {
						chatId: chatId,
						senderId: senderId,
						content: content
					};
					$http.post('http://localhost:8123/chatroom/push', JSON.stringify(data)).then(
					function (response) {
						if (response.data) $scope.msg = response.data;
					}, function (response) {
						$scope.msg = "Service not Exists";
					});
				};
			});
	</script>
	</div>
</body>
</html>
