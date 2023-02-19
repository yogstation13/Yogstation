/obj/item/organ/cyberimp/leg
	name = "leg implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_LEG
	icon_state = "implant-leg"
	w_class = WEIGHT_CLASS_NORMAL

	//to determine what type of implant for checking if both legs are the same
	var/implant_type = "leg implant"
	COOLDOWN_DECLARE(emp_notice)

/obj/item/organ/cyberimp/leg/Initialize()
	. = ..()
	update_icon()
	SetSlotFromZone()

/obj/item/organ/cyberimp/leg/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	
	var/obj/item/bodypart/L = owner.get_bodypart(zone)
	if(!L)	//how did you get an implant in a limb you don't have?
		return

	L.receive_damage(5,0,10)	//always take a least a little bit of damage to the leg

	if(prob(50))	//you're forced to use two of these for them to work so let's give em a chance to not get completely fucked
		if(COOLDOWN_FINISHED(src, emp_notice))
			to_chat(owner, span_warning("The EMP causes the [src] in your [L] to twitch randomly!"))
			COOLDOWN_START(src, emp_notice, 30 SECONDS)
		return

	L.set_disabled(TRUE)	//disable the bodypart
	addtimer(CALLBACK(src, .proc/reenableleg), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

	if(severity & EMP_HEAVY && prob(5))	//put probabilities into a calculator before you try fucking with this
		to_chat(owner, span_warning("The EMP causes your [src] to thrash your [L] around wildly breaking it!"))	
		var/datum/wound/blunt/severe/breakdown = new
		breakdown.apply_wound(L)
		L.receive_damage(20)
	else if(COOLDOWN_FINISHED(src, emp_notice))
		to_chat(owner, span_warning("The EMP causes your [src] to seize up, preventing your [L] from moving!"))
		COOLDOWN_START(src, emp_notice, 30 SECONDS)

/obj/item/organ/cyberimp/leg/proc/reenableleg()
	var/obj/item/bodypart/L = owner.get_bodypart(zone)
	if(!L)	//You got emped and then lost the leg in those 10 seconds? impressive
		return

	L.set_disabled(FALSE)
	
/obj/item/organ/cyberimp/leg/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_LEG)
			slot = ORGAN_SLOT_LEFT_LEG_AUG
		if(BODY_ZONE_R_LEG)
			slot = ORGAN_SLOT_RIGHT_LEG_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/leg/update_icon()
	if(zone == BODY_ZONE_R_LEG)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/leg/examine(mob/user)
	. = ..()
	. += span_info("[src] is assembled in the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg configuration. You can use a screwdriver to reassemble it.")
	. += span_info("You will need two of the same type of implant for them to properly function.")

/obj/item/organ/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return .
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_LEG)
		zone = BODY_ZONE_L_LEG
	else
		zone = BODY_ZONE_R_LEG
	SetSlotFromZone()
	to_chat(user, span_notice("You modify [src] to be installed on the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg."))
	update_icon()

/obj/item/organ/cyberimp/leg/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, span_warning("[src] is hit by EMP!"))
		// give the owner an idea about why his implant is glitching

/obj/item/organ/cyberimp/leg/Insert(mob/living/carbon/M, special, drop_if_replaced, special_zone)
	. = ..()
	if(HasBoth())
		AddEffect()
	
/obj/item/organ/cyberimp/leg/Remove(mob/living/carbon/M, special)
	RemoveEffect()
	. = ..()
	
/obj/item/organ/cyberimp/leg/proc/HasBoth()
	if(owner.getorganslot(ORGAN_SLOT_RIGHT_LEG_AUG) && owner.getorganslot(ORGAN_SLOT_LEFT_LEG_AUG))
		var/obj/item/organ/cyberimp/leg/left = owner.getorganslot(ORGAN_SLOT_LEFT_LEG_AUG)
		var/obj/item/organ/cyberimp/leg/right = owner.getorganslot(ORGAN_SLOT_RIGHT_LEG_AUG)
		if(left.implant_type == right.implant_type)
			return TRUE
	return FALSE

/obj/item/organ/cyberimp/leg/proc/AddEffect()
	return

/obj/item/organ/cyberimp/leg/proc/RemoveEffect()
	return

//------------water noslip implant
/obj/item/organ/cyberimp/leg/galosh
	name = "antislip implant"
	desc = "An implant that uses sensors and motors to detect when you are slipping and attempt to prevent it. It probably won't help if the floor is too slippery."
	implant_type = "noslipwater"

/obj/item/organ/cyberimp/leg/galosh/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/galosh/AddEffect()
	ADD_TRAIT(owner, TRAIT_NOSLIPWATER, "Antislip_implant")
	ADD_TRAIT(owner, TRAIT_NOSLIPICE, "Antislip_implant")

/obj/item/organ/cyberimp/leg/galosh/RemoveEffect()
	REMOVE_TRAIT(owner, TRAIT_NOSLIPWATER, "Antislip_implant")
	REMOVE_TRAIT(owner, TRAIT_NOSLIPICE, "Antislip_implant")

