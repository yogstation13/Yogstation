#define DEGENERATOR_BASE_POWER 2500000
#define DEGENERATOR_MULT_POWERGAME 0.2
#define DEGENERATOR_MULT_CLOTHING 0.5
#define DEGENERATOR_MULT_JOB 1
#define DEGENERATOR_MULT_SPECIES 2

/obj/machinery/power/degeneracy_engine
	name = "degenerator"
	desc = "Power the station with the only truly renewable resource: degeneracy."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"

	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	dir = SOUTH

	var/running = FALSE
	var/angry = FALSE
	var/obj/structure/fuel_tray/fuel_tray

	var/list/powergame_items = list(/obj/item/storage/toolbox,
									/obj/item/melee/baton/cattleprod,
									/obj/item/storage/belt/utility,
									/obj/item/gun/energy/wormhole_projector,
									/obj/vehicle/ridden/atv,
									/obj/item/gun/syringe,
									/obj/item/clothing/gloves/color/yellow)

	var/list/clothing_items = list(/obj/item/clothing/under/rank/security/skirt,
									/obj/item/clothing/head/crown,
									/obj/item/pda/clown,
									/obj/item/clothing/under/rank/clown,
									/obj/item/clothing/shoes/clown_shoes,
									/obj/item/clothing/mask/gas/clown_hat,
									/obj/item/storage/backpack/clown,
									/obj/item/storage/backpack/duffelbag/clown,
									/obj/item/pda/mime,
									/obj/item/clothing/under/rank/mime,
									/obj/item/clothing/mask/gas/mime,
									/obj/item/clothing/gloves/color/white,
									/obj/item/clothing/head/frenchberet,
									/obj/item/clothing/suit/suspenders,
									/obj/item/storage/backpack/mime)

	var/list/roles = list("Clown","Mime","Clerk","Assistant")

	var/list/species = list(/datum/species/golem,
							/datum/species/jelly,
							/datum/species/lizard,
							/datum/species/lizard,
							/datum/species/moth,
							/datum/species/plasmaman,
							/datum/species/pod,
							/datum/species/lizard)

/obj/machinery/power/degeneracy_engine/Initialize()
	connect_to_network()
	fuel_tray = new(src)
	fuel_tray.connected = src
	open()
	return ..()

/obj/machinery/power/degeneracy_engine/update_icon()
	if(running && angry)
		icon_state = "crema_active"
	else
		icon_state = initial(icon_state)

/obj/machinery/power/degeneracy_engine/proc/open()
	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	playsound(src, 'sound/effects/roll.ogg', 5, 1)
	var/turf/T = get_step(src, dir)
	fuel_tray.dir=dir
	for(var/atom/movable/AM in src)
		AM.forceMove(T)
	running = FALSE
	update_icon()

/obj/machinery/power/degeneracy_engine/proc/close()
	playsound(src, 'sound/effects/roll.ogg', 5, 1)
	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	for(var/atom/movable/AM in fuel_tray.loc)
		if(!AM.anchored || AM == fuel_tray)
			AM.forceMove(src)
	running = TRUE
	process_contents()
	update_icon()
	addtimer(CALLBACK(src, .proc/open), 40)


/obj/machinery/power/degeneracy_engine/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(running)
		to_chat(user, "<span class='danger'>It won't budge.</span>")

	close()

/obj/machinery/power/degeneracy_engine/wrench_act(mob/living/user, obj/item/I)
	if(!anchored && !isinspace())
		connect_to_network()
		to_chat(user, "<span class='notice'>You secure [src] to the floor.</span>")
		anchored = TRUE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
	else if(anchored)
		if(running)
			to_chat(user, "<span class='warning'>You can't detach [src] from the floor, it's holding on too tightly!</span>")
			return TRUE

		disconnect_from_network()
		to_chat(user, "<span class='notice'>You unsecure [src] from the floor.</span>")
		anchored = FALSE
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)

	return TRUE

