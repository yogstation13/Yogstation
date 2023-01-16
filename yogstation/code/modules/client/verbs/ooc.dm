/client/proc/find_admin_rank(client)
	var/client/C = client

	switch(C.holder.rank_name())

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

		if("Administrator-Mainterino")
			return "\[Admin-tainer\]"

		if("Moderator-Mainterino")
			return "\[Mod-tainer\]"
			
		if("Retmin-Maintainerino")
			return "\[Retmin-tainer\]"

		else
			return "\[[C.holder.rank_name()]\]"

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

/client/verb/emoji_list()
	set name = "emoji-help"
	set category = "OOC"
	set desc = "Lists all the emojis available for use!"
	if(!CONFIG_GET(flag/emojis))
		to_chat(src,span_warning("This server has emojis disabled!"))
		return
	var/static/list/yogemojis = icon_states(icon('yogstation/icons/emoji.dmi'))
	var/static/list/tgemojis = icon_states(icon('icons/emoji.dmi')) - yogemojis // If we have emojis of the same name, they override the TG ones. (https://github.com/yogstation13/Yogstation/pull/5788)
	
	to_chat(src,"<b>[span_notice("List of Emojis:")]</b>")
	to_chat(src,span_notice("[jointext(sortList(yogemojis + tgemojis),", ")]"))
