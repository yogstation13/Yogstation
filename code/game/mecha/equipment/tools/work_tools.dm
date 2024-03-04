

//Hydraulic clamp, Kill clamp, Extinguisher, RCD, RPD, Cable layer.


/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	name = "hydraulic clamp"
	desc = "Equipment for engineering exosuits. Lifts objects and loads them into cargo."
	icon_state = "mecha_clamp"
	equip_cooldown = 15
	energy_drain = 10
	toolspeed = 0.5
	usesound = 'sound/mecha/hydraulic.ogg'
	tool_behaviour = TOOL_CROWBAR
	equip_actions = list(/datum/action/innate/mecha/equipment/clamp_mode)
	/// How much damage does it apply when used
	var/dam_force = 20
	var/obj/mecha/working/ripley/cargo_holder
	harmful = FALSE

/datum/action/innate/mecha/equipment/clamp_mode
	name = "Toggle Clamp Mode"
	button_icon_state = "clamp_crowbar"

/datum/action/innate/mecha/equipment/clamp_mode/Activate()
	if(equipment.tool_behaviour == TOOL_CROWBAR)
		equipment.tool_behaviour = TOOL_WRENCH
	else
		equipment.tool_behaviour = TOOL_CROWBAR
	button_icon_state = "clamp_[equipment.tool_behaviour]"
	chassis.balloon_alert(owner, "clamp set to [(equipment.tool_behaviour==TOOL_CROWBAR) ? "pry" : "wrench"]")
	playsound(chassis, 'sound/items/change_jaws.ogg', 50, 1)
	build_all_button_icons()

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/can_attach(obj/mecha/working/ripley/M as obj)
	if(..())
		if(istype(M))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/attach(obj/mecha/M as obj)
	..()
	cargo_holder = M
	return

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/detach(atom/moveto = null)
	..()
	cargo_holder = null

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/action(atom/target, mob/living/user, params)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	
	// There are two ways things handle being pried, and I'm too lazy to make every single thing use the same one
	if(target.tool_act(user, src, tool_behaviour) & TOOL_ACT_MELEE_CHAIN_BLOCKING)
		return TRUE
	if(target.attackby(src, user, params))
		return TRUE

	if(ismecha(target))
		var/obj/mecha/M = target
		var/have_ammo
		for(var/obj/item/mecha_ammo/box in cargo_holder.cargo)
			if(istype(box, /obj/item/mecha_ammo) && box.rounds)
				have_ammo = TRUE
				if(M.ammo_resupply(box, chassis.occupant, TRUE))
					return
		if(have_ammo)
			to_chat(chassis.occupant, "No further supplies can be provided to [M].")
		else
			to_chat(chassis.occupant, "No providable supplies found in cargo hold")
		return

	if(isobj(target))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				O.anchored = TRUE
				play_tool_sound(chassis)
				if(do_after_cooldown(target))
					cargo_holder.cargo += O
					O.forceMove(chassis)
					O.anchored = FALSE
					occupant_message(span_notice("[target] successfully loaded."))
					log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]", LOG_MECHA)
				else
					O.anchored = initial(O.anchored)
			else
				occupant_message(span_warning("Not enough room in cargo compartment!"))
		else
			occupant_message(span_warning("[target] is firmly secured!"))

	else if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD)
			return
		if(chassis.occupant.a_intent == INTENT_HARM)
			M.take_overall_damage(dam_force)
			if(!M)
				return
			M.adjustOxyLoss(round(dam_force/2))
			M.updatehealth()
			target.visible_message(span_danger("[chassis] squeezes [target]."), \
								span_userdanger("[chassis] squeezes [target]."),\
								span_italics("You hear something crack."))
			log_combat(chassis.occupant, M, "attacked", "[name]", "(INTENT: [uppertext(chassis.occupant.a_intent)]) (DAMTYE: [uppertext(damtype)])")
		else
			step_away(M,chassis)
			occupant_message("You push [target] out of the way.")
			chassis.visible_message("[chassis] pushes [target] out of the way.")
		return 1



