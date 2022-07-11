/**********************Mining drone**********************/
#define MINEDRONE_COLLECT 1
#define MINEDRONE_ATTACK 2

#define MINEDRONE_KA 0
#define MINEDRONE_CUTTER 1

/mob/living/simple_animal/hostile/mining_drone
	name = "minebot"
	desc = "The instructions printed on the side read: This is a small robot used to support miners, can be set to search and collect loose ore, or to help fend off wildlife."
	gender = NEUTER
	icon = 'icons/mob/aibots.dmi'
	icon_state = "mining_drone"
	icon_living = "mining_drone"
	status_flags = CANSTUN|CANKNOCKDOWN|CANPUSH
	mouse_opacity = MOUSE_OPACITY_ICON
	weather_immunities = list("ash")
	faction = list("neutral")
	a_intent = INTENT_HARM
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	move_to_delay = 10
	health = 125
	maxHealth = 125
	melee_damage_lower = 15
	melee_damage_upper = 15
	obj_damage = 10
	environment_smash = ENVIRONMENT_SMASH_NONE
	check_friendly_fire = TRUE
	stop_automated_movement_when_pulled = TRUE
	attacktext = "drills"
	attack_sound = 'sound/weapons/circsawhit.ogg'
	sentience_type = SENTIENCE_MINEBOT
	speak_emote = list("states")
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/plasma, /obj/item/stack/ore/uranium, /obj/item/stack/ore/iron,
						  /obj/item/stack/ore/bananium, /obj/item/stack/ore/titanium)
	healable = 0
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	del_on_death = TRUE
	var/mode = MINEDRONE_COLLECT
	var/light_on = 0
	var/maintance_hatch_open = FALSE
	var/fireMode = MINEDRONE_KA

	var/obj/item/gun/energy/kinetic_accelerator/stored_gun
	var/obj/item/gun/energy/plasmacutter/cutter
	var/obj/item/t_scanner/adv_mining_scanner/scanner
	var/obj/item/reagent_containers/hypospray/medipen/pen 
	var/obj/item/wormhole_jaunter/jaunter
	var/obj/item/bikehorn/honk

	var/datum/action/innate/minedrone/toggle_light/toggle_light_action
	var/datum/action/innate/minedrone/toggle_meson_vision/toggle_meson_vision_action
	var/datum/action/innate/minedrone/toggle_mode/toggle_mode_action
	var/datum/action/innate/minedrone/dump_ore/dump_ore_action

	var/weapon_verb = /mob/living/simple_animal/hostile/mining_drone/proc/cycle_weapon
	var/reload_verb = /mob/living/simple_animal/hostile/mining_drone/proc/reload_pk
	var/jaunter_verb = /mob/living/simple_animal/hostile/mining_drone/proc/use_jaunter
	var/gps_verb = /mob/living/simple_animal/hostile/mining_drone/proc/toggle_gps

	var/obj/item/gps/internal/gpsy = 

/obj/item/gps/internal/mining_bot
	gpstag = "Mining Bot"
	desc = "It is a mining bot."

/mob/living/simple_animal/hostile/mining_drone/Initialize()
	. = ..()
	///Granting actions
	toggle_light_action = new()
	toggle_light_action.Grant(src)
	toggle_meson_vision_action = new()
	toggle_meson_vision_action.Grant(src)
	toggle_mode_action = new()
	toggle_mode_action.Grant(src)
	dump_ore_action = new()
	dump_ore_action.Grant(src)

	add_verb(src, weapon_verb)
	add_verb(src, reload_verb)
	add_verb(src, jaunter_verb)
	add_verb(src, gps_verb)

	///Equiping
	var/obj/item/gun/energy/kinetic_accelerator/newgun = new(src)
	equip_gun(newgun)

	var/obj/item/implant/radio/mining/imp = new(src)
	imp.implant(src)

	access_card = new /obj/item/card/id(src)
	var/datum/job/mining/M = new
	access_card.access = M.get_access()

	SetCollectBehavior()

/mob/living/simple_animal/hostile/mining_drone/Destroy()
	for (var/datum/action/innate/minedrone/action in actions)
		qdel(action)
	if(istype(stored_gun, /obj/item/gun/energy/kinetic_accelerator/mega))
		unequip_gun()
	if(cutter)
		cutter.forceMove(get_turf(src))
	if(scanner)
		scanner.forceMove(get_turf(src))
	if(pen)
		pen.forceMove(get_turf(src))
	if(jaunter)
		jaunter.forceMove(get_turf(src))
	if(honk)
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
		honk.forceMove(get_turf(src))
	remove_verb(src, weapon_verb)
	remove_verb(src, reload_verb)
	remove_verb(src, jaunter_verb)
	remove_verb(src, gps_verb)
	return ..()

