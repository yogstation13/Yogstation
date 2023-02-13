#define INFINITE -1

/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants/organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/item/organ/storedorgan
	var/organ_type = /obj/item/organ
	var/uses = INFINITE
	var/starting_organ

/obj/item/autosurgeon/Initialize(mapload)
	. = ..()
	if(starting_organ)
		insert_organ(new starting_organ(src))

/obj/item/autosurgeon/proc/insert_organ(var/obj/item/I)
	storedorgan = I
	I.forceMove(src)
	name = "[initial(name)] ([storedorgan.name])"

/obj/item/autosurgeon/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, span_warning("[src] has already been used. The tools are dull and won't reactivate."))
		return
	else if(!storedorgan)
		to_chat(user, span_notice("[src] currently has no implant stored."))
		return
	if(istype(storedorgan, /obj/item/organ/cyberimp/arm)) //these cunts have two limbs to select from, we'll want to check both because players are too lazy to do that themselves
		var/obj/item/organ/cyberimp/arm/bastard = storedorgan
		if(user.getorganslot(bastard.slot)) //FUCK IT WE BALL
			var/original_zone = storedorgan.zone
			if(bastard.zone == BODY_ZONE_R_ARM) // i do not like them sam i am  i do not like if else and ham
				bastard.zone = BODY_ZONE_L_ARM
			else
				bastard.zone = BODY_ZONE_R_ARM
			bastard.SetSlotFromZone()
			if(user.getorganslot(bastard.slot)) //NEVERMIND WE ARE NOT BALLING
				bastard.zone = original_zone //MISSION ABORT
				bastard.SetSlotFromZone()
			bastard.update_icon()
	storedorgan.Insert(user)//insert stored organ into the user
	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise."), span_notice("You feel a sharp sting as [src] plunges into your body."))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, span_notice("[src] already has an implant stored."))
			return
		else if(!uses)
			to_chat(user, span_notice("[src] has already been used up."))
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = I
		to_chat(user, span_notice("You insert the [I] into [src]."))
	else
		return ..()

/obj/item/autosurgeon/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, span_notice("There's no implant in [src] for you to remove."))
	else
		var/atom/drop_loc = user.drop_location()
		for(var/J in src)
			var/atom/movable/AM = J
			AM.forceMove(drop_loc)

		to_chat(user, span_notice("You remove the [storedorgan] from [src]."))
		I.play_tool_sound(src)
		storedorgan = null
		if(uses != INFINITE)
			uses--
		if(!uses)
			desc = "[initial(desc)] Looks like it's been used up."
	return TRUE

/obj/item/autosurgeon/cmo
	desc = "A single-use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/eyes/hud/medical

/obj/item/autosurgeon/upgraded_cyberheart
	uses = 1
	starting_organ = /obj/item/organ/heart/cybernetic/upgraded

/obj/item/autosurgeon/upgraded_cyberliver
	uses = 1
	starting_organ = /obj/item/organ/liver/cybernetic/upgraded

/obj/item/autosurgeon/upgraded_cyberlungs
	uses = 1
	starting_organ = /obj/item/organ/lungs/cybernetic/upgraded

/obj/item/autosurgeon/upgraded_cyberstomach
	uses = 1
	starting_organ = /obj/item/organ/stomach/cybernetic/upgraded

/obj/item/autosurgeon/thermal_eyes
	starting_organ = /obj/item/organ/eyes/robotic/thermals

/obj/item/autosurgeon/xray_eyes
	starting_organ = /obj/item/organ/eyes/robotic/xray/syndicate

/obj/item/autosurgeon/anti_stun
	starting_organ = /obj/item/organ/cyberimp/brain/anti_stun

/obj/item/autosurgeon/reviver
	starting_organ = /obj/item/organ/cyberimp/chest/reviver

/obj/item/autosurgeon/medibeam
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/medibeam

/obj/item/autosurgeon/arm
	organ_type = /obj/item/organ/cyberimp/arm //Technically means they can be meta'd by trying to put a normal organ in them and having it return no special text

