/client/proc/find_admin_rank(client)
	var/client/C = client

	switch(C.holder.rank.name)

		if("CouncilMember")
			return "\[Council\]"

		if("Moderator")
			return "\[Mod\]"

		if("Administrator")
			return "\[Admin\]"

		if("ModeratorOnProbation")
			return "\[ModOnProbation\]"

		if("Bot")
			return "\[YogBot\]"

		if("RetiredAdmin")
			return "\[Retmin\]"

		else
			return "\[[C.holder.rank.name]\]"

/client/verb/give_tip()
	set name = "Give Random Tip"
	set category = "OOC"
	set desc ="Sends you a random tip!"

	//Most of the below is a clone of what's going on in code/controllers/subsystem/ticker.dm around line 400-ish.
	//Cloned March 2019, your mileage may vary
	var/m
	var/list/randomtips = world.file2list("strings/tips.txt")
	randomtips += world.file2list("yogstation/strings/tips.txt")
	var/list/memetips = world.file2list("strings/sillytips.txt")
	if(randomtips.len && prob(95))
		m = pick(randomtips)
	else if(memetips.len)
		m = pick(memetips)

	if(m)
		to_chat(src, "<font color='purple'><b>Tip: </b>[html_encode(m)]</font>")

/client/proc/self_notes()
	set name = "View Admin Remarks"
	set category = "OOC"
	set desc = "View the notes that admins have written about you"
	
	if(check_rights(R_ADMIN,0))// If they're an admin, just give them the actual admin version of this verb.
		browse_messages(target_ckey = usr.ckey, agegate = FALSE)
		return

	if(!CONFIG_GET(flag/see_own_notes))
		to_chat(usr, "<span class='warning'>Sorry, that function is not enabled on this server!</span>")
		return

	