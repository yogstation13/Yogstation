//Soul vessel: An ancient positronic brain that serves only Ratvar.
/obj/item/mmi/posibrain/soul_vessel
	name = "soul vessel"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	var/clockwork_desc = "A soul vessel, an ancient relic that can attract the souls of the damned or simply rip a mind from an unconscious or dead human.\n\
	<span class='brass'>If active, can serve as a positronic brain, placable in cyborg shells or clockwork construct shells.</span>"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	req_access = list()
	braintype = "Servant"
	begin_activation_message = span_brass("You activate the cogwheel. It hitches and stalls as it begins spinning.")
	success_message = span_brass("The cogwheel's rotation smooths out as the soul vessel activates.")
	fail_message = span_warning("The cogwheel creaks and grinds to a halt. Maybe you could try again?")
	new_role = "Soul Vessel"
	welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a soul vessel - a clockwork mind created by Ratvar, the Clockwork Justiciar.\n\
	You answer to Ratvar and his servants. It is your discretion as to whether or not to answer to anyone else.\n\
	The purpose of your existence is to further the goals of the servants and Ratvar himself. Above all else, serve Ratvar.</b>"
	new_mob_message = span_brass("The soul vessel emits a jet of steam before its cogwheel smooths out.")
	dead_message = span_deadsay("Its cogwheel, scratched and dented, lies motionless.")
	recharge_message = span_warning("The soul vessel's internal geis capacitor is still recharging!")
	possible_names = list("Judge", "Guard", "Servant", "Smith", "Auger")
	autoping = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_replace_ai_name = TRUE
	override_cyborg_laws = TRUE
	can_update_laws = TRUE

/obj/item/mmi/posibrain/soul_vessel/Initialize()
	. = ..()
	radio.on = FALSE
	laws = new /datum/ai_laws/ratvar()
	braintype = picked_name
	GLOB.all_clockwork_objects += src

/obj/item/mmi/posibrain/soul_vessel/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/mmi/posibrain/soul_vessel/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	. = ..()
	desc = initial(desc)

/obj/item/mmi/posibrain/soul_vessel/transfer_personality(mob/candidate)
	. = ..()
	if(.)
		add_servant_of_ratvar(brainmob, TRUE)

/obj/item/mmi/posibrain/soul_vessel/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, span_warning("You fiddle around with [src], to no avail."))
		return FALSE
	if(QDELETED(brainmob))
		return
	if(!brainmob.key)
		to_chat(user, span_warning("[src] doesn't have a soul in it!"))
		return
	to_chat(user, span_brass("You begin shaping a form for the soul from [src]..."))
	if(!do_after(user, 4 SECONDS, src))
		return
	if(QDELETED(brainmob) || QDELETED(src) || !brainmob.key)
		return
	var/mob/living/simple_animal/hostile/clockwork/anima_fragment/body = new /mob/living/simple_animal/hostile/clockwork/anima_fragment (get_turf(src))
	if(!body)
		return
	if(brainmob.mind)
		brainmob.mind.transfer_to(body)
	else
		body.key = brainmob.key
	body.visible_message(span_warning("[body] suddenly emerges from [src]!"), \
	span_brass("You emerge from [src], in a new body."))
	qdel(src)

/obj/item/mmi/posibrain/soul_vessel/attack(mob/living/target, mob/living/carbon/human/user)
	if(!is_servant_of_ratvar(user) || !ishuman(target))
		return ..()
	if(QDELETED(brainmob))
		return
	if(brainmob.key)
		to_chat(user, span_nezbere("\"This vessel is filled, friend. Provide it with a body.\""))
		return
	if(is_servant_of_ratvar(target))
		to_chat(user, span_nezbere("\"It would be more wise to revive your allies, friend.\""))
		return
	if(target.suiciding)
		to_chat(user, span_nezbere("\"This ally isn't able to be revived.\""))
		return
	var/mob/living/carbon/human/H = target
	if(H.stat == CONSCIOUS)
		to_chat(user, span_warning("[H] must be dead or unconscious for you to claim [H.p_their()] mind!"))
		return
	if(H.head)
		var/obj/item/I = H.head
		if(I.flags_inv & HIDEHAIR) //they're wearing a hat that covers their skull
			to_chat(user, span_warning("[H]'s head is covered, remove [H.p_their()] [H.head] first!"))
			return
	if(H.wear_mask)
		var/obj/item/I = H.wear_mask
		if(I.flags_inv & HIDEHAIR) //they're wearing a mask that covers their skull
			to_chat(user, span_warning("[H]'s head is covered, remove [H.p_their()] [H.wear_mask] first!"))
			return
	var/obj/item/bodypart/head/HE = H.get_bodypart(BODY_ZONE_HEAD)
	if(!HE) //literally headless
		to_chat(user, span_warning("[H] has no head, and thus no mind to claim!"))
		return
	var/obj/item/organ/brain/B = H.getorgan(/obj/item/organ/brain)
	if(!B) //either somebody already got to them or robotics did
		to_chat(user, span_warning("[H] has no brain, and thus no mind to claim!"))
		return
	if(B.suicided || B.brainmob?.suiciding)
		to_chat(user, span_nezbere("\"This ally isn't able to be revived.\""))
		return
	if(!H.key) //nobody's home
		to_chat(user, span_warning("[H] has no mind to claim!"))
		return
	if(brainmob.suiciding)
		brainmob.set_suicide(FALSE)
	playsound(H, 'sound/misc/splort.ogg', 60, 1, -1)
	playsound(H, 'sound/magic/clockwork/anima_fragment_attack.ogg', 40, 1, -1)
	H.fakedeath("soul_vessel") //we want to make sure they don't deathgasp and maybe possibly explode
	H.death()
	H.cure_fakedeath("soul_vessel")
	H.apply_status_effect(STATUS_EFFECT_SIGILMARK) //let them be affected by vitality matrices
	picked_name = "Slave"
	braintype = picked_name
	brainmob.timeofhostdeath = H.timeofdeath
	user.visible_message(span_warning("[user] presses [src] to [H]'s head, ripping through the skull and carefully extracting the brain!"), \
	span_brass("You extract [H]'s consciousness from [H.p_their()] body, trapping it in the soul vessel."))
	transfer_personality(H)
	brainmob.fully_replace_character_name(null, "[braintype] [H.real_name]")
	name = "[initial(name)] ([brainmob.name])"
	B.Remove(H)
	qdel(B)
	H.update_hair()
