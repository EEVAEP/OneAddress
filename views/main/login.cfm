
<cfoutput>
    <div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
        <div id="submitMsgSection" class="text-danger p-2">#rc.loginMsg#</div>
        <div class="row shadow-lg border-0 rounded-4 w-50">
                <div class="leftSection col-md-4 d-flex align-items-center justify-content-center rounded-start-4">
                    <img class="logoLarge" src="/OneAddress/assets/img/addressbook.png" alt="Address Book Logo">
                </div>
                <div class="rightSection bg-white col-md-8 p-4 rounded-end-4">
                    <div class="text-center mb-4">
                        <h3 class="fw-normal mt-3">LOGIN</h3>
                    </div>
                    <form id="loginForm" name="loginForm" method="post">
                        <div class="mb-3">
                            <input type="text" class="inputBox" id="username" name="username" value="#rc.username#" placeholder="Username" autocomplete="username">
                        </div>
                        <div class="mb-3">
                            <input type="password" class="inputBox" id="password" name="password" value="#rc.password#" placeholder="Password">
                        </div>
                        <button data-bs-toggle="tooltip" data-bs-placement="right" title="Enter your username" type="submit" id="loginBtn" name="loginBtn" class="btn text-primary border-primary w-100 rounded-pill pe-auto" disabled>LOGIN</button>
                    </form>
                    
                </div>
        </div>
    </div>
</cfoutput>