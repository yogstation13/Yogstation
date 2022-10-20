//backpack item
#define HALFWAYCRITDEATH ((HEALTH_THRESHOLD_CRIT + HEALTH_THRESHOLD_DEAD) * 0.5)

/obj/item/defibrillator
	name = "defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibunit"
	item_state = "defibunit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	actions_types = list(/datum/action/item_action/toggle_paddles)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)

	var/on = FALSE //if the paddles are equipped (1) or on the defib (0)
	var/safety = TRUE //if you can zap people with the defibs on harm mode
	var/powered = FALSE //if there's a cell in the defib with enough power for a revive, blocks paddles from reviving otherwise
	var/obj/item/twohanded/shockpaddles/paddles
	var/obj/item/stock_parts/cell/high/cell
	var/combat = FALSE //can we revive through space suits?
	var/grab_ghost = TRUE // Do we pull the ghost back into their body?

/obj/item/defibrillator/get_cell()
	return cell

/obj/item/defibrillator/Initialize() //starts without a cell for rnd
	. = ..()
	paddles = make_paddles()
	update_icon()
	return

/obj/item/defibrillator/loaded/Initialize() //starts with hicap
	. = ..()
	paddles = make_paddles()
	cell = new(src)
	update_icon()
	return

/obj/item/defibrillator/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if(paddles?.loc == src)
		paddles.fire_act(exposed_temperature, exposed_volume)

/obj/item/defibrillator/extinguish()
	. = ..()
	if(paddles?.loc == src)
		paddles.extinguish()

/obj/item/defibrillator/update_icon()
	update_power()
	update_overlays()
	update_charge()

/obj/item/defibrillator/proc/update_power()
	if(!QDELETED(cell))
		if(QDELETED(paddles) || cell.charge < paddles.revivecost)
			powered = FALSE
		else
			powered = TRUE
	else
		powered = FALSE

/obj/item/defibrillator/proc/update_overlays()
	cut_overlays()
	if(!on)
		add_overlay("[initial(icon_state)]-paddles")
	if(powered)
		add_overlay("[initial(icon_state)]-powered")
	if(!cell)
		add_overlay("[initial(icon_state)]-nocell")
	if(!safety)
		add_overlay("[initial(icon_state)]-emagged")

/obj/item/defibrillator/proc/update_charge()
	if(powered) //so it doesn't show charge if it's unpowered
		if(!QDELETED(cell))
			var/ratio = cell.charge / cell.maxcharge
			ratio = CEILING(ratio*4, 1) * 25
			add_overlay("[initial(icon_state)]-charge[ratio]")

/obj/item/defibrillator/CheckParts(list/parts_list)
	..()
	cell = locate(/obj/item/stock_parts/cell) in contents
	update_icon()

/obj/item/defibrillator/ui_action_click()
	toggle_paddles()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/defibrillator/attack_hand(mob/user)
	if(loc == user)
		if(slot_flags == ITEM_SLOT_BACK)
			if(user.get_item_by_slot(SLOT_BACK) == src)
				ui_action_click()
			else
				to_chat(user, span_warning("Put the defibrillator on your back first!"))

		else if(slot_flags == ITEM_SLOT_BELT)
			if(user.get_item_by_slot(SLOT_BELT) == src)
				ui_action_click()
			else
				to_chat(user, span_warning("Strap the defibrillator's belt on first!"))
		return
	else if(istype(loc, /obj/machinery/defibrillator_mount))
		ui_action_click() //checks for this are handled in defibrillator.mount.dm
	return ..()

/obj/item/defibrillator/MouseDrop(obj/over_object)
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		if(!M.incapacitated() && istype(over_object, /obj/screen/inventory/hand))
			var/obj/screen/inventory/hand/H = over_object
			M.putItemFromInventoryInHandIfPossible(src, H.held_index)

/obj/item/defibrillator/attackby(obj/item/W, mob/user, params)
	if(W == paddles)
		paddles.unwield()
		toggle_paddles()
	else if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, span_notice("[src] already has a cell."))
		else
			if(C.maxcharge < paddles.revivecost)
				to_chat(user, span_notice("[src] requires a higher capacity cell."))
				return
			if(!user.transferItemToLoc(W, src))
				return
			cell = W
			to_chat(user, span_notice("You install a cell in [src]."))
			update_icon()

	else if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(cell)
			cell.update_icon()
			cell.forceMove(get_turf(src))
			cell = null
			to_chat(user, span_notice("You remove the cell from [src]."))
			update_icon()
	else
		return ..()

