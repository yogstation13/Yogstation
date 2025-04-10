/obj/item/mecha_parts/mecha_equipment/weapon
	name = "mecha weapon"
	range = MECHA_RANGED
	destroy_sound = 'sound/mecha/weapdestr.ogg'
	/// Typepath of the projectile
	var/projectile
	/// Firing Sound
	var/fire_sound
	/// How many projectiles does it shoot
	var/projectiles_per_shot = 1
	/// Amount of preditable spread in the shot
	var/variance = 0
	/// Amount of unpredictable spread in the shot
	var/randomspread = 0
	/// Firing delay
	var/projectile_delay = 0
	/// Visual effect when fired
	var/firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect
	/// Will this push the mech back when used in no gravity
	var/kickback = TRUE
	mech_flags = EXOSUIT_MODULE_COMBAT

/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(obj/mecha/M)
	if(!..())
		return FALSE
	if((locate(/obj/item/mecha_parts/concealed_weapon_bay) in M.contents) && !((locate(/obj/item/mecha_parts/mecha_equipment/melee_weapon) in M.equipment) || (locate(/obj/item/mecha_parts/mecha_equipment/weapon) in M.equipment) ))
		return TRUE
	if(M.guns_allowed)
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/proc/get_shot_amount()
	return projectiles_per_shot

/obj/item/mecha_parts/mecha_equipment/weapon/action(atom/target, mob/living/user, params)
	var/turf/curloc = get_turf(chassis)
	var/turf/targloc = get_turf(target)
	if (!targloc || !istype(targloc) || !curloc)
		return 0
	if (targloc == curloc)
		return 0

	set_ready_state(0)
	for(var/i=1 to get_shot_amount())
		var/obj/projectile/A = new projectile(curloc)
		A.firer = chassis.occupant
		A.original = target
		if(!A.suppressed && firing_effect_type)
			new firing_effect_type(get_turf(src), chassis.dir)

		var/spread = 0
		if(variance)
			if(randomspread)
				spread = round((rand() - 0.5) * variance)
			else
				spread = round((i / projectiles_per_shot - 0.5) * variance)
		A.preparePixelProjectile(target, chassis.occupant, params, spread)

		A.fire()
		playsound(chassis, fire_sound, 50, 1)

		sleep(max(0, projectile_delay))

	if(kickback)
		chassis.newtonian_move(get_dir(target, chassis))
	chassis.log_message("Fired from [src.name], targeting [target].", LOG_MECHA)
	return 1


//Base energy weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/energy
	name = "general energy weapon"
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/item/mecha_parts/mecha_equipment/weapon/energy/get_shot_amount()
	return min(round(chassis.cell.charge / energy_drain), round((OVERHEAT_MAXIMUM - chassis.overheat) / heat_cost), projectiles_per_shot)

