/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.olride.bean;

public class Order {
    int orderId;
    int driverId;
    int customerId;
    int score;
    String destLoc;
    String pickLoc;   
    java.util.Date date;
    String comment;
    String customerVisibility;
    String driverVisibility;
    
    @Override
    public String toString() {
        return ("order [driverId=" + driverId + ", customerId=" + customerId + ", score=" + score + ", destLoc=" + destLoc + ", pickLoc=" + pickLoc +", date=" + date +", comment=" + comment +", customerVisibility=" + customerVisibility +", driverVisibility=" + driverVisibility + "]");
    }
    
    public int getOrderId(){
        return(orderId);
    }
  
    public int getDriverId(){
        return(driverId);
    }
    
    public int getCustomerId(){
        return(customerId);
    }
    
    public int getScore(){
        return(score);
    }
    
    public String getDestLoc(){
        return(destLoc);
    }
    
    public String getPickLoc(){
        return(pickLoc);
    }   

    public java.util.Date getDate(){
        return(date);
    }
    
    public String getComment(){
        return(comment);
    }
    
    public String getCustomerVisibility(){
    	return (customerVisibility);
    }
    
    public String getDriverVisibility(){
    	return (driverVisibility);
    }
    
    public void setOrderId(int idZ){
        orderId = idZ;
    }
    public void setDriverId(int idX){
        driverId = idX;
    }
    public void setCustomerId(int idY){
        customerId = idY;
    }
    public void setScore(int x){
        score = x;
    }
    public void setDestLoc(String locX){
        destLoc = locX;
    }
    public void setPickLoc(String locY){
        pickLoc = locY;
    }   
    public void setDate(java.util.Date currDate){
        date = currDate;
    }
    public void setComment(String currComment){
        comment = currComment;
    }
    public void setCustomerVisibility(String v){
        customerVisibility = v;
    }
    
    public void setDriverVisibility(String v){
        driverVisibility = v;
    }
    
}
