/obj/item/boxcutter
	name = "boxcutter"
	desc = "A tool for cutting boxes, or throats."
	icon = 'modular_dripstation/icons/obj/cargo/boxcutter.dmi'
	icon_state = "boxcutter"
	item_state = "boxcutter"
	lefthand_file = 'modular_dripstation/icons/mob/inhands/equipment/boxcutter_lefthand.dmi'
	righthand_file = 'modular_dripstation/icons/mob/inhands/equipment/boxcutter_righthand.dmi'
	attack_verb = list("proded", "poked")
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FIRE_PROOF
	force = 0
	bare_wound_bonus = 20
	/// Used on Initialize, how much time to cut cable restraints and zipties.
	//var/snap_time_weak_handcuffs = 0 SECONDS
	/// Used on Initialize, how much time to cut real handcuffs. Null means it can't.
	//var/snap_time_strong_handcuffs = null

/obj/item/boxcutter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 70, 100)

	AddComponent( \
		/datum/component/transforming, \
		force_on = 10, \
		throwforce_on = 4, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		hitsound_on = 'sound/weapons/bladeslice.ogg', \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		attack_verb_on = list("cuted", "stabed", "slashed"), \
	)

	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/boxcutter/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	playsound(src, 'modular_dripstation/sound/item/boxcutter_activate.ogg', 50)
	//tool_behaviour = (active ? TOOL_KNIFE : NONE)
	//if(active)
	//	AddElement(/datum/element/cuffsnapping, snap_time_weak_handcuffs, snap_time_strong_handcuffs)
	//else
	//	RemoveElement(/datum/element/cuffsnapping, snap_time_weak_handcuffs, snap_time_strong_handcuffs)
	//return COMPONENT_NO_DEFAULT_MESSAGE
