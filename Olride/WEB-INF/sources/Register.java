package com.olride.IDServices;

import java.io.*;
import java.lang.ClassNotFoundException;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.net.HttpURLConnection;
import java.net.URL;
import com.google.gson.Gson;
import com.olride.bean.User;
import com.olride.bean.Driver;

public class Register extends HttpServlet {
	
	public void doPost(HttpServletRequest request,HttpServletResponse response)
	throws ServletException,IOException {
		
		String fullname = request.getParameter("fullname");
		String username = request.getParameter("username");
		String email = request.getParameter("email");
		String password = request.getParameter("user_password");
		String cpassword = request.getParameter("confirm_password");
		String phone = request.getParameter("phone");
		String status;
		PrintWriter out = response.getWriter();
		
		if (request.getParameter("is_driver") != null) {
			status = "driver";
		} else {
			status = "customer";
		}
		String address = "http://localhost:8080/Olride/IDServices/IdentityService";
		URL urlAddress = new URL(address);
		HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
		httpPost.setRequestMethod("POST");
		httpPost.setDoOutput(true);
		DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
		writer.writeBytes("action=register&fullname="+fullname+"&username="+username+"&email="+email+"&password="+password+"&confirm_password="+cpassword+"&phone="+phone+"&status="+status);
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
			request.setAttribute("script","<script>document.getElementById(\"errorCredential\").innerHTML=\"Username or password is not available\";</script>");
			request.getRequestDispatcher("../login/register.jsp").forward(request, response);
	    }
	}
}
