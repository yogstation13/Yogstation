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