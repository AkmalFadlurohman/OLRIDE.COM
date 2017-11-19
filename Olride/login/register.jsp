<!DOCTYPE html>
<html>
<head>
	<title>Sign Up to Olride</title>
    <link rel="stylesheet" type="text/css" href="../css/default_style.css">
    <link rel="stylesheet" type="text/css" href="../css/sign_up.css">
</head>
<body>
	<div class="frame">
        <div class="signup_header">
            <div class="horizontal_line"></div>
            <h1>SIGNUP</h1>
            <div class="horizontal_line"></div>
        </div>
        <p id="errorCredential" style="text-align: center;"></p>
        <form name="sign_up" method="post" action="../IDServices/Register">
            <p id="error_signup" style="text-align: center;"></p>
            <div class="signup_container">
                <div class="form_name">
                    <div class="signup_form">
                        Your Name
                    </div>
                    <div class="signup_form">
                        Username
                    </div>
                    <div class="signup_form">
                        Email
                    </div>
                    <div class="signup_form">
                        Password
                    </div>
                    <div class="signup_form">
                        Confirm Password
                    </div>
                    <div class="signup_form">
                        Phone Number
                    </div>
                </div>
                <div class="form_field">
                    <div class="signup_form">
                         <input type="text" name="fullname">
                    </div>
                    <div class="signup_form">
                       <input type="text" name="username" >
                    </div>
                    <div class="signup_form">
                        <input type="Email" name="email">
                    </div>
                    <div class="signup_form">
                        <input type="Password" name="user_password">
                    </div>
                    <div class="signup_form">
                        <input type="Password" name="confirm_password">
                    </div>
                    <div class="signup_form">
                        <input type="text" name="phone">
                    </div>
                </div>
                <div class="driver_form">
                    <input type="checkbox" name="is_driver" value="true" style="width: 30px">
                    <label for="is_driver">Also sign me up as a driver!</label>
                </div>
                <div class="form_button">
                    <a class="have_account" href="../login/login.jsp">Already have an account?</a>
                    <input type="submit" class="button green signup" value="REGISTER">
                </div>
            </div>
        </form>
	</div>
	<%
        		String script = null;
        		script = (String) request.getAttribute("script");
        		if (script != null) {
        			out.println(script);
        		}
    %>
    <script>
        function validateForm() {
            var email = document.sign_up.user_email.value;
            var re = /[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}/igm;
            if (document.sign_up.full_name.value == null || document.sign_up.full_name.value == "") {
                window.alert("Please fill all the required fields");
                return false;
            } else if (document.sign_up.username.value == null || document.sign_up.username.value == "") {
                window.alert("Please fill all the required fields");
                return false;
            } else if (document.sign_up.user_email.value == null || document.sign_up.user_email.value == "") {
                window.alert("Please fill all the required fields");
                return false;
            } else if (document.sign_up.user_password.value == null || document.sign_up.user_password.value == "") {
                window.alert("Please fill all the required fields");
                return false;
            } else if (document.sign_up.confirm_password.value == null || document.sign_up.confirm_password.value == "") {
                window.alert("Please fill all the required fields");
                return false;
            } else if (document.sign_up.user_phone.value == null || document.sign_up.user_phone.value == "") {
                window.alert("Please fill all the required fields");
                return false;
            } else if (document.sign_up.username.value.length > 20) {
                window.alert("Username should be 1 to 20 characters long");
                return false;
            } else if (!re.test(document.sign_up.user_email.value)) {
                window.alert("Please enter a valid email address");
                return false;
            } else if (document.sign_up.user_password.value !== document.sign_up.confirm_password.value) {
                window.alert("The passwords you entered didn't match");
                return false;
            } else if ((document.sign_up.user_phone.value.length < 9) || (document.sign_up.user_phone.value.length > 12)) {
                window.alert("Phone number should be 9 to 12 characters long");
                return false;
            }
        }
    </script>

</body>
</html>
