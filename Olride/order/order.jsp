<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson" %>

<html>
<body>
	<% 
		if (request.getParameter("id") == null) {
			request.setAttribute("script","<script>document.getElementById(\"requireLogin\").innerHTML=\"Please login using your username and password first!\";</script>");
			request.getRequestDispatcher("../login/login.jsp").forward(request,response);
		}
		int id = Integer.parseInt(request.getParameter("id"));
		response.sendRedirect("select_location.jsp?id="+id);
	%>
</body>
</html>
