/datum/admins/proc/antag_token_panel(ckey)
	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>", confidential=TRUE)
		return

	var/datum/browser/token_panel = new(usr, "tokenpanel", "Antag Token Panel", 850, 600)
	token_panel.add_stylesheet("unbanpanelcss", 'html/admin/unbanpanel.css') //CSS thief!

	var/list/data = list("<div class='searchbar'>")

	data += {"<form method='get' action='?src=[REF(src)]'>[HrefTokenFormField()]
	<input type='hidden' name='src' value='[REF(src)]'>
	Key: <input type='text' name='searchAntagTokenByKey' size='18' value='[ckey]'>
	<input type='submit' value='Search'>
	</form>
	</div>
	<div class='main'>
	"}

	if(ckey)
		var/datum/DBQuery/query_antag_token = SSdbcore.NewQuery({"SELECT reason, denial_reason, applying_admin, denying_admin, granted_time, redeemed, round_id, id
		FROM [format_table_name("antag_tokens")] WHERE ckey = '[sanitizeSQL(ckey(ckey))]'
		ORDER BY granted_time DESC"})
		if(!query_antag_token.warn_execute())
			qdel(query_antag_token)
			return

		while(query_antag_token.NextRow())
			var/reason = query_antag_token.item[1]
			var/denial_reason = query_antag_token.item[2]
			var/applying_admin = query_antag_token.item[3]
			var/denying_admin = query_antag_token.item[4]
			var/time = query_antag_token.item[5]
			var/redeemed = text2num(query_antag_token.item[6])
			var/round_id = query_antag_token.item[7]
			var/id = query_antag_token.item[8]

			data += {"<div class='banbox'><div class='header [redeemed ? "banned" : "unbanned"]'>Antag Token for:<b> [ckey]</b> granted by <b>[applying_admin]</b> on
			<b>[time]</b> during round<b> #[round_id]</b>
			</div>"}
			data += "<br><b>Token Reason:</b> <br>[reason]"

			if(denial_reason)
				data += "<br>Denied by <b>[denying_admin]</b> for '[denial_reason]'"
			if(redeemed && !denial_reason)
				data += "<br>Redeemed by <b>[denying_admin]</b>"

			if(!redeemed)
				data += "<br><a href='?_src_=holder;[HrefToken()];redeem_token_id=[id]'>Redeem</a>"
				data += "<a href='?_src_=holder;[HrefToken()];deny_token_id=[id]'>Deny</a>"
			data += "</div>"
		qdel(query_antag_token)

	data += "</div>"

	token_panel.set_content(jointext(data, ""))
	token_panel.open()

/datum/admins/proc/give_antag_token(ckey)
	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>", confidential=TRUE)
		return

	if(!ckey)
		ckey = input("Please input a ckey", "Antag Token - Ckey") as text|null

	if(!ckey)
		alert("Antag Token not applied. No valid CKEY specified")
		return

	if(has_antag_token(ckey))
		alert("The user '[ckey]' already has an antag token!")
		return


	var/roundid = input("Please input the roundID where the incident happened.", "Antag Token - RoundID") as num|null
	if(!roundid)
		alert("Antag Token not applied. No valid roundID specified")
		return

	var/reason = input("Please input the reason for this antag token.", "Antag Token - Reason") as text|null
	if(!reason)
		alert("Antag Token not applied. No valid reason specified")
		return

	var/admin_key = key_name_admin(usr)
	reason = sanitizeSQL(reason)
	var/token = list(
	list("granted_time" = "NOW()",
	"ckey" = "'[sanitizeSQL(ckey(ckey))]'",
	"round_id" = sanitizeSQL(roundid),
	"reason" = "'[reason]'",
	"applying_admin" = "'[sanitizeSQL(ckey(owner.ckey))]'",
	))

	if(!SSdbcore.MassInsert(format_table_name("antag_tokens"), token, warn = 1))
		alert("Failed to give token!")
		return

	log_admin_private("[admin_key] has applied an antag token for [ckey] with the reason '[reason]' for round #[roundid]")
	message_admins("[admin_key] has applied an antag token for [ckey] with the reason '[reason]' for round #[roundid]")

/datum/admins/proc/redeem_antag_token(ckey)
	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>", confidential=TRUE)
		return
	if(!ckey)
		return
	if(alert("Are you sure you want to redeem a token?",, "Yes", "No") != "Yes")
		return

	if(!has_antag_token(ckey))
		alert("The user '[ckey]' does not have an antag token!")
		return

	var/datum/DBQuery/query_antag_token = SSdbcore.NewQuery({"SELECT id
		FROM [format_table_name("antag_tokens")] WHERE ckey = '[sanitizeSQL(ckey(ckey))]' AND redeemed = 0
		ORDER BY granted_time DESC"})

	if(!query_antag_token.warn_execute())
		qdel(query_antag_token)
		return

	if(query_antag_token.NextRow())
		var/id = query_antag_token.item[1]
		var/datum/DBQuery/query_antag_token_redeem = SSdbcore.NewQuery({"UPDATE [format_table_name("antag_tokens")] 
		SET redeemed = 1, denying_admin = '[sanitizeSQL(ckey(owner.ckey))]'
		WHERE id = [id]"})
		if(!query_antag_token_redeem.warn_execute())
			alert("Failed to redeem token!")
			qdel(query_antag_token_redeem)
			return

		to_chat(usr, "<span class='notice'>Token Redeemed</span>")
		qdel(query_antag_token_redeem)

		var/admin_key = key_name_admin(usr)
		log_admin_private("[admin_key] has redeemed an antag token for [ckey]")
		message_admins("[admin_key] has redeemed an antag token for [ckey]")
	else
		alert("Failed to redeem token!")
	qdel(query_antag_token)


/datum/admins/proc/has_antag_token(ckey)
	var/datum/DBQuery/query_antag_token_existing = SSdbcore.NewQuery({"SELECT ckey FROM [format_table_name("antag_tokens")] WHERE ckey = '[sanitizeSQL(ckey(ckey))]' AND redeemed = 0"})

	if(!query_antag_token_existing.warn_execute())
		qdel(query_antag_token_existing)
		return

	if(query_antag_token_existing.NextRow())
		. = TRUE
	qdel(query_antag_token_existing)


/datum/admins/proc/redeem_specific_antag_token(id)
	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>", confidential=TRUE)
		return
	if(!id)
		return
	if(alert("Are you sure you want to redeem this token?",, "Yes", "No") != "Yes")
		return

	var/number_id = text2num(id)

	var/ckey
	var/datum/DBQuery/query_antag_token_exists = SSdbcore.NewQuery({"SELECT ckey FROM [format_table_name("antag_tokens")] WHERE id = [number_id]"})
	if(!query_antag_token_exists.warn_execute())
		qdel(query_antag_token_exists)
		alert("Token not redeemed!")
		return

	if(query_antag_token_exists.NextRow())
		ckey = query_antag_token_exists.item[1]

	if(!ckey)
		qdel(query_antag_token_exists)
		alert("Token not redeemed!")
		return

	qdel(query_antag_token_exists)

	var/datum/DBQuery/query_antag_token_deny = SSdbcore.NewQuery({"UPDATE [format_table_name("antag_tokens")] SET redeemed = 1, denying_admin = '[sanitizeSQL(ckey(owner.ckey))]' WHERE id = [number_id]"})

	if(!query_antag_token_deny.warn_execute())
		qdel(query_antag_token_deny)
		alert("Token not redeemed!")
		return

	antag_token_panel(ckey)

	var/admin_key = key_name_admin(usr)
	log_admin_private("[admin_key] has redeemed antag token ID [number_id]")
	message_admins("[admin_key] has redeemed antag token ID [number_id]")

/datum/admins/proc/deny_antag_token(id)
	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>", confidential=TRUE)
		return

	if(!id)
		return

	if(alert("Are you sure you want to deny this token?",, "Yes", "No") != "Yes")
		return

	var/reason = input("Please input a reason", "Denial Reason") as text|null
	if(!reason)
		return
	var/number_id = text2num(id)

	var/ckey
	var/datum/DBQuery/query_antag_token_exists = SSdbcore.NewQuery({"SELECT ckey FROM [format_table_name("antag_tokens")] WHERE id = [number_id]"})
	if(!query_antag_token_exists.warn_execute())
		qdel(query_antag_token_exists)
		alert("Token not redeemed!")
		return
	if(query_antag_token_exists.NextRow())
		ckey = query_antag_token_exists.item[1]

	if(!ckey)
		qdel(query_antag_token_exists)
		alert("Token not redeemed!")
		return

	qdel(query_antag_token_exists)

	var/datum/DBQuery/query_antag_token_deny = SSdbcore.NewQuery({"UPDATE [format_table_name("antag_tokens")] SET denying_admin = '[sanitizeSQL(ckey(owner.ckey))]',
	denial_reason = '[sanitizeSQL(reason)]', redeemed = 1 WHERE id = [number_id]"})
	if(!query_antag_token_deny.warn_execute())
		qdel(query_antag_token_deny)
		return
	qdel(query_antag_token_deny)
	antag_token_panel(ckey)

	var/admin_key = key_name_admin(usr)
	log_admin_private("[admin_key] has denied an antag token. Reason: [reason], ID:[id] [number_id]")
	message_admins("[admin_key] has denied an antag token. Reason: [reason], ID:[id] [number_id]")


/datum/admins/proc/show_redeemable_antag_tokens()
	if(!check_rights(R_ADMIN))
		return

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>", confidential=TRUE)
		return

	var/datum/browser/token_panel = new(usr, "redeemabletokenpanel", "Antag Token Panel", 850, 600)

	

	var/datum/DBQuery/query_antag_token = SSdbcore.NewQuery({"SELECT DISTINCT ckey FROM [format_table_name("antag_tokens")] WHERE redeemed = 0"})

	if(!query_antag_token.warn_execute())
		qdel(query_antag_token)
		return
		
	var/list/data = list()
	while(query_antag_token.NextRow())
		var/ckey = query_antag_token.item[1]
		data += "<a href='?_src_=holder;[HrefToken()];searchAntagTokenByKey=[ckey]'>[ckey]</a>"
		data += "<br>"
	qdel(query_antag_token)

	token_panel.set_content(jointext(data, ""))
	token_panel.open()
