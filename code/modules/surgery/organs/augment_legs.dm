/obj/item/organ/cyberimp/leg
	name = "leg implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_LEG
	icon_state = "implant-leg"
	w_class = WEIGHT_CLASS_NORMAL

	/// list of all the traits granted by this
	var/list/added_traits = list()

	/// list of all the abilities granted by this
	var/list/ability_paths = list()

	COOLDOWN_DECLARE(emp_notice)

/obj/item/organ/cyberimp/leg/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)
	SetSlotFromZone()

////////////////////////////////////////////////////////////////////////////////////
//---------------------------Insertion and removal--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/organ/cyberimp/leg/Insert(mob/living/carbon/M, special, drop_if_replaced, special_zone)
	. = ..()
	if(HasBoth())
		AddEffect()
		M.add_traits(added_traits, type)
		for(var/ability in ability_paths)
			var/datum/action/check = locate(ability) in M.actions
			if(check)
				continue
			check = new ability(M)
			check.Grant(M)

/obj/item/organ/cyberimp/leg/Remove(mob/living/carbon/M, special)
	RemoveEffect()
	M.remove_traits(added_traits, type)
	for(var/ability in ability_paths)
		var/datum/action/check = locate(ability) in M.actions
		if(!check || !istype(check))
			continue
		check.Remove(M)
		qdel(check)
	return ..()

/obj/item/organ/cyberimp/leg/proc/HasBoth()
	if(owner.getorganslot(ORGAN_SLOT_RIGHT_LEG_AUG) && owner.getorganslot(ORGAN_SLOT_LEFT_LEG_AUG))
		var/obj/item/organ/cyberimp/leg/left = owner.getorganslot(ORGAN_SLOT_LEFT_LEG_AUG)
		var/obj/item/organ/cyberimp/leg/right = owner.getorganslot(ORGAN_SLOT_RIGHT_LEG_AUG)
		if(left.name == right.name)
			return TRUE
	return FALSE

/// override for special stuff
/obj/item/organ/cyberimp/leg/proc/AddEffect()
	return

/obj/item/organ/cyberimp/leg/proc/RemoveEffect()
	return

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------EMP effect-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/organ/cyberimp/leg/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	var/obj/item/bodypart/L = owner.get_bodypart(zone)
	if(!L)	//how did you get an implant in a limb you don't have?
		return

	L.receive_damage(severity / 2, 0, severity)	//always take a least a little bit of damage to the leg

	if(prob(50))	//you're forced to use two of these for them to work so let's give em a chance to not get completely fucked
		if(COOLDOWN_FINISHED(src, emp_notice))
			to_chat(owner, span_warning("The EMP causes the [src] in your [L] to twitch randomly!"))
			COOLDOWN_START(src, emp_notice, 30 SECONDS)
		return

	L.set_disabled(TRUE)	//disable the bodypart
	addtimer(CALLBACK(src, PROC_REF(reenableleg)), (severity / 2) SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

	if(severity > EMP_LIGHT && prob(5) && !syndicate_implant)	//put probabilities into a calculator before you try fucking with this
		to_chat(owner, span_warning("[src] malfunctions and thrashes your [L] around wildly, breaking it!"))
		var/datum/wound/blunt/severe/breakdown = new
		breakdown.apply_wound(L)
		L.receive_damage(20)
	else if(COOLDOWN_FINISHED(src, emp_notice))
		to_chat(owner, span_warning("[src] malfunctions and causes your muscles to seize up, preventing your [L] from moving!"))
		COOLDOWN_START(src, emp_notice, 30 SECONDS)

/obj/item/organ/cyberimp/leg/proc/reenableleg()
	var/obj/item/bodypart/L = owner.get_bodypart(zone)
	if(!L || QDELETED(L))	//You got emped and then lost the leg in those 10 seconds? impressive
		return

	L.set_disabled(FALSE)
////////////////////////////////////////////////////////////////////////////////////
//---------------------------------EMP effect-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/organ/cyberimp/leg/update_icon(updates=ALL)
	. = ..()
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
	update_appearance(UPDATE_ICON)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Specific implants---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
 * Water no-slip
 * functionally identical to galoshes
 */
/obj/item/organ/cyberimp/leg/galosh
	name = "antislip implant"
	desc = "An implant that uses sensors and motors to detect when you are slipping and attempt to prevent it. It probably won't help if the floor is too slippery."
	added_traits = list(
		TRAIT_NOSLIPWATER,
		TRAIT_NOSLIPICE
	)

/obj/item/organ/cyberimp/leg/galosh/l
	zone = BODY_ZONE_L_LEG

/**
 * full noslip
 * for antag stuff
 */
/obj/item/organ/cyberimp/leg/noslip
	name = "advanced antislip implant"
	desc = "An implant that uses advanced sensors to detect when you are slipping and utilize motors in order to prevent it."
	syndicate_implant = TRUE
	added_traits = list(
		TRAIT_NOSLIPALL
	)

/obj/item/organ/cyberimp/leg/noslip/l
	zone = BODY_ZONE_L_LEG

/**
 * Clown shoes implant, functions much like how the shoes work, but without being able to turn them off
 */
/obj/item/organ/cyberimp/leg/clownshoes
	name = "clownshoes implant"
	desc = "Advanced clown technology has allowed the implanting of bananium to allow for heightened prankage."
	var/datum/component/waddle
	var/stepcount = 0

/obj/item/organ/cyberimp/leg/clownshoes/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/clownshoes/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1), 50)

