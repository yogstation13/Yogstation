/obj/item/gun/energy/laser/plasmacore
	name = "PlasmaCore-6e"
	desc = "The PlasmaCore-6e is the newest gun in Nanotrasen's cutting edge line of laser weaponry. Featuring an experimental plasma based cell that can be mechanically recharged. Glory to Nanotrasen."
	icon = 'monkestation/icons/obj/weapons/guns/plasmacoresixe.dmi'
	icon_state = "plasma_core_six"
	charge_sections = 6
	cell_type = /obj/item/stock_parts/cell/plasmacore
	w_class = WEIGHT_CLASS_NORMAL
	ammo_type = list(/obj/item/ammo_casing/energy/laser/hellfire)
	can_charge = FALSE
	verb_say = "states"
	var/cranking = FALSE


/obj/item/gun/energy/laser/plasmacore/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/gun_crank, \
		charging_cell = get_cell(), \
		charge_amount = 100, \
		cooldown_time = 1.5 SECONDS, \
		charge_sound = 'sound/weapons/laser_crank.ogg', \
		charge_sound_cooldown_time = 1.3 SECONDS, \
		)
	mutable_appearance(icon, "plasma_core_six_cell_backwards")
	RegisterSignal(src, COMSIG_GUN_CRANKING, PROC_REF(on_cranking))
	RegisterSignal(src, COMSIG_GUN_CRANKED, PROC_REF(on_cranked))

/obj/item/gun/energy/laser/plasmacore/proc/on_cranking(datum/source, mob/user)
	cranking = TRUE
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/energy/laser/plasmacore/proc/on_cranked(datum/source, mob/user)
	SIGNAL_HANDLER
	if(cell.charge == cell.maxcharge)
		say("Glory to Nanotrasen")
	cranking = FALSE
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/energy/laser/plasmacore/update_overlays()
	. = ..()
	. += "plasma_core_six_cell_[cranking ? "forwards" : "backwards"]"

/obj/item/stock_parts/cell/plasmacore
	name = "PlasmaCore-6e experimental cell"
	maxcharge = 600 //same as the secborg cell but i'm not reusing that here
	icon = 'icons/obj/power.dmi'
	icon_state = "icell"
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT*0.4, /datum/material/plasma=SMALL_MATERIAL_AMOUNT)