//This is pretty much just for the death-ripley
/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them!"
	energy_drain = 0
	dam_force = 0
	var/real_clamp = FALSE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/real
	desc = "They won't know what clamped them! This time for real!"
	energy_drain = 10
	dam_force = 20
	real_clamp = TRUE

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/action(atom/target)
	if(!action_checks(target))
		return
	if(!cargo_holder)
		return
	if(isobj(target))
		var/obj/O = target
		if(!O.anchored)
			if(cargo_holder.cargo.len < cargo_holder.cargo_capacity)
				chassis.visible_message("[chassis] lifts [target] and starts to load it into cargo compartment.")
				O.anchored = TRUE
				if(do_after_cooldown(target))
					cargo_holder.cargo += O
					O.forceMove(chassis)
					O.anchored = FALSE
					occupant_message(span_notice("[target] successfully loaded."))
					log_message("Loaded [O]. Cargo compartment capacity: [cargo_holder.cargo_capacity - cargo_holder.cargo.len]", LOG_MECHA)
				else
					O.anchored = initial(O.anchored)
			else
				occupant_message(span_warning("Not enough room in cargo compartment!"))
		else
			occupant_message(span_warning("[target] is firmly secured!"))

	else if(isliving(target))
		var/mob/living/M = target
		if(M.stat == DEAD)
			return
		if(chassis.occupant.a_intent == INTENT_HARM)
			if(real_clamp)
				M.take_overall_damage(dam_force)
				if(!M)
					return
				M.adjustOxyLoss(round(dam_force/2))
				M.updatehealth()
				target.visible_message(span_danger("[chassis] destroys [target] in an unholy fury."), \
									span_userdanger("[chassis] destroys [target] in an unholy fury."))
				log_combat(chassis.occupant, M, "attacked", "[name]", "(INTENT: [uppertext(chassis.occupant.a_intent)]) (DAMTYE: [uppertext(damtype)])")
			else
				target.visible_message(span_danger("[chassis] destroys [target] in an unholy fury."), \
									span_userdanger("[chassis] destroys [target] in an unholy fury."))
		else if(chassis.occupant.a_intent == INTENT_DISARM)
			if(real_clamp)
				var/mob/living/carbon/C = target
				var/play_sound = FALSE
				var/limbs_gone = ""
				var/obj/item/bodypart/affected = C.get_bodypart(BODY_ZONE_L_ARM)
				if(affected != null)
					affected.dismember(damtype)
					play_sound = TRUE
					limbs_gone = ", [affected]"
				affected = C.get_bodypart(BODY_ZONE_R_ARM)
				if(affected != null)
					affected.dismember(damtype)
					play_sound = TRUE
					limbs_gone = "[limbs_gone], [affected]"
				if(play_sound)
					playsound(src, get_dismember_sound(), 80, TRUE)
					target.visible_message(span_danger("[chassis] rips [target]'s arms off."), \
								   span_userdanger("[chassis] rips [target]'s arms off."))
					log_combat(chassis.occupant, M, "dismembered of[limbs_gone],", "[name]", "(INTENT: [uppertext(chassis.occupant.a_intent)]) (DAMTYE: [uppertext(damtype)])")
			else
				target.visible_message(span_danger("[chassis] rips [target]'s arms off."), \
								   span_userdanger("[chassis] rips [target]'s arms off."))
		else
			step_away(M,chassis)
			target.visible_message("[chassis] tosses [target] like a piece of paper.")
		return 1



/obj/item/mecha_parts/mecha_equipment/extinguisher
	name = "exosuit extinguisher"
	desc = "Equipment for engineering exosuits. A rapid-firing high capacity fire extinguisher."
	icon_state = "mecha_exting"
	equip_cooldown = 5
	energy_drain = 0
	range = MECHA_MELEE|MECHA_RANGED
	var/chem_amount = 2

/obj/item/mecha_parts/mecha_equipment/extinguisher/Initialize(mapload)
	. = ..()
	create_reagents(1000)
	reagents.add_reagent(/datum/reagent/firefighting_foam, 1000)

