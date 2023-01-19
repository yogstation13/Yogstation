/obj/item/gun/energy/e_gun
	name = "energy gun"
	desc = "A basic hybrid energy gun with two settings: disable and kill."
	icon_state = "energy"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	modifystate = 1
	can_flashlight = TRUE
	ammo_x_offset = 3
	flight_x_offset = 15
	flight_y_offset = 10

/obj/item/gun/energy/e_gun/mini
	name = "miniature energy gun"
	desc = "A small, pistol-sized energy gun with a built-in flashlight. It has two settings: disable and kill."
	icon_state = "mini"
	item_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	cell_type = /obj/item/stock_parts/cell/mini_egun
	ammo_x_offset = 2
	charge_sections = 3
	can_flashlight = FALSE // Can't attach or detach the flashlight, and override it's icon update

/obj/item/gun/energy/e_gun/mini/Initialize()
	set_gun_light(new /obj/item/flashlight/seclite(src))
	return ..()

/obj/item/gun/energy/e_gun/mini/update_icon()
	..()
	if(gun_light && gun_light.on)
		add_overlay("mini-light")

/obj/item/gun/energy/e_gun/stun
	name = "tactical energy gun"
	desc = "Military issue energy gun, is able to fire stun rounds."
	icon_state = "energytac"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/spec, /obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/e_gun/old
	name = "prototype energy gun"
	desc = "NT-P:01 Prototype Energy Gun. Early stage development of a unique laser rifle that has multifaceted energy lens allowing the gun to alter the form of projectile it fires on command."
	icon_state = "protolaser"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode/old)

/obj/item/gun/energy/e_gun/mini/practice_phaser
	name = "practice phaser"
	desc = "A modified version of the basic phaser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser/practice)
	icon_state = "decloner"

/obj/item/gun/energy/e_gun/hos
	name = "\improper X-01 MultiPhase Energy Gun"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	icon_state = "hoslaser"
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/ion/hos)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/gun/energy/e_gun/dragnet
	name = "\improper DRAGnet"
	desc = "The \"Dynamic Rapid-Apprehension of the Guilty\" net is a revolution in law enforcement technology. Alt+click it to set a destination for the netting mode if a teleporter is set up."
	icon_state = "dragnet"
	item_state = "dragnet"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/net, /obj/item/ammo_casing/energy/trap)
	can_flashlight = FALSE
	ammo_x_offset = 1
	weapon_weight = WEAPON_MEDIUM
	var/obj/item/beacon/teletarget = null

/obj/item/gun/energy/e_gun/dragnet/AltClick(mob/living/user) //stolen from hand teleporter code
	var/turf/current_location = get_turf(user)//What turf is the user on?
	var/area/current_area = current_location.loc
	if(!current_location || current_area.noteleport || is_away_level(current_location.z) || !isturf(user.loc))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if user is not located on a turf
		to_chat(user, span_notice("\The [src] isn't capable of locking a beacon from here."))
		return
	var/list/L = list(  )
	for(var/obj/machinery/computer/teleporter/com in GLOB.machines)
		if(com.target)
			var/area/A = get_area(com.target)
			if(!A || A.noteleport)
				continue
			if(com.power_station && com.power_station.teleporter_hub && com.power_station.engaged)
				L["[get_area(com.target)] (Active)"] = com.target
			else
				L["[get_area(com.target)] (Inactive)"] = com.target
	L["None (Dangerous)"] = null
	var/t1 = input(user, "Please select a teleporter to lock in on.", "DRAGnet") as anything in L
	if(user.incapacitated())
		return
	if(!L[t1])
		teletarget = null
		user.show_message(span_notice("Random teleport enabled."))
	else
		var/obj/item/beacon/T = L[t1]
		var/area/A = get_area(T)
		if(A.noteleport)
			to_chat(user, span_notice("\The [src] is malfunctioning."))
			return
		current_location = get_turf(user)	//Recheck.
		current_area = current_location.loc
		if(!current_location || current_area.noteleport || is_away_level(current_location.z) || !isturf(user.loc))//If turf was not found or they're on z level 2 or >7 which does not currently exist. or if user is not located on a turf
			to_chat(user, span_notice("\The [src] isn't capable of locking a beacon from here."))
			return
		teletarget = T
		user.show_message(span_notice("Locked In."), MSG_AUDIBLE)

/obj/item/gun/energy/e_gun/dragnet/proc/modify_projectile(obj/item/projectile/energy/net/N)
	N.teletarget = teletarget

/obj/item/gun/energy/e_gun/dragnet/snare
	name = "Energy Snare Launcher"
	desc = "Fires an energy snare that slows the target down."
	ammo_type = list(/obj/item/ammo_casing/energy/trap)

/obj/item/gun/energy/e_gun/turret
	name = "hybrid turret gun"
	desc = "A heavy hybrid energy cannon with two settings: Stun and kill."
	icon_state = "turretlaser"
	item_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	weapon_weight = WEAPON_HEAVY
	can_flashlight = FALSE
	trigger_guard = TRIGGER_GUARD_NONE
	ammo_x_offset = 2

obj/item/gun/energy/e_gun/nuclear
	name = "advanced energy gun"
	desc = "An experimental energy gun with many settings and a miniaturized nuclear reactor that can be refueled with uranium."
	icon_state = "nucgun"
	item_state = "nucgun"
	pin = null
	can_charge = FALSE
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/xray, /obj/item/ammo_casing/energy/anoxia) //a lot of firemodes so it's really an ADVANCED egun
	dead_cell = TRUE //Fuel not included, you will have to get irradiated to shoot this gun

/obj/item/gun/energy/e_gun/nuclear/attackby(obj/item/I, mob/living/carbon/user) //plasmacutter but using uranium and devoid of any safety measures
	var/charge_multiplier = 0 //2 = Refined stack, 1 = Ore
	var/previous_loc = user.loc
	if(istype(I, /obj/item/stack/sheet/mineral/uranium))
		charge_multiplier = 2
	if(istype(I, /obj/item/stack/ore/uranium))
		charge_multiplier = 1
	if(charge_multiplier)
		if(cell.charge == cell.maxcharge)
			to_chat(user, span_notice("You try to insert [I] into [src]'s nulear reactor, but it's full."))
			return
		to_chat(user, span_notice("You start delicately inserting [I] in [src]'s reactor, refueling it."))
		if(do_after(user, 1 SECONDS, src))
			I.use(1)
			cell.give(250*charge_multiplier)
			user.radiation += (75*charge_multiplier) //You are putting you hand into a nuclear reactor to put more uranium in it
			update_icon(TRUE)
		else
			if(!(previous_loc == user.loc))
				to_chat(user, span_boldwarning("You move, bumping your hand on [src]'s nulear reactor's core!")) //when I said devoid of ANY safety measures I meant it
				user.adjustToxLoss(5*charge_multiplier) //straigth toxin damage rather than rads because we want the user to be punished immediately for moving, not in 2 hours
				user.radiation += (100*charge_multiplier) //but also rads because you touched a fucking nuclear reactor's core
	else
		..()

/obj/item/gun/energy/e_gun/bouncer
	name = "bouncer energy gun"
	desc = "A special energy gun shooting ricocheting projectiles, has two settings: disable and suffocate."
	icon_state = "bouncer"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/bounce, /obj/item/ammo_casing/energy/anoxia/bounce)
	can_flashlight = FALSE
	ammo_x_offset = 2
	pin = null