/obj/item/defibrillator/emag_act(mob/user)
	if(safety)
		safety = FALSE
		to_chat(user, span_warning("You silently disable [src]'s safety protocols with the cryptographic sequencer."))
	else
		safety = TRUE
		to_chat(user, span_notice("You silently enable [src]'s safety protocols with the cryptographic sequencer."))

/obj/item/defibrillator/emp_act(severity)
	. = ..()
	
	if(cell && !(. & EMP_PROTECT_CONTENTS))
		deductcharge(5000 / severity)
		
	if (. & EMP_PROTECT_SELF)
		return
		
	if(!safety)
		safety = TRUE
		visible_message(span_notice("[src] beeps: Safety protocols enabled!"))
		playsound(src, 'sound/machines/defib_saftyOn.ogg', 50, 0)
	else
		visible_message(span_notice("[src] buzzes: Surge detected!"))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
	update_icon()

/obj/item/defibrillator/proc/toggle_paddles()
	set name = "Toggle Paddles"
	set category = "Object"
	on = !on

	var/mob/living/carbon/user = usr
	if(on)
		//Detach the paddles into the user's hands
		if(!usr.put_in_hands(paddles))
			on = FALSE
			to_chat(user, span_warning("You need a free hand to hold the paddles!"))
			update_icon()
			return
	else
		//Remove from their hands and back onto the defib unit
		paddles.unwield()
		remove_paddles(user)

	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/defibrillator/proc/make_paddles()
	return new /obj/item/twohanded/shockpaddles(src)

/obj/item/defibrillator/equipped(mob/user, slot)
	..()
	if((slot_flags == ITEM_SLOT_BACK && slot != SLOT_BACK) || (slot_flags == ITEM_SLOT_BELT && slot != SLOT_BELT))
		remove_paddles(user)
		update_icon()

/obj/item/defibrillator/item_action_slot_check(slot, mob/user)
	if(slot == user.getBackSlot())
		return 1

/obj/item/defibrillator/proc/remove_paddles(mob/user) //this fox the bug with the paddles when other player stole you the defib when you have the paddles equiped
	if(ismob(paddles.loc))
		var/mob/M = paddles.loc
		M.dropItemToGround(paddles, TRUE)
	return

/obj/item/defibrillator/Destroy()
	if(on)
		var/M = get(paddles, /mob)
		remove_paddles(M)
	QDEL_NULL(paddles)
	. = ..()
	update_icon()

/obj/item/defibrillator/proc/deductcharge(chrgdeductamt)
	if(cell)
		if(cell.charge < (paddles.revivecost+chrgdeductamt))
			powered = FALSE
			update_icon()
		if(cell.use(chrgdeductamt))
			update_icon()
			return TRUE
		else
			update_icon()
			return FALSE

/obj/item/defibrillator/proc/cooldowncheck(mob/user)
	spawn(50)
		if(cell)
			if(cell.charge >= paddles.revivecost)
				user.visible_message(span_notice("[src] beeps: Unit ready."))
				playsound(src, 'sound/machines/defib_ready.ogg', 50, 0)
			else
				user.visible_message(span_notice("[src] beeps: Charge depleted."))
				playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		paddles.cooldown = FALSE
		paddles.update_icon()
		update_icon()

/obj/item/defibrillator/compact
	name = "compact defibrillator"
	desc = "A belt-equipped defibrillator that can be rapidly deployed."
	icon_state = "defibcompact"
	item_state = "defibcompact"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	cryo_preserve = TRUE

/obj/item/defibrillator/compact/item_action_slot_check(slot, mob/user)
	if(slot == user.getBeltSlot())
		return TRUE

/obj/item/defibrillator/compact/loaded/Initialize()
	. = ..()
	paddles = make_paddles()
	cell = new(src)
	update_icon()

/obj/item/defibrillator/compact/combat
	name = "combat defibrillator"
	desc = "A belt-equipped blood-red defibrillator that can be rapidly deployed. Does not have the restrictions or safeties of conventional defibrillators and can revive through space suits."
	combat = TRUE
	safety = FALSE

