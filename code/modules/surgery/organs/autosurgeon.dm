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
	desc = "A single use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/eyes/hud/medical


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

/obj/item/autosurgeon/organ/syndicate/syndie_mantis
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/syndie_mantis

/obj/item/autosurgeon/organ/syndicate/syndie_mantis/AltClick(mob/living/user) //Basically this combines screwdriver with an insert_organ proc because I can't be assed
	var/obj/item/I = storedorgan
	var/atom/drop_loc = user.drop_location()
	if(!storedorgan)
		return
	for(var/atom/movable/AM in src)
		AM.forceMove(drop_loc)
	if(!istype(I, /obj/item/organ/cyberimp/arm/syndie_mantis/l))
		for(var/obj/item/organ/cyberimp/arm/syndie_mantis/R in drop_loc)
			R.Destroy()
		var/obj/item/organ/O = new /obj/item/organ/cyberimp/arm/syndie_mantis/l(src)
		insert_organ(O)
		to_chat(user, span_notice("You change the autosurgeon to target the left arm."))
	else
		for(var/obj/item/organ/cyberimp/arm/syndie_mantis/l/L in drop_loc)
			L.Destroy()
		var/obj/item/organ/O = new /obj/item/organ/cyberimp/arm/syndie_mantis(src)
		insert_organ(O)
		to_chat(user, span_notice("You change the autosurgeon to target the right arm."))

/obj/item/autosurgeon/organ/syndicate/syndie_hammer
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/syndie_hammer

/obj/item/autosurgeon/organ/syndicate/syndie_hammer/attack_self(mob/user) //Preternis-only implant (if you don't manually remove the implant)
	if(!ispreternis(user))
		to_chat(user, span_warning("The autosurgeon rejects your body!"))
		return
	..()

/obj/item/autosurgeon/organ/syndicate/syndie_hammer/AltClick(mob/living/user) //See mantis code
	var/obj/item/I = storedorgan
	var/atom/drop_loc = user.drop_location()
	if(!storedorgan)
		return
	for(var/atom/movable/AM in src)
		AM.forceMove(drop_loc)
	if(!istype(I, /obj/item/organ/cyberimp/arm/syndie_hammer/l))
		for(var/obj/item/organ/cyberimp/arm/syndie_hammer/R in drop_loc)
			R.Destroy()
		var/obj/item/organ/O = new /obj/item/organ/cyberimp/arm/syndie_hammer/l(src)
		insert_organ(O)
		to_chat(user, span_notice("You change the autosurgeon to target the left arm."))
	else
		for(var/obj/item/organ/cyberimp/arm/syndie_hammer/l/L in drop_loc)
			L.Destroy()
		var/obj/item/organ/O = new /obj/item/organ/cyberimp/arm/syndie_hammer(src)
		insert_organ(O)
		to_chat(user, span_notice("You change the autosurgeon to target the right arm."))

/obj/item/autosurgeon/nt_mantis
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/nt_mantis

/obj/item/autosurgeon/nt_mantis/l
	uses = 1
	starting_organ = /obj/item/organ/cyberimp/arm/nt_mantis/l

/obj/item/autosurgeon/plasmavessel //Yogs Start: Just an autosurgeon with a plasma vessel in it, used in /obj/item/storage/box/syndie_kit/xeno_organ_kit
	uses = 3
	starting_organ = /obj/item/organ/alien/plasmavessel //Yogs End
