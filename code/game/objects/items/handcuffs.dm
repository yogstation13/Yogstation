/obj/item/restraints
	icon = 'icons/obj/handcuffs.dmi'
	breakouttime = 60 SECONDS
	var/break_strength = 2 // Minimum strength required for a holopara to break it

/obj/item/restraints/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return(OXYLOSS)

/obj/item/restraints/Destroy()
	if(iscarbon(loc))
		var/mob/living/carbon/M = loc
		if(M.handcuffed == src)
			M.set_handcuffed(null)
			M.update_handcuffed()
			if(M.buckled && M.buckled.buckle_requires_restraints)
				M.buckled.unbuckle_mob(M)
		if(M.legcuffed == src)
			M.legcuffed = null
			M.update_inv_legcuffed()
	return ..()

//Handcuffs

/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon_state = "handcuff"
	item_state = "handcuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/iron=500)
	breakouttime = 60 SECONDS // add SECONDS or another unit becuase it will think deciseconds (100ds= 10s)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	break_strength = 4
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	var/trashtype = null //for disposable cuffs

/obj/item/restraints/handcuffs/attack(mob/living/carbon/C, mob/living/user)
	if(!istype(C))
		return

	if(iscarbon(user) && (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50)))
		to_chat(user, span_warning("Uh... how do those things work?!"))
		apply_cuffs(user,user)
		return

	// chance of monkey retaliation
	if(ismonkey(C) && prob(MONKEY_CUFF_RETALIATION_PROB))
		var/mob/living/carbon/monkey/M
		M = C
		M.retaliate(user)

	if(!C.handcuffed)
		if(C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore())
			C.visible_message(span_danger("[user] is trying to put [src.name] on [C]!"), \
								span_userdanger("[user] is trying to put [src.name] on [C]!"))

			playsound(loc, cuffsound, 30, 1, -2)

			if(do_after(user, 3 SECONDS, C) && (C.get_num_arms(FALSE) >= 2 || C.get_arm_ignore()))
				if(iscyborg(user))
					apply_cuffs(C, user, TRUE)
				else
					apply_cuffs(C, user)
				to_chat(user, span_notice("You handcuff [C]."))
				SSblackbox.record_feedback("tally", "handcuffs", 1, type)

				log_combat(user, C, "handcuffed")
			else
				to_chat(user, span_warning("You fail to handcuff [C]!"))
				log_combat(user, C, "attempted to handcuff")
		else
			to_chat(user, span_warning("[C] doesn't have two hands..."))

/obj/item/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user, dispense = 0)
	if(target.handcuffed)
		return

	if(!user.temporarilyRemoveItemFromInventory(src) && !dispense)
		return

	var/obj/item/restraints/handcuffs/cuffs = src
	if(trashtype)
		cuffs = new trashtype()
	else if(dispense)
		cuffs = new type()

	cuffs.forceMove(target)
	target.set_handcuffed(cuffs)

	target.update_handcuffed()
	if(trashtype && !dispense)
		qdel(src)
	return

/obj/item/restraints/handcuffs/energy/used/swarmer //energy cuffs are in abductor, why would you do this
	breakouttime= 20 SECONDS // you already get teleported across the map
	trashtype = /obj/item/restraints/handcuffs/energy/used

/obj/item/restraints/handcuffs/cable/sinew
	name = "sinew restraints"
	desc = "A pair of restraints fashioned from long strands of flesh."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinewcuff"
	materials = null
	color = null

/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "zipties"
	item_state = "coil"
	color = CABLE_HEX_COLOR_RED
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(/datum/material/iron=150, /datum/material/glass=75)
	breakouttime = 30 SECONDS
	break_strength = 2
	cuffsound = 'sound/weapons/cablecuff.ogg'
	///for generating the correct icons based off the original cable's color.
	var/cable_color = CABLE_COLOR_RED

/obj/item/restraints/handcuffs/cable/Initialize(mapload, new_color)
	. = ..()
	if(new_color)
		set_cable_color(new_color || cable_color)

/obj/item/restraints/handcuffs/cable/proc/set_cable_color(new_color)
	color = GLOB.cable_colors[new_color]
	cable_color = new_color

/obj/item/restraints/handcuffs/cable/vv_edit_var(vname, vval)
	if(vname == NAMEOF(src, cable_color))
		set_cable_color(vval)
		datum_flags |= DF_VAR_EDITED
		return TRUE
	return ..()

