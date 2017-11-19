/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.olride.OjolServices;

import static java.lang.System.out;
import java.sql.*;
import java.util.Calendar;
import java.text.SimpleDateFormat;
import java.util.Date;
import com.olride.bean.Driver;
import com.olride.bean.Order;
import java.util.ArrayList;
import java.util.List;
import javax.jws.WebService;
/**
 *
 * @author user
 */
@WebService(endpointInterface = "com.olride.OjolServices.OrderManagerInterface")
public class OrderManager implements OrderManagerInterface {
    @Override
    public void saveOrder(String destLoc, String pickLoc, int score,  String comment,int driverId, int customerId) {
    		Connection connect = null;
        
    		try {
    			Class.forName("com.mysql.jdbc.Driver");
    			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_OjolServices","root","");
    			
    			if (connect != null) {
    				String query = " insert into `order` (dest_city, pick_city, score, comment, driver_id, cust_id, date, customer_visibility, driver_visibility)" + " values ( ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    				PreparedStatement preparedStmt = connect.prepareStatement(query);
    				preparedStmt.setString(1, destLoc);
    				preparedStmt.setString(2, pickLoc);
    				preparedStmt.setInt(3, score);
    				preparedStmt.setString(4, comment);
    				preparedStmt.setInt(5, driverId);
    				preparedStmt.setInt(6, customerId);
    				preparedStmt.setDate(7, new java.sql.Date(new Date().getTime()));
    				preparedStmt.setString(8, "visible");
    				preparedStmt.setString(9, "visible");
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
    
    @Override
    public void hideOrder(int id, boolean isDriver) {
    		Connection connect = null;
		Statement statement = null;
        try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_OjolServices","root","");
			
			if (connect != null) {
				 String query;
	             if (isDriver) {
	            	 	query = " update `order` set driver_visibility = 'none' where order_id = " + id;
	             } else {  
	            	 	query = " update `order` set customer_visibility = 'none' where order_id = " + id;
	             }   
	             statement = connect.createStatement();
	             statement.executeUpdate(query);
	             connect.close();	   				
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
    }
    
    @Override
    public Order[] getListOrderDriver(int driverID){ 
    		Connection connect = null;
		Statement statement = null;
		Statement st = null;
		ResultSet resultSet = null;
		ResultSet rS = null;
		Order[] orders = null;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_OjolServices","root","");
			
			st = connect.createStatement();
			rS = st.executeQuery("select * from `order` where driver_id='"+driverID+"'");
			int count = 0;
			while (rS.next()) {
				count++;
			}
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select * from `order` where driver_id='"+driverID+"'");
			int i = 0;
			orders = new Order[count];
			while (resultSet.next()) {
				orders[i] = new Order();
				orders[i].setOrderId(resultSet.getInt("order_id"));
				orders[i].setDestLoc(resultSet.getString("dest_city"));
				orders[i].setPickLoc(resultSet.getString("pick_city"));
				orders[i].setScore(resultSet.getInt("score"));
				orders[i].setDriverId(resultSet.getInt("driver_id"));
				orders[i].setCustomerId(resultSet.getInt("cust_id"));
				orders[i].setComment(resultSet.getString("comment"));
				orders[i].setDate(resultSet.getDate("date"));
				orders[i].setCustomerVisibility(resultSet.getString("customer_visibility"));
				orders[i].setDriverVisibility(resultSet.getString("driver_visibility"));
				i++;
			}
			connect.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return orders;
    }
    
    @Override
    public Order[] getListOrderCustomer(int customerID){ 
    		Connection connect = null;
		Statement statement = null;
		Statement st = null;
		ResultSet resultSet = null;
		ResultSet rS = null;
		Order[] orders = null;
		try {
			Class.forName("com.mysql.jdbc.Driver");
			connect = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/olride_OjolServices","root","");
			
			st = connect.createStatement();
			rS = st.executeQuery("select * from `order` where cust_id='"+customerID+"'");
			int count = 0;
			while (rS.next()) {
				count++;
			}
			statement = connect.createStatement();
			resultSet = statement.executeQuery("select * from `order` where cust_id='"+customerID+"'");
			int i = 0;
			orders = new Order[count];
			while (resultSet.next()) {
				orders[i] = new Order();
				orders[i].setOrderId(resultSet.getInt("order_id"));
				orders[i].setDestLoc(resultSet.getString("dest_city"));
				orders[i].setPickLoc(resultSet.getString("pick_city"));
				orders[i].setScore(resultSet.getInt("score"));
				orders[i].setDriverId(resultSet.getInt("driver_id"));
				orders[i].setCustomerId(resultSet.getInt("cust_id"));
				orders[i].setComment(resultSet.getString("comment"));
				orders[i].setDate(resultSet.getDate("date"));
				orders[i].setCustomerVisibility(resultSet.getString("customer_visibility"));
				orders[i].setDriverVisibility(resultSet.getString("driver_visibility"));
				i++;
			}
			connect.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		return orders;
    }
}