//------------true noslip implant
/obj/item/organ/cyberimp/leg/noslip
	name = "advanced antislip implant"
	desc = "An implant that uses advanced sensors and motors to detect when you are slipping and attempt to prevent it."
	syndicate_implant = TRUE
	implant_type = "noslipall"

/obj/item/organ/cyberimp/leg/noslip/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/noslip/AddEffect()
	ADD_TRAIT(owner, TRAIT_NOSLIPALL, "Noslip_implant")

/obj/item/organ/cyberimp/leg/noslip/RemoveEffect()
	REMOVE_TRAIT(owner, TRAIT_NOSLIPALL, "Noslip_implant")


//------------clown shoes implant
/obj/item/organ/cyberimp/leg/clownshoes
	name = "clownshoes implant"
	desc = "Advanced clown technology has allowed the implanting of bananium to allow for heightened prankage."
	implant_type = "clownshoes"
	var/datum/component/waddle
	var/stepcount = 0

/obj/item/organ/cyberimp/leg/clownshoes/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/clownshoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1), 50)

/obj/item/organ/cyberimp/leg/clownshoes/AddEffect()
	owner.add_movespeed_modifier("Clownshoesimplant", update=TRUE, priority=100, multiplicative_slowdown=1, blacklisted_movetypes=(FLYING|FLOATING))
	waddle = owner.AddComponent(/datum/component/waddling)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/SqueakyStep)
	
/obj/item/organ/cyberimp/leg/clownshoes/RemoveEffect()
	owner.remove_movespeed_modifier("Clownshoesimplant")
	QDEL_NULL(waddle)

/obj/item/organ/cyberimp/leg/clownshoes/proc/SqueakyStep()
	if(stepcount % 2)
		playsound(owner, pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg'), 50, 1, -1)
	stepcount ++

//------------dash boots implant
/obj/item/organ/cyberimp/leg/jumpboots
	name = "jumpboots implant"
	desc = "An implant with a specialized propulsion system for rapid foward movement."
	implant_type = "jumpboots"
	var/datum/action/innate/boost/implant_ability
	
/obj/item/organ/cyberimp/leg/jumpboots/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/jumpboots/AddEffect()
	ADD_TRAIT(owner, TRAIT_NOSLIPICE, "Jumpboot_implant")
	implant_ability = new
	implant_ability.Grant(owner)

/obj/item/organ/cyberimp/leg/jumpboots/RemoveEffect()
	REMOVE_TRAIT(owner, TRAIT_NOSLIPICE, "Jumpboot_implant")
	if(implant_ability)
		implant_ability.Remove(owner)

/datum/action/innate/boost//legally distinct dash ability
	name = "Dash"
	desc = "Dash forward."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	COOLDOWN_DECLARE(dash_cooldown)
	var/cooldownlength = 6 SECONDS
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3
	var/mob/living/carbon/human/holder

/datum/action/innate/boost/Grant(mob/user)
	. = ..()
	holder = user

/datum/action/innate/boost/IsAvailable()
	if(COOLDOWN_FINISHED(src, dash_cooldown))
		return ..()
	else
		to_chat(holder, span_warning("The implant's internal propulsion needs to recharge still!"))
		return FALSE

/datum/action/innate/boost/Activate()
	if(!IsAvailable())
		return FALSE

	var/atom/target = get_edge_target_turf(holder, holder.dir) //gets the user's direction

	if (holder.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE))
		playsound(holder, 'sound/effects/stealthoff.ogg', 50, 1, 1)
		holder.visible_message(span_warning("[usr] dashes forward into the air!"))
		COOLDOWN_START(src, dash_cooldown, cooldownlength)
	else
		to_chat(holder, span_warning("Something prevents you from dashing forward!"))

//------------wheelies implant
/obj/item/organ/cyberimp/leg/wheelies
	name = "wheelies implant"
	desc = "Wicked sick wheelies, but now they're not in the heel of your shoes, they just in your heels."
	implant_type = "wheelies"
	var/datum/action/innate/wheelies/implant_ability
	
/obj/item/organ/cyberimp/leg/wheelies/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/wheelies/AddEffect()
	implant_ability = new
	implant_ability.Grant(owner)

/obj/item/organ/cyberimp/leg/wheelies/RemoveEffect()
	if(implant_ability)
		implant_ability.Remove(owner)

/datum/action/innate/wheelies
	name = "Toggle Wheely-Heel's Wheels"
	desc = "Pops out or in your wheely-heel's wheels."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "wheelys"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS|AB_CHECK_LYING
	var/mob/living/carbon/human/holder
	var/wheelToggle = FALSE //False means wheels are not popped out
	var/obj/vehicle/ridden/scooter/wheelys/W

/datum/action/innate/wheelies/Grant(mob/user)
	. = ..()
	holder = user
	W = new /obj/vehicle/ridden/scooter/wheelys(null)

/datum/action/innate/wheelies/Remove(mob/M)
	if(wheelToggle)
		W.unbuckle_mob(holder)
		wheelToggle = FALSE
	QDEL_NULL(W)
	. = ..()

