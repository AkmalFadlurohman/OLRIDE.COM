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
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.Path;

public class ImageRetriever extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		String username = request.getParameter("username");
		int id = Integer.parseInt(request.getParameter("id"));
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
		
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select pict from user where id='"+id+"'");
			if (resultSet.next()) {
                 byte[] pict = resultSet.getBytes("pict");
                 response.setContentType("image/jpeg");
                 response.setContentLength(pict.length);
                 response.getOutputStream().write(pict);
             } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND); // 404.
             }
			connect.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
    }

}
