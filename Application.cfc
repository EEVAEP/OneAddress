component extends="framework.one" {
    this.sessionManagement = true;

    function setupRequest() {
       
        controller('security.checkAuthorization');
    }
}