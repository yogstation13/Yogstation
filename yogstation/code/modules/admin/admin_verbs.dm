/client/proc/rejuv_all()
	set name = "Revive All"
	set category = "Fun"
	set desc = "Rejuvinate every mob/living."

	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "Revive all mobs?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	var/revive_count = 0
	for(var/mob/living/M in world)
		M.revive(TRUE, TRUE)
		revive_count++

	var/fluff_adjective = pick("benevolent","sacred","holy","godly","magnificent","benign","generous","caring") //lol
	var/fluff_adverb = pick("tenderly","gently","elegantly","gracefully","mercifully","affectionately","sympathetically","politely") //am having a lot of fun here
	var/fluff_admins = pick("admins","shitmins","podmins","moderators","bad human beings") // the fun continues years later
	var/fluff_the = pick("The","The super","One of the","All of the","At least one of the","The absolutely")
	var/fluff_decide = pick("decided","finally decided")
	var/fluff_revive = pick("revive","rejuvenate","rekindle","renew","restore","resuscitate","revitalize","repair")
	var/fluff_everyone = pick("everyone","every single one of you","the populace","the masses","each person","anybody and everybody","every player","all the greytiders","all the wonderful individuals")

	to_chat(world, "<b>[fluff_the] [fluff_adjective] [fluff_admins] have [fluff_decide] to [fluff_adverb] [fluff_revive] [fluff_everyone]. :)</b>")
	message_admins("[src] revived [revive_count] mobs.")
	log_admin("[src] revived [revive_count] mobs.")

/client/proc/admin_pick_random_player()
	set category = "Admin"
	set name = "Pick Random Player"
	set desc = "Picks a random logged-in player and brings up their player panel."

	var/list/mobs = list()

	var/what_group = input(src, "What group would you like to pick from?", "Selection", "Everyone") as null|anything in list("Everyone", "Antags Only", "Non-Antags Only")
	if(!what_group)
		return

	var/choose_from_dead = input(src, "What group would you like to pick from?", "Selection", "Everyone") as null|anything in list("Everyone", "Living Only", "Dead Only")
	if(!choose_from_dead)
		return

	if(choose_from_dead != "Dead Only")
		for(var/mob/M in GLOB.alive_mob_list)
			if(M.mind)
				mobs += M
	if(choose_from_dead != "Living Only")
		for(var/mob/M in GLOB.dead_mob_list)
			if(M.mind)
				mobs += M

	if(what_group == "Antags Only")
		for(var/mob/M in mobs)
			if(!M.mind.special_role)
				mobs -= M
	else if(what_group == "Non-Antags Only")
		for(var/mob/M in mobs)
			if(M.mind.special_role)
				mobs -= M

	if(!mobs.len)
		to_chat(src, "<span class='warning'>Error: no valid mobs found via selected options.</span>", confidential=TRUE)
		return

	var/mob/chosen_player = pick(mobs)
	to_chat(src, "[chosen_player] has been chosen", confidential=TRUE)
	holder.show_player_panel(chosen_player)

/client/proc/get_law_history()
	set name = "Get Law History"
	set category = "Admin"
	set desc = "View list of law changes for silicons."
	var/data = "<HTML><HEAD><meta charset='UTF-8'></HEAD><BODY>"
	for(var/mob/living/silicon/S in GLOB.silicon_mobs)
		if(ispAI(S))
			continue
		data += "<h1>[key_name(S)]:</h1>\n"
		data += "<ol>\n"
		for(var/lawset in S.law_history)
			var/laws = ""
			for(var/L in lawset)
				laws += L
				laws += "<br>"
			data += " <li>[laws]</li><br>\n"
		data += "</ol>\n"

	data += "</BODY></HTML>"

	src << browse(data, "window=law_history")
