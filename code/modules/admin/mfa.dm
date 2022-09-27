#define CHECK_MFA_ENABLED if(!CONFIG_GET(flag/mfa_enabled)) return TRUE

/// Checks the MFA for the client, then logs them in if they succeed
/// Returns true if login successful, false otherwise
/// The argument is TRUE if the user should be promted, false if not, useful for on login when the client may not be
/// prepared for the query
/client/proc/mfa_check(allow_query = TRUE)
	CHECK_MFA_ENABLED

	if(mfa_check_cache())
		return TRUE
	else // Need to run MFA
		if(allow_query)
			INVOKE_ASYNC(src, .proc/mfa_query_login) // Don't want to hang while the user inputs their TOTP code
		else
			to_chat(src, span_userdanger("New connection detected, use the readmin verb to authenticate!"))

		return FALSE

/// Check if the login from this location is from an existing session
/client/proc/mfa_check_cache()
	CHECK_MFA_ENABLED

	var/datum/admins/tmp_holder = GLOB.permissions.admin_datums[ckey] || GLOB.permissions.deadmins[ckey]
	if(tmp_holder && tmp_holder.cid_cache == computer_id && tmp_holder.ip_cache == address)
		return TRUE

	var/datum/DBQuery/query_mfa_check = SSdbcore.NewQuery(
		"SELECT COUNT(1) FROM [format_table_name("mfa_logins")] WHERE ckey = :ckey AND ip = INET_ATON(:address) AND cid = :cid AND datetime > current_timestamp() - INTERVAL 30 DAY;",
		list("ckey" = ckey, "address" = address, "cid" = computer_id)
	)

	var/success = (query_mfa_check.warn_execute() && query_mfa_check.NextRow() && text2num(query_mfa_check.item[1]) > 0) // Check if they have connected before from this IP/CID
	qdel(query_mfa_check)
	return success

/// Queries the user for their MFA credentials, then logs them in if they are correct
/client/proc/mfa_query_login()
	CHECK_MFA_ENABLED

	if(mfa_query())
		mfa_login()

