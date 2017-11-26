<%@page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.util.*,java.net.URL,javax.xml.namespace.QName,javax.xml.ws.Service,javax.servlet.*,javax.servlet.http.*,com.google.gson.Gson,com.olride.bean.*,com.olride.IDServices.*,com.olride.OjolServices.LocationManagerInterface" %>
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
    <title>Edit Location</title>
    <link rel="stylesheet" type="text/css" href="../css/new_style.css">
    <link rel="stylesheet" type="text/css" href="../css/location.css">
    <script>
        function showEdit(editID,saveID,locID,dummylocID,currentlocID,formID,deleteID,cancelID) {
            showSave(editID,saveID);
            showCancel(deleteID,cancelID);
            document.getElementById(locID).style.display = "none";
            document.getElementById(dummylocID).value = document.getElementById(locID).innerHTML;
            document.getElementById(currentlocID).value = document.getElementById(locID).innerHTML;
            document.getElementById(formID).style.display = "block";
        }
        function showSave(editID,saveID) {
            document.getElementById(editID).style.display = "none";
            document.getElementById(saveID).style.display = "block";
        }
        function showCancel(deleteID,cancelID) {
            document.getElementById(deleteID).style.display = "none";
            document.getElementById(cancelID).style.display = "block";
        }
        function copyDummytoNewLoc(dummylocID,newlocID) {
            var temp = document.getElementById(dummylocID).value;
            document.getElementById(newlocID).value = temp;
        }
        function hideEdit(editID,saveID,locID,formID,deleteID,cancelID) {
            document.getElementById(editID).style.display = "block";
            document.getElementById(saveID).style.display = "none";
            document.getElementById(locID).style.display = "block";
            document.getElementById(formID).style.display = "none";
            document.getElementById(deleteID).style.display = "block";
            document.getElementById(cancelID).style.display = "none";
        }
        function validateAddLoc(docID) {
            var loc = document.getElementById(docID).value;
            if (loc == null || loc == "") {
                window.alert("Location can't be blank");
                return false;
            }
        }
        function confirmDelete(url) {
            var retVal = confirm("Are you sure you want to delete this preferred location?");
            if (retVal == true) {
                window.open(url,"_self");
            }
        }
    </script>
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
        URL url = new URL(" http://localhost:8080/Olride/OjolServices/LocationManager?wsdl");
        
        QName qname = new QName("http://OjolServices.olride.com/", "LocationManagerService");

        Service service = Service.create(url, qname);
        LocationManagerInterface LM = service.getPort(LocationManagerInterface.class);
    %>
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-3"><span class="logo"></span></div>
            <div class="col-3 text-right">
                <p>
                    Hi, <b><% out.println(user.getUsername()); %></b> !<br>
                    <a href="../IDServices/Logout?id=<%out.println(user.getId());%>">Logout</a>
                </p>
            </div>
        </div>
        <div class="row">
            <div class="container">
                <div class="row">
                    <div class="col-1 text-left"></div>
                    <div class="col-4 text-left">
                        <h2>EDIT PREFERED LOCATION</h2>
                        <span id="driver-id" style="display: none">VGdWZUZ2dlJlUkM5eWpjVDcyQXJoZz09</span>
                    </div>
                    <div class="col-1 text-left"></div>
                </div>

                <div class="row">
                    <div class="col-1 text-left"></div>
                    <div class="col-4 text-left">
                        <table width="100%" border="1">
                            <tr>
                                <th width="10%">No</th>
                                <th width="65%">Location</th>
                                <th width="20%">Actions</th>
                            </tr>

                            <%
                                if (dJson != null) {
                                    int size = LM.retrieveLocation(driver.getId()).length;
                                    String[] locations = new String[size];
                                    for (int i=0;i<size;i++) {
                                        locations[i] = LM.retrieveLocation(driver.getId())[i];
                                    }
                                    for (int i=0;i<size;i++) {
                                        out.println("<tr>");
                                            out.println("<td>"+(i+1)+"</td>");
                                            out.println("<td>");
                                                out.println("<div id='prefloc"+(i+1)+"'>"+locations[i]+"</div>");
                                                out.println("<div id='form_prefloc"+(i+1)+"' style='display: none'>");
                                                    out.println("<input type='text' style=' height: 100%, width: 100%;' id='dummy_prefloc"+(i+1)+"' onkeyup=\"copyDummytoNewLoc('dummy_prefloc"+(i+1)+"','new_prefloc"+(i+1)+"');\">");
                                                out.println("</div>");
                                            out.println("</td>");
                                            out.println("<td>");
                                                out.println("<div class='edit_operation'>");
                                                    out.println("<div class='edit_button' id='edit_prefloc"+(i+1)+"' onClick=\"showEdit('edit_prefloc"+(i+1)+"','save_prefloc"+(i+1)+"','prefloc"+(i+1)+"','dummy_prefloc"+(i+1)+"','current_prefloc"+(i+1)+"','form_prefloc"+(i+1)+"','delete_prefloc"+(i+1)+"','cancel_edit"+(i+1)+"');\">✎</div>");
                                                    out.println("<div id='save_prefloc"+(i+1)+"' style='display: none'>");
                                                        out.println("<form name='edit_prefloc_form' method='POST' action='../IDServices/IdentityService' style='display: inline;' onsubmit=\"return validateAddLoc('dummy_prefloc"+(i+1)+"');\">");
                                                            out.println("<input class='save_button' type='submit' value='Save'>");
                                                            out.println("<input type='hidden' name='current_prefloc' id='current_prefloc"+(i+1)+"'>");
                                                            out.println("<input type='hidden' name='new_prefloc' id='new_prefloc"+(i+1)+"'>");
                                                            out.println("<input type='hidden' name='id' value="+user.getId()+">");
                                                            out.println("<input type='hidden' name='action' value='updateLocation'>");
                                                        out.println("</form>");
                                                    out.println("</div>");
                                                    out.println("<div class='delete_container' id='delete_prefloc"+(i+1)+"'>");
                                                            out.println("<form name='delete_prefloc_form' method='POST' action='../IDServices/IdentityService' style='display: inline;'>");
                                                                out.println("<input type='hidden' name='id' value="+user.getId()+">");
                                                                out.println("<input type='hidden' name='delPrefLoc' value='"+locations[i]+"'>");
                                                                out.println("<input type='hidden' name='action' value='deleteLocation'>");
                                                                out.println("<input class='delete_button' type='submit' value='✖'>");
                                                            out.println("</form>");
                                                    out.println("</div>");
                                                    out.println("<div class='cancel_button' id='cancel_edit"+(i+1)+"' style='display: none;' onClick=\"hideEdit('edit_prefloc"+(i+1)+"','save_prefloc"+(i+1)+"','prefloc"+(i+1)+"','form_prefloc"+(i+1)+"','delete_prefloc"+(i+1)+"','cancel_edit"+(i+1)+"');\">Cancel</div>");
                                                out.println("</div>");
                                        out.println("</td>");
                                        out.println("</tr>");
                                    }
                                }
                            %>

                        </table>
                    </div>
                    <div class="col-1 text-left"></div>
                </div>

                <br>
                <div class="row">
                    <div class="col-1"></div>
                    <div class="col-4">
                        <h3>ADD NEW LOCATION:</h3>
                    </div>
                    <div class="col-1"></div>
                </div>
                <div class="row">
                    <div class="col-1"></div>
                    <div class="col-4">
                        <form name="add_location" action="../IDServices/IdentityService" method="POST">
                            <input type="text" name="new_location" style="width:76%;height: 30px; font-size: medium">
                            <input type="hidden" name="action" value="addLocation">
                            <input type="hidden" name="id" value=<%out.println(user.getId());%>>
                            <input class="btn green" type="submit" value="ADD" style="width:20%;margin-left: 10px">
                        </form>
                    </div>
                    <div class="col-1"></div>
                </div>
                <br>
                <div class="row">
                    <div class="col-1"></div>
                    <div class="col-4">
                        <a class="btn red" href="profile.jsp?id=<%out.println(user.getId());%>">BACK</a>
                    </div>
                    <div class="col-1"></div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
