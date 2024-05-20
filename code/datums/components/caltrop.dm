/datum/component/caltrop
	///Minimum damage done when crossed
	var/min_damage

	///Maximum damage done when crossed
	var/max_damage

	///Probability of actually "firing", stunning and doing damage
	var/probability

	///Amount of time the spike will paralyze
	var/paralyze_duration

	///Miscelanous caltrop flags; shoe bypassing, walking interaction, silence
	var/flags

	///The sound that plays when a caltrop is triggered.
	var/soundfile

	///given to connect_loc to listen for something moving over target
	var/static/list/crossed_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

	///So we can update ant damage
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/cooldown = 0

/datum/component/caltrop/Initialize(min_damage = 0, max_damage = 0, probability = 100, paralyze_duration = 6 SECONDS, flags = NONE, soundfile = null)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	
	src.min_damage = min_damage
	src.max_damage = max(min_damage, max_damage)
	src.probability = probability
	src.paralyze_duration = paralyze_duration
	src.flags = flags
	src.soundfile = soundfile

	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, crossed_connections)
	else
		RegisterSignal(get_turf(parent), COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

// Inherit the new values passed to the component
/datum/component/caltrop/InheritComponent(datum/component/caltrop/new_comp, original, min_damage, max_damage, probability, flags, soundfile)
	if(!original)
		return
	if(min_damage)
		src.min_damage = min_damage
	if(max_damage)
		src.max_damage = max_damage
	if(probability)
		src.probability = probability
	if(flags)
		src.flags = flags
	if(soundfile)
		src.soundfile = soundfile

/datum/component/caltrop/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	//SIGNAL_HANDLER //we're not ready
	
	if(!prob(probability))
		return

	if(!ishuman(arrived))
		return

	var/mob/living/carbon/human/digitigrade_fan = arrived
	if(HAS_TRAIT(digitigrade_fan, TRAIT_PIERCEIMMUNE))
		return

	if((flags & CALTROP_IGNORE_WALKERS) && digitigrade_fan.m_intent == MOVE_INTENT_WALK)
		return

	var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/O = digitigrade_fan.get_bodypart(picked_def_zone)
	if(!istype(O))
		return
	if(O.status == BODYPART_ROBOTIC)
		return

	var/feetCover = (digitigrade_fan.wear_suit && (digitigrade_fan.wear_suit.body_parts_covered & FEET)) || (digitigrade_fan.w_uniform && (digitigrade_fan.w_uniform.body_parts_covered & FEET))

	if(!(flags & CALTROP_BYPASS_SHOES) && (digitigrade_fan.shoes || feetCover))
		return

	if((digitigrade_fan.movement_type & FLYING) || digitigrade_fan.buckled)
		return

	var/damage = rand(min_damage, max_damage)
	if(HAS_TRAIT(digitigrade_fan, TRAIT_LIGHT_STEP))
		damage *= 0.75
	
	digitigrade_fan.apply_damage(damage, BRUTE, picked_def_zone, wound_bonus = CANT_WOUND)

	if(cooldown < world.time - 10) //cooldown to avoid message spam.
		if(!digitigrade_fan.incapacitated(ignore_restraints = TRUE))
			digitigrade_fan.visible_message(span_danger("[digitigrade_fan] steps on [parent]."), \
					span_userdanger("You step on [parent]!"))
		else
			digitigrade_fan.visible_message(span_danger("[digitigrade_fan] slides on [parent]!"), \
					span_userdanger("You slide on [parent]!"))

		cooldown = world.time
	digitigrade_fan.Paralyze(paralyze_duration)
	if(!soundfile)
		return
	playsound(digitigrade_fan, soundfile, 15, TRUE, -3)

/datum/component/caltrop/UnregisterFromParent()
	if(ismovable(parent))
		qdel(GetComponent(/datum/component/connect_loc_behalf))