/mob/living/simple_animal/hostile/mining_drone/sentience_act()
	..()
	check_friendly_fire = 0

/mob/living/simple_animal/hostile/mining_drone/examine(mob/user)
	. = ..()
	var/t_He = p_they(TRUE)
	var/t_him = p_them()
	var/t_s = p_s()
	if(health < maxHealth)
		if(health >= maxHealth * 0.5)
			. += span_warning("[t_He] look[t_s] slightly dented.")
		else
			. += span_boldwarning("[t_He] look[t_s] severely dented!")
	. += {"<span class='notice'>Alt+clicking on [t_him] will instruct [t_him] to drop stored ore. <b>[max(0, LAZYLEN(contents) - 1)] Stored Ore</b>\n
	Field repairs can be done with a welder."}
	if(stored_gun && stored_gun.max_mod_capacity)
		. += "<b>[stored_gun.get_remaining_mod_capacity()]%</b> mod capacity remaining."
		for(var/A in stored_gun.get_modkits())
			var/obj/item/borg/upgrade/modkit/M = A
			. += span_notice("There is \a [M] installed, using <b>[M.cost]%</b> capacity.")

/mob/living/simple_animal/hostile/mining_drone/welder_act(mob/living/user, obj/item/I)
	. = TRUE
	if(mode == MINEDRONE_ATTACK)
		to_chat(user, span_info("[src] can't be repaired while in attack mode!"))
		return

	if(maxHealth == health)
		to_chat(user, span_info("[src] is at full integrity."))
		return

	if(I.use_tool(src, user, 0, volume=40))
		adjustBruteLoss(-15)
		to_chat(user, span_info("You repair some of the armor on [src]."))

/mob/living/simple_animal/hostile/mining_drone/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	maintance_hatch_open = -maintance_hatch_open
	if(maintance_hatch_open)
		to_chat(user, span_info("You open [src]'s maintance hatch."))
	else
		to_chat(user, span_info("You close [src]'s maintance hatch."))

/mob/living/simple_animal/hostile/mining_drone/multitool_act(mob/living/user)
	if(stat == DEAD && maintance_hatch_open)
		if(health >= maxHealth/2)
			to_chat(user, span_info("You pulse [src]'s wires, reactivating it!."))
			revive()
		else
			to_chat(user, span_info("You pulse [src]'s wires, but nothing happens!."))

/mob/living/simple_animal/hostile/mining_drone/attackby(obj/item/I, mob/user, params)
	if(maintance_hatch_open)
		if(I.tool_behaviour == TOOL_CROWBAR || istype(I, /obj/item/borg/upgrade/modkit))
			I.melee_attack_chain(user, stored_gun, params)
			scanner.forceMove(get_turf(src))
			cutter.forceMove(get_turf(src))
			return
		else if(istype(I, /obj/item/stack/cable_coil) && health < maxHealth)
			to_chat(user, span_notice("You begin replacing broken wires on [src]..."))
			repair_burn(I, user)	
			return	
		else if(istype(I, /obj/item/gun/energy/plasmacutter))
			if(cutter)
				to_chat(user, span_notice("You replace [src]'s plasmacutter with [I]..."))
				cutter.forceMove(get_turf(user))
				cutter = null
			else
				to_chat(user, span_notice("You insert [I] into the plasma cutter mount on the [src]..."))
			I.forceMove(src)
			cutter = I
			return
		else if(istype(I, /obj/item/stack/ore/plasma) && cutter)
			cutter.attackby(I)
			if(cutter.cell.charge == cutter.cell.maxcharge) 
				I.forceMove(src)
			return		
		else if(istype(I, /obj/item/gun/energy/kinetic_accelerator/mega))
			equip_gun(I)
			return
		else if(istype(I, /obj/item/reagent_containers/hypospray/medipen))
			if(pen)
				to_chat(user, span_notice("You replace [src]'s medipen with a new one."))
				to_chat(src, span_notice("[user] replaces your current medipen with a new one."))
				pen.forceMove(get_turf(src))
			else
				to_chat(user, span_notice("You insert a medipen into [src]."))
				to_chat(src, span_notice("[user] inserts a new medipen into you."))
			I.forceMove(src)
			pen = I
			return
		else if(istype(I, /obj/item/wormhole_jaunter))
			if(jaunter)
				to_chat(user, span_warning("[src] already has a jaunter!"))
				return
			to_chat(user, span_notice("You install a jaunter into [src]!"))
			I.forceMove(src)
			jaunter = I
			return
		else if(istype(I, /obj/item/bikehorn))
			if(honk)   /// HONK HONK HONK HONK HONK XDXDXDXD 
				to_chat(user, span_warning("[src] already has a bike horn!"))
				return
			to_chat(user, span_notice("You install a bike horn into [src]!"))
			I.forceMove(src)
			honk = I
			playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
			return
	..()
	if(honk)
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)

