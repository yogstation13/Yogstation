

//The robot bodyparts have been moved to code/module/surgery/bodyparts/robot_bodyparts.dm


/obj/item/robot_suit
	name = "cyborg endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "robo_suit"
	w_class = WEIGHT_CLASS_BULKY // yogs - can not fit in backpacks
/// Left arm part of the endoskeleton
	var/obj/item/bodypart/l_arm/robot/l_arm = null
	/// Right arm part of the endoskeleton
	var/obj/item/bodypart/r_arm/robot/r_arm = null
	/// Left leg part of this endoskeleton
	var/obj/item/bodypart/leg/left/robot/l_leg = null
	/// Right leg part of this endoskeleton
	var/obj/item/bodypart/leg/right/robot/r_leg = null
	/// Chest part of this endoskeleton
	var/obj/item/bodypart/chest/robot/chest = null
	/// Head part of this endoskeleton
	var/obj/item/bodypart/head/robot/head = null
	/// Forced name of the cyborg
	var/created_name = ""
	/// Forced master AI of the cyborg
	var/mob/living/silicon/ai/forced_ai
	/// If the cyborg starts movement free and not under lockdown
	var/locomotion = TRUE
	/// If the cyborg synchronizes it's laws with it's master AI
	var/lawsync = TRUE
	/// If the cyborg starts with a master AI
	var/aisync = TRUE
	/// If the cyborg's cover panel starts locked
	var/panel_locked = TRUE

/obj/item/robot_suit/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/robot_suit/prebuilt/Initialize(mapload)
	. = ..()
	l_arm = new(src)
	r_arm = new(src)
	l_leg = new(src)
	r_leg = new(src)
	head = new(src)
	head.flash1 = new(head)
	head.flash2 = new(head)
	chest = new(src)
	chest.wired = TRUE
	chest.cell = new /obj/item/stock_parts/cell/high/plus(chest)

/obj/item/robot_suit/update_overlays()
	. = ..()
	if(l_arm)
		. += "[l_arm.icon_state]+o"
	if(r_arm)
		. += "[r_arm.icon_state]+o"
	if(chest)
		. += "[chest.icon_state]+o"
	if(l_leg)
		. += "[l_leg.icon_state]+o"
	if(r_leg)
		. += "[r_leg.icon_state]+o"
	if(head)
		. += "[head.icon_state]+o"

/obj/item/robot_suit/proc/check_completion()
	if(src.l_arm && src.r_arm)
		if(src.l_leg && src.r_leg)
			if(src.chest && src.head)
				SSblackbox.record_feedback("amount", "cyborg_frames_built", 1)
				return 1
	return 0

/obj/item/robot_suit/examine(mob/user)
	. = ..()
	. += "If you insert an AI CPU when this endoskeleton is complete it will be constructed as a synthetic."

/obj/item/robot_suit/wrench_act(mob/living/user, obj/item/I) //Deconstucts empty borg shell. Flashes remain unbroken because they haven't been used yet
	var/turf/T = get_turf(src)
	if(l_leg || r_leg || chest || l_arm || r_arm || head)
		if(I.use_tool(src, user, 5, volume=50))
			if(l_leg)
				l_leg.forceMove(T)
				l_leg = null
			if(r_leg)
				r_leg.forceMove(T)
				r_leg = null
			if(chest)
				if (chest.cell) //Sanity check.
					chest.cell.forceMove(T)
					chest.cell = null
				chest.forceMove(T)
				new /obj/item/stack/cable_coil(T, 1)
				chest.wired = FALSE
				chest = null
			if(l_arm)
				l_arm.forceMove(T)
				l_arm = null
			if(r_arm)
				r_arm.forceMove(T)
				r_arm = null
			if(head)
				head.forceMove(T)
				head.flash1.forceMove(T)
				head.flash1 = null
				head.flash2.forceMove(T)
				head.flash2 = null
				head = null
			to_chat(user, span_notice("You disassemble the cyborg shell."))
	else
		to_chat(user, span_notice("There is nothing to remove from the endoskeleton."))
	update_appearance(UPDATE_ICON)

/obj/item/robot_suit/proc/put_in_hand_or_drop(mob/living/user, obj/item/I) //normal put_in_hands() drops the item ontop of the player, this drops it at the suit's loc
	if(!user.put_in_hands(I))
		I.forceMove(drop_location())
		return FALSE
	return TRUE

