/client/proc/rejuv_all()
	set name = "Revive All"
	set category = "Fun"
	set desc = "Rejuvinate every mob/living."

	if(!check_rights(R_ADMIN))
		return

	var/revive_count = 0
	for(var/mob/living/M in world)
		M.revive(TRUE, TRUE)
		revive_count++

	var/fluff_adjective = pick("benevolent","sacred","holy","godly","magnificent","benign","generous","caring") //lol
	var/fluff_adverb = pick("tenderly","gently","elegantly","gracefully","mercifully","affectionately","sympathetically","politely") //am having a lot of fun here

	to_chat(world, "<b>The [fluff_adjective] admins have decided to [fluff_adverb] revive everyone. :)</b>")
	message_admins("[src] revived [revive_count] mobs.")
	log_admin("[src] revived [revive_count] mobs.")