/obj/item/defibrillator/compact/combat/loaded/Initialize()
	. = ..()
	paddles = make_paddles()
	cell = new /obj/item/stock_parts/cell/infinite(src)
	update_icon()

/obj/item/defibrillator/compact/combat/loaded/attackby(obj/item/W, mob/user, params)
	if(W == paddles)
		paddles.unwield()
		toggle_paddles()
		update_icon()
		return

//paddles

/obj/item/twohanded/shockpaddles
	name = "defibrillator paddles"
	desc = "A pair of plastic-gripped paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon = 'icons/obj/defib.dmi'
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

	force = 0
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = INDESTRUCTIBLE

	var/revivecost = 1000
	var/cooldown = FALSE
	var/busy = FALSE
	var/obj/item/defibrillator/defib
	var/req_defib = TRUE
	var/combat = FALSE //If it penetrates armor and gives additional functionality
	var/grab_ghost = TRUE
	var/tlimit = DEFIB_TIME_LIMIT

	var/mob/listeningTo

/obj/item/twohanded/shockpaddles/equipped(mob/user, slot)
	. = ..()
	if(!req_defib || listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/check_range)
	listeningTo = user

/obj/item/twohanded/shockpaddles/Moved()
	. = ..()
	check_range()


/obj/item/twohanded/shockpaddles/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	if((req_defib && defib) && loc != defib)
		defib.fire_act(exposed_temperature, exposed_volume)

/obj/item/twohanded/shockpaddles/proc/check_range()
	if(!req_defib)
		return
	if(!in_range(src,defib))
		var/mob/living/L = loc
		if(istype(L))
			to_chat(L, span_warning("[defib]'s paddles overextend and come out of your hands!"))
			L.temporarilyRemoveItemFromInventory(src,TRUE)
		else
			visible_message(span_notice("[src] snap back into [defib]."))
			snap_back()

/obj/item/twohanded/shockpaddles/proc/recharge(var/time)
	if(req_defib || !time)
		return
	cooldown = TRUE
	update_icon()
	sleep(time)
	var/turf/T = get_turf(src)
	T.audible_message(span_notice("[src] beeps: Unit is recharged."))
	playsound(src, 'sound/machines/defib_ready.ogg', 50, 0)
	cooldown = FALSE
	update_icon()

/obj/item/twohanded/shockpaddles/New(mainunit)
	..()
	if(check_defib_exists(mainunit, src) && req_defib)
		defib = mainunit
		forceMove(defib)
		busy = FALSE
		update_icon()

/obj/item/twohanded/shockpaddles/update_icon()
	icon_state = "defibpaddles[wielded]"
	item_state = "defibpaddles[wielded]"
	if(cooldown)
		icon_state = "defibpaddles[wielded]_cooldown"
	if(iscarbon(loc))
		var/mob/living/carbon/C = loc
		C.update_inv_hands()

