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
	var/datum/action/innate/staff/staff_ability //the staff's current bound ability, for certain scripture
	var/list/quickbound = list(/datum/psyker_power/ranged_ability/mindcrush)
	var/maximum_quickbound = 5 // 5 because we only have 3 spells right now. 

/obj/item/staff/psyker
	name = "force staff"
	desc = "A Psykers staff, used to channel the powers of the warp with dealy prowess, or blow themselves up. More often the latter."

///////////////////////////////////////////////////////////////////////////////////
// Below follow the utter nonsense of trying to make the staff work sorta like a staff
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
	if(icon_state == "[initial(icon_state)]-crit" && heat < 25)
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
		staff_ability.unset_ranged_ability(loc)
	staff_ability = null
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
		CRASH("No user on dropped staff.")
	if(staff_ability?.owner) //if we happen to check and we AREN'T in user's hands, remove whatever ability we have
		staff_ability.unset_ranged_ability(user)
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
	var/quickbind = TRUE //if this scripture can be quickbound to a staff
	var/quickbind_desc = "This shouldn't be quickbindable. File a bug report!"
	var/chant_slowdown = 0 //slowdown added while channeling
	var/no_mobility = FALSE //if false user can move while channeling

/datum/psyker_power/New()
	creation_update()

/datum/psyker_power/proc/creation_update() //updates any on-creation effects
	return FALSE //return TRUE if updated

/datum/psyker_power/proc/run_scripture()
	var/successful = FALSE
    if(staff.busy)
        to_chat(invoker, span_warning("[staff] refuses to work, displaying the message: \"[staff.busy]!\""))
        return FALSE
    pre_recital()
    staff.busy = "A spell of ([name]) is in progress"
    channel_time *= staff.speed_multiplier
    if(!recital() || !scripture_effects()) //if we fail any of these, refund components used
        update_staff_info()
    else
        successful = TRUE
	if(staff)
		staff.busy = null
	post_recital()
	qdel(src)
	return successful

/datum/psyker_power/proc/recital() //The process of channeling and charging the spell
	to_chat(invoker, span_warning("You [channel_time <= 0 ? "channel" : "begin channeling"] the warp, to manifest a spell of \"[name]\"."))
	if(!channel_time)
		return TRUE
	if(chant_slowdown)
		invoker.add_movespeed_modifier(MOVESPEED_ID_CLOCKCHANT, update=TRUE, priority=100, multiplicative_slowdown=chant_slowdown) // we can bowwow the clockie slowdown, they wont mind.
	if(!do_after(invoker, channel_time, invoker, timed_action_flags = (no_mobility ? IGNORE_USER_LOC_CHANGE : NONE)))
		staff.busy = null
		invoker.remove_movespeed_modifier(MOVESPEED_ID_CLOCKCHANT)
        scripture_fail()
		return
	invoker.remove_movespeed_modifier(MOVESPEED_ID_CLOCKCHANT)
	return TRUE

/datum/psyker_power/proc/scripture_effects() //The actual effects of the recital after its conclusion

/datum/psyker_power/proc/scripture_fail() //Called if the scripture fails to invoke.

/datum/psyker_power/proc/pre_recital() //Called before the scripture is recited

/datum/psyker_power/proc/post_recital() //Called after the scripture is recited

///////////////////////////////////////////////////////////////////////////////////
// Framework for ranged spells, in case of close ranged spells in the future.
///////////////////////////////////////////////////////////////////////////////////

/datum/psyker_power/ranged_ability
	var/staff_overlay
	var/ranged_type = /datum/action/innate/staff
	var/ranged_message = "This is a huge goddamn bug, how'd you cast this?"
	var/timeout_time = 0
	var/allow_mobility = TRUE //if moving and swapping hands is allowed during the while
	var/datum/progressbar/progbar
	var/spell_heat = 10 //Heat generated on spell cast.

/datum/psyker_power/ranged_ability/Destroy()
	qdel(progbar)
	return ..()

/datum/psyker_power/ranged_ability/scripture_effects()
	if(staff_overlay)
		staff.add_overlay(staff_overlay)
		staff.item_state = ""
		staff.lefthand_file = '' // more sprites (waaa)
		staff.righthand_file = ''
		staff.inhand_overlay = staff_overlay
	staff.staff_ability = new ranged_type(staff)
	staff.staff_ability.staff = staff
	staff.staff_ability.set_ranged_ability(invoker, ranged_message)
	invoker.update_inv_hands()
	var/end_time = world.time + timeout_time
	var/successful = FALSE
	if(timeout_time)
		progbar = new(invoker, timeout_time, staff)
	var/turf/T = get_turf(invoker)
	while(staff && staff.staff_ability && !staff.staff_ability.finished && (staff.staff_ability.in_progress || !timeout_time || world.time <= end_time) && \
		(allow_mobility || (can_recite() && T == get_turf(invoker))))
		if(progbar)
			if(staff.staff_ability.in_progress)
				qdel(progbar)
			else
				progbar.update(end_time - world.time)
		stoplag(1)
	if(staff)
		if(staff.staff_ability)
			successful = staff.staff_ability.successful
			if(!staff.staff_ability.finished && invoker)
				invoker.client?.mouse_override_icon = initial(invoker.client?.mouse_pointer_icon)
				invoker.update_mouse_pointer()
				invoker.click_intercept = null
		staff.cut_overlays()
		staff.item_state = initial(staff.item_state)
		staff.item_state = initial(staff.lefthand_file)
		staff.item_state = initial(staff.righthand_file)
		staff.inhand_overlay = null
		invoker?.update_inv_hands()
	return successful

///////////////////////////////////////////////////////////////////////////////////
// Mindcrush, formerly kindle. 
///////////////////////////////////////////////////////////////////////////////////

/datum/psyker_power/ranged_ability/mindcrush
	name = "mindcrush"
	channel_time = 40
	sort_priority = 4
	staff_overlay = "volt"
	ranged_type = /datum/action/innate/staff/mindcrush
	timeout_time = 50
	chant_slowdown = 1
	important = TRUE
	quickbind = TRUE
	quickbind_desc = "Stuns and mutes a target from a short range."
	spell_heat = 25 // 2 casts can overheat you unless careful

/datum/action/innate/staff/mindcrush
	ranged_mousepointer = 'icons/effects/mouse_pointers/volt_target.dmi' // could make somthing for here too maybe...

/datum/action/innate/staff/mindcrush/do_ability(mob/living/carbon/human/cast_on)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(cast_on)) // cant crush a borg or a simple mob
		return FALSE
	if(isliving(clicked_on))
		var/mob/living/L = clicked_on
		L.apply_damage(200, def_zone = BODY_ZONE_HEAD)
		var/obj/item/bodypart/head = L.get_bodypart(BODY_ZONE_HEAD)
		head.gib()
		L.spawn_gibs()
		staff.heat += spell_heat
		to_chat(invoker, span_warning("so no head?"))
	to_chat(invoker, span_warning("its working"))
	//crush their head, spawn gibs.

	return TRUE
