package com.olride.IDServices;

import java.io.*;
import java.lang.ClassNotFoundException;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.net.HttpURLConnection;
import java.net.URL;


public class Logout extends HttpServlet {

	public void doGet(HttpServletRequest request,HttpServletResponse response)
	throws ServletException,IOException {
		
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
		if (exist) {
			Cookie token = cookies[j];
			token.setMaxAge(0);
			token.setPath("/");
			response.addCookie(token);
		}
		String address = "http://localhost:8080/Olride/IDServices/IdentityService";
		URL urlAddress = new URL(address);
		HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
		httpPost.setRequestMethod("POST");
		httpPost.setDoOutput(true);
		DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
		writer.writeBytes("action=logout&id="+id);
		writer.flush();
		writer.close(); 
		int respCode = httpPost.getResponseCode();
		if ("forbid".equals(request.getParameter("action")) && respCode == 200) {
			//request.setAttribute("script","<script>document.getElementById(\"requireLogin\").innerHTML=\"Your session has expired\";</script>");
			request.setAttribute("script","<script>document.getElementById(\"error\").innerHTML=\"Please log out from other browsers and computers first!\";</script>");
			request.getRequestDispatcher("../login/login.jsp").forward(request,response);
		}
		else if (request.getParameter("action") == null && respCode == 200) {
			response.sendRedirect("../login/login.jsp");
		}
	}
}
