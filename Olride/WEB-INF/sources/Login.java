package com.olride.IDServices;

import java.io.*;
import java.lang.ClassNotFoundException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.net.HttpURLConnection;
import java.net.URL;
import com.google.gson.Gson;
import com.olride.bean.*;



public class Login extends HttpServlet {

	public void doPost(HttpServletRequest request,HttpServletResponse response)
	throws ServletException,IOException {

		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		PrintWriter out = response.getWriter();
		
		String address = "http://localhost:8080/Olride/IDServices/IdentityService";
		URL urlAddress = new URL(address);
		HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
		httpPost.setRequestMethod("POST");
		httpPost.setDoOutput(true);
		DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
		writer.writeBytes("action=login&username="+username+"&password="+password);
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
		if (!"invalid".equals(resp)) {
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
		}  else {
			request.setAttribute("script","<script>document.getElementById(\"errorCredential\").innerHTML=\"Invalid username or password!\";</script>");
			request.getRequestDispatcher("../login/login.jsp").forward(request,response);
	    }
	}
}
