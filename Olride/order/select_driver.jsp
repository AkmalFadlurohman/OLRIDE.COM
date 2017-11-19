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
		String token = cookies[j].getValue();
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
	<title>Select Driver</title>
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
				<div class="submenu left">
					<div class="step_num">
						<p>1</p>
					</div>
					<div class="step_name">
						<p>Select Destination</p>
					</div>
				</div>
			
				<div class="submenu mid submenu_active">
					<div class="step_num">
						<p>2</p>
					</div>
					<div class="step_name">
						<p>Select a Driver</p>
					</div>
				</div>

				<div class="submenu right">
					<div class="step_num">
						<p>3</p>
					</div>
					<div class="step_name">
						<p>Complete Order</p>
					</div>
				</div>
			</div>
			<%
				String pickLoc = request.getParameter("pickLoc");
				String destLoc = request.getParameter("destLoc");
			%>
			<div id="driver_table_container">
				<form method="post" id="submit_select_drv" action="complete_order.jsp">
					<div class="content" id="select_driver">
						<div id="preferred_driver">
							<h2>Preferred driver</h2>
							<%
								String prefDriverName = null;
								if (request.getParameter("preferred_driver").length() != 0) {
		        						prefDriverName = request.getParameter("preferred_driver"); 
		        						User prefUDriver = null;
		        						httpPost = (HttpURLConnection) urlAddress.openConnection();
		        						httpPost.setRequestMethod("POST");
		        						httpPost.setDoOutput(true);
		        						writer = new DataOutputStream(httpPost.getOutputStream());
		        						writer.writeBytes("action=getPrefDriver&prefDriverName="+prefDriverName);
		        						writer.flush();
		        						writer.close();
		        						buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
		        						res = new StringBuilder();
		        						while ((inputLine = buffer.readLine()) != null) {
		        							res.append(inputLine);
		        						}
		        						String prefUJson = res.toString();
		        						prefUDriver = new Gson().fromJson(prefUJson,User.class);
		        						if (prefUDriver != null) {
		        							httpPost = (HttpURLConnection) urlAddress.openConnection();
			        						httpPost.setRequestMethod("POST");
			        						httpPost.setDoOutput(true);
			        						writer = new DataOutputStream(httpPost.getOutputStream());
			        						writer.writeBytes("action=getDriver&id="+prefUDriver.getId());
			        						writer.flush();
			        						writer.close();
			        						buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
			        						res = new StringBuilder();
			        						while ((inputLine = buffer.readLine()) != null) {
			        							res.append(inputLine);
			        						}
		        							String prefDJson = res.toString();
		        							Driver prefDriver = new Gson().fromJson(prefDJson,Driver.class);
		        							out.println("<table class='driver_table'>");
	        									out.println("<colgroup>");
	        										out.println("<col style='width: 20%;'>");
	        										out.println("<col style='width: 80%;'>");
	        									out.println("</colgroup>");
	        									out.println("<tr>");
	        										out.println("<td>");
	        											out.println("<img class='driver_pict' src='../IDServices/ImageRetriever?id="+prefUDriver.getId()+"' onerror=\"this.src='../img/default_profile.jpeg'\">");
	        										out.println("</td>");
	        										out.println("<td class='driver_column'>");
	        											out.println("<p class='driver_username'>"+prefUDriver.getFullname()+"</p>");
	        											out.println("<p class='driver_rating'><span>&starf;"+prefDriver.getRating()+"</span> ("+prefDriver.getVotes()+" votes)</p>");
	        											out.println("<div class='choose_driver green' onclick='chooseDriver("+prefDriver.getId()+")'>");
	        												out.println("I CHOOSE YOU");
	        											out.println("</div>");
	        										out.println("</td>");
	        									out.println("</tr>");
	        								out.println("</table>");
		        						} else {
		        							out.println("<h3>Nothing to display :(</h3>");
		        						}
		        					} else {
		        						out.println("<h3>Nothing to display :(</h3>");
		        					}
							%>
						</div>
						<div id="other_driver">
							<h2>Other drivers</h2>
							<%
			  					URL url = new URL("	http://localhost:8080/Olride/OjolServices/LocationManager?wsdl");
			    				
			    					QName qname = new QName("http://OjolServices.olride.com/", "LocationManagerService");
			    				
			    					Service service = Service.create(url, qname);
			    				
			    					LocationManagerInterface LM = service.getPort(LocationManagerInterface.class);
			        				int size = LM.getAvailableDrivers(pickLoc).length;
			        				User users = new User();
			        				Driver drivers = new Driver();
			        				String otherUJson = null;
			        				String otherDJson = null;
			        				if (size > 0) {
			        					for (int i=0;i<size;i++ ) {
			        						if (LM.getAvailableDrivers(pickLoc)[i] != user.getId()) {
			        							httpPost = (HttpURLConnection) urlAddress.openConnection();
											httpPost.setRequestMethod("POST");
											httpPost.setDoOutput(true);
											writer = new DataOutputStream(httpPost.getOutputStream());
											writer.writeBytes("action=getUser&id="+LM.getAvailableDrivers(pickLoc)[i]);
											writer.flush();
											writer.close();
											respCode = httpPost.getResponseCode();
											respMsg = httpPost.getResponseMessage();
											buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
											res = new StringBuilder();
											while ((inputLine = buffer.readLine()) != null) {
												res.append(inputLine);
											}
											buffer.close();
											otherUJson = res.toString();
											users = new Gson().fromJson(otherUJson,User.class);
											httpPost = (HttpURLConnection) urlAddress.openConnection();
											httpPost.setRequestMethod("POST");
											httpPost.setDoOutput(true);
											writer = new DataOutputStream(httpPost.getOutputStream());
											writer.writeBytes("action=getDriver&id="+users.getId());
											writer.flush();
											writer.close();
											buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
											res = new StringBuilder();
											while ((inputLine = buffer.readLine()) != null) {
												res.append(inputLine);
											}
											otherDJson = res.toString();
											drivers = new Gson().fromJson(otherDJson,Driver.class);
											out.println("<table class='driver_table'>");
	        										out.println("<colgroup>");
	        											out.println("<col style='width: 20%;'>");
	        											out.println("<col style='width: 80%;'>");
	        										out.println("</colgroup>");
	        										out.println("<tr>");
	        											out.println("<td>");
	        												out.println("<img class='driver_pict' src='../IDServices/ImageRetriever?id="+users.getId()+"' onerror=\"this.src='../img/default_profile.jpeg'\">");
	        											out.println("</td>");
	        											out.println("<td class='driver_column'>");
	        												out.println("<p class='driver_username'>"+users.getFullname()+"</p>");
	        												out.println("<p class='driver_rating'><span>&starf;"+drivers.getRating()+"</span> ("+drivers.getVotes()+" votes)</p>");
	        												out.println("<div class='choose_driver green' onclick='chooseDriver("+drivers.getId()+")'>");
	        													out.println("I CHOOSE YOU");
	        												out.println("</div>");
	        											out.println("</td>");
	        										out.println("</tr>");
	        									out.println("</table>");	
			        						} else {
			        							size -= 1;
			        						}
			            				}
			        					if (size == 0) {
				        					out.println("<h3>Nothing to display :(</h3>");
			        					}
			        				} else if (size == 0) {
			        					out.println("<h3>Nothing to display :(</h3>");
			        				}
							%>
						</div>
						<input type="hidden" name="id" value=<%out.println(user.getId()); %>>
						<input type="hidden" name="action" value="selectDriver">
						<input type="hidden" name="pickLoc" value=<%out.println(pickLoc);%>>
						<input type="hidden" name="destLoc" value='<%out.println(destLoc);%>'>
						<input type="hidden" name="selected_driver" id="selected_driver">
					</div>
				</form>
			</div>
		</div>
</body>
<script type="text/javascript">
	function chooseDriver(driver_id) {
		document.getElementById('selected_driver').value = driver_id;
		var form = document.getElementById('submit_select_drv');
		form.submit();
	}
</script>
</html>
