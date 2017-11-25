<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.OjolServices.LocationManagerInterface" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.HttpURLConnection,java.net.URL"%>
<%
	/*if (request.getParameter("id") == null) {
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
	}*/
%>
<html>
<head>

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

	<title>Profile</title>
	<link rel="stylesheet" type="text/css" href="../css/new_style.css">
</head>
<body>

	<div class="container">
		<%@include file="../template/new_header.jsp"%>
		<script>
			var menu = document.getElementById("profile_link");
			menu.setAttribute("class", menu.getAttribute("class")+" active");
		</script>
		
		<div class="row">
			<div class="col-5"><h1>MY PROFILE</h1></div>
			<div class="col-1 text-right"><a class="edit" href="edit_profile.jsp?id=<%out.println(user.getId());%>"></a></div>
		</div> 
		
		<div class="text-center profile">
            <img class="img-circle" src="../IDServices/ImageRetriever?id=<% out.print(user.getId()); %>" onerror="this.src='../img/default_profile.jpeg'"><br>
            <h2>@<%out.print(user.getUsername()); %></h2>
            <p><%out.print(user.getFullname()); %></p>
			<% 	
				if (user.getStatus().equals("driver")) {
					float rating = 0;
					if (driver.getVotes() != 0) {
						rating = driver.getRating();
					}
					out.print("<p>Driver | <span class=\"text-orange\"><b><i class=\"icon icon-star\"></i> "+String.format("%.2f",rating)+"</b></span> ("+driver.getVotes()+" votes)</p>");
				} else {
					out.println("<p>Non-Driver</p>");
				}
			%>
			<p><i class="icon icon-mail"></i> <% out.print(user.getEmail()); %></p>
			<p><i class="icon icon-phone"></i> <% out.println(user.getPhone()); %></p>
		</div>
		
		<% 	
				if (user.getStatus().equals("driver")) { %>

		<div class="row">
			<div class="col-5"><h2>PREFERED LOCATIONS</h2></div>
            <div class="col-1 text-right"><a class="edit" href="edit_location.jsp?id=<%out.println(user.getId());%>"></a></div>
        </div>
        <div class="row location-list">
			<%	
				URL url = new URL("	http://localhost:8080/Olride/OjolServices/LocationManager?wsdl");
			
				QName qname = new QName("http://OjolServices.olride.com/", "LocationManagerService");
		
				Service service = Service.create(url, qname);
				LocationManagerInterface LM = service.getPort(LocationManagerInterface.class);
				if ("driver".equals(user.getStatus())) {
					int size = LM.retrieveLocation(driver.getId()).length;
					int bound = size;
					if (bound >= 3) {
						bound = 3;
					}
					StringBuilder builder = new StringBuilder();
					builder.append("<ul>");
					for (int i=0;i<bound;i++) {
						if (i != bound-1) {
							builder.append("<li style=\"margin-left: 0px\"><b>"+LM.retrieveLocation(driver.getId())[i]+"</b></li><ul>");
						} else {	
							builder.append("<li style=\"margin-left: 0px\"><b>"+LM.retrieveLocation(driver.getId())[i]+"</b></li>");
						}
					}
					for (int i=0;i<bound;i++) {
						builder.append("</ul>");
					}

					out.println(builder.toString());
				}	
			%>
		</div>

		<% } %>

	</div>


</body>
</html>