/obj/item/restraints/handcuffs/cable/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/wirerod/W = new /obj/item/wirerod
			remove_item_from_storage(user)
			user.put_in_hands(W)
			to_chat(user, span_notice("You wrap [src] around the top of [I]."))
			qdel(src)
		else
			to_chat(user, span_warning("You need one rod to make a wired rod!"))
			return
	else if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(M.get_amount() < 6)
			to_chat(user, span_warning("You need at least six metal sheets to make good enough weights!"))
			return
		to_chat(user, span_notice("You begin to apply [I] to [src]..."))
		if(do_after(user, 3.5 SECONDS, src))
			if(M.get_amount() < 6 || !M)
				return
			var/obj/item/restraints/legcuffs/bola/S = new /obj/item/restraints/legcuffs/bola
			M.use(6)
			user.put_in_hands(S)
			to_chat(user, span_notice("You make some weights out of [I] and tie them to [src]."))
			remove_item_from_storage(user)
			qdel(src)
	else
		return ..()

/obj/item/restraints/handcuffs/cable/red
	cable_color = CABLE_COLOR_RED

/obj/item/restraints/handcuffs/cable/yellow
	cable_color = CABLE_COLOR_YELLOW

/obj/item/restraints/handcuffs/cable/blue
	cable_color = CABLE_COLOR_BLUE

/obj/item/restraints/handcuffs/cable/green
	cable_color = CABLE_COLOR_GREEN

/obj/item/restraints/handcuffs/cable/pink
	cable_color = CABLE_COLOR_PINK

/obj/item/restraints/handcuffs/cable/orange
	cable_color = CABLE_COLOR_ORANGE

/obj/item/restraints/handcuffs/cable/cyan
	cable_color = CABLE_COLOR_CYAN

/obj/item/restraints/handcuffs/cable/white
	cable_color = CABLE_COLOR_WHITE

/obj/item/restraints/handcuffs/cable/brown
	cable_color = CABLE_COLOR_BROWN

/obj/item/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	materials = list()
	breakouttime = 45 SECONDS
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used
	color = null
	break_strength = 3

/obj/item/restraints/handcuffs/cable/zipties/used
	desc = "A pair of broken zipties."
	icon_state = "zipties_used"

/obj/item/restraints/handcuffs/cable/zipties/used/attack()
	return

/obj/item/restraints/handcuffs/alien
	icon_state = "handcuffAlien"

/obj/item/restraints/handcuffs/fake
	name = "fake handcuffs"
	desc = "Fake handcuffs meant for gag purposes."
	breakouttime = 1 SECONDS
	break_strength = 1

//Legcuffs

/obj/item/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon_state = "handcuff"
	item_state = "legcuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	flags_1 = CONDUCT_1
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	slowdown = 7
	breakouttime = 30 SECONDS
	break_strength = 4

/obj/item/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = "A trap used to catch bears and other legged creatures."
	break_strength = 4
	var/armed = 0
	var/trap_damage = 20

/obj/item/restraints/legcuffs/beartrap/Initialize(mapload)
	. = ..()
	update_appearance()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(trap_stepped_on),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/restraints/legcuffs/beartrap/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][armed]"