/mob/living/simple_animal/hostile/mining_drone/death()
	DropOre(0)
	if(stored_gun)
		for(var/obj/item/borg/upgrade/modkit/M in stored_gun.modkits)
			M.uninstall(stored_gun)
		if(istype(stored_gun, /obj/item/gun/energy/kinetic_accelerator/mega))
			unequip_gun()
	if(cutter)
		cutter.forceMove(get_turf(src))
	if(scanner)
		scanner.forceMove(get_turf(src))
	if(honk)
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
		honk.forceMove(get_turf(src))
	deathmessage = "blows apart!"
	..()

/mob/living/simple_animal/hostile/mining_drone/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(.)
		return
	if(M.a_intent == INTENT_HELP)
		if(client) 
			to_chat(M, span_info("[src] is currently controlled by an onboard AI. There is no need to touch it's controlls."))
			return ..()
		toggle_mode()
		switch(mode)
			if(MINEDRONE_COLLECT)
				to_chat(M, span_info("[src] has been set to search and store loose ore."))
			if(MINEDRONE_ATTACK)
				to_chat(M, span_info("[src] has been set to attack hostile wildlife."))
		return

/// Handles dropping ore
/mob/living/simple_animal/hostile/mining_drone/AltClick(mob/user)
	. = ..()
	to_chat(user, "<span class='info'>You order [src] to drop any collected ore.</span>")
	DropOre()

/// Handles activating installed minebot mods
/mob/living/simple_animal/hostile/mining_drone/AltClickOn(atom/target)
	. = ..()
	if(istype(target, /mob/living/carbon) && pen)
		pen.attack(target, src)

/mob/living/simple_animal/hostile/mining_drone/CanAllowThrough(atom/movable/O)
	. = ..()
	if(istype(O, /obj/item/projectile/kinetic))
		var/obj/item/projectile/kinetic/K = O
		if(K.kinetic_gun)
			for(var/A in K.kinetic_gun.get_modkits())
				var/obj/item/borg/upgrade/modkit/M = A
				if(istype(M, /obj/item/borg/upgrade/modkit/minebot_passthrough))
					return TRUE
	if(istype(O, /obj/item/projectile/destabilizer))
		return TRUE

/mob/living/simple_animal/hostile/mining_drone/proc/SetCollectBehavior()
	mode = MINEDRONE_COLLECT
	vision_range = 9
	search_objects = 2
	wander = TRUE
	ranged = FALSE
	minimum_distance = 1
	retreat_distance = null
	icon_state = "mining_drone"
	to_chat(src, span_info("You are set to collect mode. You can now collect loose ore."))

/mob/living/simple_animal/hostile/mining_drone/proc/SetOffenseBehavior()
	mode = MINEDRONE_ATTACK
	vision_range = 7
	search_objects = 0
	wander = FALSE
	ranged = TRUE
	retreat_distance = 2
	minimum_distance = 1
	icon_state = "mining_drone_offense"
	to_chat(src, span_info("You are set to attack mode. You can now attack from range."))

/mob/living/simple_animal/hostile/mining_drone/AttackingTarget()
	if(istype(target, /obj/item/stack/ore) && mode == MINEDRONE_COLLECT)
		CollectOre()
		return
	if(isliving(target))
		SetOffenseBehavior()
	return ..()

/mob/living/simple_animal/hostile/mining_drone/OpenFire(atom/A)
	if(CheckFriendlyFire(A))
		return
	if(honk)
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	switch(fireMode)
		if(MINEDRONE_KA)
			stored_gun.afterattack(A, src) //of the possible options to allow minebots to have KA mods, would you believe this is the best?
		if(MINEDRONE_CUTTER)
			if(cutter && cutter.can_shoot())
				cutter.afterattack(A, src)
			else
				stored_gun.afterattack(A, src)