/obj/item/robot_suit/screwdriver_act(mob/living/user, obj/item/I) //Swaps the power cell if you're holding a new one in your other hand.
	. = ..()
	if(.)
		return TRUE

	if(!chest) //can't remove a cell if there's no chest to remove it from.
		to_chat(user, span_notice("[src] has no attached torso."))
		return

	var/obj/item/stock_parts/cell/temp_cell = user.is_holding_item_of_type(/obj/item/stock_parts/cell)
	var/swap_failed
	if(!temp_cell) //if we're not holding a cell
		swap_failed = TRUE
	else if(!user.transferItemToLoc(temp_cell, chest))
		swap_failed = TRUE
		to_chat(user, span_warning("[temp_cell] is stuck to your hand, you can't put it in [src]!"))

	if(chest.cell) //drop the chest's current cell no matter what.
		put_in_hand_or_drop(user, chest.cell)

	if(swap_failed) //we didn't transfer any new items.
		if(chest.cell) //old cell ejected, nothing inserted.
			to_chat(user, span_notice("You remove [chest.cell] from [src]."))
			chest.cell = null
		else
			to_chat(user, span_notice("The power cell slot in [src]'s torso is empty."))
		return

	to_chat(user, span_notice("You [chest.cell ? "replace [src]'s [chest.cell.name] with [temp_cell]" : "insert [temp_cell] into [src]"]."))
	chest.cell = temp_cell
	return TRUE

/obj/item/robot_suit/attackby(obj/item/W, mob/user, params)

	if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		if(!l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
			if (M.use(1))
				var/obj/item/bot_assembly/ed209/B = new
				B.forceMove(drop_location())
				to_chat(user, span_notice("You arm the robot frame."))
				var/holding_this = user.get_inactive_held_item()==src
				qdel(src)
				if (holding_this)
					user.put_in_inactive_hand(B)
			else
				to_chat(user, span_warning("You need one sheet of metal to start building ED-209!"))
				return
	else if(istype(W, /obj/item/bodypart/leg/left/robot))
		if(l_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		l_leg = W
		update_appearance(UPDATE_ICON)

	else if(istype(W, /obj/item/bodypart/leg/right/robot))
		var/obj/item/bodypart/leg/right/robot/L = W
		if(L.use_digitigrade)
			to_chat(user, span_warning("You can only install plantigrade legs on [src]!"))
			return
		if(src.r_leg)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		r_leg = W
		update_appearance(UPDATE_ICON)

	else if(istype(W, /obj/item/bodypart/l_arm/robot))
		var/obj/item/bodypart/leg/left/robot/L = W
		if(L.use_digitigrade)
			to_chat(user, span_warning("You can only install plantigrade legs on [src]!"))
			return
		if(l_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)
		W.cut_overlays()
		l_arm = W
		update_appearance(UPDATE_ICON)

	else if(istype(W, /obj/item/bodypart/r_arm/robot))
		if(r_arm)
			return
		if(!user.transferItemToLoc(W, src))
			return
		W.icon_state = initial(W.icon_state)//in case it is a dismembered robotic limb
		W.cut_overlays()
		r_arm = W
		update_appearance(UPDATE_ICON)

	else if(istype(W, /obj/item/bodypart/chest/robot))
		var/obj/item/bodypart/chest/robot/CH = W
		if(chest)
			return
		if(CH.wired && CH.cell)
			if(!user.transferItemToLoc(CH, src))
				return
			CH.icon_state = initial(CH.icon_state) //in case it is a dismembered robotic limb
			CH.cut_overlays()
			chest = CH
			update_appearance(UPDATE_ICON)
		else if(!CH.wired)
			to_chat(user, span_warning("You need to attach wires to it first!"))
		else
			to_chat(user, span_warning("You need to attach a cell to it first!"))

	else if(istype(W, /obj/item/bodypart/head/robot))
		var/obj/item/bodypart/head/robot/HD = W
		for(var/X in HD.contents)
			if(istype(X, /obj/item/organ))
				to_chat(user, span_warning("There are organs inside [HD]!"))
				return
		if(head)
			return
		if(HD.flash2 && HD.flash1)
			if(!user.transferItemToLoc(HD, src))
				return
			HD.icon_state = initial(HD.icon_state)//in case it is a dismembered robotic limb
			HD.cut_overlays()
			head = HD
			update_appearance(UPDATE_ICON)
		else
			to_chat(user, span_warning("You need to attach a flash to it first!"))

	else if (W.tool_behaviour == TOOL_MULTITOOL)
		if(check_completion())
			ui_interact(user)
		else
			to_chat(user, span_warning("The endoskeleton must be assembled before debugging can begin!"))

	else if(istype(W, /obj/item/ai_cpu))
		if(check_completion())
			var/response = tgui_alert(user, "Are you sure you want to turn this endoskeleton into a synthetic unit?", "Please Confirm", list("Yes", "No"))
			if(response != "Yes")
				return
			
			if(!user.temporarilyRemoveItemFromInventory(W))
				return
			var/mob/living/carbon/human/O = new /mob/living/carbon/human(get_turf(loc))
			O.set_species(/datum/species/wy_synth)
			O.invisibility = 0
			O.job = "Synthetic"
			var/datum/outfit/job/synthetic/SO = new()
			SO.equip(O)
			W.forceMove(O)
			var/datum/species/wy_synth/S = O.dna.species
			qdel(S.inbuilt_cpu)
			S.inbuilt_cpu = null
			S.inbuilt_cpu = W
			qdel(src)

	else if(istype(W, /obj/item/mmi))
		var/obj/item/mmi/M = W
		if(check_completion())
			if(!chest.cell)
				to_chat(user, span_warning("The endoskeleton still needs a power cell!"))
				return
			if(!isturf(loc))
				to_chat(user, span_warning("You can't put [M] in, the frame has to be standing on the ground to be perfectly precise!"))
				return
			if(!M.brainmob)
				to_chat(user, span_warning("Sticking an empty [M.name] into the frame would sort of defeat the purpose!"))
				return

			var/mob/living/brain/BM = M.brainmob
			if(!BM.key || !BM.mind)
				to_chat(user, span_warning("The MMI indicates that their mind is completely unresponsive; there's no point!"))
				return

			if(!BM.client) //braindead
				to_chat(user, span_warning("The MMI indicates that their mind is currently inactive; it might change!"))
				return

			if(BM.stat == DEAD || BM.suiciding || (M.brain && (M.brain.brain_death || M.brain.suicided)))
				to_chat(user, span_warning("Sticking a dead brain into the frame would sort of defeat the purpose!"))
				return

			if(M.brain?.organ_flags & ORGAN_FAILING)
				to_chat(user, span_warning("The MMI indicates that the brain is damaged!"))
				return

			if(is_banned_from(BM.ckey, "Cyborg") || QDELETED(src) || QDELETED(BM) || QDELETED(user) || QDELETED(M) || !Adjacent(user))
				if(!QDELETED(M))
					to_chat(user, span_warning("This [M.name] does not seem to fit!"))
				return

			if(!user.temporarilyRemoveItemFromInventory(W))
				return

			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(loc))
			if(!O)
				return
			if(user.mind.assigned_role == "Roboticist") // RD gets nothing
				SSachievements.unlock_achievement(/datum/achievement/roboborg, user.client)

			if(M.laws && M.laws.modified && M.override_cyborg_laws)
				aisync = FALSE
				lawsync = FALSE
				O.laws = M.laws
				M.laws.associate(O)

			O.invisibility = 0
			//Transfer debug settings to new mob
			O.custom_name = created_name
			O.locked = panel_locked
			if(!aisync)
				lawsync = FALSE
				O.set_connected_ai(null)
			else
				O.notify_ai(NEW_BORG)
				if(forced_ai)
					O.set_connected_ai(forced_ai)
			if(!lawsync)
				O.lawupdate = 0
				if(!M.laws.modified)
					// Give the non-modified laws which is visible on the MMI.
					O.laws = M.laws
					M.laws.associate(O)
				else if(!M.override_cyborg_laws) // MMI's laws were changed. Do not want to upload them if we say so.
					// Give random default lawset.
					O.make_laws()
					// Obvious warning that their modified laws didn't get passed on.
					to_chat(user, span_warning("Any laws uploaded to this MMI have not been transferred!"))

			SSgamemode.remove_antag_for_borging(BM.mind)
			if(!istype(M.laws, /datum/ai_laws/ratvar))
				remove_servant_of_ratvar(BM, TRUE)

			O.job = "Cyborg"

			O.cell = chest.cell
			chest.cell.forceMove(O)
			chest.cell = null
			W.forceMove(O)//Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
			if(O.mmi) //we delete the mmi created by robot/New()
				qdel(O.mmi)
			O.mmi = W //and give the real mmi to the borg.

			REMOVE_TRAIT(O, TRAIT_PACIFISM, POSIBRAIN_TRAIT) // remove the posibrain's pacifism

			O.updatename(BM.client)

			BM.mind.transfer_to(O)

			if(O.mmi.syndicate_mmi)
				O.syndiemmi_override()
				to_chat(O, span_warning("ALERT: Foreign hardware detected."))
				to_chat(O, span_warning("ERRORERRORERROR"))
				O.show_laws()
			else if(O.mind && O.mind.special_role)
				O.mind.store_memory("As a cyborg, you must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.")
				to_chat(O, span_userdanger("You have been robotized!"))
				to_chat(O, span_danger("You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead."))

			SSblackbox.record_feedback("amount", "cyborg_birth", 1)

			if(!locomotion)
				O.lockcharge = TRUE
				O.update_mobility()
				to_chat(O, span_warning("Error: Servo motors unresponsive."))

			qdel(src)
		else
			to_chat(user, span_warning("The MMI must go in after everything else!"))

	else if(istype(W, /obj/item/borg/upgrade/ai))
		var/obj/item/borg/upgrade/ai/M = W
		if(check_completion())
			if(!isturf(loc))
				to_chat(user, span_warning("You cannot install[M], the frame has to be standing on the ground to be perfectly precise!"))
				return
			if(!user.temporarilyRemoveItemFromInventory(M))
				to_chat(user, span_warning("[M] is stuck to your hand!"))
				return
			qdel(M)
			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot/shell(get_turf(src))

			if(!aisync)
				lawsync = FALSE
				O.set_connected_ai(null)
			else
				if(forced_ai)
					O.set_connected_ai(forced_ai)
				O.notify_ai(AI_SHELL)
			if(!lawsync)
				O.lawupdate = FALSE
				O.make_laws()


			O.cell = chest.cell
			chest.cell.forceMove(O)
			chest.cell = null
			O.locked = panel_locked
			O.job = "Cyborg"
			if(!locomotion)
				O.lockcharge = TRUE
				O.update_mobility()

			qdel(src)

	else if(istype(W, /obj/item/pen))
		to_chat(user, span_warning("You need to use a multitool to name [src]!"))
	else
		return ..()

/obj/item/robot_suit/ui_status(mob/user)
	if(isobserver(user))
		return ..()
	var/obj/item/held_item = user.get_active_held_item()
	if(held_item?.tool_behaviour == TOOL_MULTITOOL)
		return ..()
	to_chat(user, span_warning("You need a multitool to access debug settings!"))
	return UI_CLOSE

/obj/item/robot_suit/ui_state(mob/user)
	return GLOB.physical_state

/obj/item/robot_suit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CyborgBootDebug", "Cyborg Boot Debug")
		ui.open()

/obj/item/robot_suit/ui_data(mob/user)
	var/list/data = list()
	data["designation"] = created_name
	data["locomotion"] = locomotion
	data["panel"] = panel_locked
	data["aisync"] = aisync
	data["master"] = forced_ai ? forced_ai.name : null
	data["lawsync"] = lawsync
	return data

/obj/item/robot_suit/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/living/user = usr

	switch(action)
		if("rename")
			var/new_name = reject_bad_name(html_encode(params["new_name"]), TRUE)
			if(!new_name)
				created_name = ""
				return
			created_name = new_name
			log_game("[key_name(user)] have set \"[new_name]\" as a cyborg shell name at [loc_name(user)]")
			return TRUE
		if("locomotion")
			locomotion = !locomotion
			return TRUE
		if("panel")
			panel_locked = !panel_locked
			return TRUE
		if("aisync")
			aisync = !aisync
			return TRUE
		if("set_ai")
			var/selected_ai = select_active_ai(user, z)
			if(!in_range(src, user) && loc != user)
				return
			if(!selected_ai)
				to_chat(user, span_alert("No active AIs detected."))
				return
			forced_ai = selected_ai
			return TRUE
		if("lawsync")
			lawsync = !lawsync
			return TRUE
