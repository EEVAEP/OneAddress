<cfcomponent displayname="addressbookComponent">
    <cffunction name="hashPassword" access="private">
		<cfargument name="pass" type="string" required="true">
		<cfargument name="salt" type="string" required="true">
		<cfset local.saltedPass = arguments.pass & arguments.salt>
		<cfset local.hashedPass = hash(local.saltedPass,"SHA-256","UTF-8")>	
		<cfreturn local.hashedPass>
	</cffunction>

    <cffunction name="signup" returnType="struct" access="public">
        <cfargument required="true" name="fullName" type="string">
        <cfargument required="true" name="email" type="string">
        <cfargument required="true" name="userName" type="string">
        <cfargument required="true" name="password" type="string">
        <cfargument required="true" name="confirmpassword" type="string">
        <cfset local.response = {
            "success" = false,
            "message" = "",
            "errors" = []
        }>
        <cfif len(trim(arguments.fullName)) EQ 0>
                <cfset arrayAppend(local.response.errors, "*Fullname is required")>
        <cfelseif NOT reFindNoCase("^[A-Za-z]+(\s[A-Za-z]+)*$", arguments.fullName)>
            <cfset arrayAppend(local.response.errors, "*Enter a valid fullname")>
        </cfif>
        
        <cfif len(trim(arguments.email)) EQ 0>
                <cfset arrayAppend(local.response.errors, "*Email is required")>
        <cfelseif NOT reFindNoCase("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", arguments.email)>
                <cfset arrayAppend(local.response.errors, "*Enter a valid email")>
        </cfif>
        
        <cfif len(trim(arguments.userName)) EQ 0>
                <cfset arrayAppend(local.response.errors, "*Please enter the username")>
        <cfelseif NOT reFindNoCase("^[a-zA-Z_][a-zA-Z0-9_]{3,13}$", arguments.userName)>
                <cfset arrayAppend(local.response.errors, "*Please enter a valid username")>
        </cfif>
        
        <cfif len(trim(arguments.password)) EQ 0>
                <cfset arrayAppend(local.response.errors, "*Please enter the password")>
        <cfelseif NOT reFindNoCase("^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$", arguments.password)>
                <cfset arrayAppend(local.response.errors, "*Please enter a valid password (minimum 8 characters, 1 lowercase, 1 uppercase, 1 special character)")>
        </cfif>

        <cfif arrayLen(local.response.errors) GT 0>
            <cfreturn local.response>
        </cfif>
    
        <cfif len(trim(arguments.confirmPassword)) EQ 0>
            <cfset arrayAppend(local.response.errors, "*Password confirmation is required")>
        <cfelseif arguments.confirmPassword NEQ arguments.password>
                <cfset arrayAppend(local.response.errors, "*Password confirmation does not match the password")>
        </cfif>

       <cfquery name="local.checkUsernameAndEmail" datasource="addressbook">
            SELECT
				username
			FROM
				register
			WHERE
				username = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
				OR email = <cfqueryparam value = "#arguments.email#" cfsqltype = "cf_sql_varchar">
        </cfquery>
        <cfif local.checkUsernameAndEmail.RecordCount>
            <cfset local.response.message = "Email or Username already exists!">
            <cfreturn local.response>
		<cfelse>
            <cfset local.salt = generateSecretKey("AES")>
            <cfset local.hashedPassword = hashPassword(arguments.password, local.salt)>

            <cfquery name="local.addUser" datasource="addressbook">
                INSERT INTO
					register (
						fullname,
						email,
						username,
						password,
						salt
					)
				VALUES (
					<cfqueryparam value = "#arguments.fullName#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#arguments.email#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">,
					<cfqueryparam value = "#local.hashedPassword#" cfsqltype = "cf_sql_char">,
					<cfqueryparam value = "#local.salt#" cfsqltype = "cf_sql_varchar">
				)
            </cfquery>
            <cfset local.response.success = true>
            <cfreturn local.response>
        </cfif>
    </cffunction>

    <cffunction name="login" returnType="struct" access="public">
        <cfargument required="true" name="userName" type="string">
        <cfargument required="true" name="password" type="string">
        <cfset local.response = {
            "success" = false,
            "message" = ""
        }>
        <cftry>
            <cfquery name="local.getUserDetails" datasource="addressbook">
                SELECT
                    id,
                    username,
                    fullname,
                    password,
                    salt
                FROM
                    register
                WHERE
                    username = <cfqueryparam value = "#arguments.userName#" cfsqltype = "cf_sql_varchar">
                    
            </cfquery>
            <cfif local.getUserDetails.RecordCount EQ 0>
                <cfset local.response.message = "Wrong username or password!">
                <cfreturn local.response>
            <cfelse>
                <cfset local.salt = local.getUserDetails.salt>
			    <cfset local.hashedPassword  = hashPassword(arguments.password, local.salt)>
                <cfif local.hashedPassword  EQ  local.getUserDetails.password>
                    
                    <cfset session.isLoggedIn = true>
                    <cfset session.userId = local.getUserDetails.id>
                    <cfset session.username = local.getUserDetails.username>
                </cfif>
                <cfset local.response.success = true>
                <cfreturn local.response>
            </cfif>
            <cfcatch type="any">
                <cfreturn local.response>
            </cfcatch>
        </cftry>
    </cffunction>

    <cffunction name="fetchContacts" access="public" returntype="struct"> 
        <cfargument name="userId" type="integer" required="false" default="0">
        <cfargument name="contactId" type="integer" required="false" default="0">
        <cfset local.response = {
            "success" = true,
            "data" = []
        }>
        <cftry>
            <cfquery name="local.qryGetContacts" datasource="addressbook">
                <cfif val(arguments.contactId) EQ 0>
                    SELECT
                        idcontact,
                        firstname,
                        lastname,
                        photo,
                        email,
                        phone
                    FROM
                        contact
                    WHERE
                        iduser = <cfqueryparam value="#session.userId#" cfsqltype="cf_sql_integer">
                <cfelse>
                   SELECT
                        cd.idcontact,
                        tl.titlename,
                        cd.firstname,
                        cd.lastname,
                        gd.gendername,
                        cd.dob,
                        cd.photo,
                        cd.address,
                        cd.street,
                        cd.pincode,
                        cd.email,
                        cd.phone,
                        GROUP_CONCAT(h.idhobby) AS hobby_ids,
                        GROUP_CONCAT(h.hobby_name) AS hobby_names
                    FROM
                        contact cd
                        LEFT JOIN  user_hobbies uh ON cd.idcontact = uh.contact_id 
                        LEFT JOIN hobbies_sample h ON uh.hobby_id = h.idhobby
                        LEFT JOIN title tl ON cd.titleid = tl.idtitle
                        LEFT JOIN gender gd ON cd.genderid = gd.idgender
                    WHERE
                        cd.idcontact = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_integer">
                    GROUP BY
                        cd.idcontact,
                        tl.titlename,
                        cd.firstname,
                        cd.lastname,
                        gd.gendername,
                        cd.dob,
                        cd.photo,
                        cd.address,
                        cd.street,
                        cd.pincode,
                        cd.email,
                        cd.phone
                </cfif>
            </cfquery>
            <cfloop query="local.qryGetContacts">
                <cfif val(arguments.contactId) EQ 0>
                    
                    <cfset arrayAppend(local.response.data, {
                        "contactId" = local.qryGetContacts.idcontact,
                        "firstName" = local.qryGetContacts.firstname,
                        "lastName" = local.qryGetContacts.lastname,
                        "photo" = local.qryGetContacts.photo,
                        "email" = local.qryGetContacts.email,
                        "phone" = local.qryGetContacts.phone
                    })>
                <cfelse>
                    <cfset arrayAppend(local.response.data, {
                        "contactid" = local.qryGetContacts.idcontact,
                        "title" = local.qryGetContacts.titlename,
                        "firstname" = local.qryGetContacts.firstname,
                        "lastname" = local.qryGetContacts.lastname,
                        "gender" = local.qryGetContacts.gendername,
                        "dob" = local.qryGetContacts.dob,
                        "photo" = local.qryGetContacts.photo,
                        "address" = local.qryGetContacts.address,
                        "street" = local.qryGetContacts.street,
                        "pincode" = local.qryGetContacts.pincode,
                        "email" = local.qryGetContacts.email,
                        "phone" = local.qryGetContacts.phone,
                        "hobbyIds" = listToArray(local.qryGetContacts.hobby_ids),
                        "hobbyNames" = local.qryGetContacts.hobby_names
                    })>
                </cfif>
            </cfloop>
            <cfcatch type="any">
                <cfset local.response.success = false>
                <cfreturn local.response>
            </cfcatch>
        </cftry>
        <cfreturn local.response>
    </cffunction>

    <cffunction  name="fetchHobbies" returnType="struct" access="public"> 
        <cfset local.response = {
            "success" = true,
            "data" = []
        }>
        <cftry>
            <cfquery name="local.qryGetHobbies" datasource="addressbook">
                SELECT
                    idhobby,
                    hobby_name
                FROM
                    hobbies_sample
            </cfquery>

            <cfloop query="local.qryGetHobbies">
                <cfset arrayAppend(local.response.data, {
                    "hobbyId" = local.qryGetHobbies.idhobby,
                    "hobbyName" = local.qryGetHobbies.hobby_name
                })>
            </cfloop>
            <cfcatch type="any">
                <cfset local.response.success = false>
                <cfreturn local.response>
            </cfcatch>
        </cftry>
        <cfreturn local.response>
    </cffunction>

    <cffunction name="modifyContacts" returnType="struct" access="public">
        <cfargument required="false" name="contactId" type="string">
        <cfargument required="true" name="contactTitle" type="string">
        <cfargument required="true" name="contactFirstName" type="string">
        <cfargument required="true" name="contactLastName" type="string">
        <cfargument required="true" name="contactGender" type="string">
        <cfargument required="true" name="contactDOB" type="string">
        <cfargument required="true" name="contactImage" type="string">
        <cfargument required="true" name="contactAddress" type="string">
        <cfargument required="true" name="contactStreet" type="string">
        <cfargument required="true" name="contactPincode" type="string">
        <cfargument required="true" name="contactEmail" type="string">
        <cfargument required="true" name="contactPhone" type="string">
        <cfargument required="true" name="hobbyIdsToInsert" type="string">
        <cfargument required="true" name="hobbyIdsToDelete" type="string">
        <cfset local.response = {
            "success" = false,
            "message" = ""
        }>
        <cfset local.contactImage = "demo-contact-image.jpg">
        <cfquery name="local.getEmailPhoneQuery" datasource="addressbook">
            SELECT
                idcontact
            FROM
                contact
            WHERE
                iduser = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
                AND email = <cfqueryparam value = "#arguments.contactEmail#" cfsqltype = "cf_sql_varchar">
        </cfquery>
        <cfquery name="local.getTitleIdQuery" datasource="addressbook">
            SELECT
                idtitle
            FROM
                title
            WHERE
                titlename = <cfqueryparam value = "#arguments.contactTitle#" cfsqltype = "cf_sql_varchar">
        </cfquery>
        <cfset local.titleId = local.getTitleIdQuery.idtitle>
        <cfquery name="local.getGenderIdQuery" datasource="addressbook">
            SELECT
                idgender
            FROM
                gender
            WHERE
                gendername = <cfqueryparam value = "#arguments.contactGender#" cfsqltype = "cf_sql_varchar">
        </cfquery>
        <cfset local.genderId = local.getGenderIdQuery.idgender>

        <cfif local.getEmailPhoneQuery.RecordCount AND local.getEmailPhoneQuery.idcontact NEQ arguments.contactId>
            <cfset local.response["message"] = "Email id already exists">
        <cfelse>
            <cfif arguments.contactImage NEQ "">
                <cffile action="upload" destination="#expandpath("./assets/uploads")#" fileField="contactImage" nameconflict="MakeUnique">
                <cfset local.contactImage = cffile.serverFile>
            </cfif>
            <cfif len(trim(arguments.contactId)) EQ 0>
                <cfquery name="local.insertContactsQuery" result="local.insertContactsResult" datasource="addressbook">
                    INSERT INTO
                        contact (
                            titleid,
                            firstname,
                            lastname,
                            genderid,
                            dob,
                            photo,
                            address,
                            street,
                            pincode,
                            email,
                            phone,
                            iduser,
                            is_public
                        )
                    VALUES (
                        <cfqueryparam value = "#local.titleId#" cfsqltype = "cf_sql_integer">,
                        <cfqueryparam value = "#arguments.contactFirstName#" cfsqltype = "cf_sql_varchar">,
                        <cfqueryparam value = "#arguments.contactLastName#" cfsqltype = "cf_sql_varchar">,
                        <cfqueryparam value = "#local.genderId#" cfsqltype = "cf_sql_integer">,
                        <cfqueryparam value = "#arguments.contactDOB#" cfsqltype = "cf_sql_date">,
                        <cfqueryparam value = "#local.contactImage#" cfsqltype = "cf_sql_varchar">,
                        <cfqueryparam value = "#arguments.contactAddress#" cfsqltype = "cf_sql_varchar">,
                        <cfqueryparam value = "#arguments.contactStreet#" cfsqltype = "cf_sql_varchar">,
                        <cfqueryparam value = "#arguments.contactPincode#" cfsqltype = "cf_sql_char">,
                        <cfqueryparam value = "#arguments.contactEmail#" cfsqltype = "cf_sql_varchar">,
                        <cfqueryparam value = "#arguments.contactPhone#" cfsqltype = "cf_sql_varchar">,
                        <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">,
                        <cfqueryparam value = "1" cfsqltype = "cf_sql_integer">
                    );
                </cfquery>

                <cfif len(trim(arguments.hobbyIdsToInsert))>
                    <cfquery name="local.addHobbyQuery" datasource="addressbook">
                        INSERT INTO
                            user_hobbies (
                                contact_id,
                                hobby_id
                            )
                        VALUES
                        <cfloop list="#arguments.hobbyIdsToInsert#" index="local.i" item="local.hobbyId">
                            (
                                <cfqueryparam value="#local.insertContactsResult.GENERATEDKEY#" cfsqltype="cf_sql_integer">,
                                <cfqueryparam value="#trim(local.hobbyId)#" cfsqltype="cf_sql_integer">
                            )
                            <cfif local.i LT listLen(arguments.hobbyIdsToInsert)>,</cfif>
                        </cfloop>
                    </cfquery>
                </cfif>

                <cfset local.response["message"] = "Success">
            <cfelse>
                <cfquery name="local.updateContactDetailsQuery" datasource="addressbook">
                    UPDATE
                        contact
                    SET
                        titleid = <cfqueryparam value = "#local.titleId#" cfsqltype = "cf_sql_integer">,
                        firstName = <cfqueryparam value = "#arguments.contactFirstName#" cfsqltype = "cf_sql_varchar">,
                        lastName = <cfqueryparam value = "#arguments.contactLastName#" cfsqltype = "cf_sql_varchar">,
                        genderid = <cfqueryparam value = "#local.genderId#" cfsqltype = "cf_sql_integer">,
                        dob = <cfqueryparam value = "#arguments.contactDOB#" cfsqltype = "cf_sql_date">,
                        address = <cfqueryparam value = "#arguments.contactAddress#" cfsqltype = "cf_sql_varchar">,
                        street = <cfqueryparam value = "#arguments.contactStreet#" cfsqltype = "cf_sql_varchar">,
                        pincode = <cfqueryparam value = "#arguments.contactPincode#" cfsqltype = "cf_sql_varchar">,
                        email = <cfqueryparam value = "#arguments.contactEmail#" cfsqltype = "cf_sql_varchar">,
                        phone = <cfqueryparam value = "#arguments.contactPhone#" cfsqltype = "cf_sql_varchar">,
                        <cfif arguments.contactImage NEQ "">
                            photo = <cfqueryparam value = "#local.contactImage#" cfsqltype = "cf_sql_varchar">,
                        </cfif>
                        iduser = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
                    WHERE
                        idcontact = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_integer">
                </cfquery>

                <cfquery name="local.deleteHobbyQuery" datasource="addressbook">
                    DELETE
                    FROM
                        user_hobbies
                    WHERE
                        contact_id = <cfqueryparam value="#arguments.contactId#" cfsqltype="cf_sql_integer">
                        AND hobby_id IN (
                            <cfqueryparam value="#arguments.hobbyIdsToDelete#" cfsqltype="cf_sql_varchar" list="true">
                        )
                    </cfquery>

                <cfif len(trim(arguments.hobbyIdsToInsert))>
                    <cfquery name="local.addHobbyQuery" datasource="addressbook">
                        INSERT INTO
                            user_hobbies (
                                contact_id,
                                hobby_id
                            )
                        VALUES
                        <cfloop list="#arguments.hobbyIdsToInsert#" index="local.i" item="local.hobbyId">
                            (
                                <cfqueryparam value="#arguments.contactId#" cfsqltype="cf_sql_integer">,
                                <cfqueryparam value="#trim(local.hobbyId)#" cfsqltype="cf_sql_integer">
                            )
                            <cfif local.i LT listLen(arguments.hobbyIdsToInsert)>,</cfif>
                        </cfloop>
                    </cfquery>
                </cfif>

                <cfset local.response["message"] = "Success">
            </cfif>
        </cfif>
        <cfreturn local.response>
    </cffunction>

    <cffunction name="deleteContact" returnType="struct" access="public">
        <cfargument required="true" name="contactId" type="string">
        <cfargument required="true" name="userId" type="string">
        
        <cfset local.response = {
            "success" = false,
            "message" = ""
        }>
        <cfquery name="local.deleteContactQuery" datasource="addressbook">
            
           DELETE
            FROM
                contact
            WHERE
                idcontact = <cfqueryparam value = "#arguments.contactId#" cfsqltype = "cf_sql_integer">
                AND iduser = <cfqueryparam value = "#session.userId#" cfsqltype = "cf_sql_integer">
           
        </cfquery>
        <cfset local.response.success = true>
        <cfset local.response["message"] = "Success">
        <cfreturn local.response>
    </cffunction>
</cfcomponent>