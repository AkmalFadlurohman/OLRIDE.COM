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
        <link rel="stylesheet" type="text/css" href="../css/new_chat.css">
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
            <div id="driver-order-chat" class="row">
                <h2 class="text-center order-got-order">Got an Order!</h2>
                <h4 class="text-center" style="margin-top:5px">pikapikapikachu</h4>
                <div class="col-6 chatarea">
                    <ul class="chatlist">
                        <li class="right">
                            <div>
                                <p>ini isinya pesan.... ini isinya pesan.... ini isinya pesan.... ini isinya pesan....</p>
                            </div>
                        </li>
                        <li class="left">
                            <div>
                                <p>Apa sih, ga jelas banget ini pesan!</p>
                            </div>
                        </li>
                        <li class="left">
                            <div>
                                <p>Apa sih, ga jelas banget ini pesan!</p>
                            </div>
                        </li>
                        <li class="left">
                            <div>
                                <p>Apa sih, ga jelas banget ini pesan!</p>
                            </div>
                        </li>
                        <li class="left">
                            <div>
                                <p>Apa sih, ga jelas banget ini pesan!</p>
                            </div>
                        </li>
                        <li class="left">
                            <div>
                                <p>Apa sih, ga jelas banget ini pesan!</p>
                            </div>
                        </li>
                    </ul>
                </div>
                <div class="col-6" style="outline: 1px solid black; height:49px">
                    <div class="row">
                        <div class="col-5">
                            <textarea rows="3" cols="70" placeholder="Ketik pesanmu disini ..." style="resize:none;outline: 1px solid #ffffff00;box-sizing:border-box"></textarea>
                        </div>
                        <div class="col-1" style="padding-top:10px;box-sizing: border-box;">
                            <input id="btn-send-message" class="btn green" type="submit" value="Kirim" style="width:110px">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        

    </body>
</html>