package com.olride.IDServices;

import java.io.*;
import java.lang.ClassNotFoundException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.net.*;
import com.google.gson.Gson;
import com.olride.bean.*;



public class Login extends HttpServlet {

	public void doPost(HttpServletRequest request,HttpServletResponse response)
	throws ServletException,IOException {

		String username = request.getParameter("username");
		String password = request.getParameter("password");
		String userAgent = request.getHeader("User-Agent");
		String ipAddress = request.getParameter("ipAddress");
		
		PrintWriter out = response.getWriter();
		String address = "http://localhost:8080/Olride/IDServices/IdentityService";
		URL urlAddress = new URL(address);
		HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
		httpPost.setRequestMethod("POST");
		httpPost.setDoOutput(true);
		DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
		writer.writeBytes("action=login&username="+username+"&password="+password+"&agent="+userAgent+"&ip="+ipAddress);
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
		String resp = res.toString();
		//out.println(resp);
		if ("invalid".equals(resp)) {
			request.setAttribute("script","<script>document.getElementById(\"error\").innerHTML=\"Invalid username or password!\";</script>");
			request.getRequestDispatcher("../login/login.jsp").forward(request,response);
	    } else if ("forbidden".equals(resp)) {
	    	request.setAttribute("script","<script>document.getElementById(\"error\").innerHTML=\"Please log out from other browsers and computers first!\";</script>");
			request.getRequestDispatcher("../login/login.jsp").forward(request,response);
	    } else {
	    	User user = new User();
			user = new Gson().fromJson(resp.trim(),User.class);
			Cookie token = new Cookie("token",user.getToken());
			token.setPath("/");
			token.setMaxAge(-1);
			response.addCookie(token);
			if ("driver".equals(user.getStatus())) {
				response.sendRedirect("../profile/profile.jsp?id="+user.getId());
			} else {
				response.sendRedirect("../order/order.jsp?id="+user.getId());
			}
	    }
	}
}