/obj/item/organ/cyberimp/leg/clownshoes/AddEffect()
	owner.add_movespeed_modifier("Clownshoesimplant", update=TRUE, priority=100, multiplicative_slowdown=1, blacklisted_movetypes=(FLYING|FLOATING))
	waddle = owner.AddComponent(/datum/component/waddling)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(SqueakyStep))

/obj/item/organ/cyberimp/leg/clownshoes/RemoveEffect()
	owner.remove_movespeed_modifier("Clownshoesimplant")
	QDEL_NULL(waddle)

/obj/item/organ/cyberimp/leg/clownshoes/proc/SqueakyStep()
	if(stepcount % 2)
		playsound(owner, pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg'), 50, 1, -1)
	stepcount ++

/**
 * Functions just like the miner's jumpboots
 */
/obj/item/organ/cyberimp/leg/jumpboots
	name = "jumpboots implant"
	desc = "An implant with a specialized propulsion system for rapid foward movement."

	added_traits = list(
		NOSLIP_ICE
		)
	ability_paths = list(
		/datum/action/cooldown/boost
		)

/obj/item/organ/cyberimp/leg/jumpboots/l
	zone = BODY_ZONE_L_LEG

/**
 * also literally used for the jumpboots themselves
 */
/datum/action/cooldown/boost
	name = "Dash"
	desc = "Dash forward."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_IMMOBILE | AB_CHECK_CONSCIOUS
	cooldown_time = 6 SECONDS
	var/jumpdistance = 5 //-1 from to see the actual distance, e.g 4 goes over 3 tiles
	var/jumpspeed = 3

/datum/action/cooldown/boost/link_to(target)
	..()
	if(target && isitem(target)) // Imitate an item_action
		var/obj/item/I = target
		LAZYINITLIST(I.actions)
		I.actions += src

/datum/action/cooldown/boost/Activate()
	var/atom/target = get_edge_target_turf(owner, owner.dir) //gets the user's direction

	if(!owner.throw_at(target, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(unstun), owner)))
		to_chat(owner, span_warning("Something prevents you from dashing forward!"))
		return

	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))

	addtimer(CALLBACK(src, PROC_REF(unstun), owner), 1 SECONDS) // in case the throw callback fails/lags for whatever reason

	playsound(owner, 'sound/effects/stealthoff.ogg', 50, TRUE, 1)
	owner.visible_message(span_warning("[owner] dashes forward into the air!"))
	StartCooldown()

/datum/action/cooldown/boost/proc/unstun(mob/living/stunned)
	REMOVE_TRAIT(stunned, TRAIT_IMMOBILIZED, REF(src))

/**
 * functions like the wicked sick wheelies
 */
/obj/item/organ/cyberimp/leg/wheelies
	name = "wheelies implant"
	desc = "Wicked sick wheelies, but now they're not in the heel of your shoes, they just in your heels."
	ability_paths = list(/datum/action/innate/wheelies)

/obj/item/organ/cyberimp/leg/wheelies/l
	zone = BODY_ZONE_L_LEG

/datum/action/innate/wheelies
	name = "Toggle Wheely-Heel's Wheels"
	desc = "Pops out or in your wheely-heel's wheels."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "wheelys"
	check_flags = AB_CHECK_HANDS_BLOCKED| AB_CHECK_IMMOBILE|AB_CHECK_CONSCIOUS|AB_CHECK_LYING

	/// Keeps track of the owner of the ability
	var/mob/living/carbon/human/holder
	/// Boolean for checking if the wheels are deployed
	var/wheelToggle = FALSE
	/// keeps track of the vehicle currently created
	var/obj/vehicle/ridden/scooter/W
	/// Type of scooter to create for this ability
	var/scooter_path = /obj/vehicle/ridden/scooter/wheelys

/datum/action/innate/wheelies/Grant(mob/user)
	. = ..()
	holder = user
	W = new scooter_path(null)

/datum/action/innate/wheelies/Remove(mob/M)
	if(wheelToggle)
		W.unbuckle_mob(holder)
		wheelToggle = FALSE
	QDEL_NULL(W)
	return ..()

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

/**
 * functions like the traitor item, airshoes, by well known "coder" Lazenn
 */
/obj/item/organ/cyberimp/leg/airshoes
	name = "advanced propulsion implant"
	desc = "An implant that uses propulsion technology to keep you above the ground and let you move faster."
	syndicate_implant = TRUE

	added_traits = list(
		TRAIT_NOSLIPICE
	)

	ability_paths = list(
		/datum/action/cooldown/boost/airshoes,
		/datum/action/innate/wheelies/airshoes
		)

/obj/item/organ/cyberimp/leg/airshoes/l
	zone = BODY_ZONE_L_LEG

/datum/action/cooldown/boost/airshoes //this makes it function like the airshoes
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "thrust"
	jumpdistance = 7
	jumpspeed = 5

/datum/action/innate/wheelies/airshoes //different scooter
	name = "Toggle thrust on air shoes."
	desc = "Switch between walking and hovering."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "airshoes_d"
	scooter_path = /obj/vehicle/ridden/scooter/airshoes

/datum/action/innate/wheelies/airshoes/Activate()
	. = ..()
	button_icon_state = wheelToggle ? "airshoes_d" : "airshoes_a"

/**
 * different scooter, should probably rewrite the wheelies one so this can just be a subtype at some point
 */
/obj/item/organ/cyberimp/leg/magboot
	name = "magboot implant"
	desc = "Integrated maglock implant, allows easy movement in a zero-gravity environment."
	ability_paths = list(/datum/action/cooldown/spell/toggle/maglock/implant)

/obj/item/organ/cyberimp/leg/magboot/l
	zone = BODY_ZONE_L_LEG