/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	if(armed)
		user.visible_message(span_suicide("[user] is sticking [user.p_their()] head in the [name]! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
		return BRUTELOSS
	user.visible_message(span_suicide("[user] is sticking [user.p_their()] head in the [name] but the [name] is disarmed!"))
	return SHAME

/obj/item/restraints/legcuffs/beartrap/attack_self(mob/user)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		update_appearance(UPDATE_ICON)
		to_chat(user, span_notice("[src] is now [armed ? "armed" : "disarmed"]."))

/obj/item/restraints/legcuffs/beartrap/wrench_act(mob/living/user, obj/item/wrench/W)
	if(armed && !anchored)
		if(do_after(user, 1 SECONDS, src)) // Take the time to wrench it this trap to be more effective.
			anchored = TRUE
			playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
		return
	..()

/obj/item/restraints/legcuffs/beartrap/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(armed && anchored && do_after(user, 1 SECONDS, src)) // And take the time to disarm this anchored trap.
		close_trap()

/obj/item/restraints/legcuffs/beartrap/proc/close_trap()
	armed = FALSE
	anchored = FALSE
	update_appearance(UPDATE_ICON)
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)

/obj/item/restraints/legcuffs/beartrap/proc/trap_stepped_on(datum/source, atom/movable/entering, ...)
	SIGNAL_HANDLER

	spring_trap(entering)

/**
 * Tries to spring the trap on the target movable.
 *
 * This proc is safe to call without knowing if the target is valid or if the trap is armed.
 *
 * Does not trigger on tiny mobs.
 * If ignore_movetypes is FALSE, does not trigger on floating / flying / etc. mobs.
 */
/obj/item/restraints/legcuffs/beartrap/proc/spring_trap(atom/movable/target, ignore_movetypes = FALSE)
	if(!armed || !isturf(loc) || !isliving(target))
		return

	var/mob/living/victim = target
	if(istype(victim.buckled, /obj/vehicle))
		var/obj/vehicle/ridden_vehicle = victim.buckled
		if(!ridden_vehicle.are_legs_exposed) //close the trap without injuring/trapping the rider if their legs are inside the vehicle at all times.
			close_trap()
			ridden_vehicle.visible_message(span_danger("[ridden_vehicle] triggers \the [src]."))
			return

	//don't close the trap if they're as small as a mouse
	if(victim.mob_size <= MOB_SIZE_TINY)
		return
	if(!ignore_movetypes && (victim.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	close_trap()
	if(ignore_movetypes)
		victim.visible_message(span_danger("\The [src] ensnares [victim]!"), \
				span_userdanger("\The [src] ensnares you!"))
	else
		victim.visible_message(span_danger("[victim] triggers \the [src]."), \
				span_userdanger("You trigger \the [src]!"))
	var/def_zone = BODY_ZONE_CHEST
	if(iscarbon(victim) && victim.body_position == STANDING_UP)
		var/mob/living/carbon/carbon_victim = victim
		def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		if(!carbon_victim.legcuffed && carbon_victim.num_legs >= 2) //beartrap can't cuff your leg if there's already a beartrap or legcuffs, or you don't have two legs.
			INVOKE_ASYNC(carbon_victim, TYPE_PROC_REF(/mob/living/carbon, equip_to_slot), src, ITEM_SLOT_LEGCUFFED)
			SSblackbox.record_feedback("tally", "handcuffs", 1, type)

	victim.apply_damage(trap_damage, BRUTE, def_zone)


/obj/item/restraints/legcuffs/beartrap/Crossed(AM as mob|obj)
	if(armed && isturf(loc))
		if(isliving(AM))
			var/mob/living/L = AM
			var/snap = TRUE
			if(istype(L.buckled, /obj/vehicle))
				var/obj/vehicle/ridden_vehicle = L.buckled
				if(!ridden_vehicle.are_legs_exposed) //close the trap without injuring/trapping the rider if their legs are inside the vehicle at all times.
					close_trap()
					ridden_vehicle.visible_message(span_danger("[ridden_vehicle] triggers \the [src]."))
					return ..()

			if(L.movement_type & (FLYING|FLOATING)) //don't close the trap if they're flying/floating over it.
				snap = FALSE

			var/def_zone = BODY_ZONE_CHEST
			if(snap && iscarbon(L))
				var/mob/living/carbon/C = L
				if(C.mobility_flags & MOBILITY_STAND)
					def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
					if(!C.legcuffed && C.get_num_legs(FALSE) >= 2) //beartrap can't cuff your leg if there's already a beartrap or legcuffs, or you don't have two legs.
						C.legcuffed = src
						forceMove(C)
						C.update_inv_legcuffed()
						SSblackbox.record_feedback("tally", "handcuffs", 1, type)
			else if(snap && isanimal(L))
				var/mob/living/simple_animal/SA = L
				if(SA.mob_size <= MOB_SIZE_TINY) //don't close the trap if they're as small as a mouse.
					snap = FALSE
			if(snap)
				close_trap()
				L.visible_message(span_danger("[L] triggers \the [src]."), \
						span_userdanger("You trigger \the [src]!"))
				L.apply_damage(trap_damage, BRUTE, def_zone)
	..()

/obj/item/restraints/legcuffs/beartrap/energy
	name = "energy snare"
	armed = 1
	icon_state = "e_snare"
	trap_damage = 0
	breakouttime = 3 SECONDS
	item_flags = DROPDEL
	flags_1 = NONE
	break_strength = 2 

/obj/item/restraints/legcuffs/beartrap/energy/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(dissipate)), 100)

/obj/item/restraints/legcuffs/beartrap/energy/proc/dissipate()
	if(!ismob(loc))
		do_sparks(1, TRUE, src)
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/energy/attack_hand(mob/user)
	Crossed(user) //honk

/obj/item/restraints/legcuffs/beartrap/energy/cyborg
	breakouttime = 2 SECONDS // Cyborgs shouldn't have a strong restraint

/obj/item/restraints/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	icon_state = "bola"
	icon_state_preview = "bola_preview"
	item_state = "bola"
	lefthand_file = 'icons/mob/inhands/weapons/thrown_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/thrown_righthand.dmi'
	breakouttime = 3.5 SECONDS //easy to apply, easy to break out of
	gender = NEUTER
	break_strength = 3 
	var/immobilize = 0

/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, quickstart = TRUE)
	if(!..())
		return
	playsound(src.loc,'sound/weapons/bolathrow.ogg', 75, 1)

