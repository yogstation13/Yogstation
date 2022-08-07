#define ROBOTIC_LIGHT_BRUTE_MSG "marred"
#define ROBOTIC_MEDIUM_BRUTE_MSG "dented"
#define ROBOTIC_HEAVY_BRUTE_MSG "falling apart"

#define ROBOTIC_LIGHT_BURN_MSG "scorched"
#define ROBOTIC_MEDIUM_BURN_MSG "charred"
#define ROBOTIC_HEAVY_BURN_MSG "smoldering"

//For ye whom may venture here, split up arm / hand sprites are formatted as "l_hand" & "l_arm".
//The complete sprite (displayed when the limb is on the ground) should be named "borg_l_arm".
//Failure to follow this pattern will cause the hand's icons to be missing due to the way get_limb_icon() works to generate the mob's icons using the aux_zone var.

/obj/item/bodypart/l_arm/robot
	name = "cyborg left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_arm"
	status = BODYPART_ROBOTIC
	disable_threshold = 1

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/r_arm/robot
	name = "cyborg right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_r_arm"
	status = BODYPART_ROBOTIC
	disable_threshold = 1

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/l_leg/robot
	name = "cyborg left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_leg"
	status = BODYPART_ROBOTIC
	disable_threshold = 1

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/r_leg/robot
	name = "cyborg right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_r_leg"
	status = BODYPART_ROBOTIC
	disable_threshold = 1

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

/obj/item/bodypart/chest/robot
	name = "cyborg torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_chest"
	status = BODYPART_ROBOTIC

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	var/wired = FALSE
	var/obj/item/stock_parts/cell/cell = null


/obj/item/bodypart/chest/robot/handle_atom_del(atom/A)
	if(A == cell)
		cell = null
	return ..()

/obj/item/bodypart/chest/robot/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/bodypart/chest/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, span_warning("You have already inserted a cell!"))
			return
		else
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, span_notice("You insert the cell."))
	else if(istype(W, /obj/item/stack/cable_coil))
		if(wired)
			to_chat(user, span_warning("You have already inserted wire!"))
			return
		var/obj/item/stack/cable_coil/coil = W
		if (coil.use(1))
			wired = TRUE
			to_chat(user, span_notice("You insert the wire."))
		else
			to_chat(user, span_warning("You need one length of coil to wire it!"))
	else
		return ..()

/obj/item/bodypart/chest/robot/wirecutter_act(mob/living/user, obj/item/I)
	if(!wired)
		return
	. = TRUE
	I.play_tool_sound(src)
	to_chat(user, span_notice("You cut the wires out of [src]."))
	new /obj/item/stack/cable_coil(drop_location(), 1)
	wired = FALSE

/obj/item/bodypart/chest/robot/screwdriver_act(mob/living/user, obj/item/I)
	..()
	. = TRUE
	if(!cell)
		to_chat(user, span_warning("There's no power cell installed in [src]!"))
		return
	I.play_tool_sound(src)
	to_chat(user, span_notice("Remove [cell] from [src]."))
	cell.forceMove(drop_location())
	cell = null


