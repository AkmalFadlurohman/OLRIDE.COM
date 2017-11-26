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
	
		int size = OM.getListOrderDriver(user.getId()).length;
	%>

    <title>Driver History</title>
    <link rel="stylesheet" type="text/css" href="../css/new_style.css">
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
				<div id="page-tab-customer" class="tab text-center" onclick="window.location.href='/Olride/history/transaction_history.jsp?id=<%out.print(id);%>'">
					<div class="page-tab-content">
						MY PREVIOUS ORDER
					</div>
				</div>
			</div>
			<div class="col-3">
				<div id="page-tab-driver" class="tab text-center active" onclick="window.location.href='/Olride/history/driver_history.jsp?id=<%out.print(id);%>'">
					<div class="page-tab-content">
						DRIVER HISTORY
					</div>
				</div>
			</div>
		</div>
		<br>
		<br>

		<div id="history-page-driver">
			<% 
				if(size == 0) {
					out.print("<p id=\"driver-search-result\" class=\"text-center\" style=\"font-size: large; color: #989898; margin: 30px\">Nothing to display :(</p>");
				} else {
					for (int i=0;i<size;i++) {
						if ("visible".equals(OM.getListOrderDriver(user.getId())[i].getDriverVisibility())) {
							httpPost = (HttpURLConnection) urlAddress.openConnection();
							httpPost.setRequestMethod("POST");
							httpPost.setDoOutput(true);
							writer = new DataOutputStream(httpPost.getOutputStream());
							writer.writeBytes("action=getUser&id="+OM.getListOrderDriver(user.getId())[i].getCustomerId());
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
							User c = new User();
							c = new Gson().fromJson(driverJson.trim(),User.class);


							out.print(""+
								"<div class='row'>"+
								"	<img src='../IDServices/ImageRetriever?id="+c.getId()+"' onerror=\"this.src='../img/default_profile.jpeg'\" style='float: left; border: 1px solid black; margin: 10px' width='120' height='125'>"+
								"	<form method='POST' action='../IDServices/IdentityService'>" +
								"		<input type='hidden' name='action' value='hideOrder'>" +
								"		<input type='hidden' name='id' value="+user.getId()+">" +
								"		<input type='hidden' name='hideAs' value='driver'>" +
								"		<input type='hidden' name='orderID' value='"+OM.getListOrderDriver(user.getId())[i].getOrderId()+"'>" +
								"		<input type='submit' class='btn red' value='HIDE' style='float: right; margin: 10px'>" +
								"	</form>" +
								"	<p style='margin-bottom:0px'>Sunday, September 24th 2017</p>"+
								"	<h3 style='margin:0px'>"+c.getFullname()+"</h3>"+
								"	<small>"+OM.getListOrderDriver(user.getId())[i].getPickLoc()+" - "+OM.getListOrderDriver(user.getId())[i].getDestLoc()+"</small><br><br>"+
								"	Gave &nbsp;<span style='color:orange; font-size:1.5em'>" + OM.getListOrderDriver(user.getId())[i].getScore() + "</span> &nbsp;stars for this order" +
								"	<br>and left comment:<br>"+
								"	<p style='margin:0px 170px;'><small>"+OM.getListOrderDriver(user.getId())[i].getComment()+"</small></p>"+
								"</div><br>");
						}
					}	
				}
			%>
		</div>


	</div>

</body>
</html>