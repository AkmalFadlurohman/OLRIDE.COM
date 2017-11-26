<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.*,com.olride.bean.*,com.olride.OjolServices.OrderManagerInterface,com.olride.IDServices.*" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.HttpURLConnection,java.net.URL"%>
<%
	if (request.getParameter("id") == null) {
		request.setAttribute("script","<script>document.getElementById(\"requireLogin\").innerHTML=\"Please login using your username and password first!\";</script>");
		request.getRequestDispatcher("../login/login.jsp").forward(request,response);
	}
	int id = Integer.parseInt(request.getParameter("id"));
	Cookie cookies[] = request.getCookies();
	int k = 0;
	boolean exist = false;
	while (!exist && k<cookies.length) {
		if ("token".equals(cookies[k].getName())) {
			exist = true;
		} else {
			k++;
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

		String token = cookies[k].getValue();
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
		int resCode = httpPost.getResponseCode();
		String resMsg = httpPost.getResponseMessage();
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
		URL url = new URL("	http://localhost:8080/Olride/OjolServices/OrderManager?wsdl");
	
		QName qname = new QName("http://OjolServices.olride.com/", "OrderManagerService");

		Service service = Service.create(url, qname);
		OrderManagerInterface OM = service.getPort(OrderManagerInterface.class);
		
		int size = OM.getListOrderCustomer(user.getId()).length;
	%>

	<title>Previous Order History</title>
	<link rel="stylesheet" type="text/css" href="../css/new_style.css">
    </script>
</head>
<body>
	<div class="container">
		<%@include file="../template/new_header.jsp"%>
		<script>
			var menu = document.getElementById("history_link");
			menu.setAttribute("class", menu.getAttribute("class")+" active");
		</script>
		
		<div class="row">
			<div class="col-5"><h1>TRANSACTION HISTORY</h1></div>
		</div> 


		<div class="row">
			<div class="col-3">
				<div id="page-tab-customer" class="tab text-center active">
					<div class="page-tab-content">
						MY PREVIOUS ORDER
					</div>
				</div>
			</div>
			<div class="col-3">
				<div id="page-tab-driver" class="tab text-center" onclick="window.location.href='http://www.google.com/'">
					<div class="page-tab-content">
						DRIVER HISTORY
					</div>
				</div>
			</div>
		</div>
		<br>
		<br>

		<div id="history-page-customer">
				<% 
					if(size == 0) {
						out.print("<p id=\"driver-search-result\" class=\"text-center\" style=\"font-size: large; color: #989898; margin: 30px\">Nothing to display :(</p>");
					} else {
						for (int i=0;i<size;i++) {
							if ("visible".equals(OM.getListOrderCustomer(user.getId())[i].getCustomerVisibility())) {
								httpPost = (HttpURLConnection) urlAddress.openConnection();
								httpPost.setRequestMethod("POST");
								httpPost.setDoOutput(true);
								writer = new DataOutputStream(httpPost.getOutputStream());
								writer.writeBytes("action=getUser&id="+OM.getListOrderCustomer(user.getId())[i].getDriverId());
								writer.flush();
								writer.close();
								int respCode = httpPost.getResponseCode();
								String respMsg = httpPost.getResponseMessage();
								buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
								res = new StringBuilder();
								while ((inputLine = buffer.readLine()) != null) {
									res.append(inputLine);
								}
								buffer.close();
								String driverJson = res.toString();
								User d = new User();
								d = new Gson().fromJson(driverJson.trim(),User.class);

								String stars = "";
								for (int j = 0; j < OM.getListOrderCustomer(user.getId())[i].getScore(); j++) {
										stars += "<span style='color:orange'>&starf;</span>";
								}
								out.print(""+
								"<div class='row'>"+
								"	<img src='../IDServices/ImageRetriever?id="+d.getId()+"' onerror=\"this.src='../img/default_profile.jpeg'\" style='float: left; border: 1px solid black; margin: 10px' width='120' height='125'>"+
								"	<form method='POST' action='../IDServices/IdentityService'>" +
								"		<input type='hidden' name='action' value='hideOrder'>" +
								"		<input type='hidden' name='id' value="+user.getId()+">" +
								"		<input type='hidden' name='hideAs' value='customer'>" +
								"		<input type='hidden' name='orderID' value='"+OM.getListOrderCustomer(user.getId())[i].getOrderId()+"'>" +
								"		<input type='submit' class='btn red' value='HIDE' style='float: right; margin: 10px'>" +
								"	</form>" +
								"	<p style='margin-bottom:0px'>Sunday, September 24th 2017</p>"+
								"	<h3 style='margin:0px'>Joko Anwar</h3>"+
								"	<small>"+OM.getListOrderCustomer(user.getId())[i].getPickLoc()+" - "+OM.getListOrderCustomer(user.getId())[i].getDestLoc()+"</small><br><br>"+
								"	You rated: " + stars +
								"	<br>You commented:<br>"+
								"	<p style='margin:0px 170px;'><small>"+OM.getListOrderCustomer(user.getId())[i].getComment()+"</small></p>"+
								"</div><br>");

							}
						}	
					}
				%>
			</div>
		</div>
	</div>

</body>
</html>