/obj/item/mecha_parts/mecha_equipment/extinguisher/action(atom/target) //copypasted from extinguisher. TODO: Rewrite from scratch.
	if(!action_checks(target))
		return

	if(istype(target, /obj/structure/reagent_dispensers/foamtank) && get_dist(chassis,target) <= 1)
		var/obj/structure/reagent_dispensers/WT = target
		WT.reagents.trans_to(src, 1000)
		occupant_message(span_notice("Extinguisher refilled."))
		playsound(chassis, 'sound/effects/refill.ogg', 50, 1, -6)
	else if(reagents.total_volume >= 1)
		playsound(chassis, 'sound/effects/extinguish.ogg', 75, 1, -3)

		//Get all the turfs that can be shot at
		var/direction = get_dir(chassis,target)
		var/turf/T = get_turf(target)
		var/turf/T1 = get_step(T,turn(direction, 90))
		var/turf/T2 = get_step(T,turn(direction, -90))
		var/turf/T3 = get_step(T1, turn(direction, 90))
		var/turf/T4 = get_step(T2,turn(direction, -90))
		var/list/the_targets = list(T,T1,T2,T3,T4)

		for(var/a=0, a<5, a++)
			var/my_target = pick(the_targets)
			var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(src), my_target)
			reagents.trans_to(W, chem_amount, transfered_by = chassis.occupant)
			the_targets -= my_target
		return 1
	else
		occupant_message(span_warning("[src] is empty!"))

/obj/item/mecha_parts/mecha_equipment/extinguisher/get_equip_info()
	return "[..()] \[[src.reagents.total_volume]\]"

/obj/item/mecha_parts/mecha_equipment/extinguisher/can_attach(obj/mecha/M as obj)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat/sidewinder))
			return 1
	return 0



/obj/item/mecha_parts/mecha_equipment/rcd
	name = "mounted RCD"
	desc = "An exosuit-mounted Rapid Construction Device."
	icon_state = "mecha_rcd"
	equip_cooldown = 0 // internal RCD will handle it
	energy_drain = 0 // uses matter instead of energy
	range = MECHA_MELEE|MECHA_RANGED
	item_flags = NO_MAT_REDEMPTION
	equip_actions = list(/datum/action/innate/mecha/equipment/rcd)
	var/rcd_type = /obj/item/construction/rcd/exosuit
	var/obj/item/construction/rcd/internal_rcd

/obj/item/mecha_parts/mecha_equipment/rcd/Initialize(mapload)
	. = ..()
	GLOB.rcd_list += src
	internal_rcd = new rcd_type(src)

/obj/item/mecha_parts/mecha_equipment/rcd/Destroy()
	GLOB.rcd_list -= src
	if(internal_rcd && !QDELETED(internal_rcd))
		qdel(internal_rcd)
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/attach(obj/mecha/M)
	. = ..()
	internal_rcd.owner = M

/obj/item/mecha_parts/mecha_equipment/rcd/detach(atom/moveto)
	internal_rcd.owner = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/rcd/action(atom/target, mob/living/user, params)
	var/prox_flag = chassis.Adjacent(target)
	if(prox_flag && (istype(target, /obj/item/stack) || istype(target, /obj/item/rcd_ammo) || istype(target, /obj/item/rcd_upgrade)))
		chassis.matter_resupply(target, user)
		return TRUE
	if(!isliving(target))
		internal_rcd.afterattack(target, user, prox_flag, params) // RCD itself will handle it
		return TRUE

/obj/item/mecha_parts/mecha_equipment/rcd/get_equip_info()
	return "[..()] \[Matter: [internal_rcd ? internal_rcd.matter : 0]/[internal_rcd ? internal_rcd.max_matter : 0]\]"

/datum/action/innate/mecha/equipment/rcd
	name = "Change RCD Mode"
	button_icon_state = "rcd"

/datum/action/innate/mecha/equipment/rcd/Activate()
	var/obj/item/mecha_parts/mecha_equipment/rcd/E = equipment
	E.internal_rcd.ui_interact(owner)

/obj/item/mecha_parts/mecha_equipment/rcd/mime //special silent RCD
	name = "silenced mounted RCD"
	desc = "An expertly mimed exosuit-mounted Rapid Construction Device. Not a sound is made."
	rcd_type = /obj/item/construction/rcd/exosuit/mime


