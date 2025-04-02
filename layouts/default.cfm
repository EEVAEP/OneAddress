<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Home Page - Address Book</title>
		<link href="/OneAddress/assets/css/bootstrap.min.css" rel="stylesheet">
		<link href="/OneAddress/assets/css/default.css" rel="stylesheet">
		<link href="/OneAddress/assets/css/login.css" rel="stylesheet">
		<script src="/OneAddress/assets/js/fontawesome.js"></script>
		<script src="/OneAddress/assets/js/jquery.js"></script>
    </head>

    <body>

        <cfoutput>
            <!--- Navbar --->
            <nav class="navbar navbar-expand-lg shadow-sm customNavbar px-2">
                <div class="container-fluid">
                    <a class="navbar-brand text-white" href="/">
                        <img src="/OneAddress/assets/img/addressbook.png" alt="Logo" width="30" height="30" class="d-inline-block align-text-top">
                        ADDRESS BOOK
                    </a>
                    <cfif structkeyExists(session, "userId")>
                        <button class="btn text-white text-decoration-none d-print-none" onclick="logOut()">
                            <i class="fa-solid fa-right-from-bracket"></i>
                            Logout
                        </button>
                    <cfelse>
                        <cfif rc.action NEQ "main.login">
                            <a class="text-white text-decoration-none d-print-none" href="#buildURL('main.login')#">
                                <i class="fa-solid fa-right-to-bracket"></i>
                                Login
                            </a>
                        <cfelse>
                            <a class="text-white text-decoration-none d-print-none" href="#buildURL('main.signup')#">
                                <i class="fa-solid fa-user"></i>
                                SignUp
                            </a>
                        </cfif>
                    </cfif>
                </div>
            </nav>

            #body#
        </cfoutput>
        <footer class="text-white text-center ">
        <p>&copy; 2025 Address Book. All Rights Reserved.</p>
    </footer>
		<script src="/OneAddress/assets/js/bootstrap.bundle.min.js"></script>
		<script src="/OneAddress/assets/js/default.js"></script>
		<script src="/OneAddress/assets/js/login.js"></script>
    </body>
</html>