/mob/living/simple_animal/hostile/mining_drone/proc/CollectOre()
	for(var/obj/item/stack/ore/O in range(1, src))
		O.forceMove(src)

/mob/living/simple_animal/hostile/mining_drone/proc/DropOre(message = 1)
	if(!contents.len)
		if(message)
			to_chat(src, span_notice("You attempt to dump your stored ore, but you have none."))
		return
	if(message)
		to_chat(src, span_notice("You dump your stored ore."))
	for(var/obj/item/stack/ore/O in contents)
		O.forceMove(drop_location())

/mob/living/simple_animal/hostile/mining_drone/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(mode != MINEDRONE_ATTACK && amount > 0)
		SetOffenseBehavior()
	. = ..()

/datum/action/innate/minedrone/toggle_meson_vision
	name = "Toggle Meson Vision"
	button_icon_state = "meson"

/datum/action/innate/minedrone/toggle_meson_vision/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	if(user.sight & SEE_TURFS)
		user.sight &= ~SEE_TURFS
		user.lighting_alpha = initial(user.lighting_alpha)
	else
		user.sight |= SEE_TURFS
		user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	user.sync_lighting_plane_alpha()

	to_chat(user, span_notice("You toggle your meson vision [(user.sight & SEE_TURFS) ? "on" : "off"]."))


/mob/living/simple_animal/hostile/mining_drone/proc/toggle_mode()
	switch(mode)
		if(MINEDRONE_ATTACK)
			SetCollectBehavior()
		else
			SetOffenseBehavior()

/mob/living/simple_animal/hostile/mining_drone/proc/equip_gun(obj/item/gun/energy/kinetic_accelerator/new_gun)
	if(stored_gun)
		unequip_gun()
	new_gun.trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	new_gun.overheat_time = 20
	new_gun.holds_charge = TRUE
	new_gun.unique_frequency = TRUE
	stored_gun = new_gun

/mob/living/simple_animal/hostile/mining_drone/proc/unequip_gun()
	stored_gun.trigger_guard = initial(stored_gun.trigger_guard)
	stored_gun.overheat_time = initial(stored_gun.overheat_time)
	stored_gun.holds_charge = initial(stored_gun.holds_charge)
	stored_gun.unique_frequency = initial(stored_gun.unique_frequency)
	stored_gun.forceMove(get_turf(src))
	stored_gun = null

/mob/living/simple_animal/hostile/mining_drone/proc/repair_burn(var/obj/item/stack/cable_coil/CC, var/mob/user)
	if(!maintance_hatch_open)
		return
	if(health >= maxHealth)
		return
	if(!do_mob(user, src, 1 SECONDS))
		return
	if(CC.use(1))
		to_chat(user, span_notice("You replace some broken wires on [src]..."))
		to_chat(src, span_notice("[user] replaces some broken wires on you..."))
		adjustFireLoss(-15)
		repair_burn(CC, user)

//Actions for sentient minebots

/datum/action/innate/minedrone
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	background_icon_state = "bg_default"

/datum/action/innate/minedrone/toggle_light
	name = "Toggle Light"
	button_icon_state = "mech_lights_off"

/datum/action/innate/minedrone/toggle_light/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner

	if(user.light_on)
		user.set_light(0)
	else
		user.set_light(6)
	user.light_on = !user.light_on
	to_chat(user, span_notice("You toggle your light [user.light_on ? "on" : "off"]."))

/datum/action/innate/minedrone/toggle_mode
	name = "Toggle Mode"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/minedrone/toggle_mode/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.toggle_mode()

/datum/action/innate/minedrone/dump_ore
	name = "Dump Ore"
	button_icon_state = "mech_eject"

/datum/action/innate/minedrone/dump_ore/Activate()
	var/mob/living/simple_animal/hostile/mining_drone/user = owner
	user.DropOre()

/mob/living/simple_animal/hostile/mining_drone/proc/cycle_weapon()
	set name = "Cycle Weapon"
	set desc = "Switch between a plasma cutter or a KA."
	set category = "Mining Bot"

	if(!cutter)
		to_chat(usr, span_warning("You don't have a plasma cutter to switch to!"))
	
	if(fireMode == MINEDRONE_KA)
		fireMode = MINEDRONE_CUTTER
	else 
		fireMode = MINEDRONE_KA

	switch(fireMode)
		if(MINEDRONE_KA)
			to_chat(usr, span_notice("You will now shoot a kinetic accelerator"))
		if(MINEDRONE_CUTTER)
			to_chat(usr, span_notice("You will now shoot a plasma cutter"))