/// Asks the user for their 2FA code
/client/proc/mfa_query()
	CHECK_MFA_ENABLED

	var/datum/DBQuery/query_totp_seed = SSdbcore.NewQuery(
		"SELECT totp_seed FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)

	if(!query_totp_seed.warn_execute())
		qdel(query_totp_seed)
		var/msg = "SQL Error getting TOTP seed for [ckey]"
		message_admins(msg)
		log_admin(msg)
		return FALSE

	if(!query_totp_seed.NextRow())
		qdel(query_totp_seed)
		var/msg = "Cannot find DB entry for [ckey] who is attempting to use MFA, this shouldn't be possible."
		message_admins(msg)
		log_admin(msg)
		return FALSE

	var/seed = query_totp_seed.item[1]
	qdel(query_totp_seed)

	if(!seed)
		return mfa_enroll()

	var/code = input(src, "Please enter your authentication code", "MFA Check") as null|num

	if(code)
		var/json_codes = rustg_hash_generate_totp_tolerance(seed, 1)
		if(findtext(json_codes, "ERROR") != 0) // Something went wrong, exit
			var/msg = "Error with TOTP: [json_codes]"
			message_admins(msg)
			log_admin(msg)
			return FALSE
		var/generated_codes = json_decode(json_codes)
		if(num2text(code) in generated_codes)
			return TRUE

	var/response = alert(src, "How would you like to proceed?", "Authentication Error", "Retry TOTP", "Backup Code", "Cancel")

	if(response == "Cancel")
		return

	if(response == "Retry TOTP")
		return mfa_query()
	else if(response == "Backup Code")
		if(alert(src, "Using the backup code will forget all previous logins and require re-enrolling in MFA, Do you wish to continue?", "Confirmation", "Cancel", "Yes") != "Yes")
			return mfa_query()
		return mfa_backup_query()
	else
		CRASH("INVALID RESPONSE TO QUERY")

/// Enrolls a user the in MFA system, assigning them a TOTP seed and backup code
/client/proc/mfa_enroll()
	CHECK_MFA_ENABLED

	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return FALSE

	var/list/base32lookup = list(
		"A" = 0,
		"B" = 1,
		"C" = 2,
		"D" = 3,
		"E" = 4,
		"F" = 5,
		"G" = 6,
		"H" = 7,
		"I" = 8,
		"J" = 9,
		"K" = 10,
		"L" = 11,
		"M" = 12,
		"N" = 13,
		"O" = 14,
		"P" = 15,
		"Q" = 16,
		"R" = 17,
		"S" = 18,
		"T" = 19,
		"U" = 20,
		"V" = 21,
		"W" = 22,
		"X" = 23,
		"Y" = 24,
		"Z" = 25, // 0 and 1 skipped due to similarty to O and I, RFC 4648
		"2" = 26,
		"3" = 27,
		"4" = 28,
		"5" = 29,
		"6" = 30,
		"7" = 31
	)

	var/code_b32 = ""
	for(var/i = 0; i<16; i++) // Generate 16 character base 32 number
		code_b32 += pick(base32lookup)
	var/code_b2 = ""
	for(var/char in splittext(code_b32, ""))
		code_b2 += num2text(base32lookup[char], 5, 2)

	var/code_b16 = ""
	for(var/byte in splittext(code_b2,regex(@"([01]{4})")))
		if(byte == "")
			continue
		code_b16 += num2text(text2num(byte, 2), 1, 16)

	var/alphabet = splittext("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "")

	var/raw_backup = ""
	for(var/i = 0; i < 16; i++) // Generate 16 character base 32 number
		raw_backup += pick(alphabet)
	
	var/backup_hash = rustg_hash_string(RUSTG_HASH_SHA512, raw_backup)

	var/mfa_uri = "otpauth://totp/[ckey]?secret=[code_b32]&issuer=Yogstation13"

	var/qr_image = "<img src=\"https://api.qrserver.com/v1/create-qr-code/?data=[url_encode(mfa_uri)]&size=200x200\" />"

	var/heading = "<h2>2FA Setup</h2>"

	var/instructions = "Use the below QR Code or TOTP code in a 2FA app like Google Authenticator."

	var/codes = "TOTP CODE: [code_b32]<br>Backup code for if you lose your 2FA device: [raw_backup]"

	src << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>QR Code</TITLE></HEAD><BODY>[heading][instructions]<br>[qr_image]<br>[codes]</BODY></HTML>", "window=MFA_QR")

	while(TRUE)
		var/code = input(src, "Please verify your authentication code", "MFA Check") as null|num
		if(code)
			var/json_codes = rustg_hash_generate_totp_tolerance(code_b16, "1")
			if(findtext(json_codes, "ERROR") != 0) // Something went wrong, exit
				var/msg = "Error with TOTP: [json_codes]"
				message_admins(msg)
				log_admin(msg)
				return FALSE
			var/generated_codes = json_decode(json_codes)
			if(num2text(code) in generated_codes)
				break
		else
			return FALSE

	var/datum/DBQuery/query_set_totp_seed = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET totp_seed = :totp_seed, mfa_backup = :mfa_backup WHERE ckey = :ckey",
		list("totp_seed" = code_b16, "mfa_backup" = backup_hash, "ckey" = ckey)
	)

	var/result = query_set_totp_seed.warn_execute()
	qdel(query_set_totp_seed)
	return result

/// Asks the user for their backup codes, then resets the login and re-enrolls the user on success
/client/proc/mfa_backup_query()
	CHECK_MFA_ENABLED

	var/mfa_backup = input(src, "Please enter your authentication code", "MFA Check") as null|text
	
	if(!mfa_backup)
		return

	var/datum/DBQuery/query_mfa_backup = SSdbcore.NewQuery(
		"SELECT COUNT(1) FROM [format_table_name("player")] WHERE ckey = :ckey AND mfa_backup = :code",
		list("ckey" = ckey, "code" = rustg_hash_string(RUSTG_HASH_SHA512, mfa_backup))
	)

	if(!query_mfa_backup.warn_execute() || !query_mfa_backup.NextRow())
		qdel(query_mfa_backup)
		var/msg = "Unable to fetch backup codes for [ckey]!"
		message_admins(msg)
		log_admin(msg)
		to_chat(src, span_warning("Unable to fetch batckup codes"))
		return FALSE

	var/authed = query_mfa_backup.item[1] > 0
	qdel(query_mfa_backup)
	if(authed)
		var/msg = "[ckey] logged in with their backup code!"
		message_admins(msg)
		log_admin(msg)
		mfa_reset(ckey)
		return mfa_enroll()
	else
		to_chat(src, span_warning("Failed to validate backup code"))
		return FALSE

/// Reset MFA, clear sessions and login credentials
/proc/mfa_reset(ckey, session_only = FALSE)
	CHECK_MFA_ENABLED

	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return FALSE

	var/datum/DBQuery/query_clear_mfa = SSdbcore.NewQuery(
		"DELETE FROM [format_table_name("mfa_logins")] WHERE ckey = :ckey",
		list("ckey" = ckey)
	)
	query_clear_mfa.warn_execute()
	qdel(query_clear_mfa)

	if(!session_only)
		query_clear_mfa = SSdbcore.NewQuery(
			"UPDATE [format_table_name("player")] SET totp_seed = NULL, mfa_backup = NULL WHERE ckey = :ckey",
			list("ckey" = ckey)
		)
		query_clear_mfa.warn_execute()
		qdel(query_clear_mfa)	

/client/proc/mfa_login()
	CHECK_MFA_ENABLED

	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(alert(src, "Do you wish to remember this connection?", "Remember Me", "Yes", "No") == "Yes")
		var/datum/DBQuery/mfa_addverify = SSdbcore.NewQuery(
			"INSERT INTO [format_table_name("mfa_logins")] (ckey, ip, cid) VALUE (:ckey, INET_ATON(:address), :cid)",
			list("ckey" = ckey, "address" = address, "cid" = computer_id)
		)

		if(!mfa_addverify.Execute())
			qdel(mfa_addverify)
			var/msg = "Failed to add login info for [ckey], they will be unable to login"
			message_admins(msg)
			log_admin(msg)
			return

		qdel(mfa_addverify)

	var/datum/admins/tmp_holder = GLOB.permissions.admin_datums[ckey] || GLOB.permissions.deadmins[ckey]
	if(tmp_holder)
		// These values are cached even if the user says not to remember the session, but are only used if the DB is down during admin loading
		tmp_holder.cid_cache = computer_id
		tmp_holder.ip_cache = address

		tmp_holder.activate()

#undef CHECK_MFA_ENABLED
