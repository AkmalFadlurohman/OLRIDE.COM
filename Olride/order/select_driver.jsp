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


<html>
<head>
    <title>Select Driver</title>
    <link rel="stylesheet" type="text/css" href="../css/new_style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.6/angular.min.js"></script>
	<link rel="manifest" href="/Olride/script/manifest.json">
	<script src="https://code.jquery.com/jquery-3.2.1.min.js" integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4=" crossorigin="anonymous"></script>
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
                <div id="page-tab-driver" class="page-tab selected">
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
		<div id="order-page-driver">
            <div style="width: 100%; border: 1px solid black; border-radius: 10px;">
                <h2 style="margin-left: 10px; margin-top: 0px">PREFERRED DRIVERS: </h2>
                <div id="driver-preferred-result" style="margin: 0 30px 30px 30px">

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
								if (!"Not Available".equals(res.toString())) {
									String prefUJson = res.toString();
									prefUDriver = new Gson().fromJson(prefUJson,User.class);
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

									if ("active".equals(prefDriver.getStatus())) {
										out.println(
											"<div class='row'>" +
											"	<img src='../IDServices/ImageRetriever?id="+prefUDriver.getId()+"' onerror='this.src=\"../img/default_profile.jpeg\"' style='float: left; border: 1px solid black; margin: 10px' width='120' height='125'>" +
											"	<p style='font-size: 1.4em; margin:20px 10px 3px 10px'>"+ prefUDriver.getFullname() +"</p>" + 
											"	<p style='margin-top: 0'><span class='text-orange'><b><i class='icon icon-star'></i>"+prefDriver.getRating()+"</b></span> ("+prefDriver.getVotes()+" votes)</p>" + 
											"	<span class='btn green' style='float: right; margin: 10px' onclick='chooseDriver("+prefDriver.getId()+")'>I CHOOSE YOU!</span>" +
											"</div>");
									}
								} else {
									out.println("<p id='driver-preferred-empty' class='text-center' style='font-size: large; color: #989898; margin: 30px'>Nothing to display :(</p>");
								}
							} else {
								out.println("<p id='driver-preferred-empty' class='text-center' style='font-size: large; color: #989898; margin: 30px'>Nothing to display :(</p>");
							}
					%>

                </div>
            </div>
            <br>
            <div style="width: 100%; border: 1px solid black; border-radius: 10px;">
                <h2 style="margin-left: 10px; margin-top: 0px">OTHER DRIVERS: </h2>
                <div id="driver-search-result" style="margin: 0 30px 30px 30px">

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
									if ("active".equals(drivers.getStatus())) {
										out.println(
											"<div class='row'>" +
											"	<img src='../IDServices/ImageRetriever?id="+users.getId()+"' onerror='this.src=\"../img/default_profile.jpeg\"' style='float: left; border: 1px solid black; margin: 10px' width='120' height='125'>" +
											"	<p style='font-size: 1.4em; margin:20px 10px 3px 10px'>"+ users.getFullname() +"</p>" + 
											"	<p style='margin-top: 0'><span class='text-orange'><b><i class='icon icon-star'></i>"+drivers.getRating()+"</b></span> ("+drivers.getVotes()+" votes)</p>" + 
											"	<span class='btn green' style='float: right; margin: 10px' onclick='chooseDriver("+drivers.getId()+")'>I CHOOSE YOU!</span>" +
											"</div>");
									}
								} else {
									size -= 1;
								}
							}
							if (size == 0) {
								out.println("<p id='driver-preferred-empty' class='text-center' style='font-size: large; color: #989898; margin: 30px'>Nothing to display :(</p>");
							}
						} else if (size == 0) {
							out.println("<p id='driver-preferred-empty' class='text-center' style='font-size: large; color: #989898; margin: 30px'>Nothing to display :(</p>");
						}
					%>

                </div>
            </div>

			<form method="post" id="submit_select_drv" action="customer_chatroom.jsp">
				<input type="hidden" name="id" value=<%out.println(user.getId()); %>>
				<input type="hidden" name="action" value="selectDriver">
				<input type="hidden" name="pickLoc" value=<%out.println(pickLoc);%>>
				<input type="hidden" name="destLoc" value='<%out.println(destLoc);%>'>
				<input type="hidden" name="selected_driver" id="selected_driver">
			</form>

        </div>
    </div>
    <script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-app.js"></script>
	<script src="https://www.gstatic.com/firebasejs/4.6.2/firebase-messaging.js"></script>
	<script type="text/javascript">
		var myId = <%out.println(id);%>;
		// Preparing FCM -----------------------------------------------------------------
		var fcmToken = null;
		var config = {
			apiKey: "AIzaSyB0KWompT2YoRR99caQcanuxSr-ag5Z6-k",
			authDomain: "olride-69182.firebaseapp.com",
			databaseURL: "https://olride-69182.firebaseio.com",
			projectId: "olride-69182",
			storageBucket: "olride-69182.appspot.com",
			messagingSenderId: "679619512375"
		};
		firebase.initializeApp(config);
		
		const messaging = firebase.messaging();
		navigator.serviceWorker.register("/Olride/script/service-worker.js")
			.then((registration) => {
  			messaging.useServiceWorker(registration);
			messaging.requestPermission()
			.then(function() {
				console.log('Messaging permission granted.');
				return messaging.getToken();
			})
			.then(function(currentToken) {
				console.log(currentToken);
				fcmToken = currentToken;
				registerToken(myId,fcmToken);
			})
			.catch(function(err) {
				console.log('Error occured.', err);
			});

		});
		function registerToken(userId,fcmToken) {
			$.ajax({
				type: 'POST',
				url: 'http://localhost:8123/token/register',
				data: {
					user: userId,
					token: fcmToken
				},
				success: function(responseData, textStatus, jqXHR) {
					var value = responseData.someKey;
				},
				error: function (responseData, textStatus, errorThrown) {
					alert('POST failed.');
				},
			});
		}
		function chooseDriver(driver_id) {
			document.getElementById('selected_driver').value = driver_id;
			var form = document.getElementById('submit_select_drv');
			form.submit();
		}
	</script>


</body>
</html>
