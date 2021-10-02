/datum/admins/proc/handle_mfa(client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	if(CONFIG_GET(flag/mfa_enabled))
		if(check_mfa_cache(C))
			return TRUE
		else // Need to run MFA
			INVOKE_ASYNC(src, .proc/query_mfa, C) // Don't want to hang while the user inputs their TOTP code

			if(!deadmined)
				deactivate()

			return FALSE

	return TRUE

/datum/admins/proc/check_mfa_cache(client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return FALSE

	if(!C)
		return FALSE

	if(cid_cache == C.computer_id && ip_cache == C.address)
		return TRUE

	var/datum/DBQuery/query_mfa_check = SSdbcore.NewQuery(
		"SELECT COUNT(1) FROM [format_table_name("mfa_logins")] WHERE ckey = :ckey AND ip = INET_ATON(:address) AND cid = :cid",
		list("ckey" = target, "address" = C.address, "cid" = C.computer_id)
	)

	var/success = (query_mfa_check.warn_execute() && query_mfa_check.NextRow() && text2num(query_mfa_check.item[1]) > 0) // Check if they have connected before from this IP/CID
	qdel(query_mfa_check)
	return success

/datum/admins/proc/query_mfa(client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return
	
	if(!C)
		return

	var/datum/DBQuery/query_totp_seed = SSdbcore.NewQuery(
		"SELECT totp_seed FROM [format_table_name("player")] WHERE ckey = :ckey",
		list("ckey" = target)
	)

	if(!query_totp_seed.warn_execute())
		qdel(query_totp_seed)
		message_admins("SQL Error getting TOTP seed for [target]")
		return

	if(!query_totp_seed.NextRow())
		qdel(query_totp_seed)
		message_admins("Cannot find DB entry for [target] who is attempting to use MFA, this shouldn't be possible.")
		return

	var/seed = query_totp_seed.item[1]
	qdel(query_totp_seed)

	if(!seed)
		enroll_mfa(C)
		return

	var/code = input(C, "Please enter your authentication code", "MFA Check") as null|num

	if(code)
		var/generated_code = rustg_hash_generate_totp(seed)
		if(num2text(code) == generated_code)
			login_mfa(C)
			return

	var/response = alert(C, "How would you like to proceed?", "Authentication Error", "Retry TOTP", "Backup Code", "Cancel")

	if(response == "Cancel")
		return

	if(response == "Retry TOTP")
		query_mfa()
		return
	else if(response == "Backup Code")
		query_mfa_backup()
	else
		CRASH("INVALID RESPONSE TO QUERY")

/datum/admins/proc/enroll_mfa(client/C)
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
		code_b16 = num2text(text2num(code_b2, 2), 0, 16)

	to_chat(C, span_userdanger("Your 2FA code is [code_b32]!"), confidential = TRUE)

	while(TRUE)
		var/code = input(C, "Please verify your authentication code", "MFA Check") as null|num

		if(code)
			var/generated_code = rustg_hash_generate_totp(code_b16)
			if(num2text(code) == generated_code)
				break
		else
			return
	
	var/alphabet = splittext("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", "")

	var/raw_backup = ""
	for(var/i = 0; i < 16; i++) // Generate 16 character base 32 number
		raw_backup += pick(alphabet)
	
	var/backup_hash = rustg_hash_string("sha512", raw_backup)
	to_chat(C, span_userdanger("Your 2FA backup code is [raw_backup]. This can be used to recover your account in the event you lose your 2FA device."), confidential=TRUE)

	var/datum/DBQuery/query_set_totp_seed = SSdbcore.NewQuery(
		"UPDATE [format_table_name("player")] SET totp_seed = :totp_seed, mfa_backup = :mfa_backup WHERE ckey = :ckey",
		list("totp_seed" = code_b16, "mfa_backup" = backup_hash, "ckey" = target)
	)

	if(!query_set_totp_seed.warn_execute())
		qdel(query_set_totp_seed)
		return
	qdel(query_set_totp_seed)
	login_mfa(C)

/datum/admins/proc/query_mfa_backup(client/C)
	var/mfa_backup = input(C, "Please enter your authentication code", "MFA Check") as null|text
	
	if(!mfa_backup)
		return

	var/datum/DBQuery/query_mfa_backup = SSdbcore.NewQuery(
		"SELECT COUNT(1) FROM [format_table_name("player")] WHERE ckey = :ckey AND mfa_backup = :code",
		list("ckey" = target, "code" = rustg_hash_string("sha512", mfa_backup))
	)

	if(!query_mfa_backup.warn_execute() || !query_mfa_backup.NextRow())
		qdel(query_mfa_backup)
		message_admins("Unable to fetch backup codes for [target]!")

	var/authed = query_mfa_backup.item[1] > 0
	qdel(query_mfa_backup)
	if(authed)
		login_mfa(C)
	else
		to_chat(C, span_warning("Failed to validate backup code"))
	

/datum/admins/proc/login_mfa(client/C)
	if(IsAdminAdvancedProcCall())
		var/msg = " has tried to elevate permissions!"
		message_admins("[key_name_admin(usr)][msg]")
		log_admin("[key_name(usr)][msg]")
		return

	var/datum/DBQuery/mfa_addverify = SSdbcore.NewQuery(
		"INSERT INTO [format_table_name("mfa_logins")] (ckey, ip, cid) VALUE (:ckey, INET_ATON(:address), :cid)",
		list("ckey" = target, "address" = C.address, "cid" = C.computer_id)
	)

	if(!mfa_addverify.Execute())
		qdel(mfa_addverify)
		message_admins("Failed to add login info for [target], they will be unable to login")
		return

	qdel(mfa_addverify)

	var/datum/admins/admin = GLOB.deadmins[target] || GLOB.admin_datums[target]
	admin.activate()