/obj/item/mecha_parts/mecha_equipment/weapon/energy/start_cooldown()
	set_ready_state(0)
	var/shot_amount = get_shot_amount()
	chassis.use_power(energy_drain * shot_amount)
	chassis.adjust_overheat(heat_cost * shot_amount)
	addtimer(CALLBACK(src, PROC_REF(set_ready_state), 1), equip_cooldown)

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser
	equip_cooldown = 5
	name = "\improper CH-PS \"Immolator\" laser"
	desc = "A weapon for combat exosuits. Shoots basic lasers."
	icon_state = "mecha_laser"
	energy_drain = 3
	heat_cost = 5
	projectile = /obj/projectile/beam/laser
	fire_sound = 'sound/weapons/laser.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler
	equip_cooldown = 8
	name = "\improper CH-DS \"Peacemaker\" disabler"
	desc = "A weapon for combat exosuits. Shoots basic disablers."
	icon_state = "mecha_disabler"
	energy_drain = 3
	heat_cost = 2
	projectile = /obj/projectile/beam/disabler
	fire_sound = 'sound/weapons/taser2.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/disabler/action_checks(atom/target)
	. = ..()
	if(. && HAS_TRAIT(chassis.occupant, TRAIT_NO_STUN_WEAPONS))
		to_chat(chassis.occupant, span_warning("You cannot use non-lethal weapons!"))
		return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	equip_cooldown = 15
	name = "\improper CH-LC \"Solaris\" laser cannon"
	desc = "A weapon for combat exosuits. Shoots heavy lasers."
	icon_state = "mecha_laser"
	energy_drain = 6
	heat_cost = 15
	projectile = /obj/projectile/beam/laser/heavylaser/no_fire
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/xray
	equip_cooldown = 10
	name = "\improper CH-XC \"Transitum\" x-ray laser"
	desc = "A weapon for combat exosuits. Shoots concentrated X-ray blasts."
	icon_state = "mecha_xray"
	energy_drain = 6
	heat_cost = 15
	projectile = /obj/projectile/beam/xray
	fire_sound = 'sound/weapons/laser3.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion
	equip_cooldown = 20
	name = "\improper MKIV ion heavy cannon"
	desc = "A weapon for combat exosuits. Shoots technology-disabling ion beams. Don't catch yourself in the blast!"
	icon_state = "mecha_ion"
	energy_drain = 20
	heat_cost = 10
	projectile = /obj/projectile/ion/heavy	//Big boy 2/2 EMP bolts
	fire_sound = 'sound/weapons/laser.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla
	equip_cooldown = 35
	name = "\improper MKI Tesla Cannon"
	desc = "A weapon for combat exosuits. Fires bolts of electricity similar to the experimental tesla engine."
	icon_state = "mecha_ion"
	energy_drain = 50
	heat_cost = 10
	projectile = /obj/projectile/energy/tesla/cannon
	fire_sound = 'sound/magic/lightningbolt.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/pulse
	equip_cooldown = 30
	name = "eZ-13 MK2 heavy pulse rifle"
	desc = "A weapon for combat exosuits. Shoots powerful destructive blasts capable of demolishing obstacles."
	icon_state = "mecha_pulse"
	energy_drain = 12
	heat_cost = 20
	projectile = /obj/projectile/beam/pulse/heavy
	fire_sound = 'sound/weapons/marauder.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma
	equip_cooldown = 10
	range = MECHA_MELEE|MECHA_RANGED
	name = "217-D Heavy Plasma Cutter"
	desc = "A device that shoots resonant plasma bursts at extreme velocity. The blasts are capable of crushing rock and demolishing solid obstacles."
	icon_state = "mecha_plasmacutter"
	item_state = "plasmacutter"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	energy_drain = 3
	heat_cost = 2
	projectile = /obj/projectile/plasma/adv/mech
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	toolspeed = 0.25 // high-power cutting
	tool_behaviour = TOOL_WELDER
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/can_attach(obj/mecha/M)
	if(M.melee_allowed && !M.guns_allowed)	//Should only hold true for melee mechs
		return 0
	else if(..()) 	//combat mech
		return 1
	else if(M.equipment.len < M.max_equip && istype(M))
		return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/action(atom/target, mob/living/user, params)
	if(!chassis.Adjacent(target))
		return ..()
	// Again, two ways using tools can be handled, so check both
	if(target.tool_act(chassis.occupant, src, TOOL_WELDER, params) & TOOL_ACT_MELEE_CHAIN_BLOCKING)
		return TRUE
	if(target.attackby(src, chassis.occupant, params))
		return TRUE
	if(user.combat_mode) // hurt things
		chassis.default_melee_attack(target)
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma/use(used)
	return chassis?.cell?.use(used * energy_drain)

/obj/item/mecha_parts/mecha_equipment/weapon/energy/mecha_kineticgun
	equip_cooldown = 10
	name = "Exosuit Proto-kinetic Accelerator"
	desc = "An exosuit-mounted mining tool that does increased damage in low pressure. Drawing from an onboard power source allows it to project further than the handheld version."
	icon_state = "mecha_kineticgun"
	energy_drain = 3
	heat_cost = 2
	projectile = /obj/projectile/kinetic/mech
	fire_sound = 'sound/weapons/kenetic_accel.ogg'
	harmful = FALSE

//attachable to all mechas, like the plasma cutter
/obj/item/mecha_parts/mecha_equipment/weapon/energy/mecha_kineticgun/can_attach(obj/mecha/M)
	if(M.melee_allowed && !M.guns_allowed)	//Should only hold true for melee mechs
		return 0
	else if(..()) 	//combat mech
		return 1
	else if(M.equipment.len < M.max_equip && istype(M))
		return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser
	name = "\improper PBT \"Pacifier\" mounted taser"
	desc = "A weapon for combat exosuits. Shoots non-lethal stunning electrodes."
	icon_state = "mecha_taser"
	energy_drain = 2
	equip_cooldown = 8
	heat_cost = 5
	projectile = /obj/projectile/energy/electrode
	fire_sound = 'sound/weapons/taser.ogg'


