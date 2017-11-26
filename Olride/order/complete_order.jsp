<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.IDServices.*,com.olride.OjolServices.LocationManagerInterface" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.HttpURLConnection,java.net.URL"%>
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
<!DOCTYPE html>
<html>
<head>
	<title>Complete Your Order</title>
	<link rel="stylesheet" type="text/css" href="../css/new_style.css">

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
		String pickLoc = request.getParameter("pickLoc");
		String destLoc = request.getParameter("destLoc");
		int selectedDriverID = Integer.parseInt(request.getParameter("selected_driver"));
		httpPost = (HttpURLConnection) urlAddress.openConnection();
		httpPost.setRequestMethod("POST");
		httpPost.setDoOutput(true);
		writer = new DataOutputStream(httpPost.getOutputStream());
		writer.writeBytes("action=getUser&id="+selectedDriverID);
		writer.flush();
		writer.close();
		buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
		res = new StringBuilder();
		while ((inputLine = buffer.readLine()) != null) {
			res.append(inputLine);
		}
		buffer.close();
		String selectedDriverJson =  res.toString();
		User selectedDriver = new User();
		selectedDriver = new Gson().fromJson(selectedDriverJson,User.class);
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
					<div id="page-tab-finish" class="page-tab">
						<div class="page-tab-image">
							<div class="circle">3</div>
						</div>
						<div class="page-tab-content">
							Chat Driver
						</div>
					</div>
				</div>
				<div style="width:25%; float:left">
					<div id="page-tab-finish" class="page-tab selected">
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

			<div id="order-page-finish" style="width: 100%;">
				<h2 style="margin-left: 10px; margin-top: 0px">HOW WAS IT? </h2>
				<div id="driver-finish-order" class="text-center profil" style="padding-bottom: 60px">
					<img class="img-circle" src="../IDServices/ImageRetriever?id=<% out.print(selectedDriver.getId()); %>" onerror="this.src='../img/default_profile.jpeg'"><br>
					<h2 style="margin-bottom: 0px">@<%out.print(selectedDriver.getUsername()); %></h2>
					<p style="margin-top: 10px"><%out.print(selectedDriver.getFullname()); %></p>
					<i id="star-1" class="icon icon-star-full big" onclick="rate1()"></i>
					<i id="star-2" class="icon icon-star-full big" onclick="rate2()"></i>
					<i id="star-3" class="icon icon-star-full big" onclick="rate3()"></i>
					<i id="star-4" class="icon icon-star-full big" onclick="rate4()"></i>
					<i id="star-5" class="icon icon-star-full big" onclick="rate5()"></i>
					<form id="submit_cmplt_ordr" method="POST" action="../IDServices/IdentityService">
						<input type="hidden" name="rating" id="rating" value="0">
						<input type="hidden" name="id" value=<%out.println(user.getId()); %>>
						<input type="hidden" name="pickLoc" value=<%out.println(pickLoc);%>>
						<input type="hidden" name="destLoc" value='<%out.println(destLoc);%>'>
						<input type="hidden" name="selected_driver" value=<%out.println(selectedDriverID);%>>
						<input type="hidden" name="action" value="completeOrder">
						<br>
						<br>
						<br>
						<textarea id="comment" name="comment" form="submit_cmplt_ordr" style="width: 90%; height: 100px; padding: 10px; resize: none" placeholder="Your comment..." ></textarea>
						<input class="btn green" style="float: right; margin: 30px" type="submit" name="submit" value="COMPLETE ORDER">
					</form>
				</div>
			</div> 
		</div>

		<script type="text/javascript">
			var star1 = document.getElementById('1-star');
			var star2 = document.getElementById('2-star');
			var star3 = document.getElementById('3-star');
			var star4 = document.getElementById('4-star');
			var	star5 = document.getElementById('5-star');
			var rate = document.getElementById('rating');

			function rate1() {
				rate.value = 1;
				setRating(1);
			}	
			function rate2() {
				rate.value = 2;
				setRating(2);
			}
			function rate3() {
				rate.value = 3;
				setRating(3);
			}
			function rate4() {
				rate.value = 4;
				setRating(4);
			}
			function rate5() {
				rate.value = 5;
				setRating(5);
			}	

			function setRating(val) {
				for (var i = 1; i <= 5; i++) {
					if (i <= val) {
						document.getElementById('star-'+i).style.color = "orange";
					} else {
						document.getElementById('star-'+i).style.color = "#c2c2c2";
					}
				}
			}


		</script>
	</div>
</body>
</html>
