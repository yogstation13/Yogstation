/mob/living/simple_animal/borer/verb/infect_victim()
	set name = "Infect"
	set category = "Borer"
	set desc = "Infect a adjacent human being"

	if(victim)
		to_chat(src, "<span class='warning'>You already have a host! leave this one if you want a new one.</span>")
		return

	if(stat == DEAD)
		return

	var/list/choices = list()
	for(var/mob/living/carbon/H in view(1,src))
		if(H != src && Adjacent(H))
			choices += H

	var/mob/living/carbon/human/H = input(src,"Who do you wish to infect?") in null|choices
	if(!H)
		return

	if(H.borer)
		to_chat(src, "<span class='warning'>[victim] is already infected!</span>")
		return

	if(CanInfect(H))
		to_chat(src, "<span class='warning'>You slither up [H] and begin probing at their ear canal...</span>")
		layer = MOB_LAYER
		if(!do_mob(src, H, 30))
			to_chat(src, "<span class='warning'>As [H] moves away, you are dislodged and fall to the ground.</span>")
			return

		if(!H || !src)
			return

		Infect(H)

/mob/living/simple_animal/borer/proc/CanInfect(var/mob/living/carbon/human/H)
	if(!Adjacent(H))
		return FALSE

	if(!H.mind)
		to_chat(src, "<span class='warning'>[H] does not have a mind.</span>")
		return FALSE

	if(!checkStrength())
		return FALSE

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='warning'>I must be conscious to do this...</span>")
		return FALSE

	/*if(H.mind.devilinfo)
		to_chat(src, "<span class='warning'>This being has a strange presence, it would be unwise to enter their body.")
		return 0*/

	if(isshadow(H))
		to_chat(src, "<span class='warning'>[H] cannot be infected! Retreating!</span>")
		return FALSE

	if(!H.mind.active)
		to_chat(src, "<span class='warning'>[H] does not have an active mind.</span>")
		return FALSE

	var/unprotected = TRUE

	if(H.head && istype(H.head, /obj/item/clothing))//are they wearing a thing on their head?
		var/obj/item/clothing/CH = H.head
		if (CH.clothing_flags & THICKMATERIAL)//if so, is it too thick to get through?
			if(H.wear_suit && istype(H.wear_suit, /obj/item/clothing))//are they wearing a suit as well?
				var/obj/item/clothing/CS = H.wear_suit
				if (CS.clothing_flags & THICKMATERIAL)//is THAT thick as well?
					unprotected = FALSE
					to_chat(src, "<span class='warning'>[H] is wearing protective clothing! We can't get through!</span>")

	return unprotected

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!victim)
		to_chat(src, "<span class='warning'>You are not inside a host body!</span>")
		return

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot secrete chemicals in your current state.</span>")

	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		return

	if(!checkStrength())
		return FALSE

	var content = ""
	content += "<p>Chemicals: <span id='chemicals'>[chemicals]</span></p>"

	content += "<table>"

	for(var/datum in typesof(/datum/borer_chem))
		var/datum/borer_chem/C = new datum()
		if(C.chemname)
			content += "<tr><td><a class='chem-select' href='?_src_=\ref[src];src=\ref[src];borer_use_chem=[C.chemname]'>[C.chemname] ([C.chemuse])</a><p>[C.chem_desc]</p></td></tr>"

	content += "</table>"

	var/html = get_html_template(content)

	usr << browse(null, "window=ViewBorer\ref[src]Chems;size=600x800")
	usr << browse(html, "window=ViewBorer\ref[src]Chems;size=600x800")

	return

/mob/living/simple_animal/borer/verb/hide()
	set category = "Borer"
	set name = "Hide"
	set desc = "Become invisible to the common eye."

	if(victim)
		to_chat(src, "<span class='warning'>You cannot do this whilst you are infecting a host</span>")

	if(src.stat != CONSCIOUS)
		return

	if (src.layer != TURF_LAYER+0.2)
		src.layer = TURF_LAYER+0.2
		src.visible_message("<span class='name'>[src] scurries to the ground!</span>", \
						"<span class='noticealien'>You are now hiding.</span>")
	else
		src.layer = MOB_LAYER
		src.visible_message("[src] slowly peaks up from the ground...", \
					"<span class='noticealien'>You stop hiding.</span>")

