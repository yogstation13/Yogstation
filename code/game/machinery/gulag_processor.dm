/*
Gulag processor
It automatically strips the prisoner and equips a prisoner ID, prisoner jumpsuit and oranges sneakers.
You can set the amount of points in the regular console
*/

GLOBAL_VAR_INIT(gulag_required_items, typecacheof(list(
		/obj/item/implant,
		/obj/item/clothing/suit/space/eva/plasmaman,
		/obj/item/clothing/under/plasmaman,
		/obj/item/clothing/head/helmet/space/plasmaman,
		/obj/item/tank/internals,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/gas)))

//Gulag processor
/obj/machinery/gulag_processor
	name = "labor camp processing machine"
	desc = "A machine used to process prisoners before they're sent to the labor camp. Alt-Click to remove an inserted ID."
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"
	state_open = FALSE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 5000
	circuit = /obj/item/circuitboard/machine/gulag_processor

	var/stun_duration = 70 //Half of a stunbaton

	var/obj/item/card/id/prisoner/id = null

	var/jumpsuit_type = /obj/item/clothing/under/rank/prisoner

	var/shoes_type = /obj/item/clothing/shoes/sneakers/orange

	var/obj/machinery/gulag_item_reclaimer/linked_reclaimer


/obj/machinery/gulag_processor/Initialize(mapload)
	. = ..()
	locate_reclaimer()

/obj/machinery/gulag_processor/Destroy()
	if(linked_reclaimer)
		linked_reclaimer.linked_teleporter = null

	return ..()

/obj/machinery/gulag_processor/examine(mob/user)
	. = ..()
	if(id)
		. += span_notice("\The [id] ID has been inserted.")
	else
		. += span_warning("There is no ID inserted.")

/obj/machinery/gulag_processor/AltClick(mob/living/user)
	if(id)
		id.forceMove(get_turf(src))
		id = null
	..()

/obj/machinery/gulag_processor/interact(mob/user)
	. = ..()
	toggle_open()

/obj/machinery/gulag_processor/updateUsrDialog()
	return

/obj/machinery/gulag_processor/attackby(obj/item/I, mob/user)
	if(!occupant && default_deconstruction_screwdriver(user, "[icon_state]", "[icon_state]",I))
		update_appearance(UPDATE_ICON)
		return

	if(default_deconstruction_crowbar(I))
		return

	if(default_pry_open(I))
		return

	if(istype(I, /obj/item/card/id/prisoner))
		if(!id)
			I.moveToNullspace()
			id = I
			to_chat(user, span_notice("You insert [I]."))
			return
		else
			to_chat(user, span_notice("There's an ID inserted already."))


	return ..()

/obj/machinery/gulag_processor/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) + (state_open ? "_open" : "")
	//no power or maintenance
	if(stat & (NOPOWER|BROKEN))
		icon_state += "_unpowered"
		if((stat & MAINT) || panel_open)
			icon_state += "_maintenance"
		return

	if((stat & MAINT) || panel_open)
		icon_state += "_maintenance"
		return

	//running and someone in there
	if(occupant)
		icon_state += "_occupied"
		return


/obj/machinery/gulag_processor/proc/locate_reclaimer()
	linked_reclaimer = locate(/obj/machinery/gulag_item_reclaimer)
	if(linked_reclaimer)
		linked_reclaimer.linked_teleporter = src

/obj/machinery/gulag_processor/proc/toggle_open()
	if(panel_open)
		to_chat(usr, span_notice("Close the maintenance panel first."))
		return

	if(state_open)
		close_machine()
		return

	open_machine()

/obj/machinery/gulag_processor/close_machine()
	..()

	if(occupant)
		if(id)
			handle_prisoner(id)
			id = null
		else
			visible_message(span_warning("No ID inserted. Processing aborted.."))
	else
		open_machine()
		visible_message(span_warning("No occupant detected. Processing aborted."))
		return

// strips and stores all occupant's items
/obj/machinery/gulag_processor/proc/strip_occupant()
	if(linked_reclaimer)
		linked_reclaimer.stored_items[occupant] = list()

	var/mob/living/carbon/human/mob_occupant = occupant
	for(var/obj/item/W in mob_occupant)
		if(!is_type_in_typecache(W, GLOB.gulag_required_items))
			if(mob_occupant.temporarilyRemoveItemFromInventory(W))
				if(istype(W, /obj/item/restraints/handcuffs))
					W.forceMove(get_turf(src))
					continue
				if(linked_reclaimer)
					linked_reclaimer.stored_items[mob_occupant] += W
					linked_reclaimer.contents += W
					W.forceMove(linked_reclaimer)
				else
					W.forceMove(src)

/obj/machinery/gulag_processor/proc/handle_prisoner(obj/item/id)
	if(!ishuman(occupant))
		return
	strip_occupant()
	var/mob/living/carbon/human/prisoner = occupant
	if(!isplasmaman(prisoner) && jumpsuit_type)
		prisoner.equip_to_appropriate_slot(new jumpsuit_type)
	if(shoes_type)
		prisoner.equip_to_appropriate_slot(new shoes_type)
	if(id)
		prisoner.equip_to_appropriate_slot(id)

	if(!isnull(GLOB.data_core.general))
		for(var/r in GLOB.data_core.security)
			var/datum/data/record/R = r
			if(R.fields["name"] == prisoner.real_name)
				R.fields["criminal"] = WANTED_PRISONER

	open_machine()
	prisoner.Paralyze(stun_duration)
	if(!prisoner.handcuffed && (prisoner.get_num_arms(FALSE) >= 2 || prisoner.get_arm_ignore()))
		prisoner.set_handcuffed(new /obj/item/restraints/handcuffs/cable/zipties/used(prisoner))
		prisoner.update_handcuffed()
	visible_message(span_warning("Prisoner Processed."))

/obj/item/circuitboard/machine/gulag_processor
	name = "labor camp processor (Machine Board)"
	build_path = /obj/machinery/gulag_processor
	req_components = list(
							/obj/item/stock_parts/scanning_module,
							/obj/item/stock_parts/manipulator)
