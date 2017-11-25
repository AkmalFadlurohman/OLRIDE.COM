package com.olride.IDServices;

import java.io.*;
import java.lang.ClassNotFoundException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.net.*;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import com.google.gson.Gson;
import org.apache.commons.fileupload.disk.DiskFileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.*;
import java.security.SecureRandom;
import java.util.Date;
import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.*;
import com.nimbusds.jwt.*;
import java.text.*;
import com.olride.bean.*;
import com.olride.OjolServices.*;



public class IdentityService extends HttpServlet {

	public void doPost(HttpServletRequest request,HttpServletResponse response)
	throws ServletException,IOException {
		User user = new User();
		Driver driver = new Driver();

		PrintWriter out = response.getWriter();

		String action = request.getParameter("action");
		if ("getUser".equals(action)) {
			int id = Integer.parseInt(request.getParameter("id"));
			user = getUserByID(id);
			String uJson = new Gson().toJson(user);
			out.println(uJson);			
		} else if ("getDriver".equals(action)) {
			int id = Integer.parseInt(request.getParameter("id"));
			driver = getDriverByID(id);
			String dJson = new Gson().toJson(driver);
			out.println(dJson);			
		} else if ("login".equals(action)) {
			String username = request.getParameter("username");
			String password = request.getParameter("password");
			String userAgent = request.getParameter("agent");
			String ipAddress = request.getParameter("ip");
			if (validateLogin(username,password)) {
				if (checkLoginStatus(username)) {
					user = getUserByUsername(username);
					int id = user.getId();
					String token = user.getToken();
					if (validateAccess(id,token,userAgent,ipAddress)) {
						String uJson = new Gson().toJson(user);
						out.println(uJson);
					} else {
						out.println("forbidden");
					}
				} else {
					generateToken(username,userAgent,ipAddress);
					user = getUserByUsername(username);
					String uJson = new Gson().toJson(user);
					out.println(uJson);
				}
			} else {
				out.println("invalid");
			}
		} else if ("register".equals(action)) {
			String fullname = request.getParameter("fullname");
			String username = request.getParameter("username");
			String email = request.getParameter("email");
			String password = request.getParameter("password");
			String cpassword = request.getParameter("confirm_password");
			String phone = request.getParameter("phone");
			String status = request.getParameter("status");
			String userAgent = request.getParameter("agent");
			String ipAddress = request.getParameter("ip");
			if (password.equals(cpassword) && validateRegister(username)) {
				insertUserToDB(fullname,username,email,password,phone,status);
				generateToken(username,userAgent,ipAddress);
				user = getUserByUsername(username);
				if ("driver".equals(user.getStatus())) {
					insertDriverToDB(user.getId());
				}
				String uJson = new Gson().toJson(user);
				out.println(uJson);
			} else {
				out.println("invalid");
			}
		} else if ("logout".equals(action)) {
			int id = Integer.parseInt(request.getParameter("id"));
			logOut(id);
			response.setStatus(200);
		} else if ("validateToken".equals(action)) {
			int id = Integer.parseInt(request.getParameter("id"));
			String token = request.getParameter("token");
			user = getUserByToken(token);
			if (user.getId() != id) {
				out.println("invalid");
			} else {
				if (validateToken(id,token)) {
					out.println("valid");
				} else {
					out.println("expired");
				}				
			}
		} else if ("validateAccess".equals(action)) {
			int id = Integer.parseInt(request.getParameter("id"));
			String token = request.getParameter("token");
			String userAgent = request.getParameter("agent");
			String ipAddress = request.getParameter("ip");

			user = getUserByToken(token);
			if (validateToken(id,token)) {
				if (validateAccess(id,token,userAgent,ipAddress)) {
					out.println("valid");
				} else {
					out.println("forbidden");
				}
			} else {
				out.println("expired");
			}
		} else if ("getUserFromToken".equals(action)) {
			String token = request.getParameter("token");
			user = getUserByToken(token);
			String uJson = new Gson().toJson(user);
			out.println(uJson);	
		} else if ("getPrefDriver".equals(action)) {
			String name = request.getParameter("prefDriverName");
			user = getUserByName(name);
			if (user.getId() == 0) {
				out.println("Not Available");
			} else {
				String prefDriverJson = new Gson().toJson(user);
				out.println(prefDriverJson);		
			}	
		} else if ("addLocation".equals(action) || "updateLocation".equals(action) || "deleteLocation".equals(action) || "completeOrder".equals(action) || "hideOrder".equals(action)){
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
				if (validateToken(id,token)) {
					if ("addLocation".equals(action)) {
						URL url = new URL("	http://localhost:8080/Olride/OjolServices/LocationManager?wsdl");
						
						QName qname = new QName("http://OjolServices.olride.com/", "LocationManagerService");
						
						Service service = Service.create(url, qname);
						LocationManagerInterface LM = service.getPort(LocationManagerInterface.class);
					
						String newLoc = request.getParameter("new_location");
						LM.addLocation(id,newLoc);
						response.sendRedirect("../profile/edit_location.jsp?id="+id);
						
					} else if ("updateLocation".equals(action)) {
						URL url = new URL("http://localhost:8080/Olride/OjolServices/LocationManager?wsdl");
						
						QName qname = new QName("http://OjolServices.olride.com/", "LocationManagerService");
						
						Service service = Service.create(url, qname);
						LocationManagerInterface LM = service.getPort(LocationManagerInterface.class);
						
						String currentPrefloc = request.getParameter("current_prefloc");
						String newPrefloc = request.getParameter("new_prefloc");
						LM.editLocation(id,currentPrefloc,newPrefloc);
						response.sendRedirect("../profile/edit_location.jsp?id="+id);
					} else if ("deleteLocation".equals(action)) {
						URL url = new URL("http://localhost:8080/Olride/OjolServices/LocationManager?wsdl");
						
						QName qname = new QName("http://OjolServices.olride.com/", "LocationManagerService");
						
						Service service = Service.create(url, qname);
						LocationManagerInterface LM = service.getPort(LocationManagerInterface.class);
						
						String delPrefloc = request.getParameter("delPrefLoc");
						LM.delLocation(id,delPrefloc);
						response.sendRedirect("../profile/edit_location.jsp?id="+id);
					} else if ("completeOrder".equals(action)) {
						String pickLoc = request.getParameter("pickLoc");
		    				String destLoc = request.getParameter("destLoc");
		    				int selectedDriverID = Integer.parseInt(request.getParameter("selected_driver"));
						String comment = request.getParameter("comment");
						int score = Integer.parseInt(request.getParameter("rating"));
						URL url = new URL("http://localhost:8080/Olride/OjolServices/OrderManager?wsdl");
						
						QName qname = new QName("http://OjolServices.olride.com/", "OrderManagerService");
						
						Service service = Service.create(url, qname);
						
						OrderManagerInterface OM = service.getPort(OrderManagerInterface.class);
						
						OM.saveOrder(destLoc,pickLoc,score,comment,selectedDriverID,id);
						upvoteDriver(selectedDriverID,score);
						response.sendRedirect("../order/select_location.jsp?id="+id);
					} else if ("hideOrder".equals(action)) {
						user = getUserByID(id);
						int orderId = Integer.parseInt(request.getParameter("orderID"));
						String hideAs = request.getParameter("hideAs");
						URL url = new URL("http://localhost:8080/Olride/OjolServices/OrderManager?wsdl");
						
						QName qname = new QName("http://OjolServices.olride.com/", "OrderManagerService");
						
						Service service = Service.create(url, qname);
						
						OrderManagerInterface OM = service.getPort(OrderManagerInterface.class);
						OM.hideOrder(orderId,"driver".equals(hideAs));
						if ("customer".equals(hideAs)) {
							response.sendRedirect("../history/transaction_history.jsp?id="+id);							
						} else {
							response.sendRedirect("../history/driver_history.jsp?id="+id);
						}
					}
				} else {
					response.sendRedirect("../IDServices/Logout?id="+id);
				}
			}
		} else if (action == null) {
			String userID = null;
			String newName = null;
			String newPhone = null;
			String newStatus = "customer";
			boolean isMultipart = ServletFileUpload.isMultipartContent(request);
			InputStream inputStream = null;
			boolean isFileUploaded = false;
			
			if (isMultipart) {
				ServletFileUpload servletFileUpload = new ServletFileUpload(new DiskFileItemFactory());
				try {
					List<FileItem> fileItems = servletFileUpload.parseRequest(request);
					for (FileItem fileItem : fileItems) {
						if (fileItem.isFormField()) {
							if (fileItem.getFieldName().equalsIgnoreCase("newName")) {
								newName = fileItem.getString();
							} else if (fileItem.getFieldName().equalsIgnoreCase("newPhone")) {
								newPhone = fileItem.getString();
							} else if(fileItem.getFieldName().equalsIgnoreCase("newStatus")) {
								if (fileItem.getString().equalsIgnoreCase("on")) {
									newStatus = "driver";
								}
							} else if(fileItem.getFieldName().equalsIgnoreCase("id")) {
								userID = fileItem.getString();
							}
						} else {
							inputStream = fileItem.getInputStream();
							String fileName = new File(fileItem.getName()).getName();
							if (!"".equals(fileName)) {
								isFileUploaded = true;
							}
						}
					}
				} catch(FileUploadException ex) {
					ex.printStackTrace();
				}
			}
			int id = 0;
			if (userID != null) {
				id = Integer.parseInt(userID);
			}
			if (id != 0) {
				Connection connect = null;
				Statement statement = null;
				ResultSet resultSet = null;
				PreparedStatement preparedStatement = null;
				
				try {
					Class.forName("com.mysql.jdbc.Driver");
					connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
					
					if (isFileUploaded) {
						String query="UPDATE user set name= ? ,phone= ? ,status= ?,pict= ? WHERE id= ? ";
						preparedStatement = connect.prepareStatement(query);
						preparedStatement.setString(1, newName);
						preparedStatement.setString(2, newPhone);
						preparedStatement.setString(3, newStatus);
						preparedStatement.setBlob(4, inputStream);
						preparedStatement.setInt(5, id);
						int row = preparedStatement.executeUpdate();
						if (row > 0) {
							connect.close();
						}
					} else {
						String query="UPDATE user set name= ? ,phone= ? ,status= ? WHERE id= ? ";
						preparedStatement = connect.prepareStatement(query);
						preparedStatement.setString(1, newName);
						preparedStatement.setString(2, newPhone);
						preparedStatement.setString(3, newStatus);
						preparedStatement.setInt(4,id);
						int row = preparedStatement.executeUpdate();
						if (row > 0) {
							connect.close();
						}	
					}
				} catch (SQLException e) {
					e.printStackTrace();
				} catch (ClassNotFoundException e) {
					e.printStackTrace();
				}
				response.sendRedirect("../profile/profile.jsp?id="+id);
			}
		}
	}
	public void doGet(HttpServletRequest request,HttpServletResponse response)
	throws ServletException,IOException {
		PrintWriter out = response.getWriter();
		out.println("hello");
		//doPost(request,response);
	}
	public User getUserByUsername(String username) {
		User user = new User();
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select * from user where username='"+username+"'");
			if (resultSet.next()) {
				user.setId(resultSet.getInt("id"));
				user.setFullname(resultSet.getString("name"));
				user.setEmail(resultSet.getString("email"));
				user.setPhone(resultSet.getString("phone"));
				user.setUsername(resultSet.getString("username"));
				user.setToken(resultSet.getString("token"));
				user.setStatus(resultSet.getString("status"));
			}
			connect.close();
		} catch (SQLException e) {
			user.setFullname(e.getMessage());
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return user;
	}
	public User getUserByID(int userID) {
		User user = new User();
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select * from user where id='"+userID+"'");
			if (resultSet.next()) {
				user.setId(resultSet.getInt("id"));
				user.setFullname(resultSet.getString("name"));
				user.setEmail(resultSet.getString("email"));
				user.setPhone(resultSet.getString("phone"));
				user.setUsername(resultSet.getString("username"));
				user.setToken(resultSet.getString("token"));
				user.setStatus(resultSet.getString("status"));
			}
			connect.close();
		} catch (SQLException e) {
			user.setFullname(e.getMessage());
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return user;
	}
	public Driver getDriverByID(int driverID) {
		Driver driver = new Driver();
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select * from driver where driver_id='"+driverID+"'");
			if (resultSet.next()) {
				driver.setId(resultSet.getInt("driver_id"));
				driver.setVotes(resultSet.getInt("votes"));
				driver.setTotalScore(resultSet.getInt("total_score"));
			}
			connect.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return driver;
	}
	public User getUserByName(String name) {
		User user = new User();
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select * from user where name='"+name+"'");
			if (resultSet.next()) {
				user.setId(resultSet.getInt("id"));
				user.setFullname(resultSet.getString("name"));
				user.setEmail(resultSet.getString("email"));
				user.setPhone(resultSet.getString("phone"));
				user.setUsername(resultSet.getString("username"));
				user.setToken(resultSet.getString("token"));
				user.setStatus(resultSet.getString("status"));
			}
			connect.close();
		} catch (SQLException e) {
			user.setFullname(e.getMessage());
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return user;
	}
	public User getUserByToken(String token) {
		User user = new User();
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select * from user where token='"+token+"'");
			if (resultSet.next()) {
				user.setId(resultSet.getInt("id"));
				user.setFullname(resultSet.getString("name"));
				user.setEmail(resultSet.getString("email"));
				user.setPhone(resultSet.getString("phone"));
				user.setUsername(resultSet.getString("username"));
				user.setToken(resultSet.getString("token"));
				user.setStatus(resultSet.getString("status"));
			}
			connect.close();
		} catch (SQLException e) {
			user.setFullname(e.getMessage());
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return user;
	}
	public boolean validateLogin(String username, String password) {
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		String storedPassword;
		boolean valid = false;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
		
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select password from user where username='"+username+"'");
			if (resultSet.next()) {
				storedPassword = resultSet.getString("password");
				if (storedPassword.equals(password)) {
					valid = true;
				}
			}
			connect.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return valid;
	}
	public boolean checkLoginStatus(String username) {
		User  user = new User();
		user = getUserByUsername(username);
		return (user.getToken() != null);
	}
	public boolean validateAccess(int id,String token,String userAgent,String ipAddress) {
		Connection connect = null;
		ResultSet resultSet = null;
		Statement statement = null;
		byte[] sharedSecret = new byte[64];
		boolean valid = false;

		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			if (connect != null) {
				statement = connect.createStatement();
				resultSet = statement.executeQuery("select secret from user where id='"+id+"'");
				if (resultSet.next()) {
					sharedSecret = resultSet.getBytes("secret");
					try {
						SignedJWT signedJWT = SignedJWT.parse(token);						
						JWSVerifier verifier = new MACVerifier(sharedSecret);
						if (signedJWT.verify(verifier)) {
							String registeredAgent = (String) signedJWT.getJWTClaimsSet().getClaim("registeredAgent");
							String registeredIP = (String) signedJWT.getJWTClaimsSet().getClaim("registeredIP");
							if (registeredAgent.equals(userAgent) && registeredIP.equals(ipAddress)) {
								valid = true;
							}							
						}
					} catch(ParseException e ) {
						e.printStackTrace();
					} catch(JOSEException e) {
						e.printStackTrace();
					}
					connect.close();			
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();;
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return valid;
	}
	public boolean validateRegister(String username) {
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		String storedPassword;
		boolean valid = false;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
		
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select username,password from user where username='"+username+"'");
			int count = 0;
			while (resultSet.next()) {
				count++;
			}
			connect.close();
			if (count == 0) {
				valid = true;
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return valid;
	}
	
	public void generateToken(String username,String userAgent,String ipAddress) {
		SecureRandom random = new SecureRandom();
		byte[] sharedSecret = new byte[64];
		random.nextBytes(sharedSecret);
		
		String token = null;
		try {
			JWSSigner signer = new MACSigner(sharedSecret);
			JWTClaimsSet claimsSet = new JWTClaimsSet.Builder()
			.subject(username)
			.issuer("olride.com")
			.expirationTime(new Date(new Date().getTime() + 3600 * 24 * 1000))
			.claim("registeredAgent",userAgent)
			.claim("registeredIP",ipAddress)
			.build();
			
			SignedJWT signedJWT = new SignedJWT(new JWSHeader(JWSAlgorithm.HS512), claimsSet);
			signedJWT.sign(signer);
			token = signedJWT.serialize();
		} catch(KeyLengthException e ) {
			e.printStackTrace();
		} catch(JOSEException e) {
			e.printStackTrace();
		}
		Connection connect = null;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			if (connect != null) {
		    		String query = "UPDATE user SET token = ? ,secret = ? WHERE username = ? ";
		    		PreparedStatement preparedStmt = connect.prepareStatement(query);
		    		preparedStmt.setString(1, token);
		    		preparedStmt.setBytes(2, sharedSecret);
		    		preparedStmt.setString(3, username);
		    		preparedStmt.executeUpdate();
				if (preparedStmt != null) {
					preparedStmt.close();
					connect.close();	
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
	boolean validateToken(int userID,String userToken) {
		byte[] sharedSecret = new byte[64];
		String token = null;
		Connection connect = null;
		ResultSet resultSet = null;
		Statement statement = null;
		boolean valid = false;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			if (connect != null) {
				statement = connect.createStatement();
				resultSet = statement.executeQuery("select token,secret from user where id='"+userID+"'");
				if (resultSet.next()) {
					token = resultSet.getString("token");
					sharedSecret = resultSet.getBytes("secret");
					try {
						SignedJWT signedJWT = SignedJWT.parse(token);
						
						JWSVerifier verifier = new MACVerifier(sharedSecret);
						if (signedJWT.verify(verifier)) {
							Date expDate = signedJWT.getJWTClaimsSet().getExpirationTime();
							Date curDate = new Date(new Date().getTime());
							if (curDate.before(expDate) && token.equals(userToken)) {
								valid = true;
							}						
						}
					} catch(ParseException e ) {
						e.printStackTrace();
					} catch(JOSEException e) {
						e.printStackTrace();
					}
					connect.close();			
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();;
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return valid;
	}
	public void insertUserToDB(String fullname, String username, String email, String password,String phone, String status) {
		Connection connect = null;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			if (connect != null) {
				String query = "INSERT INTO user (name, email, phone, username, password,status)" + " VALUES (?, ?, ?, ?, ?, ? )";
				
				PreparedStatement preparedStmt = connect.prepareStatement(query);
		    		preparedStmt.setString(1, fullname);
		    		preparedStmt.setString(2, email);
		    		preparedStmt.setString(3, phone);
		    		preparedStmt.setString(4, username);
		    		preparedStmt.setString(5, password);
		    		preparedStmt.setString(6, status);
		    
		    		preparedStmt.executeUpdate();
		    
				if (preparedStmt != null) {
					connect.close();			
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();;
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
	public void insertDriverToDB(int userID) {
		Connection connect = null;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
			if (connect != null) {
				String query = "INSERT INTO driver (driver_id, total_score, votes)" + " VALUES (?, ?, ? )";
				
				PreparedStatement preparedStmt = connect.prepareStatement(query);
		    		preparedStmt.setInt(1, userID);
		    		preparedStmt.setInt(2, 0);
		    		preparedStmt.setInt(3, 0);
		    
		    		preparedStmt.executeUpdate();
		    
				if (preparedStmt != null) {
					connect.close();			
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();;
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
	public void logOut(int userID) {
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;

		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
		
			String query="UPDATE user set token = ? ,secret= ?  WHERE id= ? ";
			PreparedStatement preparedStatement = connect.prepareStatement(query);
			preparedStatement.setNull(1, Types.VARCHAR);
			preparedStatement.setNull(2, Types.VARCHAR);
			preparedStatement.setInt(3, userID);
			
			int row = preparedStatement.executeUpdate();
			if (row > 0) {
				connect.close();
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
	void upvoteDriver(int driverID,int score) {
		Connection connect = null;
		Statement statement = null;
		ResultSet resultSet = null;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_IDServices","root","");
		
			statement = connect.createStatement();
			statement.executeUpdate("UPDATE driver SET votes = votes + 1, total_score = total_score +"+score+" WHERE driver_id = '"+driverID+"'");
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}
}