/mob/living/simple_animal/borer/verb/dominate_victim()
	set category = "Borer"
	set name = "Paralyze Victim"
	set desc = "Freeze the limbs of a potential host with supernatural fear."

	if(world.time - used_dominate < 150)
		to_chat(src, "<span class='warning'>You cannot use that ability again so soon.</span>")
		return

	if(victim)
		to_chat(src, "<span class='warning'>You cannot do that from within a host body.</span>")
		return

	if(src.stat != CONSCIOUS)
		to_chat(src, "<span class='warning'>You cannot do that in your current state.</span>")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/C in view(1,src))
		if(C.stat == CONSCIOUS)
			choices += C

	if(world.time - used_dominate < dominate_cooldown)
		to_chat(src, "<span class='warning'>You cannot use that ability again so soon.</span>")
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to dominate?") in null|choices


	if(!M || !src) return
	if(!Adjacent(M)) return

	if(M.borer)
		to_chat(src, "<span class='warning'>You cannot paralyze someone who is already infected!</span>")
		return

	src.layer = MOB_LAYER

	to_chat(src, "<span class='warning'>You focus your psychic lance on [M] and freeze their limbs with a wave of terrible dread.</span>")
	to_chat(M, "<span class='userdanger'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>")
	M.Stun(40)

	used_dominate = world.time

/mob/living/simple_animal/borer/verb/release_victim()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."

	if(!victim)
		to_chat(src, "<span class='userdanger'>You are not inside a host body.</span>")
		return

	if(stat != CONSCIOUS)
		to_chat(src, "<span class='userdanger'>You cannot leave your host in your current state.</span>")

	if(!victim || !src) return

	if(leaving)
		leaving = FALSE
		to_chat(src, "<span class='userdanger'>You decide against leaving your host.</span>")
		return

	to_chat(src, "<span class='userdanger'>You begin disconnecting from [victim]'s synapses and prodding at their internal ear canal.</span>")

	if(victim.stat != DEAD)
		to_chat(victim, "<span class='userdanger'>An odd, uncomfortable pressure begins to build inside your skull, behind your ear...</span>")

	leaving = TRUE

	spawn(100)

		if(!victim || !src) return
		if(!leaving) return
		if(controlling) return

		if(src.stat != CONSCIOUS)
			to_chat(src, "<span class='userdanger'>You cannot release your host in your current state.</span>")
			return

		to_chat(src, "<span class='userdanger'>You wiggle out of [victim]'s ear and plop to the ground.</span>")
		if(victim.mind)
			to_chat(victim, "<span class='danger'>Something slimy wiggles out of your ear and plops to the ground!</span>")
			to_chat(victim, "<span class='danger'>As though waking from a dream, you shake off the insidious mind control of the brain worm. Your thoughts are your own again.</span>")
		leave_victim()



