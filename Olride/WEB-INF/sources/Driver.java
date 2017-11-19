/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.olride.bean;

import java.util.*;
public class Driver {
   private int id;
   private int totalVotes;
   private int totalScore;
   

   public int getId() {
       return (id);
   }

   public String toString() {
	   return ("driver [id=" + id + ", totalVotes=" + totalVotes + ", totalScore=" + totalScore + "]");
   }

   public float getRating() {
	   if (totalScore == 0) {
		   return (float) 0;
	   } else {
		   return (float) (totalScore/totalVotes);		   
	   }
   }

   public int getVotes() {
       return (totalVotes);
   }
   
   public int getTotalScore(){
       return (totalVotes);
   }
   
   public void setId(int x) {
       id = x;
   }

   public void setVotes(int x) {
       totalVotes = x;
   }
   
   public void setTotalScore(int y){
       totalScore = y;
   }
}
