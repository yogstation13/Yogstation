/obj/item/gun/medbeam
	name = "medical beamgun"
	desc = "Don't cross the streams!"
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	w_class = WEIGHT_CLASS_NORMAL

	var/mob/living/current_target
	var/last_check = 0
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	var/max_range = 8
	var/active = 0
	var/datum/beam/current_beam = null
	var/mounted = 0 //Denotes if this is a handheld or mounted version

	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/medbeam/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/gun/medbeam/Destroy(mob/user)
	STOP_PROCESSING(SSobj, src)
	LoseTarget()
	return ..()

/obj/item/gun/medbeam/dropped(mob/user)
	..()
	LoseTarget()

/obj/item/gun/medbeam/equipped(mob/user)
	..()
	LoseTarget()

/obj/item/gun/medbeam/proc/LoseTarget()
	if(active)
		qdel(current_beam)
		current_beam = null
		active = 0
		on_beam_release(current_target)
	current_target = null

/obj/item/gun/medbeam/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(isliving(user))
		add_fingerprint(user)

	if(current_target)
		LoseTarget()
	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	current_beam = new(user,current_target,time=6000,beam_icon_state="medbeam",btype=/obj/effect/ebeam/medical)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)

/obj/item/gun/medbeam/process()

	var/source = loc
	if(!mounted && !isliving(source))
		LoseTarget()
		return

	if(!current_target)
		LoseTarget()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(get_dist(source, current_target)>max_range || !los_check(source, current_target))
		LoseTarget()
		if(isliving(source))
			to_chat(source, span_warning("You lose control of the beam!"))
		return

	if(current_target)
		on_beam_tick(current_target)

/obj/item/gun/medbeam/proc/los_check(atom/movable/user, mob/target)
	var/turf/user_turf = user.loc
	if(mounted)
		user_turf = get_turf(user)
	else if(!istype(user_turf))
		return 0
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE //Grille/Glass so it can be used through common windows
	for(var/turf/turf in getline(user_turf,target))
		if(mounted && turf == user_turf)
			continue //Mechs are dense and thus fail the check
		if(turf.density)
			qdel(dummy)
			return 0
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return 0
		for(var/obj/effect/ebeam/medical/B in turf)// Don't cross the str-beams!
			if(B.owner.origin != current_beam.origin)
				explosion(B.loc,0,3,5,8)
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1

/obj/item/gun/medbeam/proc/on_beam_hit(var/mob/living/target)
	return

/obj/item/gun/medbeam/proc/on_beam_tick(var/mob/living/target)
	if(target.health != target.maxHealth)
		new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")
	target.adjustBruteLoss(-4)
	target.adjustFireLoss(-4)
	target.adjustToxLoss(-1)
	target.adjustOxyLoss(-1)
	return

/obj/item/gun/medbeam/proc/on_beam_release(var/mob/living/target)
	return

/obj/effect/ebeam/medical
	name = "medical beam"

//////////////////////////////Mech Version///////////////////////////////
/obj/item/gun/medbeam/mech
	mounted = 1

/obj/item/gun/medbeam/mech/Initialize()
	. = ..()
	STOP_PROCESSING(SSobj, src) //Mech mediguns do not process until installed, and are controlled by the holder obj

///////////////////////////I AM ZE ÜBERMENSCH///////////////////////////
/obj/item/gun/medbeam/uber
	name = "augmented medical beamgun"
	desc = "Doctor, are you sure this will work?"
	icon_state = "chronogun0"
	actions_types = list(/datum/action/item_action/activate_uber)
	var/ubercharge = 0
	var/ubering = FALSE
	var/mob/last_holder
	var/mob/uber_target

/// Fully charged for debugging/bus purposes
/obj/item/gun/medbeam/uber/precharged
	name = "fully-charged augmented medical beamgun"
	ubercharge = 100
	icon_state = "chronogun10"

