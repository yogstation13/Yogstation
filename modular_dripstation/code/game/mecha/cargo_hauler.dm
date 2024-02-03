GLOBAL_DATUM(cargo_ripley, /obj/mecha/working/ripley/cargo)

/obj/mecha/working/ripley/cargo
	desc = "An ailing, old, repurposed cargo hauler. Most of its equipment wires are frayed or missing and its frame is rusted. You should handle best queen carefully."
	name = "\improper APLU \"Queen Bess II\""
	icon_state = "hauler"
	silicon_icon_state = "hauler-empty"
	icon = 'modular_dripstation/icons/mob/mecha/cargo_hauler.dmi'
	fast_pressure_step_in = 1 //step_in while in low pressure conditions, fast as fuck boi
	slow_pressure_step_in = 1.3 //step_in while in normal pressure conditions
	step_in = 1.3
	max_equip = 5 //modified exoskeleton power drive
	max_integrity = 150 //Lesser health then have normal RIPLEY mech, so it's harder to use as a weapon.
	obj_integrity = 75 //Starting at low health
	internals_req_access = list(ACCESS_CARGO, ACCESS_MECH_SCIENCE) //Giving access to cargotech & robo

/obj/mecha/working/ripley/cargo/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Mech`s power drive looks modified.</span>"

/obj/mecha/working/ripley/cargo/attack_hand(mob/living/carbon/human/user, params)
	. = ..()
	if(user.a_intent == INTENT_DISARM)
		user.say("All hail the queen!")

/obj/mecha/working/ripley/cargo/Initialize(mapload)
	. = ..()
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.33, 1) //Starts at very low charge

	//Attach hydraulic clamp ONLY
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)

	take_damage(50, sound_effect=FALSE) //Low starting health
	if(!GLOB.cargo_ripley && mapload)
		GLOB.cargo_ripley = src

/obj/mecha/working/ripley/cargo/Destroy()
	if(GLOB.cargo_ripley == src)
		GLOB.cargo_ripley = null

	return ..()

/obj/structure/mecha_wreckage/ripley/cargo
	name = "\improper APLU \"Queen Bess II\ wreckage"
	desc = "Oh no, Bessy!"
	icon_state = "hauler-broken"
	icon = 'modular_dripstation/icons/mob/mecha/cargo_hauler.dmi'
	orig_mecha = /obj/mecha/working/ripley/cargo