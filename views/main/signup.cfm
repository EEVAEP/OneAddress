<cfoutput>
    <div class="container d-flex flex-column justify-content-center align-items-center py-5 mt-5">
        <div id="submitMsgSection" class="p-2">#rc.signupMsg#</div>
        <div class="row shadow-lg border-0 rounded-4 w-75">
                <div class="leftSection col-md-4 d-flex align-items-center justify-content-center rounded-start-4">
                    <img class="logoLarge" src="/OneAddress/assets/img/addressbook.png" alt="Address Book Logo">
                </div>
                <div class="rightSection bg-white col-md-8 p-4 rounded-end-4">
                    <div class="text-center mb-2">
                        <h3 class="fw-normal">SIGN UP</h3>
                    </div>
                    <form id="signupForm" name="signupForm" method="post" enctype="multipart/form-data">
                        <div class="mb-3">
                            <input type="text" class="inputBox" id="fullname" name="fullname" placeholder="Full Name" maxlength="40">
                            <div class="text-danger signup-error" id="fullnameError"></div>
                        </div>
                        <div class="mb-3">
                            <input type="email" class="inputBox" id="email" name="email" placeholder="Email ID" autocomplete="username" maxlength="40">
                            <div class="text-danger signup-error" id="emailError"></div>
                        </div>
                        <div class="mb-3">
                            <input type="text" class="inputBox" id="username" name="username" placeholder="Username" autocomplete="username" maxlength="40">
                            <div class="text-danger signup-error" id="usernameError"></div>
                        </div>
                        <div class="mb-3">
                            <input type="password" class="inputBox" id="password" name="password" placeholder="Password">
                            <div class="text-danger signup-error" id="passwordError"></div>
                        </div>
                        <div class="mb-3">
                            <input type="password" class="inputBox" id="confirmPassword" name="confirmPassword" placeholder="Confirm Password">
                            <div class="text-danger signup-error" id="confirmPasswordError"></div>
                        </div>
                        
                        <button type="submit" name="submitBtn" id="submitBtn" class="btn text-primary border-primary w-100 rounded-pill">REGISTER</button>
                    </form>
                    <div class="text-center mt-3">
                        Already have an account? <a class="text-decoration-none" href="index.cfm">Login</a>
                    </div>
                </div>
        </div>
    </div>
</cfoutput>