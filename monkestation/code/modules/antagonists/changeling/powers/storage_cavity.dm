/datum/action/changeling/storage_cavity
	name = "Storage Cavity"
	desc = "We evolve smaller organs, allowing us to covertly store things in their place. Opening and closing it isn't very stealthy, though."
	helptext = "Can store up to 3 small items. IDs can open things from inside. Works in lesser form and while downed. Can be seen and removed via surgery."
	button_icon = 'monkestation/icons/mob/actions/actions_changeling.dmi'
	button_icon_state = "storage_cavity"
	dna_cost = 1
	req_stat = SOFT_CRIT

	var/obj/item/organ/internal/storage_cavity/cavity

/datum/action/changeling/storage_cavity/Grant(mob/grant_to)
	. = ..()
	create_cavity()

/datum/action/changeling/storage_cavity/Remove(mob/remove_from)
	. = ..()
	qdel(cavity)

/datum/action/changeling/storage_cavity/sting_action(mob/living/user, mob/living/target)
	..()

	if(create_cavity())
		to_chat(user, span_warning("Our insides squelch as we regrow our storage cavity."))

	if(!cavity)
		user.balloon_alert(user, "no cavity!")
		return FALSE

	if(!cavity.atom_storage)
		qdel(cavity) // Attempt to recover.
		CRASH("[user] ([user.key]) tried to use their cavity storage, but it didn't have a storage datum. This should never happen.")

	if(user in cavity.atom_storage.is_using)
		cavity.atom_storage.hide_contents(user)
	else
		cavity.atom_storage.open_storage(user)

	return FALSE

/// Creates a storage cavity organ if we don't already have one. Returns whether we grew a new one.
/datum/action/changeling/storage_cavity/proc/create_cavity()
	if(!iscarbon(owner) || cavity)
		return FALSE
	cavity = new
	cavity.Insert(owner)
	RegisterSignals(cavity, list(COMSIG_QDELETING, COMSIG_ORGAN_REMOVED), PROC_REF(forget_cavity))
	return TRUE

/datum/action/changeling/storage_cavity/proc/forget_cavity(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(cavity, list(COMSIG_QDELETING, COMSIG_ORGAN_REMOVED))
	cavity = null

/obj/item/organ/internal/storage_cavity
	name = "rigid membrane"
	desc = "An enlarged protective membrane with rigid walls. It looks like a few things might fit inside."
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "storage_cavity"
	visual = TRUE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STORAGE_CAVITY
	decay_factor = 0

	var/list/access = list()

/obj/item/organ/internal/storage_cavity/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/storage_cavity)

/obj/item/organ/internal/storage_cavity/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	if(!. || !owner)
		return
	forceMove(receiver)
	RegisterSignal(receiver, COMSIG_MOB_TRIED_ACCESS, PROC_REF(on_try_access))

/obj/item/organ/internal/storage_cavity/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_MOB_TRIED_ACCESS)

/obj/item/organ/internal/storage_cavity/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isidcard(arrived))
		var/obj/item/item = arrived
		access += item.GetAccess()


/obj/item/organ/internal/storage_cavity/Exited(atom/movable/gone, direction)
	. = ..()
	if(isidcard(gone))
		var/obj/item/item = gone
		access -= item.GetAccess()

/obj/item/organ/internal/storage_cavity/proc/on_try_access(datum/source, obj/target)
	SIGNAL_HANDLER
	return target.check_access_list(access)

/datum/storage/storage_cavity
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = 6
	max_slots = 3
	silent = TRUE
	silent_for_user = TRUE
	rustle_sound = FALSE
	allow_big_nesting = FALSE

	var/datum/bodypart_overlay/simple/storage_cavity/overlay

	/// Hack to make refresh_views not trigger opening and closing effects.
	var/refreshing

/datum/storage/storage_cavity/open_storage(mob/user)
	. = ..()
	if(!. || refreshing)
		return

	var/obj/item/organ/cavity = real_location?.resolve()
	if(!istype(cavity))
		return

	playsound(cavity, 'sound/effects/wounds/splatter.ogg', vol = 30, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)

	if(cavity.owner != user)
		return

	user.visible_message(
		message = span_danger("[user]'s chest opens up, revealing a large cavity!"),
		self_message = span_notice("We open our storage cavity."),
		blind_message = span_hear("You hear a squelch."),
		vision_distance = 2
	)

	apply_overlay(cavity, user)

/datum/storage/storage_cavity/hide_contents(mob/user)
	. = ..()
	if(isobserver(user) || refreshing)
		return

	var/obj/item/organ/cavity = real_location?.resolve()
	if(!istype(cavity))
		return

	playsound(cavity, 'sound/effects/wounds/splatter.ogg', vol = 30, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, ignore_walls = FALSE)

	if(cavity.owner != user)
		return

	user.visible_message(
		message = span_danger("[user]'s chest closes up!"),
		self_message = span_notice("We close our storage cavity."),
		blind_message = span_hear("You hear a squelch."),
		vision_distance = 2
	)

	clear_overlay(cavity, user)

/datum/storage/storage_cavity/refresh_views()
	refreshing = TRUE
	. = ..()
	refreshing = FALSE

/datum/storage/storage_cavity/proc/apply_overlay(obj/item/organ/cavity, mob/living/carbon/user)
	RegisterSignal(cavity, COMSIG_ORGAN_REMOVED, PROC_REF(clear_overlay))
	RegisterSignal(user, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	var/obj/item/bodypart/chest = user.get_bodypart(BODY_ZONE_CHEST)
	overlay = new
	chest.add_bodypart_overlay(overlay)
	user.update_body()

/datum/storage/storage_cavity/proc/clear_overlay(obj/item/organ/cavity, mob/living/carbon/user)
	SIGNAL_HANDLER
	UnregisterSignal(cavity, COMSIG_ORGAN_REMOVED)
	UnregisterSignal(user, COMSIG_ATOM_EXAMINE)
	var/obj/item/bodypart/chest = user.get_bodypart(BODY_ZONE_CHEST)
	chest.remove_bodypart_overlay(overlay)
	user.update_body()
	QDEL_NULL(overlay)

/datum/storage/storage_cavity/proc/on_examine(mob/living/carbon/user, mob/examiner, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_bolddanger("[user.p_Their()] chest has a large, open cavity!")

/datum/bodypart_overlay/simple/storage_cavity
	icon = 'monkestation/icons/mob/species/misc/bodypart_overlay_simple.dmi'
	icon_state = "storage_cavity"
	layers = EXTERNAL_ADJACENT
