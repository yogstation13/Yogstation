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

/obj/item/staff/psyker
	name = "force staff"
	desc = "A Psykers staff, used to channel the powers of the warp with dealy prowess, or blow themselves up. More often the latter."

///////////////////////////////////////////////////////////////////////////////////
// Below follow the utter nonsense of trying to make the staff work sorta like a slab
///////////////////////////////////////////////////////////////////////////////////

/datum/action/innate/staff
	click_action = TRUE
	var/obj/item/staff/psyker/staff
	var/successful = FALSE
	var/in_progress = FALSE
	var/finished = FALSE

/obj/item/staff/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/staff/process()
	if(heat > 0)
		heat --
	if(icon_state == "[initial(icon_state)]-crit" && heat < 18)
		icon_state = "[initial(icon_state)]" // Purple smoke radiating off?
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

/obj/item/staff/proc/warp_gib(mob/living/user)
	user.gib() // haha he went too crazy

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

/obj/item/staff/psyker/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/clock/quickbind)) //clock stuff below here
		var/datum/action/item_action/clock/quickbind/Q = action
		recite_scripture(quickbound[Q.scripture_index], user, FALSE)

/obj/item/staff/psyker/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(isliving(loc))
		slab_ability.unset_ranged_ability(loc)
	slab_ability = null
	return ..()

/obj/item/staff/psyker/dropped(mob/user, slot)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(check_on_mob), user, slot), 0.1 SECONDS) //dropped is called before the item is out of the slot, so we need to check slightly later

/obj/item/staff/psyker/equipped(mob/user, slot)
	. = ..()
    if(!is_psyker(user)) // Todo, give the psyker the gene on spawn so only they can use the staff
		to_chat(user, span_warning("You hear whispering and chittering from somewhere beyond your mind closing in, and quickly drop the staff before anything bad can happen."))
		user.adjust_confusion(5 SECONDS)
		user.adjust_dizzy(5 SECONDS)
        // make them drop it.
        return
	update_quickbind(user)

/obj/item/staff/psyker/proc/check_on_mob(mob/user, slot)
	if(!user)
		CRASH("No user on dropped slab.")
	if(slab_ability?.owner) //if we happen to check and we AREN'T in user's hands, remove whatever ability we have
		slab_ability.unset_ranged_ability(user)
	if(!LAZYFIND(user.held_items, src))
		update_quickbind(user, TRUE)
///////////////////////////////////////////////////////////////////////////////////
// Overall framework for all spells, channeling, and such
///////////////////////////////////////////////////////////////////////////////////

/datum/psyker_power
	var/descname = "useless" //a simple name for the scripture's effect
	var/name = "scripture"
	var/desc = "Ancient Ratvarian lore. This piece seems particularly mundane."
	var/channel_time = 1 SECONDS //In seconds, how long a ritual takes to chant
	var/obj/item/staff/psyker/staff //The parent staff
	var/mob/living/invoker //The staff's holder
	var/quickbind = FALSE //if this scripture can be quickbound to a clockwork slab
	var/quickbind_desc = "This shouldn't be quickbindable. File a bug report!"
	var/primary_component
	var/chant_slowdown = 0 //slowdown added while channeling
	var/no_mobility = FALSE //if false user can move while channeling

/datum/clockwork_scripture/New()
	creation_update()

/datum/clockwork_scripture/proc/creation_update() //updates any on-creation effects
	return FALSE //return TRUE if updated

/datum/clockwork_scripture/proc/run_scripture()
	var/successful = FALSE
    if(slab.busy)
        to_chat(invoker, span_warning("[slab] refuses to work, displaying the message: \"[slab.busy]!\""))
        return FALSE
    pre_recital()
    slab.busy = "Invocation ([name]) in progress"
    channel_time *= slab.speed_multiplier
    if(!recital() || !check_special_requirements() || !scripture_effects()) //if we fail any of these, refund components used
        adjust_clockwork_power(power_cost)
        update_slab_info()
    else
        successful = TRUE
        if(slab) //if the slab exists, record spell usage
            SSblackbox.record_feedback("tally", "clockcult_scripture_recited", 1, name)
	if(slab)
		slab.busy = null
	post_recital()
	qdel(src)
	return successful