/mob/living/simple_animal/borer/verb/jumpstart()
	set category = "Borer"
	set name = "Jumpstart Host"
	set desc = "Brings your host back from the dead."

	if(!victim)
		to_chat(src, "<span class='warning'>You need a host to be able to use this.</span>")
		return

	if(docile)
		to_chat(src, "<span class='warning'>You are feeling too docile to use this!</span>")
		return

	if(chemicals < 250)
		to_chat(src, "<span class='warning'>You need 250 chemicals to use this!</span>")
		return

	if(!checkStrength())
		return 0

	if(victim.stat == DEAD)
		GLOB.dead_mob_list -= victim
		GLOB.alive_mob_list += victim
		victim.tod = null
		victim.setToxLoss(0)
		victim.setOxyLoss(0)
		victim.setCloneLoss(0)
		victim.SetKnockdown(0)
		victim.SetStun(0)
		victim.SetParalyzed(0)
		victim.radiation = 0
		victim.heal_overall_damage(victim.getBruteLoss(), victim.getFireLoss())
		victim.reagents.clear_reagents()
		if(istype(victim,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = victim
			H.restore_blood()
			H.remove_all_embedded_objects()
		//victim.update_canmove()
		victim.med_hud_set_status()
		victim.med_hud_set_health()
		victim.stat = CONSCIOUS
		log_game("[src]/([src.ckey]) has revived [victim]/([victim.ckey]")
		chemicals -= 250
		to_chat(src, "<span class='notice'>You send a jolt of energy to your host, reviving them!</span>")
		victim.grab_ghost(force = TRUE) //brings the host back, no eggscape
		victim <<"<span class='notice'>You bolt upright, gasping for breath!</span>"

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!victim)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(src.stat != CONSCIOUS)
		to_chat(src, "You cannot do that in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		return

	if(victim.stat == DEAD)
		to_chat(src, "<span class='warning'>This host lacks enough brain function to control.</span>")
		return

	if(world.time - used_control < control_cooldown)
		to_chat(src, "<span class='warning'>It's too soon to use that!</span>")
		return

	if(!checkStrength())
		return FALSE
	if(client.prefs.afreeze)
		to_chat(src, "<span class='warning'>You are frozen by an administrator.</span>")
		return

	to_chat(src, "<span class='danger'>You begin delicately adjusting your connection to the host brain...</span>")

	addtimer(CALLBACK(src,.proc/full_control), 100 + victim.getBrainLoss()*5)

/mob/living/simple_animal/borer/proc/full_control()
	if(!victim || !src || controlling || victim.stat == DEAD)
		return

	if(docile)
		src <<"<span class='warning'>You are feeling far too docile to do that.</span>"
		return

	else

		log_game("[src]/([src.ckey]) assumed control of [victim]/([victim.ckey] with borer powers.")
		to_chat(src, "<span class='warning'>You plunge your probosci deep into the cortex of the host brain, interfacing directly with their nervous system.</span>")
		to_chat(victim, "<span class='userdanger'>You feel a strange shifting sensation behind your eyes as an alien consciousness displaces yours.</span>")

		// host -> brain
		var/h2b_id = victim.computer_id
		var/h2b_ip= victim.lastKnownIP
		victim.computer_id = null
		victim.lastKnownIP = null

		qdel(host_brain)
		host_brain = new(src)

		host_brain.ckey = victim.ckey

		host_brain.name = victim.name

		if(victim.mind)
			host_brain.mind = victim.mind

		if(!host_brain.computer_id)
			host_brain.computer_id = h2b_id

		if(!host_brain.lastKnownIP)
			host_brain.lastKnownIP = h2b_ip

		// self -> host
		var/s2h_id = src.computer_id
		var/s2h_ip= src.lastKnownIP
		src.computer_id = null
		src.lastKnownIP = null

		victim.ckey = src.ckey
		victim.mind = src.mind

		if(!victim.computer_id)
			victim.computer_id = s2h_id

		if(!victim.lastKnownIP)
			victim.lastKnownIP = s2h_ip

		controlling = TRUE

		victim.verbs += /mob/living/carbon/proc/release_control
		victim.verbs += /mob/living/carbon/proc/spawn_larvae

		victim.med_hud_set_status()

/mob/living/simple_animal/borer/verb/punish()
	set category = "Borer"
	set name = "Punish"
	set desc = "Punish your victim"

	if(!victim)
		to_chat(src, "<span class='warning'>You are not inside a host body.</span>")
		return

	if(src.stat != CONSCIOUS)
		to_chat(src, "You cannot do that in your current state.")
		return

	if(docile)
		to_chat(src, "<span class='warning'>You are feeling far too docile to do that.</span>")
		return

	if(chemicals < 75)
		to_chat(src, "<span class='warning'>You need 75 chems to punish your host.</span>")
		return

	if(!checkStrength())
		return FALSE

	var/punishment = input("Select a punishment:.", "Punish") as null|anything in list("Blindness","Deafness","Stun")

	if(!punishment)
		return

	if(chemicals < 75)
		to_chat(src, "<span class='warning'>You need 75 chems to punish your host.</span>")
		return

	switch(punishment) //Hardcoding this stuff.
		if("Blindness")
			victim.blind_eyes(200)
		if("Deafness")
			var/obj/item/organ/ears/ears = victim.getorganslot(ORGAN_SLOT_EARS)
			ears.deaf = 200
		if("Stun")
			victim.Paralyze(100)

	log_game("[src]/([src.ckey]) punished [victim]/([victim.ckey] with [punishment]")

	chemicals -= 75


mob/living/carbon/proc/release_control()

	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	if(borer && borer.host_brain)
		if(!borer.docile) //if the borer is docile they have to give up control regardless
			if(alert(src, "Sure you want to give up your control so soon?", "Confirm", "Yes", "No") != "Yes")
				return
		to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [borer.host_brain]</span>")

		borer.detatch()

		verbs -= /mob/living/carbon/proc/release_control
		verbs -= /mob/living/carbon/proc/spawn_larvae

/mob/living/carbon/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce"
	set desc = "Vomit out your younglings."
	var/poll_time = 100

	if(isbrain(src))
		to_chat(src, "<span class='usernotice'>You need a mouth to be able to do this.</span>")
		return

	if(!borer)
		return

	if(world.time < borer.next_spawn_time)
		to_chat(src, "<span class='warning'>We are already reproducing.</span>")
		return

	if(borer.chemicals >= 100)
		to_chat(src, "<span class='notice'>We prepare our host for the creation of a new borer.</span>")
		borer.next_spawn_time = world.time + poll_time
		var/list/Bcandidates = pollCandidates("Do you want to play as a borer?", ROLE_BORER, null, ROLE_BORER, poll_time) // we use this to FIND candidates. not necessarily use them.
		if(!Bcandidates.len)
			to_chat(src, "<span class='usernotice'>Our reproduction system seems to have failed... Perhaps we should try again some other time?</span>")
			return

		borer.chemicals -= 100

		new /obj/effect/decal/cleanable/vomit(get_turf(src))
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)
		visible_message("<span class='danger'>[src] heaves violently, expelling a rush of vomit and a wriggling, sluglike creature!</span>")

		log_game("[src]/([src.ckey]) has spawned a new borer via reproducing.")
		var/mob/living/simple_animal/borer/newborer = new(get_turf(src))
		var/mob/dead/observer/O = pick(Bcandidates)
		newborer.transfer_personality(O.client)
	else
		to_chat(src, "<span class='warning'>You do not have enough chemicals stored to reproduce.</span>")
		return
