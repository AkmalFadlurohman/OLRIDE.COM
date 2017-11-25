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
	<link rel="stylesheet" type="text/css" href="../css/default_style.css">
	<link rel="stylesheet" type="text/css" href="../css/order.css">
	<link rel="stylesheet" type="text/css" href="../css/header.css">
</head>
<body>
	<div class="frame">
		<div class="header">
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

				<div class="submenu">
					<div class="step_num">
						<p>3</p>
					</div>
					<div class="step_name">
						<p>Chat Driver</p>
					</div>
				</div>

				<div class="submenu submenu_active">
					<div class="step_num">
						<p>4</p>
					</div>
					<div class="step_name">
						<p>Complete Order</p>
					</div>
				</div>
			</div>


			<form id="submit_cmplt_ordr" method="POST" action="../IDServices/IdentityService">
				<div class="content" id="complete_order">
					<h2>How was it?</h2>
					<div id="driver_profile">
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
						<img class='driver_pict' src="../IDServices/ImageRetriever?id=<% out.println(selectedDriver.getId()); %>" onerror="this.src='../img/default_profile.jpeg'">
						<p>@<%out.println(selectedDriver.getUsername()); %></p>
						<p><%out.println(selectedDriver.getFullname()); %></p>
					</div>
					<div class="rating_bar" style="background-color: rgba(0,255,0,0.2);">
						<span class="star" id="1-star" onclick="rate1()">&starf;</span>
						<span class="star" id="2-star" onclick="rate2()">&starf;</span>
						<span class="star" id="3-star" onclick="rate3()">&starf;</span>
						<span class="star" id="4-star" onclick="rate4()">&starf;</span>
						<span class="star" id="5-star" onclick="rate5()">&starf;</span>
						<input type="hidden" name="rating" id="rating">
					</div>
					<textarea id="comment" name="comment" form="submit_cmplt_ordr" rows="8" cols="35" placeholder="Your comment..."></textarea>
					<input type="hidden" name="id" value=<%out.println(user.getId()); %>>
					<input type="hidden" name="pickLoc" value=<%out.println(pickLoc);%>>
					<input type="hidden" name="destLoc" value='<%out.println(destLoc);%>'>
					<input type="hidden" name="selected_driver" value=<%out.println(selectedDriverID);%>>
					<input type="hidden" name="action" value="completeOrder">
					<div id="finish_button_container">
						<input id="finish_button" class="button green" type="submit" name="submit" value="Complete Order">
					</div>
				</div>
			</form>
		</div>
	</div>
</body>
<script type="text/javascript">
	var star1 = document.getElementById('1-star');
	var star2 = document.getElementById('2-star');
	var star3 = document.getElementById('3-star');
	var star4 = document.getElementById('4-star');
	var	star5 = document.getElementById('5-star');
	var rate = document.getElementById('rating');

	rate3();

	function rate1() {
		rate.value = 1;
		light1();
	}	
	function rate2() {
		rate.value = 2;
		light2();
	}
	function rate3() {
		rate.value = 3;
		light3();
	}
	function rate4() {
		rate.value = 4;
		light4();
	}
	function rate5() {
		rate.value = 5;
		light5();
	}	

	function light1() {
		rate.value = 1;
		star1.style.color = "yellow";
		star2.style.color = "gray";
		star3.style.color = "gray";
		star4.style.color = "gray";
		star5.style.color = "gray";
	}
	function light2() {
		rate.value = 2;
		star1.style.color = "yellow";
		star2.style.color = "yellow";
		star3.style.color = "gray";
		star4.style.color = "gray";
		star5.style.color = "gray";
	}
	function light3() {
		rate.value = 3;
		star1.style.color = "yellow";
		star2.style.color = "yellow";
		star3.style.color = "yellow";
		star4.style.color = "gray";
		star5.style.color = "gray";
	}
	function light4() {
		rate.value = 4;
		star1.style.color = "yellow";
		star2.style.color = "yellow";
		star3.style.color = "yellow";
		star4.style.color = "yellow";
		star5.style.color = "gray";
	}
	function light5() {
		rate.value = 5;
		star1.style.color = "yellow";
		star2.style.color = "yellow";
		star3.style.color = "yellow";
		star4.style.color = "yellow";
		star5.style.color = "yellow";
	}

</script>
</html>
