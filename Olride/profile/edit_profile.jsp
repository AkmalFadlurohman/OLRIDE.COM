<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*" %>
<%@ page import="java.io.BufferedReader,java.io.DataOutputStream,java.io.InputStreamReader,java.net.HttpURLConnection,java.net.URL"%>
<%
	if (request.getParameter("id") == null) {
        request.setAttribute("script","<script>document.getElementById(\"requireLogin\").innerHTML=\"Please login using your username and password first!\";</script>");
        request.getRequestDispatcher("../login/login.jsp").forward(request,response);
    }
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
        URL ipChecker = new URL("http://checkip.amazonaws.com");
        BufferedReader reader = new BufferedReader(new InputStreamReader(ipChecker.openStream()));
        String ipAddress = reader.readLine();
        String userAgent = request.getHeader("User-Agent");

        String token = cookies[j].getValue();
        String address = "http://localhost:8080/Olride/IDServices/IdentityService";
        URL urlAddress = new URL(address);
        HttpURLConnection httpPost = (HttpURLConnection) urlAddress.openConnection();
        httpPost.setRequestMethod("POST");
        httpPost.setDoOutput(true);
        DataOutputStream writer = new DataOutputStream(httpPost.getOutputStream());
        writer.writeBytes("action=validateAccess&id="+id+"&token="+token+"&agent="+userAgent+"&ip="+ipAddress);
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
        String msg = res.toString();
        if ("expired".equals(msg)) {
            response.sendRedirect("../IDServices/Logout?action=expire&id="+id);
        } else if ("forbidden".equals(msg)) {
            response.sendRedirect("../IDServices/Logout?action=forbid&id="+id);
        }
    }
%>
<html>
<head>
    <%   
        //int id = 1;
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
        Driver driver = new Driver();
        String dJson = null;
        if ("driver".equals(user.getStatus())) {
            httpPost = (HttpURLConnection) urlAddress.openConnection();
            httpPost.setRequestMethod("POST");
            httpPost.setDoOutput(true);
            writer = new DataOutputStream(httpPost.getOutputStream());
            writer.writeBytes("action=getDriver&id="+user.getId());
            writer.flush();
            writer.close();
            buffer = new BufferedReader(new InputStreamReader(httpPost.getInputStream()));
            res = new StringBuilder();
            while ((inputLine = buffer.readLine()) != null) {
                res.append(inputLine);
            }
            dJson = res.toString();
            driver = new Gson().fromJson(dJson,Driver.class);
        }
    %>
    <title>Edit Profile</title>
    <link rel="stylesheet" type="text/css" href="../css/new_style.css">
    <link rel="stylesheet" type="text/css" href="../css/header.css">
    <link rel="stylesheet" type="text/css" href="../css/switch.css">
</head>
<body>
    <div class="container">
		<%@include file="../template/new_header.jsp"%>
        <script>
            var menu = document.getElementById("profile_link");
            menu.setAttribute("class", menu.getAttribute("class")+" active");
        </script>
        <div class="row">
            <div class="col-6 text-left">
                <h2>EDIT PROFILE</h2>
            </div>
        </div>
        <form name="edit_identity" method="POST" action="../IDServices/IdentityService" enctype="multipart/form-data">
            <div class="row">
                <div class="col-2 text-left">
                    <img class="img-circle" src="../IDServices/ImageRetriever?id=<% out.println(user.getId()); %>" onerror="this.src='../img/default_profile.jpeg'">
                </div>
                <div class="col-4" style="margin-top: 10%">
                    <input id="file_name" type="text" readonly="readonly">
                    <input type="file" name="pictFile" class="upload_file" onchange="showFileName(this);">
                </div>
            </div>
            <div class="row">
                <div class="col-2 text-left" style="line-height: 35px,margin-top:5px;">
                    Your Name
                </div>
                <div class="col-4 line-height-medium" style="margin-top:5px;">
                    <input id="current_name" name="newName" type="text">
                </div>
            </div>
            <div class="row">
                <div class="col-2 text-left" style="line-height: 35px">
                    Phone
                </div>
                <div class="col-4 line-height-medium" style="margin-top:10px;">
                    <input id="current_phone" name="newPhone" type="text">
                </div>
            </div>
            <div class="row" style="margin-top: 5px" >
                <div class="col-2 text-left" style="line-height: 35px">
                    Driver Status
                </div>
                <div class="col-4 line-height-medium" style="margin-top:5px;">
                    <label class="switch">
                        <input type="checkbox" name="newStatus" id="current_stat">
                        <span class="slider round"></span>
                    </label>
                </div>
            </div>
            <br>
            <br>
            <div class="row">
                <div class="col-3 text-left">
                    <a class="btn red" href='profile.jsp?id=<%out.println(user.getId());%>'>BACK</a>
                </div>
                <div class="col-3 text-right">
                    <input  name="id" type="hidden" value=<%out.println(user.getId());%>>
                    <input class="btn green" type="submit" value="SAVE">
                </div>
            </div>      
        </form>
    </div>
    <%
        if (user.getStatus().equals("driver")) {
            out.println("<script>document.getElementById('current_stat').checked = true;</script>");
        }
        out.println("<script>document.getElementById('current_name').value = '"+user.getFullname()+"';</script>");
        out.println("<script>document.getElementById('current_phone').value = '"+user.getPhone()+"';</script>");
    %>
    <script>
        function showFileName(inputFile) {
            var arrTemp = inputFile.value.split('\\');
            document.getElementById("file_name").value = arrTemp[arrTemp.length - 1];
        }
        function validateForm() {
            if (document.edit_identity.current_name.value == null || document.edit_identity.current_name.value == "") {
                window.alert("Name can't be blank");
                return false;
            } else if (document.edit_identity.current_phone.value == null || document.edit_identity.current_phone.value == "") {
                window.alert("Phone can't be blank");
                return false;
            } else if (document.edit_identity.current_phone.value.length < 9 || document.edit_identity.current_phone.value.length > 12) {
                window.alert("Phone number should be 9 to 12 characters long");
                return false;
            }
        }
    </script>
</body>
</html>