/obj/item/mecha_parts/mecha_equipment/pipe_dispenser
	name = "mounted RPD"
	desc = "An exosuit-mounted Rapid Pipe Dispenser"
	icon_state = "mecha_pipe_dispenser"
	equip_cooldown = 0 // internal RPD will handle it
	energy_drain = 0 // uses matter instead of energy
	range = MECHA_MELEE|MECHA_RANGED
	item_flags = NO_MAT_REDEMPTION
	equip_actions = list(/datum/action/innate/mecha/equipment/pipe_dispenser)
	var/rpd_type = /obj/item/pipe_dispenser/exosuit // in case there's ever any other type of RPD for mechs for some reason
	var/obj/item/pipe_dispenser/internal_rpd

/obj/item/mecha_parts/mecha_equipment/pipe_dispenser/Initialize(mapload)
	. = ..()
	internal_rpd = new rpd_type(src)

/obj/item/mecha_parts/mecha_equipment/pipe_dispenser/Destroy()
	if(internal_rpd && !QDELETED(internal_rpd))
		qdel(internal_rpd)
	return ..()

/obj/item/mecha_parts/mecha_equipment/pipe_dispenser/attach(obj/mecha/M)
	. = ..()
	internal_rpd.owner = M

/obj/item/mecha_parts/mecha_equipment/pipe_dispenser/detach(atom/moveto)
	internal_rpd.owner = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/pipe_dispenser/action(atom/target, mob/living/user, params)
	if(internal_rpd.pre_attack(target, user))
		return FALSE
	chassis.Beam(target, icon_state="rped_upgrade",time=2)
	return TRUE

/datum/action/innate/mecha/equipment/pipe_dispenser
	name = "Change RPD Mode"
	button_icon_state = "rpd"

/datum/action/innate/mecha/equipment/pipe_dispenser/Activate()
	var/obj/item/mecha_parts/mecha_equipment/pipe_dispenser/E = equipment
	E.internal_rpd.ui_interact(owner)


/obj/item/mecha_parts/mecha_equipment/t_scanner
	name = "exosuit T-ray scanner"
	desc = "An exosuit-mounted terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes. Has much higher range than the handheld version."
	icon_state = "mecha_t_scanner"
	equip_actions = list(/datum/action/innate/mecha/equipment/t_scanner)
	selectable = FALSE
	/// Scanning distance
	var/distance = 6
	/// Whether the scanning is enabled
	var/scanning = FALSE
	/// Stored t-ray scan images
	var/list/t_ray_images

/obj/item/mecha_parts/mecha_equipment/t_scanner/attach(obj/mecha/M)
	. = ..()
	RegisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(on_mech_move))

/obj/item/mecha_parts/mecha_equipment/t_scanner/detach(atom/moveto)
	UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)
	if(scanning)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/t_scanner/process(delta_time)
	if(!update_scan(chassis.occupant))
		return PROCESS_KILL

/obj/item/mecha_parts/mecha_equipment/t_scanner/proc/on_mech_move()
	if(chassis.occupant?.client)
		update_scan(chassis.occupant)

/obj/item/mecha_parts/mecha_equipment/t_scanner/proc/update_scan(mob/pilot, force_remove=FALSE) // twice the range, no downtime
	if(!pilot?.client)
		return FALSE
	if(t_ray_images?.len)
		pilot.client.images.Remove(t_ray_images)
		QDEL_NULL(t_ray_images)
	if(!scanning || force_remove)
		return FALSE

	t_ray_images = list()
	for(var/obj/O in orange(distance, chassis))
		if(HAS_TRAIT(O, TRAIT_T_RAY_VISIBLE))
			var/image/I = new(loc = get_turf(O))
			var/mutable_appearance/MA = new(O)
			MA.alpha = 128
			MA.dir = O.dir
			I.appearance = MA
			t_ray_images += I

	if(t_ray_images.len)
		pilot.client.images += t_ray_images
	
	return TRUE

/obj/item/mecha_parts/mecha_equipment/t_scanner/grant_actions(mob/pilot)
	. = ..()
	update_scan(pilot)

/obj/item/mecha_parts/mecha_equipment/t_scanner/remove_actions(mob/pilot)
	update_scan(pilot, TRUE)
	return ..()