/mob/living/simple_animal/hostile/mining_drone/proc/reload_pk()
	set name = "PK Reload"
	set desc = "Reloads your plasmacutter(if you have one) with plasma stucks from your contents. "
	set category = "Mining Bot"

	if(!cutter)
		to_chat(usr, span_warning("You don't have a plasma cutter to reload!"))
		return

	if(cutter.cell.charge == cutter.cell.maxcharge) 
		to_chat(usr, span_warning("You don't need to recharge your plasma cutter!"))
		return

	var/yes = FALSE //No
	for(var/atom/movable/AM in src)
		if(istype(AM, /obj/item/stack/ore/plasma) && cutter)
			var/obj/item/stack/ore/plasma/ammo = AM
			cutter.attackby(ammo)
			yes = TRUE //Yes
			if(cutter.cell.charge == cutter.cell.maxcharge) 
				break
	if(yes)
		to_chat(usr, span_info("You recharge your plasma cutter!"))
	else
		to_chat(usr, span_info("You don't have any plasma to recharge your plasma cutter with."))

/mob/living/simple_animal/hostile/mining_drone/proc/use_jaunter()
	set name = "Activate Wormhole Jaunter"
	set desc = "Activates your wormhole jaunter, if you have one. "
	set category = "Mining Bot"

	if(!jaunter)
		to_chat(usr, span_warning("You don't have a jaunter to activate!"))
		return

	jaunter.attack_self(usr)

/mob/living/simple_animal/hostile/mining_drone/proc/toggle_gps()
	set name = "Toggle GPS"
	set desc = "Makes you emmit a GPS signal, or stop emmitting it if you already are doing that. "
	set category = "Mining Bot"

	if(!gpsy)
		var/obj/item/gps/internal/mining_bot/new_gps = new(src)
		new_gps.name = usr.name
		to_chat(usr, span_notice("You now emmit a GPS signal."))
	else
		qdel(gpsy)
		to_chat(usr, span_notice("You no more emmit a GPS signal."))

/**********************Minebot Upgrades**********************/

//Melee

/obj/item/mine_bot_upgrade
	name = "minebot melee upgrade"
	desc = "A minebot upgrade."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'

/obj/item/mine_bot_upgrade/afterattack(mob/living/simple_animal/hostile/mining_drone/M, mob/user, proximity)
	. = ..()
	if(!istype(M) || !proximity)
		return
	upgrade_bot(M, user)

/obj/item/mine_bot_upgrade/proc/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.melee_damage_upper != initial(M.melee_damage_upper))
		to_chat(user, "[src] already has a combat upgrade installed!")
		return
	M.melee_damage_lower += 7
	M.melee_damage_upper += 7
	qdel(src)

//Health

/obj/item/mine_bot_upgrade/health
	name = "minebot armor upgrade"

/obj/item/mine_bot_upgrade/health/upgrade_bot(mob/living/simple_animal/hostile/mining_drone/M, mob/user)
	if(M.maxHealth != initial(M.maxHealth))
		to_chat(user, "[src] already has reinforced armor!")
		return
	M.maxHealth += 45
	M.updatehealth()
	qdel(src)

//AI

/obj/item/slimepotion/slime/sentience/mining
	name = "minebot AI upgrade"
	desc = "Can be used to grant sentience to minebots. It's incompatible with minebot armor and melee upgrades, and will override them."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	sentience_type = SENTIENCE_MINEBOT
	var/base_health_add = 5 //sentient minebots are penalized for beign sentient; they have their stats reset to normal plus these values
	var/base_damage_add = 1 //this thus disables other minebot upgrades
	var/base_speed_add = 1
	var/base_cooldown_add = 10 //base cooldown isn't reset to normal, it's just added on, since it's not practical to disable the cooldown module

/obj/item/slimepotion/slime/sentience/mining/after_success(mob/living/user, mob/living/simple_animal/SM)
	if(istype(SM, /mob/living/simple_animal/hostile/mining_drone))
		var/mob/living/simple_animal/hostile/mining_drone/M = SM
		M.maxHealth = initial(M.maxHealth) + base_health_add
		M.melee_damage_lower = initial(M.melee_damage_lower) + base_damage_add
		M.melee_damage_upper = initial(M.melee_damage_upper) + base_damage_add
		M.move_to_delay = initial(M.move_to_delay) + base_speed_add
		if(M.stored_gun)
			M.stored_gun.overheat_time += base_cooldown_add

#undef MINEDRONE_COLLECT
#undef MINEDRONE_ATTACK