/obj/item/autosurgeon/arm/examine(mob/user)
	. = ..()
	if(storedorgan) //So the extra text that distinguishes it from a normal autosurgeon doesn't appear if it's used up
		. += "This autosurgeon can switch which arm it will install the implant into with ALT + CLICK."

/obj/item/autosurgeon/arm/AltClick(mob/user) //Basically runs screwdriver_act on the implant inside
	if(storedorgan)
		var/obj/item/organ/cyberimp/arm/implant = storedorgan
		if(implant.zone == BODY_ZONE_R_ARM)
			implant.zone = BODY_ZONE_L_ARM
			to_chat(user, span_notice("You change the autosurgeon to target the left arm."))
		else
			implant.zone = BODY_ZONE_R_ARM
			to_chat(user, span_notice("You change the autosurgeon to target the right arm."))
		implant.SetSlotFromZone()
		implant.update_icon() //If for whatever reason, the implant is removed from the autosurgeon after it's switched

/obj/item/autosurgeon/arm/syndicate/syndie_mantis
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/syndie_mantis

/obj/item/autosurgeon/arm/syndicate/syndie_hammer
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/syndie_hammer

/obj/item/autosurgeon/arm/syndicate/syndie_hammer/attack_self(mob/user) //Preternis-only implant (if you don't manually remove the implant)
	if(!ispreternis(user))
		to_chat(user, span_warning("The autosurgeon rejects your body!"))
		return
	..()

/obj/item/autosurgeon/nt_mantis
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/nt_mantis

/obj/item/autosurgeon/nt_mantis/left
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/nt_mantis/left

/obj/item/autosurgeon/plasmavessel //Yogs Start: Just an autosurgeon with a plasma vessel in it, used in /obj/item/storage/box/syndie_kit/xeno_organ_kit
	uses = 3
	starting_organ = /obj/item/organ/alien/plasmavessel //Yogs End

/obj/item/autosurgeon/syndicate/spinalspeed
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/chest/spinalspeed

//Limb autosurgeons

/obj/item/autosurgeon/limb
	name = "limb autosurgeon"
	desc = "A experimental device that can automatically augment or replace a pre-existing limb with one stored in the autosurgeon. It has a slot to insert limbs and a screwdriver slot for removing accidentally added items."
	organ_type = /obj/item/bodypart //Not an organ but guh

/obj/item/autosurgeon/limb/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(!uses)
		to_chat(user, span_warning("[src] has already been used. The tools are dull and won't reactivate."))
		return
	else if(!storedorgan)
		to_chat(user, span_notice("[src] currently has no limb stored."))
		return
	var/obj/item/bodypart/augmentor = storedorgan
	augmentor.replace_limb(user, TRUE)
	user.visible_message(span_danger("[user] presses a button on [src], and you watch as the device replaces one of their limbs!"), span_danger("A flash of agony washes over you as [src] replaces one of your limbs."))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/limb/attackby(obj/item/I, mob/user, params)
	if(istype(I, organ_type))
		if(storedorgan)
			to_chat(user, span_notice("[src] already has a limb stored."))
			return
		else if(!uses)
			to_chat(user, span_notice("[src] has already been used up."))
			return
		if(!user.transferItemToLoc(I, src))
			return
		storedorgan = I
		to_chat(user, span_notice("You insert the [I] into [src]."))
	else
		return ..()

/obj/item/autosurgeon/limb/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!storedorgan)
		to_chat(user, span_notice("There's no limb in [src] for you to remove."))
	else
		var/atom/drop_loc = user.drop_location()
		for(var/J in src)
			var/atom/movable/AM = J
			AM.forceMove(drop_loc)

		to_chat(user, span_notice("You remove the [storedorgan] from [src]."))
		I.play_tool_sound(src)
		storedorgan = null
		if(uses != INFINITE)
			uses--
		if(!uses)
			desc = "[initial(desc)] Looks like it's been used up."
	return TRUE

/obj/item/autosurgeon/limb/head/robot
	uses = 1
	starting_organ = /obj/item/bodypart/head/robot

