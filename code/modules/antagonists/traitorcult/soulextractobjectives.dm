/datum/objective/soul_extraction //yeet some fucker's brain with a soul vessel
	name = "soul extraction"
	var/obj/item/mmi/posibrain/soul_vessel/agent/linked_vessel
	explanation_text = "<span class='nezbere'>tear out some fucker's brain hahaha</span>"

/datum/objective/soul_extraction/New()
	..()
	target = find_target_by_role(role = ROLE_CLOCK_AGENT, role_type = TRUE, invert = TRUE)
	update_explanation_text()

/datum/objective/soul_extraction/update_explanation_text()
	if(!target)
		explanation_text = "Free Objective"
	else
		explanation_text = "<span class='nezbere'>Extract the brain of [target], the [target.assigned_role] into a soul vessel. You'll need use a replica fabricator on a positronic brain to create the soul vessel.</span>"

/datum/objective/soul_extraction/admin_edit(mob/admin)
	admin_simple_target_pick(admin)

/datum/objective/soul_extraction/check_completion()
	var/list/datum/mind/owners = get_owners()
	if(!target)
		return TRUE
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue

		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc. also gets the brain if it's inside a borg.

		for(var/obj/item/mmi/posibrain/soul_vessel/agent/S in all_items) //Check for items
			if(S == linked_vessel)
				return TRUE
	return FALSE

/obj/item/mmi/posibrain/soul_vessel/agent
	clockwork_desc = "A soul vessel, usable to rip a mind from an unconscious or dead body for storage. Use this in-hand to configure it to a target."
	autoping = FALSE
	agent = TRUE
	var/datum/objective/soul_extraction/linked_objective //objective the vessel is currently linked to after getting a mind successfully

/obj/item/mmi/posibrain/soul_vessel/agent/attack_ghost(mob/dead/observer/user) //lol
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_GHOST, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE
	if(user.client)
		if(IsAdminGhost(user))
			attack_ai(user)
		else if(user.client.prefs.inquisitive_ghost)
			user.examinate(src)
	return FALSE

/obj/item/mmi/posibrain/soul_vessel/agent/attack(mob/living/target, mob/living/carbon/human/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='warning'>You ineffectively slap [target] with [src].</span>")
		return FALSE
	if(braintype)
		to_chat(user, "<span class='nezbere'>This vessel is already filled!</span>")
		return
	var/datum/objective/soul_extraction/linked_objective
	var/datum/team/T = SSticker.mode.clock_agent_team
	for(var/datum/objective/soul_extraction/O in T?.objectives)
		if(O.target == target)
			linked_objective = O
			break
	if(!linked_objective)
		to_chat(user, "<span class='nezbere'>This is not the mind we are looking for.</span>")
		return
	var/mob/living/carbon/human/H = target
	if(H.stat == CONSCIOUS)
		to_chat(user, "<span class='warning'>[H] must be dead or unconscious for you to claim [H.p_their()] mind!</span>")
		return
	if(H.head)
		var/obj/item/I = H.head
		if(I.flags_inv & HIDEHAIR) //they're wearing a hat that covers their skull
			to_chat(user, "<span class='warning'>[H]'s head is covered, remove [H.p_their()] [H.head] first!</span>")
			return
	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(I.flags_inv & HIDEHAIR) //they're wearing a mask that covers their skull
			to_chat(user, "<span class='warning'>[H]'s head is covered, remove [H.p_their()] [H.wear_mask] first!</span>")
			return
	var/obj/item/bodypart/head/HE = H.get_bodypart(BODY_ZONE_HEAD)
	if(!HE) //literally headless
		to_chat(user, "<span class='warning'>[H] has no head, and thus no mind to claim!</span>")
		return
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)
	if(!B) //either somebody already got to them or robotics did
		to_chat(user, "<span class='warning'>[H] has no brain, and thus no mind to claim!</span>")
		return
	playsound(H, 'sound/misc/splort.ogg', 60, 1, -1)
	playsound(H, 'sound/magic/clockwork/anima_fragment_attack.ogg', 40, 1, -1) //BONK
	H.fakedeath("soul_vessel") //we want to make sure they don't deathgasp and maybe possibly explode
	H.death()
	H.cure_fakedeath("soul_vessel")
	H.apply_status_effect(STATUS_EFFECT_SIGILMARK)
	picked_name = "Slave"
	braintype = picked_name
	brainmob.timeofhostdeath = H.timeofdeath
	user.visible_message("<span class='warning'>[user] presses [src] to [H]'s head, ripping through the skull and carefully extracting the brain!</span>", \
	"<span class='brass'>You extract [H]'s consciousness from [H.p_their()] body, trapping it in the soul vessel.</span>")
	to_chat(user, "<span class='nezbere'>That will do. Do not lose it.</span>")
	transfer_personality(H)
	brainmob.fully_replace_character_name(null, "[braintype] [H.real_name]")
	name = "[initial(name)] ([brainmob.name])"
	B.Remove(H)
	qdel(B)
	H.update_hair()
	linked_objective.linked_vessel = src //we did it boys we saved the universe
	icon_state = "soul_vessel-occupied" //stuff here in case the captured person goes catatonic
	dead_message = "<span class='brass'>Its cogwheel struggles to keep turning, but refuses to stop</span>"


/obj/item/mmi/posibrain/soul_vessel/agent/attacked_by(obj/item/I, mob/user)
	. = ..()
	if(user.mind.has_antag_datum(/datum/antagonist/cult/agent) && istype(I, /obj/item/soulstone))
		var/obj/item/soulstone/S = I
		var/datum/team/T = SSticker.mode.blood_agent_team
		for(var/datum/objective/soulshard/O in T?.objectives)
			if(O.target == brainmob.mind)
				O.linked_stone = S
				to_chat(user, "<span class='cultlarge'>\"Perfect. This is the one we need. Do not lose it.\"</span>")
				log_combat(user, brainmob, "captured [brainmob.name]'s soul", src)
				S.transfer_soul("VICTIM", brainmob, user)
				qdel(src)
				break

/datum/objective/soulshard
	name = "soulshard"
	var/obj/item/soulstone/linked_stone
	explanation_text = "<span class='cultbold'>FETCH ME THEIR SOULSSSSSSSS</span>"

/datum/objective/soulshard/New()
	..()
	target = find_target_by_role(role = ROLE_BLOOD_AGENT, role_type = TRUE, invert = TRUE)
	update_explanation_text()

/datum/objective/soulshard/update_explanation_text()
	if(!target)
		explanation_text = "Free Objective"
	else
		explanation_text = "<span class='cultbold'>Attain a soulstone and use it to capture [target]'s soul. They are occupied as a [target.assigned_role]. You can get soulstones by using twisted construction on 30 sheets of reinforced glass.</span>"

/datum/objective/soulshard/check_completion()
	var/list/datum/mind/owners = get_owners()
	if(!target)
		return TRUE
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue

		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc. also gets the brain if it's inside a borg.

		for(var/obj/item/soulstone/S in all_items) //Check for items
			if(S == linked_stone)
				return TRUE
	return FALSE
