
function logOut() {
	if (confirm("Confirm logout")) {
		$.ajax({
			type: "POST",
			url: "/OneAddress/index.cfm?action=main.logout",
			success: function(response) {
                
				if (response.success) {
					location.reload();
				}
				else {
                    alert("Sorry, Unable to logout!");
				}
			},
			error: function () {
				alert("Sorry, Unable to logout!");
			}
		});
	}
}

function viewContact(event) {
	const viewContactName = $("#viewContactName");
	const viewContactGender = $("#viewContactGender");
	const viewContactDOB = $("#viewContactDOB");
	const viewContactAddress = $("#viewContactAddress");
	const viewContactPincode = $("#viewContactPincode");
	const viewContactEmail = $("#viewContactEmail");
	const viewContactPhone = $("#viewContactPhone");
	const viewContactPicture = $("#viewContactPhoto");
	const viewContactHobbies = $("#viewContactHobby");

	$.ajax({
		type: "POST",
		url: "/OneAddress/index.cfm?action=main.fetchContacts",
		data: { contactId: event.target.value },
		success: function(response) {
            console.log(response);
			const { title, firstname, lastname, gender, dob, photo, address, street,  pincode, email, phone, hobbyNames } = response.data[0];
			const formattedDOB = new Date(dob).toLocaleDateString('en-US', {
				year: "numeric",
				month: "long",
				day: "numeric",
			})

			viewContactName.text(`${title} ${firstname} ${lastname}`);
			viewContactGender.text(gender);
			viewContactDOB.text(formattedDOB);
			viewContactAddress.text(`${address}, ${street}`);
			viewContactPincode.text(pincode);
			viewContactEmail.text(email);
			viewContactPhone.text(phone);
			viewContactPicture.attr("src", `./assets/uploads/${photo}`);
			viewContactHobbies.text(hobbyNames);
			$('#viewContactModal').modal('show');
		}
	});
}

function deleteContact(event) {
	if (confirm("Delete this contact?")) {
		$.ajax({
			type: "POST",
			url: "/OneAddress/index.cfm?action=main.deleteContact",
			data: { contactId: event.target.value },
			success: function(response) {
				
				if (response.message === "Success") {
					location.reload();
				}
			}
		});
	}
}

function createContact() {
	$("#contactManagementHeading").text("CREATE CONTACT");
	$(".error").text("");
	$("#contactManagement")[0].reset();
	$("#editContactId").val("");
	$("#contactManagementMsgSection").text("");
	$("#editContactHobby").attr("defaultValue", []);
	$('#contactManagementModal').modal('show');
	$("#editContactPicture").attr("");
}

function editContact(event) {
	$("#contactManagementHeading").text("EDIT CONTACT");
	$(".error").text("");
	$("#contactManagementMsgSection").text("");
	$.ajax({
		type: "POST",
		url: "/OneAddress/index.cfm?action=main.fetchContacts",
		
		data: { contactId: event.target.value },
		success: function(response) {
			const { contactid, title, firstname, lastname, gender, dob, photo, address, street, pincode, email, phone, hobbyIds } = response.data[0];
			const formattedDOB = new Date(dob).toLocaleDateString('fr-ca');

			$("#editContactId").val(contactid);
			$("#editContactTitle").val(title);
			$("#editContactFirstName").val(firstname);
			$("#editContactLastName").val(lastname);
			$("#editContactGender").val(gender);
			$("#editContactDOB").val(formattedDOB);
			$("#editContactImage").val("");
			$("#editContactPicture").attr("src", `/OneAddress/assets/uploads/${photo}`);
			$("#editContactAddress").val(address);
			$("#editContactStreet").val(street);
			$("#editContactPincode").val(pincode);
			$("#editContactEmail").val(email);
			$("#editContactPhone").val(phone);
			$("#editContactHobby").val(hobbyIds);
			$("#editContactHobby").attr("defaultValue", hobbyIds);
			$('#contactManagementModal').modal('show');
		}
	});
}

