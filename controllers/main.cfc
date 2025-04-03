component accessors=true {
    property addressbookService;

    function init(fw) {
        variables.fw=arguments.fw;
        return this;
    }

    function default() {
        param name="rc.contacts.data" default=[];
        param name="rc.hobbies.data" default=[];
        local.contacts = variables.addressbookService.fetchContacts();
        local.hobbies = variables.addressbookService.fetchHobbies();
        rc.contacts = local.contacts.data;
        rc.hobbies = local.hobbies.data;
    }

    function signup(struct rc) {
        param name="rc.signupMsg" default="";
        param name="rc.fullname" default="";
        param name="rc.email" default="";
        param name="rc.username" default="";
        param name="rc.password" default="";
        param name="rc.confirmpassword" default="";
        if(structKeyExists(rc, "submitBtn")) {
            local.signupResult = variables.addressbookService.signup(
                fullname = rc.fullname,
                email = rc.email,
                username = rc.username,
                password = rc.password,
                confirmpassword = rc.confirmpassword
            );
            if (structKeyExists(local.signupResult, "errors") && isArray(local.signupResult.errors) && arrayLen(local.signupResult.errors) > 0) {
                rc.signupMsg = ArrayToList(local.signupResult.errors, "<br>"); 
            }
            else if (local.signupResult.success) {
                rc.signupMsg = "Signup successfull. <a href='#variables.fw.buildURL('main.login')#'>Login</a> to continue.";
            }
            else {
                rc.signupMsg = local.signupResult.message;
            }
        }
    }

    function login(struct rc) {
        param name="rc.loginMsg" default="";
        param name="rc.username" default="";
        param name="rc.password" default="";
        if(structKeyExists(rc, "loginBtn")) {
            local.loginResult = variables.addressbookService.login(
                username = rc.username,
                password = rc.password
            );

            if (local.loginResult.success) {
                variables.fw.redirect('main.default');
            }
            else {
                rc.loginMsg = local.loginResult.message;
            }
        }
    }

    public string function fetchContacts(struct rc) {
        param name="local.contacts.data" default=[];
        local.contacts = variables.addressbookService.fetchContacts(
            contactId = rc.contactId
        );
        variables.fw.renderData( "json", local.contacts );
    }

    public string function logout() {
        local.response = { "success" = false };
        structClear(session);
        local.response.success = true;
        variables.fw.renderData( "json", local.response );
    }

    public string function modifyContacts(struct rc) {
        local.response = {
            "success" = false,
            "message" = ""
        }
        if (!structKeyExists(session, "isLoggedIn")) {
            local.response.success = false;
            local.response.message = "User not logged in!";
            variables.fw.renderData( "json", local.response );
            return;
        }
        local.response = variables.addressbookService.modifyContacts(
            contactId = rc.contactId,
            contactTitle = rc.contactTitle,
            contactFirstName = rc.contactFirstName,
            contactLastName = rc.contactLastName,
            contactGender = rc.contactGender,
            contactDOB = rc.contactDOB,
            contactImage = rc.contactImage,
            contactAddress = rc.contactAddress,
            contactStreet = rc.contactStreet,
            contactPincode = rc.contactPincode,
            contactEmail = rc.contactEmail,
            contactPhone = rc.contactPhone,
            hobbyIdsToInsert = rc.hobbyIdsToInsert,
            hobbyIdsToDelete = rc.hobbyIdsToDelete
        );
        variables.fw.renderData( "json", local.response );
    }

    public string function deleteContact(struct rc) {
        local.response = {
            "success" = false,
            "message" = ""
        }
        if (!structKeyExists(session, "isLoggedIn")) {
            local.response.success = false;
            local.response.message = "User not logged in!";
            variables.fw.renderData( "json", local.response );
            return;
        }
        local.response = variables.addressbookService.deleteContact(
            contactId = rc.contactId,
            userId = session.userId
        );
        variables.fw.renderData( "json", local.response );
    }
}