//**************
//*****Keys*******************
//**************		**  **
/obj/item/keycard
	name = "security keycard"
	desc = "This feels like it belongs to a door."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "keycard"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 7
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	var/puzzle_id = null
	
//Skeleton key - drops from Legion megafauna, gives access to area behind Legion.
/obj/item/keycard/necropolis
	name = "skeleton key"
	desc = "Legends say it can open any lock. Luckily airlocks today don't have such locks on them."
	icon_state = "skeleton"
	puzzle_id = "legion"

//Two test keys for use alongside the two test doors.
/obj/item/keycard/cheese
	name = "cheese keycard"
	desc = "Look, I still don't understand the reference. What the heck is a keyzza?"
	color = "#f0da12"
	puzzle_id = "cheese"

/obj/item/keycard/swordfish
	name = "titanic keycard"
	desc = "Smells like it was at the bottom of a harbor."
	color = "#3bbbdb"
	puzzle_id = "swordfish"

//***************
//*****Doors*****
//***************

/obj/machinery/door/keycard
	name = "locked door"
	desc = "This door only opens when a keycard is swiped. It looks virtually indestructable."
	icon = 'icons/obj/doors/puzzledoor/default.dmi'
	icon_state = "door_closed"
	explosion_block = 3
	heat_proof = TRUE
	max_integrity = 600
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	damage_deflection = 70
	var/puzzle_id = null	//Make sure that the key has the same puzzle_id as the keycard door!
	var/open_message = "The door beeps, and slides opens."

//Standard Expressions to make keycard doors basically un-cheeseable
/obj/machinery/door/keycard/Bumped(atom/movable/AM)
	return !density && ..()

/obj/machinery/door/keycard/emp_act(severity)
	return

/obj/machinery/door/keycard/ex_act(severity, target)
	return

/obj/machinery/door/keycard/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating)
		return

/obj/machinery/door/keycard/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I,/obj/item/keycard))
		var/obj/item/keycard/key = I
		if((!puzzle_id || puzzle_id == key.puzzle_id)  && density)
			if(open_message)
				to_chat(user, span_notice("[open_message]"))
			open()
			return
		else if(puzzle_id != key.puzzle_id)
			to_chat(user, span_notice("[src] buzzes. This must not be the right key."))
			return
		else
			to_chat(user, span_notice("This door doesn't appear to close."))
			return
			
//Door behind Legion megafauna
/obj/machinery/door/keycard/necropolis
	name = "locked door"
	desc = "A strange looking door. It seems to be watching you. There is a keyhole sticking out of it."
	icon = 'icons/obj/doors/puzzledoor/necropolis.dmi'
	puzzle_id = "legion"

//Test doors. Gives admins a few doors to use quickly should they so choose.
/obj/machinery/door/keycard/cheese
	name = "blue airlock"
	desc = "Smells like... pizza?"
	puzzle_id = "cheese"

/obj/machinery/door/keycard/swordfish
	name = "blue airlock"
	desc = "If nautical nonsense be something you wish."
	puzzle_id = "swordfish"

//*************************
//***Box Pushing Puzzles***
//*************************
//We're working off a subtype of pressureplates, which should work just a BIT better now.
/obj/structure/holobox
	name = "holobox"
	desc = "A hard-light box, containing a secure decryption key."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "laserbox"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF

//Uses the pressure_plate settings for a pretty basic custom pattern that waits for a specific item to trigger. Easy enough to retool for mapping purposes or subtypes.
/obj/item/pressure_plate/hologrid
	name = "hologrid"
	desc = "A high power, electronic input port for a holobox, which can unlock the hologrid's storage compartment. Safe to stand on."
	icon = 'icons/obj/puzzle_small.dmi'
	icon_state = "lasergrid"
	anchored = TRUE
	trigger_mob = FALSE
	trigger_item = TRUE
	specific_item = /obj/structure/holobox
	removable_signaller = FALSE //Being a pressure plate subtype, this can also use signals.
	roundstart_signaller_freq = FREQ_HOLOGRID_SOLUTION //Frequency is kept on it's own default channel however.
	active = TRUE
	trigger_delay = 10
	protected = TRUE
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	var/reward = /obj/item/reagent_containers/food/snacks/cookie
	var/claimed = FALSE

/obj/item/pressure_plate/hologrid/examine(mob/user)
	. = ..()
	if(claimed)
		. += span_notice("This one appears to be spent already.")

/obj/item/pressure_plate/hologrid/trigger()
	reward = new reward(loc)
	flick("lasergrid_a",src)
	icon_state = "lasergrid_full"

/obj/item/pressure_plate/hologrid/Crossed(atom/movable/AM)
	. = ..()
	if(trigger_item && istype(AM, specific_item) && !claimed)
		claimed = TRUE
		flick("laserbox_burn", AM)
		QDEL_IN(AM, 15)