function validateContactForm() {
    const fields = [
        { id: "editContactTitle", errorId: "titleError", message: "Please select one option", regex: null },
        { id: "editContactFirstName", errorId: "firstNameError", message: "Please enter your First name", regex: /^[a-zA-Z ]+$/ },
        { id: "editContactLastName", errorId: "lastNameError", message: "Please enter your Last name", regex: /^[a-zA-Z ]+$/ },
        { id: "editContactGender", errorId: "genderError", message: "Please select one option", regex: null },
        { id: "editContactDOB", errorId: "dobError", message: "Please select your DOB", regex: null },
        { id: "editContactAddress", errorId: "addressError", message: "Please enter your address", regex: null },
        { id: "editContactStreet", errorId: "streetError", message: "Please enter your street", regex: null },
        { id: "editContactPincode", errorId: "pincodeError", message: "Please enter your pin", regex: /^\d{6}$/, customError: "Pincode should be six digits" },
        { id: "editContactEmail", errorId: "emailError", message: "Please enter your mail", regex: /^[^\s@]+@[^\s@]+\.[^\s@]+$/ },
        { id: "editContactPhone", errorId: "phoneError", message: "Please enter your contact number", regex: /^\d{10}$/, customError: "Phone number should be 10 characters long and contain only digits" },
        { id: "editContactHobby", errorId: "hobbyError", message: "Please select atleast one user hobby", regex: null },
    ];

    let valid = true;

    fields.forEach(field => {
		const fieldValue = $(`#${field.id}`).val();
        const value = Array.isArray(fieldValue) ? fieldValue.toString() : fieldValue.trim();

        if (value === "" || (field.regex && !field.regex.test(value))) {
            const errorMessage = value === "" ? field.message : field.customError || field.message;
            $(`#${field.errorId}`).text(errorMessage);
            valid = false;
        } else {
            $(`#${field.errorId}`).text("");
        }
    });

    return valid;
}

$("#contactManagement").submit(function(event) {
	event.preventDefault();
	const thisForm = this;
	const contactManagementMsgSection = $("#contactManagementMsgSection");
	const currentContactHobbies = $("#editContactHobby").val();
	const previousContactHobbies = ($("#editContactHobby").attr("defaultValue") || "").split(",");

	const contactDataObj = {
		contactId: $("#editContactId").val(),
        contactTitle: $("#editContactTitle").val(),
        contactFirstName: $("#editContactFirstName").val(),
        contactLastName: $("#editContactLastName").val(),
        contactGender: $("#editContactGender").val(),
        contactDOB: $("#editContactDOB").val(),
		contactImage: $("#editContactImage")[0].files[0] || "",
        contactAddress: $("#editContactAddress").val(),
        contactStreet: $("#editContactStreet").val(),
        contactPincode: $("#editContactPincode").val(),
        contactEmail: $("#editContactEmail").val(),
        contactPhone: $("#editContactPhone").val(),
		hobbyIdsToInsert: currentContactHobbies.filter(element => !previousContactHobbies.includes(element.trim())).join(","),
		hobbyIdsToDelete: previousContactHobbies.filter(element => !currentContactHobbies.includes(element.trim())).join(",")
	};
	
	// Convert object to formData
	const contactData = new FormData();
	Object.keys(contactDataObj).forEach(key => {
		contactData.append(key, contactDataObj[key]);
	});

	contactManagementMsgSection.text("");
	if (!validateContactForm()) return;
	$.ajax({
		type: "POST",
		url: "/OneAddress/index.cfm?action=main.modifyContacts",
		data: contactData,
		enctype: 'multipart/form-data',
		processData: false,
		contentType: false,
		success: function(response) {
			console.log(response);
			
			if (response.message === "Success") {
				contactManagementMsgSection.css("color", "green");
				loadHomePageData();
				if ($("#editContactId").val() === "") {
					thisForm.reset();
				}
			}
			else {
				contactManagementMsgSection.css("color", "red");
			}
			contactManagementMsgSection.text(response.message);
		},
		error: function () {
			contactManagementMsgSection.text("We encountered an error!");
		}
	});
});



function loadHomePageData() {
	$('#mainContent').load(document.URL +  ' #mainContent');
}