/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..())//if it gets caught or the target can't be cuffed,
		return//abort
	if(iscarbon(hit_atom))
		return impactCarbon(hit_atom, throwingdatum)
	if(isanimal(hit_atom))
		return impactAnimal(hit_atom, throwingdatum)

/obj/item/restraints/legcuffs/bola/proc/impactCarbon(mob/living/carbon/hit_carbon, datum/thrownthing/throwingdatum)
	if(hit_carbon.legcuffed || !hit_carbon.get_num_legs(FALSE) >= 2)
		return
	visible_message(span_danger("\The [src] ensnares [hit_carbon]!"))
	hit_carbon.legcuffed = src
	forceMove(hit_carbon)
	hit_carbon.update_inv_legcuffed()
	SSblackbox.record_feedback("tally", "handcuffs", 1, type)
	to_chat(hit_carbon, span_userdanger("\The [src] ensnares you!"))
	hit_carbon.Immobilize(immobilize)
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)

/obj/item/restraints/legcuffs/bola/proc/impactAnimal(mob/living/simple_animal/hit_animal, datum/thrownthing/throwingdatum)
	return // Does nothing by default

/obj/item/restraints/legcuffs/bola/tactical//traitor variant
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	item_state = "bola_r"
	breakouttime = 7 SECONDS
	immobilize = 20
	break_strength = 4 

/obj/item/restraints/legcuffs/bola/watcher //tribal bola for tribal lizards
	name = "watcher Bola"
	desc = "A Bola made from the stretchy sinew of fallen watchers."
	icon_state = "bola_watcher"
	icon_state_preview = "bola_watcher_preview"
	item_state = "bola_watcher"
	breakouttime = 4.5 SECONDS

/obj/item/restraints/legcuffs/bola/energy //For Security
	name = "energy bola"
	desc = "A specialized hard-light bola designed to ensnare fleeing criminals and aid in arrests."
	icon_state = "ebola"
	item_state = "ebola"
	hitsound = 'sound/weapons/taserhit.ogg'
	w_class = WEIGHT_CLASS_SMALL
	breakouttime = 6 SECONDS
	break_strength = 2

/obj/item/restraints/legcuffs/bola/energy/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(iscarbon(hit_atom))
		var/obj/item/restraints/legcuffs/beartrap/B = new /obj/item/restraints/legcuffs/beartrap/energy/cyborg(get_turf(hit_atom))
		B.Crossed(hit_atom)
		qdel(src)
	..()

/obj/item/restraints/legcuffs/bola/gonbola
	name = "gonbola"
	desc = "Hey, if you have to be hugged in the legs by anything, it might as well be this little guy."
	icon_state = "gonbola"
	icon_state_preview = "gonbola_preview"
	item_state = "bola_r"
	breakouttime = 30 SECONDS
	slowdown = 0
	var/datum/status_effect/gonbolaPacify/effectReference

/obj/item/restraints/legcuffs/bola/gonbola/impactCarbon(mob/living/carbon/hit_carbon, datum/thrownthing/throwingdatum)
	. = ..()
	effectReference = hit_carbon.apply_status_effect(STATUS_EFFECT_GONBOLAPACIFY)

/obj/item/restraints/legcuffs/bola/gonbola/dropped(mob/user)
	. = ..()
	if(effectReference)
		QDEL_NULL(effectReference)