/datum/clockwork_scripture/proc/recital() //The process of speaking the words
	to_chat(invoker, span_brass("You [channel_time <= 0 ? "channel" : "begin channeling"] the warp, to manifest a spell of \"[name]\"."))
	if(!channel_time)
		return TRUE
	if(chant_slowdown)
		invoker.add_movespeed_modifier(MOVESPEED_ID_CLOCKCHANT, update=TRUE, priority=100, multiplicative_slowdown=chant_slowdown)
	if(!do_after(invoker, channel_time, invoker, timed_action_flags = (no_mobility ? IGNORE_USER_LOC_CHANGE : NONE), extra_checks = CALLBACK(src, PROC_REF(check_special_requirements))))
		slab.busy = null
		invoker.remove_movespeed_modifier(MOVESPEED_ID_CLOCKCHANT)
        scripture_fail()
		return
	invoker.remove_movespeed_modifier(MOVESPEED_ID_CLOCKCHANT)
	return TRUE

/datum/clockwork_scripture/proc/scripture_effects() //The actual effects of the recital after its conclusion

/datum/clockwork_scripture/proc/scripture_fail() //Called if the scripture fails to invoke.

/datum/clockwork_scripture/proc/pre_recital() //Called before the scripture is recited

/datum/clockwork_scripture/proc/post_recital() //Called after the scripture is recited

///////////////////////////////////////////////////////////////////////////////////
// Framework for ranged spells, in case of close ranged spells in the future.
///////////////////////////////////////////////////////////////////////////////////

/datum/clockwork_scripture/ranged_ability
	var/slab_overlay
	var/ranged_type = /datum/action/innate/slab
	var/ranged_message = "This is a huge goddamn bug, how'd you cast this?"
	var/timeout_time = 0
	var/allow_mobility = TRUE //if moving and swapping hands is allowed during the while
	var/datum/progressbar/progbar

/datum/clockwork_scripture/ranged_ability/Destroy()
	qdel(progbar)
	return ..()

/datum/clockwork_scripture/ranged_ability/scripture_effects()
	if(slab_overlay)
		slab.add_overlay(slab_overlay)
		slab.item_state = "clockwork_slab"
		slab.lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
		slab.righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
		slab.inhand_overlay = slab_overlay
	slab.slab_ability = new ranged_type(slab)
	slab.slab_ability.slab = slab
	slab.slab_ability.set_ranged_ability(invoker, ranged_message)
	invoker.update_inv_hands()
	var/end_time = world.time + timeout_time
	var/successful = FALSE
	if(timeout_time)
		progbar = new(invoker, timeout_time, slab)
	var/turf/T = get_turf(invoker)
	while(slab && slab.slab_ability && !slab.slab_ability.finished && (slab.slab_ability.in_progress || !timeout_time || world.time <= end_time) && \
		(allow_mobility || (can_recite() && T == get_turf(invoker))))
		if(progbar)
			if(slab.slab_ability.in_progress)
				qdel(progbar)
			else
				progbar.update(end_time - world.time)
		stoplag(1)
	if(slab)
		if(slab.slab_ability)
			successful = slab.slab_ability.successful
			if(!slab.slab_ability.finished && invoker)
				invoker.client?.mouse_override_icon = initial(invoker.client?.mouse_pointer_icon)
				invoker.update_mouse_pointer()
				invoker.click_intercept = null
		slab.cut_overlays()
		slab.item_state = initial(slab.item_state)
		slab.item_state = initial(slab.lefthand_file)
		slab.item_state = initial(slab.righthand_file)
		slab.inhand_overlay = null
		invoker?.update_inv_hands()
	return successful //slab doesn't look like a word now.

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