/obj/item/mecha_parts/mecha_equipment/weapon/honker
	name = "\improper HoNkER BlAsT 5000"
	desc = "Equipment for clown exosuits. Spreads fun and joy to everyone around. Honk!"
	icon_state = "mecha_honker"
	energy_drain = 20
	equip_cooldown = 150
	heat_cost = 20
	range = MECHA_MELEE|MECHA_RANGED
	kickback = FALSE
	mech_flags = EXOSUIT_MODULE_HONK

/obj/item/mecha_parts/mecha_equipment/weapon/honker/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/honker/action(target, params)
	playsound(chassis, 'sound/items/airhorn.ogg', 100, 1)
	chassis.occupant_message("<font color='red' size='5'>HONK</font>")
	for(var/mob/living/carbon/M in ohearers(6, chassis))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
				continue
		var/turf/turf_check = get_turf(M)
		if(isspaceturf(turf_check) && !turf_check.Adjacent(src)) //in space nobody can hear you honk.
			continue
		to_chat(M, "<font color='red' size='7'>HONK</font>")
		M.SetSleeping(0)
		M.adjust_stutter(2 SECONDS)
		M.adjustEarDamage(0, 30)
		M.Knockdown(6 SECONDS)
		if(prob(30))
			M.Stun(10 SECONDS)
			M.Unconscious(8 SECONDS)
		else
			M.adjust_jitter(50 SECONDS)

	log_message("Honked from [src.name]. HONK!", LOG_MECHA)
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUPFLW(chassis.occupant)] used a Mecha Honker in [ADMIN_VERBOSEJMP(T)]")
	log_game("[key_name(chassis.occupant)] used a Mecha Honker in [AREACOORD(T)]")
	return 1


//Base ballistic weapon type
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	name = "general ballistic weapon"
	fire_sound = 'sound/weapons/gunshot.ogg'
	var/projectiles
	var/projectiles_cache //ammo to be loaded in, if possible.
	var/projectiles_cache_max
	var/projectile_energy_cost
	var/disabledreload //For weapons with no cache (like the rockets) which are reloaded by hand
	var/ammo_type

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_shot_amount()
	return min(projectiles, projectiles_per_shot)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action_checks(target)
	if(!..())
		return 0
	if(projectiles <= 0)
		return 0
	return 1

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	return "[..()] \[[src.projectiles][projectiles_cache_max &&!projectile_energy_cost?"/[projectiles_cache]":""]\][!disabledreload &&(src.projectiles < initial(src.projectiles))?" - <a href='byond://?src=[REF(src)];rearm=1'>Rearm</a>":null]"


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rearm()
	if(projectiles < initial(projectiles))
		var/projectiles_to_add = initial(projectiles) - projectiles

		if(projectile_energy_cost)
			while(chassis.get_charge() >= projectile_energy_cost && projectiles_to_add)
				projectiles++
				projectiles_to_add--
				chassis.use_power(projectile_energy_cost)

		else
			if(!projectiles_cache)
				return FALSE
			if(projectiles_to_add <= projectiles_cache)
				projectiles = projectiles + projectiles_to_add
				projectiles_cache = projectiles_cache - projectiles_to_add
			else
				projectiles = projectiles + projectiles_cache
				projectiles_cache = 0

		send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",src.get_equip_info())
		log_message("Rearmed [src.name].", LOG_MECHA)
		return TRUE


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/needs_rearm()
	. = !(projectiles > 0)