/datum/action/innate/mecha/equipment/t_scanner
	name = "Toggle T-ray Scanner"
	button_icon_state = "t_scanner_off"

/datum/action/innate/mecha/equipment/t_scanner/Activate()
	var/obj/item/mecha_parts/mecha_equipment/t_scanner/t_scan = equipment
	t_scan.scanning = !t_scan.scanning
	t_scan.update_scan(t_scan.chassis.occupant)
	t_scan.chassis.occupant_message("You [t_scan.scanning ? "activate" : "deactivate"] [t_scan].")
	button_icon_state = "t_scanner_[t_scan.scanning ? "on" : "off"]"
	build_all_button_icons()
	if(t_scan.scanning)
		START_PROCESSING(SSobj, t_scan)
	else
		STOP_PROCESSING(SSobj, t_scan)

/obj/item/mecha_parts/mecha_equipment/cable_layer
	name = "cable layer"
	desc = "Equipment for engineering exosuits. Lays cable along the exosuit's path."
	icon_state = "mecha_wire"
	var/datum/callback/event
	var/turf/old_turf
	var/obj/structure/cable/last_piece
	var/obj/item/stack/cable_coil/cable
	var/max_cable = 1000

/obj/item/mecha_parts/mecha_equipment/cable_layer/Initialize(mapload)
	. = ..()
	cable = new(src, 0)

/obj/item/mecha_parts/mecha_equipment/cable_layer/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat/sidewinder))
			return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/cable_layer/attach()
	..()
	event = chassis.events.addEvent("onMove", CALLBACK(src, PROC_REF(layCable)))
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/detach()
	chassis.events.clearEvent("onMove",event)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/Destroy()
	if(chassis)
		chassis.events.clearEvent("onMove",event)
	return ..()

/obj/item/mecha_parts/mecha_equipment/cable_layer/action(obj/item/stack/cable_coil/target)
	if(!action_checks(target))
		return
	if(istype(target) && target.amount)
		var/cur_amount = cable? cable.amount : 0
		var/to_load = max(max_cable - cur_amount,0)
		if(to_load)
			to_load = min(target.amount, to_load)
			if(!cable)
				cable = new(src, 0)
			cable.amount += to_load
			target.use(to_load)
			occupant_message(span_notice("[to_load] meters of cable successfully loaded."))
			send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",src.get_equip_info())
		else
			occupant_message(span_warning("Reel is full."))
	else
		occupant_message(span_warning("Unable to load [target] - no cable found."))


/obj/item/mecha_parts/mecha_equipment/cable_layer/Topic(href,href_list)
	..()
	if(href_list["toggle"])
		set_ready_state(!equip_ready)
		occupant_message("[src] [equip_ready?"dea":"a"]ctivated.")
		log_message("[equip_ready?"Dea":"A"]ctivated.", LOG_MECHA)
		return
	if(href_list["cut"])
		if(cable && cable.amount)
			var/m = round(input(chassis.occupant,"Please specify the length of cable to cut","Cut cable",min(cable.amount,30)) as num, 1)
			m = min(m, cable.amount)
			if(m)
				use_cable(m)
				new /obj/item/stack/cable_coil(get_turf(chassis), m)
		else
			occupant_message("There's no more cable on the reel.")
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/get_equip_info()
	var/output = ..()
	if(output)
		return "[output] \[Cable: [cable ? cable.amount : 0] m\][(cable && cable.amount) ? "- <a href='?src=[REF(src)];toggle=1'>[!equip_ready?"Dea":"A"]ctivate</a>|<a href='?src=[REF(src)];cut=1'>Cut</a>" : null]"
	return

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/use_cable(amount)
	if(!cable || cable.amount<1)
		set_ready_state(1)
		occupant_message("Cable depleted, [src] deactivated.")
		log_message("Cable depleted, [src] deactivated.", LOG_MECHA)
		return
	if(cable.amount < amount)
		occupant_message("No enough cable to finish the task.")
		return
	cable.use(amount)
	update_equip_info()
	return 1

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/reset()
	last_piece = null

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/dismantle_floor(turf/new_turf)
	if(isfloorturf(new_turf))
		var/turf/open/floor/T = new_turf
		if(!isplatingturf(T))
			if(!T.broken && !T.burnt)
				new T.floor_tile(T)
			T.make_plating()
	return new_turf.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE

