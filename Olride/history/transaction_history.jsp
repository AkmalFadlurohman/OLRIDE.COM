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
		String token = cookies[k].getValue();
		String address = "http://localhost:8080/Olride/IDServices/IdentityService";
		URL urlAddress = new URL(address);
		HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
		httpPost.setRequestMethod("POST");
		httpPost.setDoOutput(true);
		DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
		writer.writeBytes("action=validateToken&id="+id+"&token="+token);
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
			response.sendRedirect("../IDServices/Logout?action=expired&id="+id);
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
	<title>Previous Order History</title>
	<link rel="stylesheet" type="text/css" href="../css/default_style.css">
    <link rel="stylesheet" type="text/css" href="../css/history.css">
    <link rel="stylesheet" type="text/css" href="../css/header.css">

	<script type="text/javascript" src="format_date.js"></script>
    </script>
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
			<%@include file="../template/header.jsp"%>
		</div>
		<div class="menu_container">
            <%@include file="../template/menu.jsp"%>
            <script>
            	document.getElementById("history_link").setAttribute("class", "menu menu_active");
            </script>
        </div>
        <div class="history_container">
        	<div class="subheader">
        		<div class="title"><h1>Transaction History</h1></div>
        	</div>
    		<ul id="history_nav" class="nav_bar">
    			<li>
    				<a class="history_menu menu_active" href='transaction_history.jsp?id=<% out.println(user.getId());%>'>
						<h3>MY PREVIOUS ORDER</h3>
				</a>
    			</li>
    			<li>
    				<a class="history_menu" href='driver_history.jsp?id=<% out.println(user.getId());%>'>
						<h3>DRIVER HISTORY</h3>
				</a>
    			</li>
    		</ul>
    		<div id="history_table_container">
	    		<table class="history_table">
					<colgroup>
						<col style="width: 20%;">
						<col style="width: 80%;">
					</colgroup>

					<tbody>
						<%
							URL url = new URL("	http://localhost:8080/Olride/OjolServices/OrderManager?wsdl");
    					
							QName qname = new QName("http://OjolServices.olride.com/", "OrderManagerService");
				
							Service service = Service.create(url, qname);
							OrderManagerInterface OM = service.getPort(OrderManagerInterface.class);
							
							int size = OM.getListOrderCustomer(user.getId()).length;
							if (size > 0) {
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
										out.println("<tr>");
                                        		out.println("<td class='img_col'>");
                                            		out.println("<img class='history_pict' src='../IDServices/ImageRetriever?id="+d.getId()+"' onerror=\"this.src='../img/default_profile.jpeg'\">");
                                        		out.println("</td>");
                                      		out.println("<td class='order_data'>");
                                           		out.println("<div class='left_data'>");
                                           		out.println("<p class='history_date' id='row"+(i+1)+"'></p>");
                                           		out.println("<p class='history_username'>"+d.getUsername()+"</p>");
                                           		out.println("<p class='history_loc'>"+OM.getListOrderCustomer(user.getId())[i].getPickLoc()+" - "+OM.getListOrderCustomer(user.getId())[i].getDestLoc()+"</p>");
                                           		out.println("<p class='history_rating'>You rated: ");
                                           			for (int j = 0; j < OM.getListOrderCustomer(user.getId())[i].getScore(); j++) {
                                               			 out.print("<span style='color:orange'>&starf;</span>");
                                            			}
                                        			out.println("</p>");
                                            		out.println("<p class='history_comment'>You commented:</p>");
                                           		out.println("<p class='history_comment' style='margin-left: 30px;'>"+OM.getListOrderCustomer(user.getId())[i].getComment()+"</p>");
                                            		out.println("</div>");
                                            		out.println("<div class'right_data'>");
                                                		out.println("<form style='display: inline' method='POST' action='../IDServices/IdentityService'>");
                                                			out.println("<input type='hidden' name='action' value='hideOrder'>");
                                                    		out.println("<input type='hidden' name='id' value="+user.getId()+">");
															out.println("<input type='hidden' name='page' value='transaction'>");
                                                    		out.println("<input type='hidden' name='orderID' value='"+OM.getListOrderCustomer(user.getId())[i].getOrderId()+"'>");
                                                    		out.println("<input type='submit' class='hide_hist_button' value='HIDE'>");
                                                		out.println("</form>");
                                            		out.println("</div>");
                                        		out.println("</td>");
                                        	out.println("</tr>");
									}
								}			
							} 
						%>
					</tbody>
	    		</table>
    		</div>
        </div>
	</div>
</body>
</html>