/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/Topic(href, href_list)
	..()
	if (href_list["rearm"])
		src.rearm()
	return

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action(atom/target, mob/living/user, params)
	if(..())
		projectiles -= get_shot_amount()
		send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",src.get_equip_info())
		return 1


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	name = "\improper FNX-99 \"Hades\" Carbine"
	desc = "A weapon for combat exosuits. Shoots incendiary bullets."
	icon_state = "mecha_carbine"
	equip_cooldown = 10
	heat_cost = 4
	projectile = /obj/projectile/bullet/incendiary/fnx99
	projectiles = 24
	projectiles_cache = 24
	projectiles_cache_max = 96
	harmful = TRUE
	ammo_type = "incendiary"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced
	name = "\improper S.H.H. \"Quietus\" Carbine"
	desc = "A weapon for combat exosuits. A mime invention, field tests have shown that targets cannot even scream before going down."
	fire_sound = null
	icon_state = "mecha_mime"
	equip_cooldown = 30
	heat_cost = 10
	projectile = /obj/projectile/bullet/mime
	projectiles = 6
	projectile_energy_cost = 50
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	name = "\improper LBX AC 10 \"Scattershot\""
	desc = "A weapon for combat exosuits. Shoots a spread of pellets."
	icon_state = "mecha_scatter"
	equip_cooldown = 20
	heat_cost = 8
	projectile = /obj/projectile/bullet/scattershot
	projectiles = 72
	projectiles_cache = 72
	projectiles_cache_max = 288
	projectiles_per_shot = 6
	variance = 25
	harmful = TRUE
	ammo_type = "scattershot"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	name = "\improper Ultra AC 2"
	desc = "A weapon for combat exosuits. Shoots a rapid, three shot burst."
	icon_state = "mecha_uac2"
	equip_cooldown = 10
	heat_cost = 3
	projectile = /obj/projectile/bullet/lmg
	projectiles = 300
	projectiles_cache = 300
	projectiles_cache_max = 1200
	projectiles_per_shot = 3
	variance = 6
	randomspread = 1
	projectile_delay = 2
	harmful = TRUE
	ammo_type = "lmg"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/bfg
	name = "\improper BFG-90 \"Graze\" Radioactive Cannon"
	desc = "A weapon for combat exosuits. Shoots an incredibly hot beam surrounded by a field of plasma."
	icon_state = "mecha_laser"
	equip_cooldown = 2 SECONDS
	heat_cost = 15
	projectile = /obj/projectile/beam/bfg
	projectiles = 5
	projectiles_cache = 0
	projectiles_cache_max = 10
	harmful = TRUE
	ammo_type = "bfg"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/venom
	name = "\improper K0-B3 \"Snakebite\" Carbine"
	desc = "A weapon for combat exosuits. Shoots incendiary bullets."
	icon_state = "mecha_venom"
	equip_cooldown = 10
	heat_cost = 5
	fire_sound = 'sound/weapons/smgshot.ogg'
	projectile = /obj/projectile/bullet/c45/venom	//yes the same one
	projectiles = 24
	projectiles_cache = 24
	projectiles_cache_max = 96
	harmful = TRUE
	ammo_type = "venom"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	name = "\improper SRM-8 missile rack"
	desc = "A weapon for combat exosuits. Launches light explosive missiles."
	icon_state = "mecha_missilerack"
	projectile = /obj/projectile/bullet/a84mm_he
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 8
	projectiles_cache = 0
	projectiles_cache_max = 0
	disabledreload = TRUE
	equip_cooldown = 60
	heat_cost = 20
	harmful = TRUE
	ammo_type = "missiles_he"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/breaching
	name = "\improper BRM-6 missile rack"
	desc = "A weapon for combat exosuits. Launches low-explosive breaching missiles designed to explode only when striking a sturdy target."
	icon_state = "mecha_missilerack_six"
	projectile = /obj/projectile/bullet/a84mm_br
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 6
	projectiles_cache = 0
	projectiles_cache_max = 0
	disabledreload = TRUE
	equip_cooldown = 60
	heat_cost = 20
	harmful = TRUE
	ammo_type = "missiles_br"


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher
	var/missile_speed = 2
	var/missile_range = 30
	var/diags_first = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/action(target)
	var/obj/O = new projectile(chassis.loc)
	playsound(chassis, fire_sound, 50, 1)
	log_message("Launched a [O.name] from [name], targeting [target].", LOG_MECHA)
	projectiles--
	proj_init(O)
	O.throw_at(target, missile_range, missile_speed, chassis.occupant, FALSE, diagonals_first = diags_first)
	return 1

//used for projectile initilisation (priming flashbang) and additional logging
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/proc/proj_init(obj/O)
	return


