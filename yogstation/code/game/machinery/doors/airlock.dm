/obj/machinery/door/airlock/AltClick(mob/living/user)
	if(isobserver(user))
		to_chat(user, "<span class='danger'>Psst, you can't interact with the world, ghosts!</span>")
		return

	if (!user.canUseTopic(src))
		to_chat(user, "<span class='info'>You can't do this right now!</span>")
		return

	if(stat & (NOPOWER|BROKEN) || (obj_flags & EMAGGED))
		to_chat(user, "<span class='info'>The door isn't working!</span>")
		return

	if(request_cooldown > world.time)
		to_chat(user, "<span class='info'>The airlock's spam filter is blocking your request. Please wait at least 10 seconds between requests.</span>")
		return

	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		if(!AI.client)
			continue

		var/userjob = user.job	//bootleg fix
		if(isnull(userjob))
			userjob = "Unknown" //very bootleg fix

		to_chat(AI, "<span class='info'><a href='?src=\ref[AI];track=[html_encode(user.name)]'><span class='name'>[user.name] ([userjob])</span></a> is requesting you to open [src]. <a href='?src=\ref[AI];remotedoor=\ref[src]'>(Open)</a></span>")
	request_cooldown = world.time + (COOLDOWN_TIME * 10)
	to_chat(user, "<span class='info'>Request sent.</span>")