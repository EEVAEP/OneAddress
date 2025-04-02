
$("#username, #password").on("input", function () {
	const username = $("#username").val();
	const password = $("#password").val();
	const loginBtn = $("#loginBtn");

    loginBtn.prop("disabled", false);
    loginBtn.attr("data-bs-original-title", "");

	if (username.trim() == "") {
		loginBtn.prop("disabled", true);
		loginBtn.attr("data-bs-original-title", "Enter your username");
	}
	else if (password.trim() == "") {
		loginBtn.prop("disabled", true);
		loginBtn.attr("data-bs-original-title", "Enter your password");
	}

});

$(document).ready(function(){
	// Enable custom tooltip styling using bootstrap
	$('[data-bs-toggle="tooltip"]').tooltip();
});