/obj/item/twohanded/shockpaddles/suicide_act(mob/user)
	if(req_defib && !defib.deductcharge(revivecost))
		user.visible_message(span_danger("[user] is putting the paddles on [user.p_their()] chest but it has no charge!"))
		return SHAME
	user.visible_message(span_danger("[user] is putting the live paddles on [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/machines/defib_zap.ogg', 50, 1, -1)
	return OXYLOSS

/obj/item/twohanded/shockpaddles/dropped(mob/user)
	if(!req_defib)
		return ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	if(user)
		var/obj/item/twohanded/offhand/O = user.get_inactive_held_item()
		if(istype(O))
			O.unwield()
		to_chat(user, span_notice("The paddles snap back into the main unit."))
		snap_back()
	return unwield(user)

/obj/item/twohanded/shockpaddles/proc/snap_back()
	if(!defib)
		return
	defib.on = FALSE
	forceMove(defib)
	defib.update_icon()

/obj/item/twohanded/shockpaddles/proc/check_defib_exists(mainunit, mob/living/carbon/M, obj/O)
	if(!req_defib)
		return TRUE //If it doesn't need a defib, just say it exists
	if (!mainunit || !istype(mainunit, /obj/item/defibrillator))	//To avoid weird issues from admin spawns
		qdel(O)
		return FALSE
	else
		return TRUE

/obj/item/twohanded/shockpaddles/attack(mob/M, mob/user)

	if(busy)
		return
	if(req_defib && !defib.powered)
		user.visible_message(span_notice("[defib] beeps: Unit is unpowered."))
		playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
		return
	if(!wielded)
		if(iscyborg(user))
			to_chat(user, span_warning("You must activate the paddles in your active module before you can use them on someone!"))
		else
			to_chat(user, span_warning("You need to wield the paddles in both hands before you can use them on someone!"))
		return
	if(cooldown)
		if(req_defib)
			to_chat(user, span_warning("[defib] is recharging!"))
		else
			to_chat(user, span_warning("[src] are recharging!"))
		return

	if(user.a_intent == INTENT_DISARM)
		do_disarm(M, user)
		return

	if(!iscarbon(M))
		if(req_defib)
			to_chat(user, span_warning("The instructions on [defib] don't mention how to revive that..."))
		else
			to_chat(user, span_warning("You aren't sure how to revive that..."))
		return
	var/mob/living/carbon/H = M


	if(user.zone_selected != BODY_ZONE_CHEST)
		to_chat(user, span_warning("You need to target your patient's chest with [src]!"))
		return

	if(user.a_intent == INTENT_HARM)
		do_harm(H, user)
		return

	if((!req_defib && grab_ghost) || (req_defib && defib.grab_ghost))
		H.notify_ghost_cloning("Your heart is being defibrillated!")
		H.grab_ghost() // Shove them back in their body.
	else if(H.can_defib(FALSE))
		H.notify_ghost_cloning("Your heart is being defibrillated. Re-enter your corpse if you want to be revived!", source = src)
	do_help(H, user)

/obj/item/twohanded/shockpaddles/proc/shock_touching(dmg, mob/H)
	if(isliving(H.pulledby))		//CLEAR!
		var/mob/living/M = H.pulledby
		if(M.electrocute_act(30, src))
			M.visible_message(span_danger("[M] is electrocuted by [M.p_their()] contact with [H]!"))
			M.emote("scream")

/obj/item/twohanded/shockpaddles/proc/do_disarm(mob/living/M, mob/living/user)
	if(req_defib && defib.safety)
		return
	if(!req_defib && !combat)
		return
	busy = TRUE
	M.visible_message(span_danger("[user] has touched [M] with [src]!"), \
			span_userdanger("[user] has touched [M] with [src]!"))
	M.adjustStaminaLoss(50)
	M.Paralyze(100)
	M.updatehealth() //forces health update before next life tick //isn't this done by adjustStaminaLoss anyway?
	playsound(src,  'sound/machines/defib_zap.ogg', 50, 1, -1)
	M.emote("gasp")
	log_combat(user, M, "stunned", src)
	if(req_defib)
		defib.deductcharge(revivecost)
		cooldown = TRUE
	busy = FALSE
	update_icon()
	if(req_defib)
		defib.cooldowncheck(user)
	else
		recharge(6 SECONDS)

/obj/item/twohanded/shockpaddles/proc/do_harm(mob/living/carbon/H, mob/living/user)
	if(req_defib && defib.safety)
		return
	if(!req_defib && !combat)
		return
	user.visible_message(span_warning("[user] begins to place [src] on [H]'s chest."),
		span_warning("You overcharge the paddles and begin to place them onto [H]'s chest..."))
	busy = TRUE
	update_icon()
	if(do_after(user, 3 SECONDS, H))
		user.visible_message(span_notice("[user] places [src] on [H]'s chest."),
			span_warning("You place [src] on [H]'s chest and begin to charge them."))
		var/turf/T = get_turf(defib)
		playsound(src, 'sound/machines/defib_charge.ogg', 50, 0)
		if(req_defib)
			T.audible_message(span_warning("\The [defib] lets out an urgent beep and lets out a steadily rising hum..."))
		else
			user.audible_message(span_warning("[src] let out an urgent beep."))
		if(do_after(user, 3 SECONDS, H)) //Takes longer due to overcharging
			if(!H)
				busy = FALSE
				update_icon()
				return
			if(H && H.stat == DEAD)
				to_chat(user, span_warning("[H] is dead."))
				playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
				busy = FALSE
				update_icon()
				return
			user.visible_message(span_boldannounce("<i>[user] shocks [H] with \the [src]!"), span_warning("You shock [H] with \the [src]!"))
			playsound(src, 'sound/machines/defib_zap.ogg', 100, 1, -1)
			playsound(src, 'sound/weapons/egloves.ogg', 100, 1, -1)
			H.emote("scream")
			shock_touching(45, H)
			if(H.can_heartattack() && !H.undergoing_cardiac_arrest())
				if(!H.stat)
					H.visible_message(span_warning("[H] thrashes wildly, clutching at [H.p_their()] chest!"),
						span_userdanger("You feel a horrible agony in your chest!"))
				H.set_heartattack(TRUE)
			H.apply_damage(50, BURN, BODY_ZONE_CHEST)
			log_combat(user, H, "overloaded the heart of", defib)
			H.Paralyze(100)
			H.Jitter(100)
			if(req_defib)
				defib.deductcharge(revivecost)
				cooldown = TRUE
			busy = FALSE
			update_icon()
			if(!req_defib)
				recharge(6 SECONDS)
			if(req_defib && (defib.cooldowncheck(user)))
				return
	busy = FALSE
	update_icon()

/obj/item/twohanded/shockpaddles/proc/do_help(mob/living/carbon/H, mob/living/user)
	user.visible_message(span_warning("[user] begins to place [src] on [H]'s chest."), span_warning("You begin to place [src] on [H]'s chest..."))
	busy = TRUE
	update_icon()
	if(do_after(user, 3 SECONDS, H)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
		user.visible_message(span_notice("[user] places [src] on [H]'s chest."), span_warning("You place [src] on [H]'s chest."))
		playsound(src, 'sound/machines/defib_charge.ogg', 75, 0)
		var/total_burn	= 0
		var/total_brute	= 0
		var/tplus = world.time - H.timeofdeath	//length of time spent dead
		var/obj/item/organ/heart = H.getorgan(/obj/item/organ/heart)
		if(do_after(user, 1.5 SECONDS, H))
			if(user.job == "Medical Doctor" || user.job == "Paramedic" || user.job == "Chief Medical Officer")
				user.say("Clear!", forced = "defib")
		if(do_after(user, 0.5 SECONDS, H)) //Counting the delay for "Clear", revive time is 5sec total
			for(var/obj/item/carried_item in H.contents)
				if(istype(carried_item, /obj/item/clothing/suit/space))
					if((!combat && !req_defib) || (req_defib && !defib.combat))
						user.audible_message(span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Patient's chest is obscured. Operation aborted."))
						playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
						busy = FALSE
						update_icon()
						return
			if(H.stat == DEAD)
				H.visible_message(span_warning("[H]'s body convulses a bit."))
				playsound(src, "bodyfall", 50, 1)
				playsound(src, 'sound/machines/defib_zap.ogg', 75, 1, -1)
				total_brute	= H.getBruteLoss()
				total_burn	= H.getFireLoss()
				shock_touching(30, H)
				var/failed

				if (H.suiciding)
					failed = span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Recovery of patient impossible. Further attempts futile.")
				else if (H.hellbound)
					failed = span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Patient's soul unrecoverable.  Further attempts futile.")
				else if(total_burn >= MAX_REVIVE_FIRE_DAMAGE || total_brute >= MAX_REVIVE_BRUTE_DAMAGE)
					failed = span_boldnotice("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Severe tissue damage makes recovery of patient impossible via defibrillator. Surgical repair may allow for successful resuscitation.")
				else if(HAS_TRAIT(H, TRAIT_HUSK))
					failed = span_boldnotice("[req_defib ? "[defib]" : "[src]"] buzzes: Restucitation failed - Lack of important fluids has rendered the patient body unsurvivable. Application of experimental DNA recovery surgery or an upgraded cloner recommended.") 
				else if(H.get_ghost())
					failed = span_boldnotice("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - No activity in patient's brain. Further attempts may be successful.")
				else if (HAS_TRAIT(H, TRAIT_NODEFIB))
					failed = span_boldnotice("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Biology incompatiable.")
				else if (tplus > tlimit)
					failed = span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Body has decayed for too long. Further attempts futile.")
				else if (!heart)
					failed = span_boldnotice("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Patient's heart is missing. A replacement may allow for successful resuscitation.")
				else if (heart.organ_flags & ORGAN_FAILING)
					failed = span_boldnotice("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Patient's heart too damaged. A coronary bypass or replacement may allow for successful resuscitation.")
				else
					var/obj/item/organ/brain/BR = H.getorgan(/obj/item/organ/brain)
					if(BR)
						if(BR.organ_flags & ORGAN_FAILING)
							failed = span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Patient's brain tissue is damaged making recovery of patient impossible via defibrillator. Brain repair may result in successful defibrillation.")
						if(BR.brain_death)
							failed = span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Patient's brain damaged beyond point of no return. Brain repair may result in successful defibrillation.")
						if(BR.suicided || BR.brainmob?.suiciding)
							failed = span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - No intelligence pattern can be detected in patient's brain. Further attempts futile.")
					else
						failed = span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed - Patient's brain is missing. Further attempts futile.")

				if(failed)
					user.visible_message(failed)
					playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
				else
					//If the body has been fixed so that they would not be in crit when defibbed, give them oxyloss to put them back into crit
					if (H.health > HALFWAYCRITDEATH)
						H.adjustOxyLoss(H.health - HALFWAYCRITDEATH, 0)
					else
						var/overall_damage = total_brute + total_burn + H.getToxLoss() + H.getOxyLoss()
						var/mobhealth = H.health
						H.adjustOxyLoss((mobhealth - HALFWAYCRITDEATH) * (H.getOxyLoss() / overall_damage), 0)
						H.adjustToxLoss((mobhealth - HALFWAYCRITDEATH) * (H.getToxLoss() / overall_damage), 0)
						H.adjustFireLoss((mobhealth - HALFWAYCRITDEATH) * (total_burn / overall_damage), 0, required_status = BODYPART_ANY)
						H.adjustBruteLoss((mobhealth - HALFWAYCRITDEATH) * (total_brute / overall_damage), 0, required_status = BODYPART_ANY)
					H.updatehealth() // Previous "adjust" procs don't update health, so we do it manually.
					user.visible_message(span_notice("[req_defib ? "[defib]" : "[src]"] pings: Resuscitation successful."))
					SSachievements.unlock_achievement(/datum/achievement/defib, user.client)
					playsound(src, 'sound/machines/defib_success.ogg', 50, 0)
					H.set_heartattack(FALSE)
					H.revive()
					H.emote("gasp")
					H.Jitter(100)
					SEND_SIGNAL(H, COMSIG_LIVING_MINOR_SHOCK)
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "saved_life", /datum/mood_event/saved_life)
					log_combat(user, H, "revived", defib)
				if(req_defib)
					defib.deductcharge(revivecost)
					cooldown = 1
				update_icon()
				if(req_defib)
					defib.cooldowncheck(user)
				else
					recharge(6 SECONDS)
			else if (!H.getorgan(/obj/item/organ/heart))
				user.visible_message(span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Patient's heart is missing. Operation aborted."))
				playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
			else if(H.undergoing_cardiac_arrest())
				playsound(src, 'sound/machines/defib_zap.ogg', 50, 1, -1)
				if(!(heart.organ_flags & ORGAN_FAILING))
					H.set_heartattack(FALSE)
					user.visible_message(span_notice("[req_defib ? "[defib]" : "[src]"] pings: Patient's heart is now beating again."))
				else
					user.visible_message(span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Resuscitation failed, heart damage detected."))

			else
				user.visible_message(span_warning("[req_defib ? "[defib]" : "[src]"] buzzes: Patient is not in a valid state. Operation aborted."))
				playsound(src, 'sound/machines/defib_failed.ogg', 50, 0)
	busy = FALSE
	update_icon()

/obj/item/twohanded/shockpaddles/cyborg
	name = "cyborg defibrillator paddles"
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	req_defib = FALSE

/obj/item/twohanded/shockpaddles/cyborg/attack(mob/M, mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(R.emagged)
			combat = TRUE
		else
			combat = FALSE
	else
		combat = FALSE

	. = ..()

/obj/item/twohanded/shockpaddles/syndicate
	name = "syndicate defibrillator paddles"
	desc = "A pair of paddles used to revive deceased operatives. It possesses both the ability to penetrate armor and to deliver powerful shocks offensively."
	combat = TRUE
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	req_defib = FALSE

#undef HALFWAYCRITDEATH