/obj/machinery/power/degeneracy_engine/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return

	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>You short out the degeneracy sensors.</span>")

/obj/machinery/power/degeneracy_engine/proc/burn_it_all()
	angry = TRUE
	visible_message("<span class='danger'>[src] begins to shake violently!</span>")
	var/list/conts = GetAllContents() - src - fuel_tray
	if(!conts.len)
		audible_message("<span class='italics'>You hear a hollow crackle.</span>")
		return

	else
		audible_message("<span class='danger'>You hear a screeching sound as the degenerator activates.</span>")

		update_icon()

		for(var/mob/living/M in conts)
			if (M.stat != DEAD)
				M.emote("scream")

			log_attack("[M]/[M.ckey] was cremated by a degenerator.")
			M.death(1)
			if(M) //some animals get automatically deleted on death.
				M.ghostize()
				qdel(M)

		for(var/obj/O in conts) //conts defined above, ignores crematorium and tray
			qdel(O)

		if(!locate(/obj/effect/decal/cleanable/ash) in get_step(src, dir))//prevent pile-up
			new/obj/effect/decal/cleanable/ash/crematorium(src)

/obj/machinery/power/degeneracy_engine/proc/process_contents()
	if(obj_flags & EMAGGED)
		burn_it_all()
		return

	var/list/contents = GetAllContents()
	var/power_total = 0
	//Powergame check
	for(var/obj/content in contents)
		if(content.type in powergame_items)
			power_total += DEGENERATOR_BASE_POWER * DEGENERATOR_MULT_POWERGAME

	//Clothing check
	for(var/obj/content in contents)
		if(content.type in clothing_items)
			power_total += DEGENERATOR_BASE_POWER * DEGENERATOR_MULT_CLOTHING

	//Job check
	for(var/mob/content in contents)
		if(content.mind && (content.mind.assigned_role in roles))
			power_total += DEGENERATOR_BASE_POWER * DEGENERATOR_MULT_JOB

	//Species check
	for(var/mob/living/carbon/human/content in contents)
		if(content.dna.species.type in species)
			power_total += DEGENERATOR_BASE_POWER * DEGENERATOR_MULT_SPECIES

	if(power_total > 0)
		burn_it_all()
		add_avail(power_total)
	else
		visible_message("<span class='danger'>[src] seems content.</span>")
		angry = FALSE

//Generator fuel tray.
/obj/structure/fuel_tray
	name = "fuel tray"
	desc = "Apply clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/obj/machinery/power/degeneracy_engine/connected = null
	anchored = TRUE
	pass_flags = LETPASSTHROW
	max_integrity = 350

/obj/structure/fuel_tray/Destroy()
	if(connected)
		connected.fuel_tray = null
		connected.update_icon()
		connected = null
	return ..()

/obj/structure/fuel_tray/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal (loc, 2)
	qdel(src)

/obj/structure/fuel_tray/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/fuel_tray/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if (src.connected)
		connected.close()
		add_fingerprint(user)
	else
		to_chat(user, "<span class='warning'>That's not connected to anything!</span>")

/obj/structure/fuel_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user)
	if(!ismovableatom(O) || O.anchored || !Adjacent(user) || !user.Adjacent(O) || O.loc == user)
		return
	if(!ismob(O))
		if(!istype(O, /obj/structure/closet/body_bag))
			return
	else
		var/mob/M = O
		if(M.buckled)
			return
	if(!ismob(user) || user.lying || user.incapacitated())
		return
	O.forceMove(src.loc)
	if (user != O)
		visible_message("<span class='warning'>[user] stuffs [O] into [src].</span>")
	return

/obj/structure/fuel_tray/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover))
		return 1
	else
		return 0

/obj/structure/fuel_tray/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSTABLE)

/obj/structure/fuel_tray/attackby(obj/item/I, mob/user, params)
	I.forceMove(src.loc)