/obj/item/autosurgeon/limb/chest/robot
	uses = 1
	starting_organ = /obj/item/bodypart/chest/robot

/obj/item/autosurgeon/limb/l_arm/robot
	uses = 1
	starting_organ = /obj/item/bodypart/l_arm/robot

/obj/item/autosurgeon/limb/r_arm/robot
	uses = 1
	starting_organ = /obj/item/bodypart/r_arm/robot

/obj/item/autosurgeon/limb/l_leg/robot
	uses = 1
	starting_organ = /obj/item/bodypart/l_leg/robot

/obj/item/autosurgeon/limb/r_leg/robot
	uses = 1
	starting_organ = /obj/item/bodypart/r_leg/robot

//implants all the organs back to back, only single use
//not a derivative of autosurgeons because things get fucky
//someone is more than welcome to combine the two if they want, just make sure it actually works
/obj/item/multisurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant or organ into the user without the hassle of extensive surgery. It has a slot to insert implants/organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autoimplanter"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL
	var/list/obj/item/organ/storedorgan = list()
	var/organ_type = /obj/item/organ
	var/uses = 1
	var/list/starting_organ

/obj/item/multisurgeon/Initialize(mapload)
	. = ..()
	for(var/organ in starting_organ)
		insert_organ(new organ(src))

/obj/item/multisurgeon/proc/insert_organ(var/obj/item/I)
	storedorgan |= I
	I.forceMove(src)

/obj/item/multisurgeon/examine(mob/user)
	. = ..()
	if(storedorgan)
		. += span_info("Inside this multisurgeon is:")
		for(var/obj/item/organ/implants in storedorgan)
			. += span_info("-[implants.zone] [implants]")

/obj/item/multisurgeon/attack_self(mob/user)//when the object it used...
	if(!uses)
		to_chat(user, span_warning("[src] has already been used. The tools are dull and won't reactivate."))
		return
	else if(!storedorgan)
		to_chat(user, span_notice("[src] currently has no implant stored."))
		return
	for(var/obj/item/organ/toimplant in storedorgan)
		if(istype(toimplant, /obj/item/organ/cyberimp/arm)) //these cunts have two limbs to select from, we'll want to check both because players are too lazy to do that themselves
			var/obj/item/organ/cyberimp/arm/bastard = toimplant
			if(user.getorganslot(bastard.slot)) //FUCK IT WE BALL
				var/original_zone = toimplant.zone
				if(bastard.zone == BODY_ZONE_R_ARM) // i do not like them sam i am  i do not like if else and ham
					bastard.zone = BODY_ZONE_L_ARM
				else
					bastard.zone = BODY_ZONE_R_ARM
				bastard.SetSlotFromZone()
				if(user.getorganslot(bastard.slot)) //NEVERMIND WE ARE NOT BALLING
					bastard.zone = original_zone //MISSION ABORT
					bastard.SetSlotFromZone()
				bastard.update_icon()
		toimplant.Insert(user)//insert stored organ into the user
	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise."), span_notice("You feel a sharp sting as [src] plunges into your body."))
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	name = initial(name)
	if(uses != INFINITE)
		uses--
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/multisurgeon/jumpboots //for miners
	starting_organ = list(/obj/item/organ/cyberimp/leg/jumpboots, /obj/item/organ/cyberimp/leg/jumpboots/l)

/obj/item/multisurgeon/airshoes //for traitors
	starting_organ = list(/obj/item/organ/cyberimp/leg/airshoes, /obj/item/organ/cyberimp/leg/airshoes/l)

/obj/item/multisurgeon/noslipall //for traitors
	starting_organ = list(/obj/item/organ/cyberimp/leg/noslip, /obj/item/organ/cyberimp/leg/noslip/l)

/obj/item/multisurgeon/magboots //for ce
	desc = "A single-use multisurgeon that contains magboot implants for each leg."
	starting_organ = list(/obj/item/organ/cyberimp/leg/magboot, /obj/item/organ/cyberimp/leg/magboot/l)
