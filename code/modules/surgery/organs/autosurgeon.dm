/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants/organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	var/list/storedorgans = list()
	var/list/starting_organs = list()
	/// How many organs can be inserted into this beyond the initial ones (make sure this is a larger number than the number of starting organs)
	var/refills = 0

	var/static/list/organ_types = typecacheof(list(
		/obj/item/organ,
		/obj/item/bodypart
	))
	var/static/list/blacklisted_organs = typecacheof(list(
		/obj/item/organ/regenerative_core // Full heal with revive on demand.
	))
	
	///The arm that is prioritized first when inserting arm implants (swaps after implanting an arm implant)
	var/target_arm = BODY_ZONE_L_ARM

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Basic stuff------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/Initialize(mapload)
	. = ..()
	for(var/i in starting_organs)
		insert_organ(i, null, TRUE)

/obj/item/autosurgeon/examine(mob/user)
	. = ..()
	if(length(storedorgans))	
		. += span_notice("it contains.")
		for(var/i in storedorgans)
			. += span_notice("- [i]")
	if(locate(/obj/item/organ/cyberimp/arm) in storedorgans)
		. += span_notice("It will implant any arm implants in the [target_arm == BODY_ZONE_L_ARM ? "left" : "right"] arm first.")
		. += span_notice("This can be switched with ALT + CLICK.")
	if(refills > 0)
		. += span_notice("Can accept [refills] more implants before it ceases to function.")

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Adding organs----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/attackby(obj/item/I, mob/user, params) //putting new things in
	if(!user.combat_mode)
		insert_organ(I, user)
	return ..()
		
/obj/item/autosurgeon/proc/insert_organ(obj/inserted, mob/user, bypass_refills)
	if(!refills && !bypass_refills)
		if(user)
			to_chat(user, span_notice("[src] has already been used up."))
		return FALSE
	if(is_type_in_typecache(inserted, blacklisted_organs) || !is_type_in_typecache(inserted, organ_types))
		if(user)
			to_chat(user, span_notice("[inserted] does not fit in \the [src]."))
		return FALSE
	if(ispath(inserted))
		inserted = new inserted()
	storedorgans += inserted
	inserted.forceMove(src)
	name = "primed [initial(name)]"

	if(refills != INFINITE && !bypass_refills)
		refills--

	if(user)
		to_chat(user, span_notice("You insert the [inserted] into [src]."))
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Arm Swapping------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/AltClick(mob/user) //changes the prioritized arm
	if(locate(/obj/item/organ/cyberimp/arm) in storedorgans)
		swap_arm()
		to_chat(user, span_notice("You change the autosurgeon to target the [target_arm == BODY_ZONE_L_ARM ? "left" : "right"] arm."))

/obj/item/autosurgeon/proc/swap_arm()
	target_arm = target_arm == BODY_ZONE_L_ARM ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Attempts to implant a single item---------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/proc/handle_surgery(obj/item, mob/living/carbon/human/user)
	if(istype(item, /obj/item/organ/cyberimp/arm)) //these cunts have two limbs to select from, we'll want to check both because players are too lazy to do that themselves
		var/obj/item/organ/cyberimp/bastard = item
		bastard.zone = target_arm //try the preferred limb
		bastard.SetSlotFromZone()
		swap_arm()
		if(user.getorganslot(bastard.slot)) //preferred limb is full
			bastard.zone = target_arm
			bastard.SetSlotFromZone()
			swap_arm()
			if(user.getorganslot(bastard.slot)) //other limb is full, revert to the first selection and just FUCKING DO IT
				bastard.zone = target_arm
				bastard.SetSlotFromZone()
				swap_arm()
		bastard.update_appearance(UPDATE_ICON)
		bastard.Insert(user)

	else if(istype(item, /obj/item/organ)) //if it's just a regular organ
		var/obj/item/organ/thing = item
		thing.Insert(user)

	else if(istype(item, /obj/item/bodypart)) //if it's a limb
		var/obj/item/bodypart/thing = item
		thing.replace_limb(user, TRUE)
	else
		stack_trace("[src] attempted to implant [item] in [user]")

////////////////////////////////////////////////////////////////////////////////////
//----------------------Use the item to implant every stored item-----------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/attack_self(mob/user)//when the object it used...
	if(!length(storedorgans))
		if(refills)
			to_chat(user, span_notice("[src] currently has no implant stored."))
		else
			to_chat(user, span_warning("[src] has already been used. The tools are dull and won't reactivate."))
		return
	if(!ishuman(user))
		to_chat(user, span_warning("You don't know how to use this."))
		return
	for(var/i in storedorgans)
		handle_surgery(i, user)
	storedorgans = list()
	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise."), span_notice("You feel a sharp sting as [src] plunges into your body."))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	name = initial(name)
	if(!refills)
		name = "dulled [initial(name)]"
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Removing items----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(length(storedorgans))
		var/atom/drop_loc = user.drop_location()
		for(var/J in storedorgans)
			var/atom/movable/AM = J
			AM.forceMove(drop_loc)
			to_chat(user, span_notice("You remove the [J] from [src]."))
			storedorgans -= J
		
		I.play_tool_sound(src)
		if(!refills)
			name = "dulled [initial(name)]"
			desc = "[initial(desc)] Looks like it's been used up."
	else
		to_chat(user, span_notice("There's no implant in [src] for you to remove."))
	return TRUE
	
