/obj/mecha/working/ripley
	desc = "Autonomous Power Loader Unit MK-I. Designed primarily around heavy lifting, the Ripley can be outfitted with utility equipment to fill a number of roles."
	name = "\improper APLU MK-I \"Ripley\""
	icon_state = "ripley"
	silicon_icon_state = "ripley-empty"
	step_in = 2 //Move speed, lower is faster.
	max_temperature = 20000
	max_integrity = 400
	integrity_failure = 200
	deflect_chance = 15
	armor = list(MELEE = 40, BULLET = 20, LASER = 10, ENERGY = 0, BOMB = 40, BIO = 0, RAD = 20, FIRE = 100, ACID = 100, ELECTRIC = 75)
	max_equip = 6
	internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING, ACCESS_MECH_RUINS)
	var/list/cargo = new
	var/cargo_capacity = 15
	var/hides = 0
	weather_protection = NONE
	enclosed = FALSE //Normal ripley has an open cockpit design
	enter_delay = 10 //can enter in a quarter of the time of other mechs
	exit_delay = 10
	/// Custom Ripley step and turning sounds (from TGMC)
	stepsound = 'sound/mecha/powerloader_step.ogg'
	turnsound = 'sound/mecha/powerloader_turn2.ogg'
	opacity = FALSE //Ripley has a window

/obj/mecha/working/ripley/Move()
	. = ..()
	update_pressure()

/obj/mecha/working/ripley/Destroy()
	for(var/atom/movable/A in cargo)
		A.forceMove(drop_location())
		step_rand(A)
	cargo.Cut()
	return ..()

/obj/mecha/working/ripley/go_out()
	..()
	update_appearance(UPDATE_ICON)

/obj/mecha/working/ripley/moved_inside(mob/living/carbon/human/H)
	..()
	update_appearance(UPDATE_ICON)

/obj/mecha/working/ripley/update_overlays()
	. = ..()
	var/datum/component/armor_plate/C = GetComponent(/datum/component/armor_plate)
	if(!C || !C.amount)
		return
	if(C.amount < 3)
		. += (occupant ? "ripley-g" : "ripley-g-open")
	else
		. += (occupant ? "ripley-g-full" : "ripley-g-full-open")

/obj/mecha/working/ripley/check_for_internal_damage(list/possible_int_damage,ignore_threshold=null)
	if (!enclosed)
		possible_int_damage -= (MECHA_INT_TEMP_CONTROL + MECHA_INT_TANK_BREACH) //if we don't even have an air tank, these two doesn't make a ton of sense.
	. = ..()


/obj/mecha/working/ripley/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/armor_plate,3,/obj/item/stack/sheet/animalhide/goliath_hide,list(MELEE = 10, BULLET = 5, LASER = 5))

/obj/mecha/working/ripley/firefighter
	desc = "Autonomous Power Loader Unit MK-II. This model is fitted with a pressurized cabin and thermal protection."
	name = "\improper APLU MK-II \"Firefighter\""
	icon_state = "firefighter"
	max_temperature = 65000
	max_integrity = 500
	integrity_failure = 250
	fast_pressure_step_in = 1.75 //step_in while in low pressure conditions
	slow_pressure_step_in = 3 //step_in while in normal pressure conditions
	step_in = 3
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	weather_protection = WEATHER_LAVA|WEATHER_STORM
	flags_1 = HEAR_1 | RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	armor = list(MELEE = 40, BULLET = 30, LASER = 30, ENERGY = 0, BOMB = 60, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, ELECTRIC = 100)
	enclosed = TRUE
	enter_delay = 40
	silicon_icon_state = null
	opacity = TRUE

// maybe janitor ERTs could get this or something?
/obj/mecha/working/ripley/janitorial/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/washer = new /obj/item/mecha_parts/mecha_equipment/weapon/pressure_washer
	washer.attach(src)
	var/obj/item/mecha_parts/mecha_equipment/big_mop = new /obj/item/mecha_parts/mecha_equipment/melee_weapon/mop
	big_mop.attach(src)
	var/obj/item/mecha_parts/mecha_equipment/swatter = new /obj/item/mecha_parts/mecha_equipment/melee_weapon/flyswatter
	swatter.attach(src)

/obj/mecha/working/ripley/deathripley
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE"
	name = "\improper DEATH-RIPLEY"
	icon_state = "deathripley"
	fast_pressure_step_in = 2 //step_in while in low pressure conditions
	slow_pressure_step_in = 4 //step_in while in normal pressure conditions
	step_in = 4
	slow_pressure_step_in = 3
	opacity=0
	light_power = 7
	enclosed = TRUE
	enter_delay = 40
	silicon_icon_state = null
	opacity = TRUE

/obj/mecha/working/ripley/deathripley/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	ME.attach(src)

/obj/mecha/working/ripley/deathripley/real
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE. FOR REAL"
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 90, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, ELECTRIC = 75)
	fast_pressure_step_in = 1.5
	slow_pressure_step_in = 3
	step_in = 3

/obj/mecha/working/ripley/deathripley/real/Initialize(mapload)
	. = ..()
	for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
		E.detach()
		qdel(E)
	equipment.Cut()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/real
	ME.attach(src)

/obj/mecha/working/ripley/mining
	desc = "An old, dusty mining Ripley."
	name = "\improper APLU \"Miner\""

/obj/mecha/working/ripley/mining/Initialize(mapload)
	. = ..()
	update_integrity(275) //Low starting health
	if(cell)
		cell.charge = FLOOR(cell.charge * 0.25, 1) //Starts at very low charge
	if(prob(70)) //Maybe add a drill
		if(prob(15)) //Possible diamond drill... Feeling lucky?
			var/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/D = new
			D.attach(src)
		else
			var/obj/item/mecha_parts/mecha_equipment/drill/D = new
			D.attach(src)

	else //Add plasma cutter if no drill
		var/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/P = new
		P.attach(src)

	//Add ore box to cargo
	cargo.Add(new /obj/structure/ore_box(src))

	//Attach hydraulic clamp
	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/HC = new
	HC.attach(src)
	for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)//Deletes the beacon so it can't be found easily
		qdel(B)

	var/obj/item/mecha_parts/mecha_equipment/mining_scanner/scanner = new
	scanner.attach(src)

/obj/mecha/working/ripley/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/working/ripley/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(href_list["drop_from_cargo"]) in cargo
		if(O)
			occupant_message(span_notice("You unload [O]."))
			O.forceMove(drop_location())
			cargo -= O
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]", LOG_MECHA)
	return


/obj/mecha/working/ripley/contents_explosion(severity, target)
	for(var/X in cargo)
		var/obj/O = X
		if(prob(30/severity))
			cargo -= O
			O.forceMove(drop_location())
	. = ..()

/obj/mecha/working/ripley/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(cargo.len)
		for(var/obj/O in cargo)
			output += "<a href='byond://?src=[REF(src)];drop_from_cargo=[REF(O)]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/working/ripley/relay_container_resist(mob/living/user, obj/O)
	to_chat(user, span_notice("You lean on the back of [O] and start pushing so it falls out of [src]."))
	if(do_after(user, 30 SECONDS, O))
		if(!user || user.stat != CONSCIOUS || user.loc != src || O.loc != src )
			return
		to_chat(user, span_notice("You successfully pushed [O] out of [src]!"))
		O.forceMove(drop_location())
		cargo -= O
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to push [O] out of [src]!"))
