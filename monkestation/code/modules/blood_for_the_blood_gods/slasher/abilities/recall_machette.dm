/datum/action/cooldown/slasher/summon_machette
	name = "Summon Machette"
	desc = "Summon your machete to your active hand, or create one if it doesn't exist. This machete deals 15 BRUTE on hit increasing by 2.5 for every soul you own, and stuns on throw."

	button_icon_state = "summon_machete"

	cooldown_time = 15 SECONDS

	var/obj/item/slasher_machette/stored_machette


/datum/action/cooldown/slasher/summon_machette/Destroy()
	. = ..()
	QDEL_NULL(stored_machette)

/datum/action/cooldown/slasher/summon_machette/Activate(atom/target)
	. = ..()
	if(owner.stat == DEAD)
		return
	if(!stored_machette || QDELETED(stored_machette))
		stored_machette = new /obj/item/slasher_machette
		var/datum/antagonist/slasher/slasherdatum = owner.mind.has_antag_datum(/datum/antagonist/slasher)
		if(!slasherdatum)
			return
		slasherdatum.linked_machette = stored_machette

	if(!owner.put_in_hands(stored_machette))
		stored_machette.forceMove(get_turf(owner))
	else
		SEND_SIGNAL(owner, COMSIG_LIVING_PICKED_UP_ITEM, stored_machette)

/obj/item/slasher_machette
	name = "slasher's machete"
	desc = "An old machete, clearly showing signs of wear and tear due to its age."

	icon = 'goon/icons/obj/items/weapons.dmi'
	icon_state = "welder_machete"
	hitsound = 'goon/sounds/impact_sounds/Flesh_Cut_1.ogg'

	inhand_icon_state = "PKMachete0"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/melee_righthand.dmi'

	force = 20 //damage increases by 2.5 for every soul they take
	throwforce = 15 //damage goes up by 2.5 for every soul they take
	demolition_mod = 1.25
	armour_penetration = 10
	//tool_behaviour = TOOL_CROWBAR // lets you pry open doors forcibly

	sharpness = SHARP_EDGED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/// Used to keep track of the force we had before throws. After the throw, `throwforce` is
	/// restored to this.
	var/pre_throw_force

/obj/item/slasher_machette/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_PRE_THROW, PROC_REF(pre_throw))
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(post_throw))

/obj/item/slasher_machette/Destroy(force)
	UnregisterSignal(src, list(COMSIG_MOVABLE_PRE_THROW, COMSIG_MOVABLE_POST_THROW))
	return ..()

/obj/item/slasher_machette/proc/pre_throw(obj/item/source, list/arguments)
	SIGNAL_HANDLER
	var/mob/living/thrower = arguments[4]
	if(!istype(thrower) || !thrower.mind.has_antag_datum(/datum/antagonist/slasher))
		// Just in case our thrower isn't actually a slasher (somehow). This shouldn't ever come up,
		// but if it does, then we just prevent the throw.
		return COMPONENT_CANCEL_THROW

	var/turf/below_turf = get_turf(arguments[4]) // the turf below the person throwing
	var/turf_light_level = below_turf.get_lumcount()
	var/area/ismaints = get_area(below_turf)
	pre_throw_force = throwforce
	if(istype(ismaints, /area/station/maintenance))
		throwforce = 1.1 * throwforce
	else
		throwforce = throwforce * (max(clamp((1 - turf_light_level), 0, 1)))

/obj/item/slasher_machette/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(iscarbon(hit_atom))
		playsound(src, 'goon/sounds/impact_sounds/Flesh_Stab_3.ogg', 25, 1)
	if(isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		hit_living.Knockdown(2 SECONDS)

/obj/item/slasher_machette/proc/post_throw(obj/item/source, datum/thrownthing, spin)
	SIGNAL_HANDLER
	// Restore the force we had before the throw.
	throwforce = pre_throw_force

/obj/item/slasher_machette/attack_hand(mob/user, list/modifiers)
	if(isliving(user))
		var/mob/living/living_user = user
		if(!user.mind.has_antag_datum(/datum/antagonist/slasher))
			forceMove(get_turf(user))
			user.emote("scream")
			living_user.adjustBruteLoss(force)
			to_chat(user, span_warning("You scream out in pain as you hold the [src]!"))
			return FALSE
	var/datum/antagonist/slasher/slasherdatum = user.mind?.has_antag_datum(/datum/antagonist/slasher)
	if(slasherdatum?.active_action && istype(slasherdatum.active_action, /datum/action/cooldown/slasher/soul_steal))
		return FALSE // Blocks the attack
	return ..() // Proceeds with normal attack if no soul steal is active

/obj/item/slasher_machette/attack(mob/living/target_mob, mob/living/user, params)
	if(isliving(user))
		var/mob/living/living_user = user
		if(!user.mind.has_antag_datum(/datum/antagonist/slasher))
			forceMove(get_turf(user))
			user.emote("scream")
			living_user.adjustBruteLoss(force)
			to_chat(user, span_warning("You scream out in pain as you hold the [src]!"))
			return
	var/datum/antagonist/slasher/slasherdatum = user.mind?.has_antag_datum(/datum/antagonist/slasher)
	if(slasherdatum?.active_action)
		return TRUE // Blocks the attack
	return ..()

/obj/machinery/door/airlock/proc/attack_slasher_machete(atom/target, mob/living/user)
	if(!user.mind.has_antag_datum(/datum/antagonist/slasher))
		return
	if(isElectrified() && shock(user, 100)) //Mmm, fried slasher!
		add_fingerprint(user)
		return
	if(!density) //Already open
		return
	if(locked || welded || seal) //Extremely generic, as slasher is stupid.
		if((user.istate & ISTATE_HARM))
			return
		to_chat(user, span_warning("[src] refuses to budge!"))
		return
	add_fingerprint(user)
	user.visible_message(span_warning("[user] begins prying open [src]."),\
						span_noticealien("You begin digging your machete into [src] with all your might!"),\
						span_warning("You hear groaning metal..."))
	var/time_to_open = 5 //half a second
	if(hasPower())
		time_to_open = 5 SECONDS //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE, mixer_channel = CHANNEL_SOUND_EFFECTS)


	if(do_after(user, time_to_open, src))
		if(density && !open(BYPASS_DOOR_CHECKS)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			to_chat(user, span_warning("Despite your efforts, [src] managed to resist your attempts to open it!"))
		return
