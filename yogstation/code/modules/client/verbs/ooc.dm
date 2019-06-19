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

/client/self_notes()
	set name = "View Admin Remarks"
	set category = "OOC"
	set desc = "View the notes that admins have written about you."
	
	if(check_rights(R_ADMIN,0))// If they're an admin, just give them the actual admin version of this verb.
		browse_messages(target_ckey = usr.ckey, agegate = FALSE)
		return

	if(!CONFIG_GET(flag/see_own_notes))
		to_chat(usr, "<span class='warning'>Sorry, that function is not enabled on this server!</span>")
		return

	if((world.time - last_note_query) < 200) // 20 seconds
		to_chat(src,"<span class='danger'>Please wait before asking for your notes again.</span>")
		return
	last_note_query = world.time

	if(!SSdbcore.Connect())
		to_chat(usr, "<span class='danger'>Failed to establish database connection.</span>")
		return
	
	var/const/ruler = "<hr style='background:#000000; border:0; height:3px'>"
	var/const/rulersmall = "<hr style='background:#000000; border:0; height:1px'>"
	var/list/output = list("<h2><center>[ckey]</center></h2>[ruler]<h2>Notes</h2>[ruler]")
	var/datum/DBQuery/notes_query = SSdbcore.NewQuery("SELECT targetckey,text,timestamp FROM [format_table_name("messages")] WHERE type = 'note' AND targetckey = '[ckey]' AND deleted = 0 AND secret <> 1 AND (expire_timestamp > NOW() OR expire_timestamp IS NULL) AND timestamp < (NOW() - INTERVAL 1 week) ORDER BY timestamp DESC") // NOTE: This only shows the player notes that are more than a *WEEK* old.
	//item 1: Text
	//item 2: Timestamp
	while(notes_query.NextRow())
		var/notetext = notes_query.item[1]
		var/timestamp = notes_query.item[2]
		var/note = "<p><b>[timestamp]</b></p><br>[notetext]<br>[rulersmall]<br>"
		output += note
	qdel(notes_query)
	var/datum/browser/browser = new(usr, "Note panel", "Manage player notes", 1000, 500)
	var/datum/asset/notes_assets = get_asset_datum(/datum/asset/simple/notes)
	notes_assets.send(usr.client)
	browser.set_content(jointext(output, ""))
	browser.open()