/obj/item/bodypart/chest/robot/examine(mob/user)
	. = ..()
	if(cell)
		. += {"It has a [cell] inserted.\n
		<span class='info'>You can use a <b>screwdriver</b> to remove [cell].</span>"}
	else
		. += span_info("It has an empty port for a <b>power cell</b>.")
	if(wired)
		. += "Its all wired up[cell ? " and ready for usage" : ""].\n"+\
		span_info("You can use <b>wirecutters</b> to remove the wiring.")
	else
		. += span_info("It has a couple spots that still need to be <b>wired</b>.")

/obj/item/bodypart/chest/robot/drop_organs(mob/user, violent_removal)
	if(wired)
		new /obj/item/stack/cable_coil(drop_location(), 1)
		wired = FALSE
	if(cell)
		cell.forceMove(drop_location())
		cell = null
	..()


/obj/item/bodypart/head/robot
	name = "cyborg head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	item_state = "buildpipe"
	icon = 'icons/mob/augmentation/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_head"
	status = BODYPART_ROBOTIC

	brute_reduction = 5
	burn_reduction = 4

	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG

	var/obj/item/assembly/flash/handheld/flash1 = null
	var/obj/item/assembly/flash/handheld/flash2 = null


/obj/item/bodypart/head/robot/handle_atom_del(atom/A)
	if(A == flash1)
		flash1 = null
	if(A == flash2)
		flash2 = null
	return ..()

/obj/item/bodypart/head/robot/Destroy()
	QDEL_NULL(flash1)
	QDEL_NULL(flash2)
	return ..()

/obj/item/bodypart/head/robot/examine(mob/user)
	. = ..()
	if(!flash1 && !flash2)
		. += span_info("It has two empty eye sockets for <b>flashes</b>.")
	else
		var/single_flash = FALSE
		if(!flash1 || !flash2)
			single_flash = TRUE
			. += {"One of its eye sockets is currently occupied by a flash.\n
			<span class='info'>It has an empty eye socket for another <b>flash</b>.</span>"}
		else
			. += "It has two eye sockets occupied by flashes."
		. += span_notice("You can remove the seated flash[single_flash ? "":"es"] with a <b>crowbar</b>.")

/obj/item/bodypart/head/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/F = W
		if(flash1 && flash2)
			to_chat(user, span_warning("You have already inserted the eyes!"))
			return
		else if(F.burnt_out)
			to_chat(user, span_warning("You can't use a broken flash!"))
			return
		else
			if(!user.transferItemToLoc(F, src))
				return
			if(flash1)
				flash2 = F
			else
				flash1 = F
			to_chat(user, span_notice("You insert the flash into the eye socket."))
			return
	return ..()

/obj/item/bodypart/head/robot/crowbar_act(mob/living/user, obj/item/I)
	if(flash1 || flash2)
		I.play_tool_sound(src)
		to_chat(user, span_notice("You remove the flash from [src]."))
		if(flash1)
			flash1.forceMove(drop_location())
			flash1 = null
		if(flash2)
			flash2.forceMove(drop_location())
			flash2 = null
	else
		to_chat(user, span_warning("There is no flash to remove from [src]."))
	return TRUE


/obj/item/bodypart/head/robot/drop_organs(mob/user, violent_removal)
	if(flash1)
		flash1.forceMove(user.loc)
		flash1 = null
	if(flash2)
		flash2.forceMove(user.loc)
		flash2 = null
	..()




/obj/item/bodypart/l_arm/robot/surplus
	name = "surplus prosthetic left arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20

/obj/item/bodypart/r_arm/robot/surplus
	name = "surplus prosthetic right arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20

/obj/item/bodypart/l_leg/robot/surplus
	name = "surplus prosthetic left leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20

/obj/item/bodypart/r_leg/robot/surplus
	name = "surplus prosthetic right leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'icons/mob/augmentation/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20



/obj/item/bodypart/l_leg/robot/ipc
	icon = 'icons/mob/human_parts.dmi'
	limb_override = TRUE

/obj/item/bodypart/r_leg/robot/ipc
	icon = 'icons/mob/human_parts.dmi'
	limb_override = TRUE

/obj/item/bodypart/l_arm/robot/ipc
	icon = 'icons/mob/human_parts.dmi'
	limb_override = TRUE

/obj/item/bodypart/r_arm/robot/ipc
	icon = 'icons/mob/human_parts.dmi'
	limb_override = TRUE

/obj/item/bodypart/head/robot/ipc
	icon = 'icons/mob/human_parts.dmi'
	limb_override = TRUE



/obj/item/bodypart/l_leg/robot/ipc/bship
	name = "Bishop Cyberkinetics Left Leg"
	icon_state = "bshipc_l_leg"
	species_id = "bshipc"

/obj/item/bodypart/r_leg/robot/ipc/bship
	name = "Bishop Cyberkinetics Right Leg"
	icon_state = "bshipc_r_leg"
	species_id = "bshipc"

/obj/item/bodypart/l_arm/robot/ipc/bship
	name = "Bishop Cyberkinetics Left Arm"
	icon_state = "bshipc_l_arm"
	species_id = "bshipc"

/obj/item/bodypart/r_arm/robot/ipc/bship
	name = "Bishop Cyberkinetics Right Arm"
	icon_state = "bshipc_r_arm"
	species_id = "bshipc"

/obj/item/bodypart/head/robot/ipc/bship
	name = "Bishop Cyberkinetics Head"
	icon_state = "bshipc_head"
	species_id = "bshipc"

/obj/item/bodypart/l_leg/robot/ipc/bship2
	name = "Bishop Cyberkinetics (2.0) Left Leg"
	icon_state = "bs2ipc_l_leg"
	species_id = "bs2ipc"

/obj/item/bodypart/r_leg/robot/ipc/bship2
	name = "Bishop Cyberkinetics (2.0) Right Leg"
	icon_state = "bs2ipc_r_leg"
	species_id = "bs2ipc"

/obj/item/bodypart/l_arm/robot/ipc/bship2
	name = "Bishop Cyberkinetics (2.0) Left Arm"
	icon_state = "bs2ipc_l_arm"
	species_id = "bs2ipc"

/obj/item/bodypart/r_arm/robot/ipc/bship2
	name = "Bishop Cyberkinetics (2.0) Right Arm"
	icon_state = "bs2ipc_r_arm"
	species_id = "bs2ipc"

/obj/item/bodypart/head/robot/ipc/bship2
	name = "Bishop Cyberkinetics (2.0) Head"
	icon_state = "bs2ipc_head"
	species_id = "bs2ipc"

/obj/item/bodypart/l_leg/robot/ipc/hsi
	name = "Hephaestus Industries Left Leg"
	icon_state = "hsiipc_l_leg"
	species_id = "hsiipc"

/obj/item/bodypart/r_leg/robot/ipc/hsi
	name = "Hephaestus Industries Right Leg"
	icon_state = "hsiipc_r_leg"
	species_id = "hsiipc"

/obj/item/bodypart/l_arm/robot/ipc/hsi
	name = "Hephaestus Industries Left Arm"
	icon_state = "hsiipc_l_arm"
	species_id = "hsiipc"

/obj/item/bodypart/r_arm/robot/ipc/hsi
	name = "Hephaestus Industries Right Arm"
	icon_state = "hsiipc_r_arm"
	species_id = "hsiipc"

/obj/item/bodypart/head/robot/ipc/hsi
	name = "Hephaestus Industries Head"
	icon_state = "hsiipc_head"
	species_id = "hsiipc"

/obj/item/bodypart/l_leg/robot/ipc/hsi2
	name = "Hephaestus Industries (2.0) Left Leg"
	icon_state = "hi2ipc_l_leg"
	species_id = "hi2ipc"

/obj/item/bodypart/r_leg/robot/ipc/hsi2
	name = "Hephaestus Industries (2.0) Right Leg"
	icon_state = "hi2ipc_r_leg"
	species_id = "hi2ipc"

/obj/item/bodypart/l_arm/robot/ipc/hsi2
	name = "Hephaestus Industries (2.0) Left Arm"
	icon_state = "hi2ipc_l_arm"
	species_id = "hi2ipc"

/obj/item/bodypart/r_arm/robot/ipc/hsi2
	name = "Hephaestus Industries (2.0) Right Arm"
	icon_state = "hi2ipc_r_arm"
	species_id = "hi2ipc"

/obj/item/bodypart/head/robot/ipc/hsi2
	name = "Hephaestus Industries (2.0) Head"
	icon_state = "hi2ipc_head"
	species_id = "hi2ipc"

/obj/item/bodypart/l_leg/robot/ipc/sgm
	name = "Shellguard Munitions Left Leg"
	icon_state = "sgmipc_l_leg"
	species_id = "sgmipc"

/obj/item/bodypart/r_leg/robot/ipc/sgm
	name = "Shellguard Munitions Right Leg"
	icon_state = "sgmipc_r_leg"
	species_id = "sgmipc"

/obj/item/bodypart/l_arm/robot/ipc/sgm
	name = "Shellguard Munitions Left Arm"
	icon_state = "sgmipc_l_arm"
	species_id = "sgmipc"

/obj/item/bodypart/r_arm/robot/ipc/sgm
	name = "Shellguard Munitions Right Arm"
	icon_state = "sgmipc_r_arm"
	species_id = "sgmipc"

/obj/item/bodypart/head/robot/ipc/sgm
	name = "Shellguard Munitions Head"
	icon_state = "sgmipc_head"
	species_id = "sgmipc"

/obj/item/bodypart/l_leg/robot/ipc/wtm
	name = "Ward-Takahashi Left Leg"
	icon_state = "wtmipc_l_leg"
	species_id = "wtmipc"

/obj/item/bodypart/r_leg/robot/ipc/wtm
	name = "Ward-Takahashi Right Leg"
	icon_state = "wtmipc_r_leg"
	species_id = "wtmipc"

/obj/item/bodypart/l_arm/robot/ipc/wtm
	name = "Ward-Takahashi Left Arm"
	icon_state = "wtmipc_l_arm"
	species_id = "wtmipc"

/obj/item/bodypart/r_arm/robot/ipc/wtm
	name = "Ward-Takahashi Right Arm"
	icon_state = "wtmipc_r_arm"
	species_id = "wtmipc"

/obj/item/bodypart/head/robot/ipc/wtm
	name = "Ward-Takahashi Head"
	icon_state = "wtmipc_head"
	species_id = "wtmipc"

/obj/item/bodypart/l_leg/robot/ipc/xmg
	name = "Xion Manufacturing Left Leg"
	icon_state = "xmgipc_l_leg"
	species_id = "xmgipc"

/obj/item/bodypart/r_leg/robot/ipc/xmg
	name = "Xion Manufacturing Right Leg"
	icon_state = "xmgipc_r_leg"
	species_id = "xmgipc"

/obj/item/bodypart/l_arm/robot/ipc/xmg
	name = "Xion Manufacturing Left Arm"
	icon_state = "xmgipc_l_arm"
	species_id = "xmgipc"

/obj/item/bodypart/r_arm/robot/ipc/xmg
	name = "Xion Manufacturing Right Arm"
	icon_state = "xmgipc_r_arm"
	species_id = "xmgipc"

/obj/item/bodypart/head/robot/ipc/xmg
	name = "Xion Manufacturing Head"
	icon_state = "xmgipc_head"
	species_id = "xmgipc"

/obj/item/bodypart/l_leg/robot/ipc/xmg2
	name = "Xion Manufacturing (2.0) Left Leg"
	icon_state = "xm2ipc_l_leg"
	species_id = "xm2ipc"

/obj/item/bodypart/r_leg/robot/ipc/xmg2
	name = "Xion Manufacturing (2.0) Right Leg"
	icon_state = "xm2ipc_r_leg"
	species_id = "xm2ipc"

/obj/item/bodypart/l_arm/robot/ipc/xmg2
	name = "Xion Manufacturing (2.0) Left Arm"
	icon_state = "xm2ipc_l_arm"
	species_id = "xm2ipc"

/obj/item/bodypart/r_arm/robot/ipc/xmg2
	name = "Xion Manufacturing (2.0) Right Arm"
	icon_state = "xm2ipc_r_arm"
	species_id = "xm2ipc"

/obj/item/bodypart/head/robot/ipc/xmg2
	name = "Xion Manufacturing (2.0) Head"
	icon_state = "xm2ipc_head"
	species_id = "xm2ipc"

/obj/item/bodypart/l_leg/robot/ipc/zhp
	name = "Zeng-Hu Pharmaceuticals Left Leg"
	icon_state = "zhpipc_l_leg"
	species_id = "zhpipc"

/obj/item/bodypart/r_leg/robot/ipc/zhp
	name = "Zeng-Hu Pharmaceuticals Right Leg"
	icon_state = "zhpipc_r_leg"
	species_id = "zhpipc"

/obj/item/bodypart/l_arm/robot/ipc/zhp
	name = "Zeng-Hu Pharmaceuticals Left Arm"
	icon_state = "zhpipc_l_arm"
	species_id = "zhpipc"

/obj/item/bodypart/r_arm/robot/ipc/zhp
	name = "Zeng-Hu Pharmaceuticals Right Arm"
	icon_state = "zhpipc_r_arm"
	species_id = "zhpipc"

/obj/item/bodypart/head/robot/ipc/zhp
	name = "Zeng-Hu Pharmaceuticals Head"
	icon_state = "zhpipc_head"
	species_id = "zhpipc"

#undef ROBOTIC_LIGHT_BRUTE_MSG
#undef ROBOTIC_MEDIUM_BRUTE_MSG
#undef ROBOTIC_HEAVY_BRUTE_MSG

#undef ROBOTIC_LIGHT_BURN_MSG
#undef ROBOTIC_MEDIUM_BURN_MSG
#undef ROBOTIC_HEAVY_BURN_MSG
