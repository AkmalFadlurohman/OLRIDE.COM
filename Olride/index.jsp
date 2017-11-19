<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.HttpURLConnection,java.net.URL"%>

<html>
<body>
	<% 
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
			response.sendRedirect("login/login.jsp");
		} else {
			String token = cookies[j].getValue();
			String address = "http://localhost:8080/Olride/IDServices/IdentityService";
			URL urlAddress = new URL(address);
			HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
			httpPost.setRequestMethod("POST");
			httpPost.setDoOutput(true);
			DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
			writer.writeBytes("action=getUserFromToken&token="+token);
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
			User user = new User();
			user = new Gson().fromJson(msg,User.class);
			if ("driver".equals(user.getStatus())) {
				response.sendRedirect("../Olride/profile/profile.jsp?id="+user.getId());
			} else {
				response.sendRedirect("../Olride/order/order.jsp?id="+user.getId());
			}
		}
	%>
</body>
</html>