/// The augmented medical beamgun is 58% charged.
/obj/item/gun/medbeam/uber/examine(mob/user)
	. = ..()
	if(ubercharge == 100)
		. += span_notice("[src] is fully charged!")
	else
		. += span_notice("[src] is [ubercharge]% charged.")

/// Handles ubercharge ticks and icon changes
/obj/item/gun/medbeam/uber/process(delta_time)
	..()

	if(current_target && !ubering)

		if(current_target.health == current_target.maxHealth)
			ubercharge += 1.25*delta_time/10 // 80 seconds

		if(current_target.health < current_target.maxHealth)
			ubercharge += 2.5*delta_time/10 // 40 seconds

	if(ubering)
		// No uber flashing
		if(current_target != uber_target)
			uber_act()
			ubercharge = 0
		else
			ubercharge -= 12.5*delta_time/10
		if(ubercharge <= 0)
			uber_act()

	if(ubercharge >= 100)
		ubercharge = 100
		name = "fully-charged augmented medical beamgun"
	else
		name = "augmented medical beamgun"

	if(ubercharge < 0)
		ubercharge = 0
	
	icon_state = "chronogun[round(ubercharge/10)]"

/// Sets last_holder for uber_act() to prevent exploits
/obj/item/gun/medbeam/uber/equipped(mob/user)
	..()
	last_holder = user

/// If target is lost, uber is lost
/obj/item/gun/medbeam/uber/LoseTarget()
	if(ubering)
		uber_act()
		ubercharge = 0

	..()

/// Activates/deactivates über
/obj/item/gun/medbeam/uber/proc/uber_act()
	if(!ubering)
		ubering = TRUE
		uber_target = current_target

		last_holder.status_flags |= GODMODE
		last_holder.overlay_fullscreen("uber", /obj/screen/fullscreen/uber)
		last_holder.add_atom_colour(list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0), TEMPORARY_COLOUR_PRIORITY)

		uber_target.status_flags |= GODMODE
		uber_target.overlay_fullscreen("uber", /obj/screen/fullscreen/uber)
		uber_target.add_atom_colour(list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0), TEMPORARY_COLOUR_PRIORITY)

	else /// this could remove an admin-given godmode but theres like 0.001% chance that will ever be an issue
		ubering = FALSE

		last_holder.status_flags &= ~GODMODE
		last_holder.clear_fullscreen("uber")
		last_holder.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)

		uber_target.status_flags &= ~GODMODE
		uber_target.clear_fullscreen("uber")
		uber_target.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)

/datum/action/item_action/activate_uber
	name = "Activate Übercharge"
	icon_icon = 'icons/obj/chronos.dmi'
	button_icon_state = "chronogun"

/// Activates über if ubercharge is ready
/datum/action/item_action/activate_uber/Trigger()

	if(!istype(target, /obj/item/gun/medbeam/uber))
		return

	var/obj/item/gun/medbeam/uber/gun = target

	if(!IsAvailable())
		return

	if(gun.ubering)
		to_chat(owner, span_warning("You are already using übercharge!"))
		return

	if(gun.ubercharge < 100)
		to_chat(owner, span_warning("[gun] is only [gun.ubercharge]% charged!"))
		return

	gun.uber_act()

//////////////////////////////Arm Version///////////////////////////////
/obj/item/gun/medbeam/arm
	name = "medical beamgun arm"
	desc = "A bulky medical beam gun based on syndicate designs, can only be used when attached to an arm."

/obj/item/gun/medbeam/arm/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/gun/medbeam/arm/Destroy()
	var/obj/item/bodypart/part
	new /obj/item/medbeam_arm(get_turf(src))
	if(iscarbon(loc))
		var/mob/living/carbon/holder = loc
		var/index = holder.get_held_index_of_item(src)
		if(index)
			part = holder.hand_bodyparts[index]
	. = ..()
	if(part)
		part.drop_limb()

/// Just a placeholder until its put on as to not let people use it when its detached
/obj/item/medbeam_arm
	name = "medical beamgun arm"
	desc = "A bulky medical beam gun based on syndicate designs, can only be used when attached to an arm."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
