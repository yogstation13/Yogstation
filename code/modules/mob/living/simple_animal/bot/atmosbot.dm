#define ATMOSBOT_MAX_AREA_SCAN 100
#define ATMOSBOT_HOLOBARRIER_COOLDOWN 150

#define ATMOSBOT_CHECK_BREACH 0
#define ATMOSBOT_LOW_OXYGEN 1
#define ATMOSBOT_AREA_STABLE 4

#define ATMOSBOT_NOTHING 0
#define ATMOSBOT_DEPLOY_FOAM 1
#define ATMOSBOT_SPRAY_MIASMA 5

//Floorbot
/mob/living/simple_animal/bot/atmosbot
	name = "\improper Automatic Station Stabilizer Bot"
	desc = "Or the A.S.S. Bot for short."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "atmosbot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	spacewalk = TRUE

	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FLOOR_BOT
	model = "Floorbot"
	bot_core = /obj/machinery/bot_core/floorbot
	window_id = "autofloor"
	window_name = "Automatic Station Atmospherics Restabilizer v1.1"
	path_image_color = "#FFA500"

	auto_patrol = TRUE

	var/action
	var/turf/target
	//The pressure at which the bot scans for breaches
	var/breached_pressure = 20
	//Weakref of deployed barrier
	var/datum/weakref/deployed_smartmetal
	//Deployment time of last barrier
	var/last_barrier_tick
	//Gasses
	

/mob/living/simple_animal/bot/atmosbot/Initialize(mapload, new_toolbox_color)
	. = ..()
	var/datum/job/engineer/J = new/datum/job/engineer
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/atmosbot/turn_on()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/atmosbot/turn_off()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/atmosbot/set_custom_texts()
	text_hack = "You corrupt [name]'s safety protocols."
	text_dehack = "You detect errors in [name] and reset his programming."
	text_dehack_fail = "[name] is not responding to reset commands!"

/mob/living/simple_animal/bot/atmosbot/emag_act(mob/user)
	. = ..()
	if(emagged == 2)
		audible_message("<span class='danger'>[src] ominously whirs....</span>")
		playsound(src, "sparks", 75, TRUE)

/mob/living/simple_animal/bot/atmosbot/handle_automated_action()
	if(!..())
		return

	if(prob(5))
		audible_message("[src] makes an excited whirring sound!")

	action = ATMOSBOT_NOTHING
	if(!isspaceturf(get_turf(src)))
		switch(check_area_atmos())
			if(ATMOSBOT_CHECK_BREACH)
				if(last_barrier_tick + ATMOSBOT_HOLOBARRIER_COOLDOWN < world.time)
					target = return_nearest_breach()
					action = ATMOSBOT_DEPLOY_FOAM
	update_icon()

	if(!target)
		if(auto_patrol)
			if(mode == BOT_IDLE || mode == BOT_START_PATROL)
				start_patrol()

			if(mode == BOT_PATROL)
				bot_patrol()

	if(target)
		if(loc == get_turf(target))
			if(check_bot(target))
				if(prob(50))
					target = null
					path = list()
					return
			//Do foam here
			deploy_smartmetal()
			

		if(!LAZYLEN(path))
			var/turf/target_turf = get_turf(target)
			path = get_path_to(src, target_turf, /turf/proc/Distance_cardinal, 0, 30, id=access_card, simulated_only = FALSE)

			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				mode = BOT_IDLE
				return

		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return


/mob/living/simple_animal/bot/atmosbot/proc/deploy_smartmetal()
	if(emagged == 2)
		explosion(src.loc,1,2,4,flame_range = 2)
		qdel(src)
	else
		deployed_smartmetal = WEAKREF(new /obj/effect/particle_effect/fluid/foam/metal/smart(get_turf(src)))
		qdel(src)
	return

//Analyse the atmosphere to see if there is a potential breach nearby
/mob/living/simple_animal/bot/atmosbot/proc/check_area_atmos()
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/gas_mix = T.return_air()
	if(gas_mix.return_pressure() < breached_pressure)
		return ATMOSBOT_CHECK_BREACH
	//Too little oxygen or too little pressure
	var/partial_pressure = R_IDEAL_GAS_EQUATION * gas_mix.return_temperature() / gas_mix.return_volume()
	var/oxygen_moles = gas_mix.get_moles(GAS_O2) * partial_pressure
	if(oxygen_moles < 20 || gas_mix.return_pressure() < WARNING_LOW_PRESSURE)
		return ATMOSBOT_LOW_OXYGEN

//Returns the closest turf that needs a holoprojection set up
/mob/living/simple_animal/bot/atmosbot/proc/return_nearest_breach()
	var/turf/origin = get_turf(src)

	if(origin.blocks_air)
		return null

	var/room_limit = ATMOSBOT_MAX_AREA_SCAN
	var/list/checked_turfs = list()
	var/list/to_check_turfs = list(origin)
	while(room_limit > 0 && LAZYLEN(to_check_turfs))
		room_limit --
		var/turf/checking_turf = to_check_turfs[1]
		//We have checked this turf
		checked_turfs += checking_turf
		to_check_turfs -= checking_turf
		var/blocked = FALSE
		for(var/obj/structure/holosign/barrier/atmos/A in checking_turf)
			blocked = TRUE
			break
		if(blocked || !checking_turf.CanAtmosPass(checking_turf))
			continue
		//Add adjacent turfs
		for(var/direction in list(NORTH, SOUTH, EAST, WEST))
			var/turf/adjacent_turf = get_step(checking_turf, direction)
			if(adjacent_turf in checked_turfs || !adjacent_turf.CanAtmosPass(adjacent_turf) || istype(adjacent_turf.loc, /area/space))
				continue
			if(isspaceturf(adjacent_turf))
				return checking_turf
			to_check_turfs |= adjacent_turf
	return null

/mob/living/simple_animal/bot/atmosbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<tt><b>Atmospheric Stabalizer Controls v1.1</b></tt><br><br>"
	dat += "Status: <a href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</a><br>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<br>"
	if(!locked || issilicon(user) || IsAdminGhost(user))
		dat += "Breach Pressure: <a href='?src=[REF(src)];set_breach_pressure=1'>[breached_pressure]</a><br>"
		dat += "Patrol Station: <A href='?src=[REF(src)];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A><BR>"
	return dat

/mob/living/simple_animal/bot/atmosbot/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["set_breach_pressure"])
		var/new_breach_pressure = input(usr, "Pressure to scan for breaches at? (0 to 100)", "Breach Pressure") as num
		if(!isnum(new_breach_pressure) || new_breach_pressure < 0 || new_breach_pressure > 100)
			return
		breached_pressure = new_breach_pressure
	update_controls()
	update_icon()

/mob/living/simple_animal/bot/atmosbot/update_icon()
	icon_state = "atmosbot[on][on?"_[action]":""]"

/mob/living/simple_animal/bot/atmosbot/UnarmedAttack(atom/A, proximity)
	if(isturf(A) && A == get_turf(src))
		return deploy_smartmetal()
	return ..()

/mob/living/simple_animal/bot/atmosbot/explode()
	on = FALSE
	visible_message("<span class='boldannounce'>[src] blows apart!</span>")

	var/atom/Tsec = drop_location()

	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/analyzer(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)

	do_sparks(3, TRUE, src)
	..()