/datum/action/innate/wheelies/Activate()
	if(!(W.is_occupant(holder)))
		wheelToggle = FALSE
	if(wheelToggle)
		W.unbuckle_mob(holder)
		wheelToggle = FALSE
		return
	W.forceMove(get_turf(holder))
	W.buckle_mob(holder)
	wheelToggle = TRUE

//------------Airshoes implant
/obj/item/organ/cyberimp/leg/airshoes
	name = "advanced propulsion implant"
	desc = "An implant that uses propulsion technology to keep you above the ground and let you move faster."
	syndicate_implant = TRUE
	implant_type = "airshoes"
	var/datum/action/innate/boost/implant_dash
	var/datum/action/innate/airshoes/implant_scooter
	
/obj/item/organ/cyberimp/leg/airshoes/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/airshoes/AddEffect()
	ADD_TRAIT(owner, TRAIT_NOSLIPICE, "Airshoes_implant")
	implant_dash = new
	implant_dash.Grant(owner)
	implant_dash.jumpdistance = 7
	implant_dash.jumpspeed = 5//this makes it function like the airshoes
	implant_scooter = new
	implant_scooter.Grant(owner)

/obj/item/organ/cyberimp/leg/airshoes/RemoveEffect()
	REMOVE_TRAIT(owner, TRAIT_NOSLIPICE, "Airshoes_implant")
	if(implant_dash)
		implant_dash.Remove(owner)
	if(implant_scooter)
		implant_scooter.Remove(owner)

/datum/action/innate/airshoes
	name = "Toggle thrust on air shoes."
	desc = "Switch between walking and hovering."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "airshoes_a"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS|AB_CHECK_LYING
	var/mob/living/carbon/human/holder
	var/wheelToggle = FALSE //False means wheels are not popped out
	var/obj/vehicle/ridden/scooter/airshoes/W

/datum/action/innate/airshoes/Grant(mob/user)
	. = ..()
	holder = user
	W = new /obj/vehicle/ridden/scooter/airshoes(null)

/datum/action/innate/airshoes/Remove(mob/M)
	if(wheelToggle)
		W.unbuckle_mob(holder)
		wheelToggle = FALSE
	QDEL_NULL(W)
	. = ..()

/datum/action/innate/airshoes/Activate()
	if(!(W.is_occupant(holder)))
		wheelToggle = FALSE
	if(wheelToggle)
		W.unbuckle_mob(holder)
		wheelToggle = FALSE
		return
	W.forceMove(get_turf(holder))
	W.buckle_mob(holder)
	wheelToggle = TRUE

//------------magboot implant
/obj/item/organ/cyberimp/leg/magboot
	name = "magboot implant"
	desc = "Integrated maglock implant, allows easy movement in a zero-gravity environment."
	implant_type = "magboot"
	var/datum/action/innate/magboots/implant_ability

/obj/item/organ/cyberimp/leg/magboot/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/magboot/AddEffect()
	implant_ability = new
	implant_ability.Grant(owner)
	
/obj/item/organ/cyberimp/leg/magboot/RemoveEffect()
	if(implant_ability)
		implant_ability.Remove(owner)
	owner.remove_movespeed_modifier("Magbootimplant")

/datum/action/innate/magboots
	var/lockdown = FALSE
	name = "Maglock"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "magboots0"
	icon_icon = 'icons/obj/clothing/shoes.dmi'
	background_icon_state = "bg_default"

/datum/action/innate/magboots/Grant(mob/M)
	if(!ishuman(M))
		return
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE, .proc/UpdateSpeed)

/datum/action/innate/magboots/Remove(mob/M)
	UnregisterSignal(owner, COMSIG_MOVABLE_PRE_MOVE)
	. = ..()

/datum/action/innate/magboots/Trigger()
	if(!lockdown)
		ADD_TRAIT(owner, TRAIT_NOSLIPWATER, "maglock implant")
		ADD_TRAIT(owner, TRAIT_NOSLIPICE, "maglock_implant")
		ADD_TRAIT(owner, TRAIT_MAGBOOTS, "maglock implant")
		button_icon_state = "magboots1"
	else
		REMOVE_TRAIT(owner, TRAIT_NOSLIPWATER, "maglock implant")
		REMOVE_TRAIT(owner, TRAIT_NOSLIPICE, "maglock_implant")
		REMOVE_TRAIT(owner, TRAIT_MAGBOOTS, "maglock implant")
		button_icon_state = "magboots0"
	UpdateButtonIcon()
	lockdown = !lockdown
	to_chat(owner, span_notice("You [lockdown ? "enable" : "disable"] your mag-pulse traction system."))
	owner.update_gravity(owner.has_gravity())

/datum/action/innate/magboots/proc/UpdateSpeed()	
	if(lockdown && !HAS_TRAIT(owner, TRAIT_IGNORESLOWDOWN) && owner.has_gravity())
		owner.add_movespeed_modifier("Magbootimplant", update=TRUE, priority=100, multiplicative_slowdown=2, blacklisted_movetypes=(FLYING|FLOATING))
	else if(owner.has_movespeed_modifier("Magbootimplant"))
		owner.remove_movespeed_modifier("Magbootimplant")
