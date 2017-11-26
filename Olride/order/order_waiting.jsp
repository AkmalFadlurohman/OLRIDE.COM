<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson" %>
<%@ page import="java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.IDServices.*" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.*"%>
<html>
    <head>
        <% 
            if (request.getParameter("id") == null) {
                request.setAttribute("script","<script>document.getElementById(\"requireLogin\").innerHTML=\"Please login using your username and password first!\";</script>");
                request.getRequestDispatcher("../login/login.jsp").forward(request,response);
            }
            int id = Integer.parseInt(request.getParameter("id"));
    
            // Check if driver
            String address = "http://localhost:8080/Olride/IDServices/IdentityService";
            URL urlAddress = new URL(address);
            HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
            httpPost.setRequestMethod("POST");
            httpPost.setDoOutput(true);
            DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
            writer.writeBytes("action=getUser&id="+id);
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
            String uJson = res.toString();
            User user = new Gson().fromJson(uJson,User.class);
            if (!"driver".equals(user.getStatus())) {
                response.sendRedirect("select_location.jsp?id="+id);
            }
        %>
        <title>Waiting Order</title>
        <link rel="stylesheet" type="text/css" href="../css/new_style.css">
    </head>
    <body>
        <div class="container">
            <%@include file="../template/new_header.jsp"%>
            <script>
                    var menu = document.getElementById("order_link");
                    menu.setAttribute("class", menu.getAttribute("class")+" active");
            </script>
            <div class="row">
                <div class="col-6"><h1>LOOKING FOR AN ORDER</h1></div>
            </div>
            <div id="driver-order-wait" class="row">
                <br>
                <br>
                <br>
                <br>
                <h2 class="text-center">Finding Order <span id="animate-dot">...</span></h2>
                <br>
                <br>
                <br>
                <div class="col-6 text-center">
                    <a href="/Olride/order/order.jsp?id=<%out.print(id);%>" class="btn red" style="color: white; padding: 15px 25px">Cancel</a>
                    <br>
                    <br>
                    <br>
                    <br>
                    <a href="/Olride/order/driver_chatroom.jsp?id=<%out.print(id);%>">Next shortcut</a>
                </div>
            </div>
        </div>
        
        <script>
            var dots = window.setInterval( function() {
                var wait = document.getElementById("animate-dot");
                if ( wait.innerHTML.length > 3 ) 
                    wait.innerHTML = "";
                else 
                    wait.innerHTML += ".";
            }, 500);
        </script>
    </body>
</html>