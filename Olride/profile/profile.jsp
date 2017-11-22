<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.OjolServices.LocationManagerInterface" %>
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
		if ("forbidden".equals(msg)) {
			response.sendRedirect("../IDServices/Logout?action=forbid&id="+id);
		}
	}
%>
<html>
<head>
    <title>Profile</title>
    <link rel="stylesheet" type="text/css" href="../css/default_style.css">
    <link rel="stylesheet" type="text/css" href="../css/profile.css">
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
            <script>
                document.getElementById("profile_link").setAttribute("class", "menu menu_active");
            </script>
        </div>
        <div class="profile_container">
            <div class="subheader">
                <div class="title"><h1>My Profile</h1></div>
                <div class="edit_profile_button"><a href='edit_profile.jsp?id=<%out.println(user.getId());%>'>✎</a></div>
            </div>
            <div class="profile_info_container">
                <img class="profile_pict_frame" id="profile_pict" src="../IDServices/ImageRetriever?id=<% out.println(user.getId()); %>" onerror="this.src='../img/default_profile.jpeg'">
                <div class="profile_data_container">
                		<div class='username_display'><strong>@<%out.println(user.getUsername()); %></strong></div>
                   	<p><%out.println(user.getFullname()); %></p>
                     <% if (user.getStatus().equals("driver")) {
                            out.println("<p>Driver | <span style='color : #f9880e'>☆<span id='driver_rating'>Rating</span></span> (<span id='driver_votes'>(xxx Votes)</span> votes)</p>");
                            float rating = 0;
                            if (driver.getVotes() != 0) {
                            		rating = driver.getRating();
                            }
                            out.println("<script>document.getElementById('driver_rating').innerHTML = "+String.format("%.3f",rating)+";</script>");
                            out.println("<script>document.getElementById('driver_votes').innerHTML ="+driver.getVotes()+";</script>");
                        } else {
                           	out.println("<p>Non-Driver</p>");
                        }
                     %>
                     <p>✉<% out.println(user.getEmail()); %></p>
                     <p>☏<% out.println(user.getPhone()); %></p>
                </div>
            	</div>
            	<div id="display_prefloc" class="prefloc_container">
            		<% 	if (!user.getStatus().equals("driver")) {
                    		out.println("<script>document.getElementById('display_prefloc').style.display = 'none';</script>");
                		}
           		%>
            		<div class="subheader">
                		<div class="title"><h1>Preferred Locations</h1></div>
                		<div class="edit_prefloc_button"><a href='edit_location.jsp?id=<%out.println(user.getId());%>'>✎</a></div>
            		</div>
            		<div class="prefloc_list">
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
            							builder.append("<li>►"+LM.retrieveLocation(driver.getId())[i]+"</li><ul>");
            						} else {	
            							builder.append("<li>►"+LM.retrieveLocation(driver.getId())[i]+"</li>");
            						}
            					}
            					for (int i=0;i<bound;i++) {
            						builder.append("</ul>");
            					}
            					out.println(builder.toString());
            				}	
            			%>
            		</div>
       		</div>    
        </div>
        
	</div>
</body>
</html>
