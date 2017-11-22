
<html>
    <head>
        <title>DAGO-JEK | Order</title>
        <link rel="stylesheet" type="text/css" href="../css/new_style.css">
    </head>
    <body>
        <div class="container">
            <div class="row">
                <div class="col-3"><span class="logo"></span></div>
                <div class="col-3 text-right">
                    <p class="user-action">
                        Hi, <b>fadhilimamk</b> !<br>
                        <a href="/">Logout</a>
                    </p>
                </div>
            </div>
            <div class="row">
                <a class="col-2 tab text-center active" href="/index.php/main/order?u=VGdWZUZ2dlJlUkM5eWpjVDcyQXJoZz09">ORDER</a>
                <a class="col-2 tab text-center" href="/index.php/main/history?u=VGdWZUZ2dlJlUkM5eWpjVDcyQXJoZz09">HISTORY</a>
                <a class="col-2 tab text-center" href="/index.php/main/profil?u=VGdWZUZ2dlJlUkM5eWpjVDcyQXJoZz09">MY PROFILE</a>
            </div>
            <div class="row">
                <div class="col-6"><h1>MAKE AN ORDER</h1></div>
                <span id="customer-id" style="display: none">VGdWZUZ2dlJlUkM5eWpjVDcyQXJoZz09</span>
            </div>
            <div class="row">
            <div style="width:25%; float:left">
                    <div id="page-tab-location" class="page-tab selected">
                        <div class="page-tab-image">
                            <div class="circle">1</div>
                        </div>
                        <div class="page-tab-content">
                            Select Destination
                        </div>
                    </div>
                </div>
                <div style="width:25%; float:left">
                    <div id="page-tab-driver" class="page-tab">
                        <div class="page-tab-image">
                            <div class="circle">2</div>
                        </div>
                        <div class="page-tab-content">
                            Select a Driver
                        </div>
                    </div>
                </div>
                <div style="width:25%; float:left">
                    <div id="page-tab-finish" class="page-tab">
                        <div class="page-tab-image">
                            <div class="circle">3</div>
                        </div>
                        <div class="page-tab-content">
                            Chat Driver
                        </div>
                    </div>
                </div>
                <div style="width:25%; float:left">
                    <div id="page-tab-finish" class="page-tab">
                        <div class="page-tab-image">
                            <div class="circle">4</div>
                        </div>
                        <div class="page-tab-content">
                            Complete your order
                        </div>
                    </div>
                </div>
            </div>
            <br>
            <br>
            <div id="order-page-location">
                <form id="orderForm">
                    <div class="row">
                        <div class="col-2" style="line-height: 40px">
                            <span style="padding-left: 30%;">Picking Point</span> <br>
                        </div>
                        <div class="col-4" style="line-height: 30px">
                            <input id="orderPickup" style="width: 80%;height: 30px;padding-left: 5px;font-size: medium" type="text" name="picking_point" placeholder="Pick up point">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-2" style="line-height: 40px">
                            <span style="padding-left: 30%">Destination</span> <br>
                        </div>
                        <div class="col-4" style="line-height: 30px">
                            <input id="orderDestination" style="width: 80%; height: 30px;padding-left: 5px;font-size: medium" type="text" name="destination" placeholder="Destination">
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-2" style="line-height: 40px">
                            <span style="padding-left: 30%">Preferred Driver</span>
                        </div>
                        <div class="col-4">
                            <input id="orderPreferredDriver" style="width: 80%;height: 30px;padding-left: 5px;font-size: medium" type="text" name="driver" placeholder="(optional)"><br>
                        </div>
                    </div>
                    <br>
                    <br>
                    <br>
                    <div class="row text-center">
                        <a href="#" class="btn green" style="font-size: 2em" onclick="makeOrder()">Next</a>
                    </div>
                </form>
            </div>
    
            <div id="order-page-driver">
                <div style="width: 100%; border: 1px solid black; border-radius: 10px;">
                    <h2 style="margin-left: 10px; margin-top: 0px">PREFERRED DRIVERS: </h2>
                    <div id="driver-preferred-result" style="margin: 0 30px 30px 30px">
                        <p id="driver-preferred-empty" class="text-center" style="font-size: large; color: #989898; margin: 30px">Nothing to display :(</p>
                    </div>
                </div>
                <br>
                <div style="width: 100%; border: 1px solid black; border-radius: 10px;">
                    <h2 style="margin-left: 10px; margin-top: 0px">OTHER DRIVERS: </h2>
                    <div id="driver-search-result" style="margin: 0 30px 30px 30px">
                        <p id="driver-preferred-empty" class="text-center" style="font-size: large; color: #989898; margin: 30px">Nothing to display :(</p>
                    </div>
                </div>
            </div>
    
            <div id="order-page-finish" style="width: 100%;">
                <h2 style="margin-left: 10px; margin-top: 0px">HOW WAS IT? </h2>
                <div id="driver-finish-order" class="text-center profil" style="padding-bottom: 60px">
                    <p id="driver-preferred-empty" class="text-center" style="font-size: large; color: #989898; margin: 30px">Nothing to display :(</p>
                </div>
            </div>
    
    
        </div>
    
        <script type="text/javascript" src="/order.js"></script>
    </body>
    </html>