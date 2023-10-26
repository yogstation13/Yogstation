// Handling for psyker stuff. Could be in another file but idc enough to find a good spot.

/obj/item/staff
	name = "inert staff"
	desc = "Usually used to channel power, this one seems hollow. Probably shouldn`t have it anyways..."
	icon = ''
	icon_state = ""
	item_state = ""
	lefthand_file = ''
	righthand_file = '' // TODO, All sprites :3
	slot_flags = ITEM_SLOT_BACK
	force = 8 // bonk
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL // its a big stick basically
	hitsound = '' // todo
	attack_verb = list("thwacked", "cleansed", "purified", "cludged")
	var/heat = 0 // To allow warp effects
	var/busy //If the staff is currently being used by something
	var/selected_spell
	var/datum/action/innate/slab/slab_ability //the slab's current bound ability, for certain scripture
	var/list/quickbound = list(/datum/clockwork_scripture/ranged_ability/kindle)
	var/maximum_quickbound = 5 // 5 because we only have 3 spells right now. 

/obj/item/staff/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/staff/process()
	if(heat > 0)
		heat --
	if(icon_state == "[initial(icon_state)]-crit" && heat < 25)
		icon_state = "[initial(icon_state)]" // Purple smoke radiating off?

/obj/item/staff/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
	..() //Todo make this work. dont use after attack, thats for smacking someone.
	heat += 2
	switch(heat)
		if(heat >= 20 && heat < 30)
			icon_state = "[initial(icon_state)]-crit"
			if(COOLDOWN_FINISHED(src, overheat_alert))
				to_chat(user, span_warning("You feel a presense pressing on your mind!"))
				COOLDOWN_START(src, overheat_alert, 5 SECONDS)
		if(heat >= 30 && heat < 40)
			to_chat(user, span_warning("The strain on your mind is too much!"))
			// Think D20 but only bad things. 
		if(heat >= 40)
			addtimer(CALLBACK(src, PROC_REF(warp_gib), user), 5 SECONDS)
			to_chat(user, span_warning("The denizens of the warp have come for your soul! Embrace the pain!"))
			usr.say("AAAA HAHAHAHAHA!!!")
	return

/obj/item/staff/proc/warp_gib(mob/living/user)
	user.gib() // haha he went too crazy

/obj/item/staff/psyker
	name = "force staff"
	desc = "Usually used to channel power, this one seems hollow. Probably shouldn`t have it anyways..."

///////////////////////////////////////////////////////////////////////////////////
// Below follow the utter nonsense of trying to make the staff work sorta like a slab
///////////////////////////////////////////////////////////////////////////////////

/datum/action/innate/staff
	click_action = TRUE
	var/obj/item/staff/psyker/staff
	var/successful = FALSE
	var/in_progress = FALSE
	var/finished = FALSE

/datum/action/innate/staff/Destroy()
	staff = null
	return ..()

/datum/action/innate/staff/IsAvailable(feedback = FALSE)
	return TRUE

/datum/action/innate/staff/InterceptClickOn(mob/living/caller, params, atom/clicked_on)
	if(in_progress)
		return FALSE
	if(caller.incapacitated() || !staff || !(staff in caller.held_items) || clicked_on == staff)
		unset_ranged_ability(caller)
		return FALSE

	. = ..()
	if(!.)
		return FALSE
	var/mob/living/i_hate_this = caller || owner || usr
	i_hate_this?.client?.mouse_override_icon = initial(caller?.client?.mouse_override_icon)
	i_hate_this?.update_mouse_pointer()
	i_hate_this?.click_intercept = null
	finished = TRUE
	QDEL_IN(src, 0.1 SECONDS)
	return TRUE

///////////////////////////////////////////////////////////////////////////////////
// Below is kindle, hopefully it will be a different spell soon
///////////////////////////////////////////////////////////////////////////////////

/datum/clockwork_scripture/ranged_ability/kindle
	descname = "Short-Range Single-Target Stun"
	name = "Kindle"
	desc = "Charges your slab with divine energy, allowing you to overwhelm a target with Ratvar's light."
	invocations = list("Divinity, show them your light!")
	whispered = TRUE
	channel_time = 40
	power_cost = 150
	usage_tip = "The light can be used from up to two tiles away. Damage taken will GREATLY REDUCE the stun's duration."
	tier = SCRIPTURE_DRIVER
	primary_component = BELLIGERENT_EYE
	sort_priority = 4
	slab_overlay = "volt"
	ranged_type = /datum/action/innate/slab/kindle
	ranged_message = "<span class='brass'><i>You charge the clockwork slab with divine energy.</i>\n\
	<b>Left-click a target within melee range to stun!\n\
	Click your slab to cancel.</b></span>"
	timeout_time = 50
	chant_slowdown = 1
	no_mobility = FALSE
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Stuns and mutes a target from a short range."

/datum/action/innate/slab/kindle
	ranged_mousepointer = 'icons/effects/mouse_pointers/volt_target.dmi'

/datum/action/innate/slab/kindle/do_ability(mob/living/caller, params, atom/clicked_on)
	var/turf/T = caller.loc
	if(!isturf(T))
		return FALSE

	if(clicked_on in view(7, get_turf(caller)))

		successful = TRUE

		var/turf/U = get_turf(clicked_on)
		to_chat(caller, span_brass("You release the light of Ratvar!"))
		clockwork_say(caller, text2ratvar("Purge all untruths and honor Engine!"))
		log_combat(caller, U, "fired at with Kindle")
		playsound(caller, 'sound/magic/blink.ogg', 50, TRUE, frequency = 0.5)
		var/obj/projectile/kindle/A = new(T)
		A.preparePixelProjectile(clicked_on, caller, params)
		A.fire()

	return TRUE

/obj/projectile/kindle
	name = "kindled flame"
	icon_state = "pulse0"
	nodamage = TRUE
	damage = 0 //We're just here for the stunning!
	damage_type = BURN
	armor_flag = BOMB
	range = 3
	log_override = TRUE

/obj/projectile/kindle/Destroy()
	visible_message(span_warning("[src] flickers out!"))
	. = ..()

/obj/projectile/kindle/on_hit(atom/clicked_on, blocked = FALSE)
	if(isliving(clicked_on))
		var/mob/living/L = clicked_on
		if(is_servant_of_ratvar(L) || L.stat || L.has_status_effect(STATUS_EFFECT_KINDLE))
			return BULLET_ACT_HIT
		var/atom/O = L.can_block_magic()
		playsound(L, 'sound/magic/fireball.ogg', 50, TRUE, frequency = 1.25)
		if(O)
			if(isitem(O))
				L.visible_message(span_warning("[L]'s eyes flare with dim light!"), \
				span_userdanger("Your [O] glows white-hot against you as it absorbs [src]'s power!"))
			else if(ismob(O))
				L.visible_message(span_warning("[L]'s eyes flare with dim light!"))
			playsound(L, 'sound/weapons/sear.ogg', 50, TRUE)
		else
			L.visible_message(span_warning("[L]'s eyes blaze with brilliant light!"), \
			span_userdanger("Your vision suddenly screams with white-hot light!"))
			L.Paralyze(1.5 SECONDS)
			L.apply_status_effect(STATUS_EFFECT_KINDLE)
			L.flash_act(1, 1)
			if(iscultist(L))
				L.adjustFireLoss(15)

	return ..()