////////////////////////////////////////////////////////////////////////////////////
//--------------------------Head of staff Autosurgeons----------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/cmo
	desc = "A single-use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organs = list(/obj/item/organ/cyberimp/eyes/hud/medical)

/obj/item/autosurgeon/magboots //for ce
	desc = "A single-use autosurgeon that contains magboot implants for each leg. A screwdriver can be used to remove them, but implants can't be placed back in."
	starting_organs = list(/obj/item/organ/cyberimp/leg/magboot, /obj/item/organ/cyberimp/leg/magboot/l)

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Antag Autosurgeons---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/upgraded_cyberheart
	starting_organs = list(/obj/item/organ/heart/cybernetic/upgraded)

/obj/item/autosurgeon/upgraded_cyberliver
	starting_organs = list(/obj/item/organ/liver/cybernetic/upgraded)

/obj/item/autosurgeon/upgraded_cyberlungs
	starting_organs = list(/obj/item/organ/lungs/cybernetic/upgraded)

/obj/item/autosurgeon/upgraded_cyberstomach
	starting_organs = list(/obj/item/organ/stomach/cybernetic/upgraded)

/obj/item/autosurgeon/thermal_eyes
	starting_organs = list(/obj/item/organ/eyes/robotic/thermals)

/obj/item/autosurgeon/medibeam
	starting_organs = list(/obj/item/organ/cyberimp/arm/medibeam)

/obj/item/autosurgeon/plasmavessel
	starting_organs = list(/obj/item/organ/alien/plasmavessel)

/obj/item/autosurgeon/head/robot
	starting_organs = list(/obj/item/bodypart/head/robot)

/obj/item/autosurgeon/chest/robot
	starting_organs = list(/obj/item/bodypart/chest/robot)

/obj/item/autosurgeon/l_arm/robot
	starting_organs = list(/obj/item/bodypart/l_arm/robot)

/obj/item/autosurgeon/r_arm/robot
	starting_organs = list(/obj/item/bodypart/r_arm/robot)

/obj/item/autosurgeon/l_leg/robot
	starting_organs = list(/obj/item/bodypart/leg/left/robot)

/obj/item/autosurgeon/r_leg/robot
	starting_organs = list(/obj/item/bodypart/leg/right/robot)

//------------------------Antag Autosurgeons without metashield-------------------
/obj/item/autosurgeon/suspicious
	name = "syndicate autosurgeon"
	icon_state = "autoimplanter_red"

/obj/item/autosurgeon/suspicious/reusable
	refills = INFINITE

/obj/item/autosurgeon/suspicious/airshoes
	starting_organs = list(/obj/item/organ/cyberimp/leg/airshoes, /obj/item/organ/cyberimp/leg/airshoes/l)

/obj/item/autosurgeon/suspicious/noslipall
	starting_organs = list(/obj/item/organ/cyberimp/leg/noslip, /obj/item/organ/cyberimp/leg/noslip/l)

/obj/item/autosurgeon/suspicious/spinalspeed
	starting_organs = list(/obj/item/organ/cyberimp/chest/spinalspeed)

/obj/item/autosurgeon/suspicious/syndie_mantis
	starting_organs = list(/obj/item/organ/cyberimp/arm/syndie_mantis)

/obj/item/autosurgeon/suspicious/stechkin_implant
	starting_organs = list(/obj/item/organ/cyberimp/arm/stechkin_implant)

/obj/item/autosurgeon/suspicious/anti_stun
	starting_organs = list(/obj/item/organ/cyberimp/brain/anti_stun/syndicate)

/obj/item/autosurgeon/suspicious/reviver
	starting_organs = list(/obj/item/organ/cyberimp/chest/reviver/syndicate)

/obj/item/autosurgeon/suspicious/xray_eyes
	starting_organs = list(/obj/item/organ/eyes/robotic/xray/syndicate)

/obj/item/autosurgeon/suspicious/syndie_hammer
	starting_organs = list(/obj/item/organ/cyberimp/arm/syndie_hammer)

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------NT Autosurgeons---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/nt_mantis
	starting_organs = list(/obj/item/organ/cyberimp/arm/nt_mantis)

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Admeme Autosurgeons--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/obj/item/autosurgeon/jumpboots //for admins
	starting_organs = list(/obj/item/organ/cyberimp/leg/jumpboots, /obj/item/organ/cyberimp/leg/jumpboots/l)

/obj/item/autosurgeon/wheelies //for admins
	starting_organs = list(/obj/item/organ/cyberimp/leg/wheelies, /obj/item/organ/cyberimp/leg/wheelies/l)
