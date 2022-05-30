/obj/item/modular_computer/tablet/integrated  // Borg Built-in tablet interface
	name = "modular interface"
	icon_state = "tablet-silicon"
	icon_state_base = "tablet-silicon"
	icon_state_unpowered = "tablet-silicon"
	icon_state_powered = "tablet-silicon"
	hardware_flag = PROGRAM_INTEGRATED
	has_light = FALSE //tablet light button actually enables/disables the borg lamp
	comp_light_luminosity = 0
	variants = null
	///Ref to the borg we're installed in. Set by the borg during our creation.
	var/mob/living/silicon/robot/borgo
	///Ref to the RoboTact app. Important enough to borgs to deserve a ref.
	var/datum/computer_file/program/robotact/robotact
	///IC log that borgs can view in their personal management app
	var/list/borglog = list()

/obj/item/modular_computer/tablet/integrated/Initialize(mapload)
	. = ..()
	vis_flags |= VIS_INHERIT_ID
	borgo = loc
	if(!istype(borgo))
		borgo = null
		stack_trace("[type] initialized outside of a borg, deleting.")
		return INITIALIZE_HINT_QDEL

/obj/item/modular_computer/tablet/integrated/Destroy()
	borgo = null
	return ..()

/obj/item/modular_computer/tablet/integrated/turn_on(mob/user)
	if(borgo?.stat != DEAD)
		return ..()
	return FALSE

/obj/item/modular_computer/tablet/integrated/play_computer_sound(soundin, vol, vary)
	if(isobserver(usr) || !borgo)
		return
	borgo.playsound_local(loc, soundin, vol, vary, -1)

/**
  * Returns a ref to the RoboTact app, creating the app if need be.
  *
  * The RoboTact app is important for borgs, and so should always be available.
  * This proc will look for it in the tablet's robotact var, then check the
  * hard drive if the robotact var is unset, and finally attempt to create a new
  * copy if the hard drive does not contain the app. If the hard drive rejects
  * the new copy (such as due to lack of space), the proc will crash with an error.
  * RoboTact is supposed to be undeletable, so these will create runtime messages.
  */
/obj/item/modular_computer/tablet/integrated/proc/get_robotact()
	if(!borgo)
		return null
	if(!robotact)
		var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
		robotact = hard_drive.find_file_by_name("robotact")
		if(!robotact)
			stack_trace("Cyborg [borgo] ( [borgo.type] ) was somehow missing their self-manage app in their tablet. A new copy has been created.")
			robotact = new(hard_drive)
			if(!hard_drive.store_file(robotact))
				qdel(robotact)
				robotact = null
				CRASH("Cyborg [borgo]'s tablet hard drive rejected recieving a new copy of the self-manage app. To fix, check the hard drive's space remaining. Please make a bug report about this.")
	return robotact

//Makes the light settings reflect the borg's headlamp settings
/obj/item/modular_computer/tablet/integrated/ui_data(mob/user)
	. = ..()
	.["has_light"] = TRUE
	.["light_on"] = borgo?.lamp_enabled
	.["comp_light_color"] = borgo?.lamp_color

//Overrides the ui_act to make the flashlight controls link to the borg instead
/obj/item/modular_computer/tablet/integrated/ui_act(action, params)
	switch(action)
		if("PC_toggle_light")
			if(!borgo)
				return FALSE
			borgo.toggle_headlamp()
			return TRUE

		if("PC_light_color")
			if(!borgo)
				return FALSE
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = input(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color) as color|null
				if(!new_color || QDELETED(borgo))
					return
				if(color_hex2num(new_color) < 200) //Colors too dark are rejected
					to_chat(user, "<span class='warning'>That color is too dark! Choose a lighter one.</span>")
					new_color = null
			borgo.lamp_color = new_color
			borgo.toggle_headlamp(FALSE, TRUE)
			return TRUE
	return ..()

/obj/item/modular_computer/tablet/integrated/syndicate
	icon_state = "tablet-silicon-syndicate"
	icon_state_base = "tablet-silicon-syndicate"
	icon_state_unpowered = "tablet-silicon-syndicate"
	icon_state_powered = "tablet-silicon-syndicate"
	device_theme = "syndicate"


/obj/item/modular_computer/tablet/integrated/syndicate/Initialize()
	. = ..()
	borgo.lamp_color = COLOR_RED //Syndicate likes it red
