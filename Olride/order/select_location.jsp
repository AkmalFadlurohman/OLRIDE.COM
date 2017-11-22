<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.IDServices.*" %>
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
    <title>Select Location</title>
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
                <div id="page-tab-location" class="page-tab selected">
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
                <div id="page-tab-finish" class="page-tab">
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
        <div id="order-page-location">
            <form method="POST" id="submit_select_loc" name="submit_select_loc" action="select_driver.jsp" onsubmit="return validateForm()">
                <div class="row">
                    <div class="col-2" style="line-height: 40px">
                        <span style="padding-left: 30%;">Picking Point</span> <br>
                    </div>
                    <div class="col-4" style="line-height: 30px">
                        <input id="picking_point" style="width: 80%;height: 30px;padding-left: 5px;font-size: medium" type="text" name="pickLoc" placeholder="Pick up point">
                    </div>
                </div>
                <div class="row">
                    <div class="col-2" style="line-height: 40px">
                        <span style="padding-left: 30%">Destination</span> <br>
                    </div>
                    <div class="col-4" style="line-height: 30px">
                        <input id="destination" style="width: 80%; height: 30px;padding-left: 5px;font-size: medium" type="text" name="destLoc" placeholder="Destination">
                    </div>
                </div>
                <div class="row">
                    <div class="col-2" style="line-height: 40px">
                        <span style="padding-left: 30%">Preferred Driver</span>
                    </div>
                    <div class="col-4">
                        <input id="orderPreferredDriver" style="width: 80%;height: 30px;padding-left: 5px;font-size: medium" type="text" name="preferred_driver" placeholder="(optional)"><br>
                    </div>
                </div>
                <br>
                <br>
                <br>
                <div class="row text-center">
					<input type="hidden" name="action" value="selectLocation">
					<input type="hidden" name="id" value=<%out.println(user.getId()); %>>
                    <input type="submit" class="btn green" style="font-size: 2em; width:auto" value="Next" id="loc_button"/>
                </div>
            </form>
        </div>
    </div>

    
	<script type="text/javascript">
        function validateForm() {
            if(document.getElementById("picking_point").value == null || document.getElementById("picking_point").value == "") {
                window.alert("Please fill the picking location");
                return false;
			}
            if (document.getElementById("destination").value == null || document.getElementById("destination").value == "") {
                window.alert("Please fill the destination location");
                return false;
            }
			return true;
        }
	</script>

</body>
</html>