/obj/item/mecha_parts/mecha_equipment/cable_layer/proc/layCable(turf/new_turf)
	if(equip_ready || !istype(new_turf) || !dismantle_floor(new_turf))
		return reset()
	var/fdirn = turn(chassis.dir,180)
	for(var/obj/structure/cable/LC in new_turf)		// check to make sure there's not a cable there already
		if(LC.d1 == fdirn || LC.d2 == fdirn)
			return reset()
	if(!use_cable(1))
		return reset()
	var/obj/structure/cable/NC = new(new_turf, "red")
	NC.d1 = 0
	NC.d2 = fdirn
	NC.update_appearance(UPDATE_ICON)

	var/datum/powernet/PN
	if(last_piece && last_piece.d2 != chassis.dir)
		last_piece.d1 = min(last_piece.d2, chassis.dir)
		last_piece.d2 = max(last_piece.d2, chassis.dir)
		last_piece.update_appearance(UPDATE_ICON)
		PN = last_piece.powernet

	if(!PN)
		PN = new()
		GLOB.powernets += PN
	NC.powernet = PN
	PN.cables += NC
	NC.mergeConnectedNetworks(NC.d2)

	//NC.mergeConnectedNetworksOnTurf()
	last_piece = NC
	return 1

//Dunno where else to put this so shrug
/obj/item/mecha_parts/mecha_equipment/ripleyupgrade
	name = "Firefighter Conversion Kit"
	desc = "A pressurized canopy attachment kit for an Autonomous Power Loader Unit MK-I \"Ripley\" mecha, to convert it to the slower, but space-worthy MK-II design. This kit cannot be removed, once applied."
	icon_state = "ripleyupgrade"

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade/can_attach(obj/mecha/working/ripley/M)
	if(M.type != /obj/mecha/working/ripley)
		to_chat(loc, span_warning("This conversion kit can only be applied to APLU MK-I models."))
		return FALSE
	if(M.cargo.len)
		to_chat(loc, span_warning("[M]'s cargo hold must be empty before this conversion kit can be applied."))
		return FALSE
	if(!M.maint_access) //non-removable upgrade, so lets make sure the pilot or owner has their say.
		to_chat(loc, span_warning("[M] must have maintenance protocols active in order to allow this conversion kit."))
		return FALSE
	if(M.occupant) //We're actualy making a new mech and swapping things over, it might get weird if players are involved
		to_chat(loc, span_warning("[M] must be unoccupied before this conversion kit can be applied."))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/ripleyupgrade/attach(obj/mecha/M)
	var/obj/mecha/working/ripley/firefighter/N = new /obj/mecha/working/ripley/firefighter(get_turf(M),1)
	if(!N)
		return
	QDEL_NULL(N.cell)
	if (M.cell)
		N.cell = M.cell
		M.cell.forceMove(N)
		M.cell = null
	QDEL_NULL(N.scanmod)
	if (M.scanmod)
		N.scanmod = M.scanmod
		M.scanmod.forceMove(N)
		M.scanmod = null
	QDEL_NULL(N.capacitor)
	if (M.capacitor)
		N.capacitor = M.capacitor
		M.capacitor.forceMove(N)
		M.capacitor = null
	for(var/obj/item/mecha_parts/E in M.contents)
		if(istype(E, /obj/item/mecha_parts/concealed_weapon_bay)) //why is the bay not just a variable change who did this
			E.forceMove(N)
	for(var/obj/item/mecha_parts/mecha_equipment/E in M.equipment) //Move the equipment over...
		E.detach()
		E.attach(N)
		M.equipment -= E
	N.dna_lock = M.dna_lock
	N.maint_access = M.maint_access
	N.strafe = M.strafe
	N.update_integrity(M.get_integrity()) //This is not a repair tool
	if (M.name != "\improper APLU MK-I \"Ripley\"")
		N.name = M.name
	M.wreckage = 0
	qdel(M)
	playsound(get_turf(N),'sound/items/ratchet.ogg',50,1)
	return
