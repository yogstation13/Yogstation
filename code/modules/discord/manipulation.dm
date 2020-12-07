// Verb to manipulate IDs and ckeys
/client/proc/discord_id_manipulation()
	set name = "Discord Manipulation"
	set category = "Admin.Player Interaction"

	if(!check_rights(R_ADMIN))
		return

	holder.discord_manipulation()


/datum/admins/proc/discord_manipulation()
	if(!usr.client.holder)
		return

	var/lookup_choice = alert(usr, "Do you wish to lookup account by ID or ckey?", "Lookup Type", "ID", "Ckey", "Cancel")
	switch(lookup_choice)
		if("ID")
			var/lookup_id = input(usr,"Enter Discord ID to lookup ckey") as text
			var/returned_ckey = SSdiscord.lookup_ckey(lookup_id)
			if(returned_ckey)
				var/unlink_choice = alert(usr, "Discord ID [lookup_id] is linked to Ckey [returned_ckey]. Do you wish to unlink or cancel?", "Account Found", "Unlink", "Cancel")
				if(unlink_choice == "Unlink")
					SSdiscord.unlink_account(returned_ckey)
			else
				to_chat(usr, "<span class='warning'>Discord ID <b>[lookup_id]</b> has no associated ckey</span>")
		if("Ckey")
			var/lookup_ckey = input(usr,"Enter Ckey to lookup ID") as text
			var/returned_id = SSdiscord.lookup_id(lookup_ckey)
			if(returned_id)
				to_chat(usr, "<span class='notice'>Ckey <b>[lookup_ckey]</b> is assigned to Discord ID <b>[returned_id]</b></span>")
				to_chat(usr, "<span class='notice'>Discord mention format: <b>&lt;@[returned_id]&gt;</b></span>") // &lt; and &gt; print < > in HTML without using them as tags
				var/unlink_choice = alert(usr, "Ckey [lookup_ckey] is linked to Discord ID [returned_id]. Do you wish to unlink or cancel?", "Account Found", "Unlink", "Cancel")
				if(unlink_choice == "Unlink")
					SSdiscord.unlink_account(lookup_ckey)
			else
				to_chat(usr, "<span class='warning'>Ckey <b>[lookup_ckey]</b> has no associated Discord ID!</span>")
