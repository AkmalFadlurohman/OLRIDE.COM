<div class="row">
    <div class="col-3"><span class="logo"></span></div>
    <div class="col-3 text-right">
        <p class="user-action">
            Hi, <b><% out.println(user.getUsername()); %></b> !<br>
            <a href="../IDServices/Logout?id=<%out.println(user.getId());%>">Logout</a>
        </p>
    </div>
</div>
<div class="row">
    <a id="order_link" class="col-2 tab text-center" href="../order/order.jsp?id=<%out.println(user.getId());%>">ORDER</a>
    <a id="history_link" class="col-2 tab text-center" href="../history/transaction_history.jsp?id=<%out.println(user.getId());%>">HISTORY</a>
    <a id="profile_link" class="col-2 tab text-center" href="../profile/profile.jsp?id=<%out.println(user.getId());%>">MY PROFILE</a>
</div>