/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	name = "\improper SGL-6 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed flashbangs."
	icon_state = "mecha_grenadelnchr"
	projectile = /obj/item/grenade/flashbang
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 6
	projectiles_cache = 6
	projectiles_cache_max = 24
	missile_speed = 1.5
	equip_cooldown = 60
	heat_cost = 10
	var/det_time = 20
	ammo_type = "flashbang"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/proj_init(obj/item/grenade/flashbang/F)
	var/turf/T = get_turf(src)
	message_admins("[ADMIN_LOOKUPFLW(chassis.occupant)] fired a [src] in [ADMIN_VERBOSEJMP(T)]")
	log_game("[key_name(chassis.occupant)] fired a [src] in [AREACOORD(T)]")
	addtimer(CALLBACK(F, TYPE_PROC_REF(/obj/item/grenade/flashbang, prime)), det_time)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/clusterbang //Because I am a heartless bastard -Sieve //Heartless? for making the poor man's honkblast? - Kaze
	name = "\improper SOB-3 grenade launcher"
	desc = "A weapon for combat exosuits. Launches primed clusterbangs. You monster."
	projectiles = 3
	projectiles_cache = 0
	projectiles_cache_max = 0
	disabledreload = TRUE
	projectile = /obj/item/grenade/clusterbuster
	equip_cooldown = 90
	heat_cost = 20
	ammo_type = "clusterbang"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar
	name = "banana mortar"
	desc = "Equipment for clown exosuits. Launches banana peels."
	icon_state = "mecha_bananamrtr"
	projectile = /obj/item/grown/bananapeel
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 20
	heat_cost = 2 // honk
	mech_flags = EXOSUIT_MODULE_HONK

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar
	name = "mousetrap mortar"
	desc = "Equipment for clown exosuits. Launches armed mousetraps."
	icon_state = "mecha_mousetrapmrtr"
	projectile = /obj/item/assembly/mousetrap/armed
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 15
	missile_speed = 1.5
	projectile_energy_cost = 100
	equip_cooldown = 10
	heat_cost = 2
	mech_flags = EXOSUIT_MODULE_HONK

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar/proj_init(obj/item/assembly/mousetrap/armed/M)
	M.secured = 1


//Classic extending punching glove, but weaponised!
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove
	name = "\improper Oingo Boingo Punch-face"
	desc = "Equipment for clown exosuits. Delivers fun right to your face!"
	icon_state = "mecha_punching_glove"
	energy_drain = 250
	equip_cooldown = 20
	heat_cost = 5
	range = MECHA_MELEE|MECHA_RANGED
	missile_range = 5
	projectile = /obj/item/punching_glove
	fire_sound = 'sound/items/bikehorn.ogg'
	projectiles = 10
	projectile_energy_cost = 500
	diags_first = TRUE
	mech_flags = EXOSUIT_MODULE_HONK

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove/can_attach(obj/mecha/combat/honker/M)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove/action(target)
	. = ..()
	if(.)
		chassis.occupant_message("<font color='red' size='5'>HONK</font>")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove/proj_init(obj/item/punching_glove/PG)
	if(!istype(PG))
		return
	 //has to be low sleep or it looks weird, the beam doesn't exist for very long so it's a non-issue
	chassis.Beam(PG, icon_state = "chain", time = missile_range * 20, maxdistance = missile_range + 2)

/obj/item/punching_glove
	name = "punching glove"
	desc = "INCOMING HONKS"
	throwforce = 35
	icon_state = "punching_glove"

/obj/item/punching_glove/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		if(ismovable(hit_atom))
			var/atom/movable/AM = hit_atom
			AM.safe_throw_at(get_edge_target_turf(AM,get_dir(src, AM)), 7, 2)
		qdel(src)

// pressure washer, technically a gun
/obj/item/mecha_parts/mecha_equipment/weapon/pressure_washer
	name = "exosuit-mounted pressure washer"
	desc = "A high-power pressure washer."
	icon_state = "mecha_washer"
	range = MECHA_MELEE|MECHA_RANGED
	projectile = /obj/projectile/reagent/pressure_washer
	firing_effect_type = null
	fire_sound = 'sound/effects/extinguish.ogg'
	var/chem_amount = 5

/obj/item/mecha_parts/mecha_equipment/weapon/pressure_washer/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	reagents.add_reagent(/datum/reagent/water, 1000)

/obj/item/mecha_parts/mecha_equipment/weapon/pressure_washer/action(atom/target, mob/living/user, params)
	if(istype(target, /obj/structure/reagent_dispensers/watertank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/WT = target
		WT.reagents.trans_to(src, 1000)
		occupant_message(span_notice("Pressure washer refilled."))
		playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
		return TRUE
	else if(reagents.total_volume < 1)
		occupant_message(span_notice("Not enough water!"))
		return TRUE
	if(..())
		reagents.remove_reagent(/datum/reagent/water, chem_amount)
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/pressure_washer/can_attach(obj/mecha/M)
	if(istype(M, /obj/mecha/working) && M.equipment.len < M.max_equip)
		return TRUE
	return ..()

/obj/item/mecha_parts/mecha_equipment/weapon/pressure_washer/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"
