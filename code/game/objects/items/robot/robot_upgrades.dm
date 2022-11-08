// robot_upgrades.dm
// Contains various borg upgrades.
#define EXPANDER_MAXIMUM_STACK 2


/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	var/locked = FALSE
	var/installed = 0
	var/require_module = 0
	var/module_type = null
	// if true, is not stored in the robot to be ejected
	// if module is reset
	var/one_use = FALSE
	///	Bitflags listing module compatibility. Used in the exosuit fabricator for creating sub-categories.
	var/list/module_flags = NONE

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/R, user = usr)
	if(R.stat == DEAD)
		to_chat(user, span_notice("[src] will not function on a deceased cyborg."))
		return FALSE
	if(module_type && !istype(R.module, module_type))
		to_chat(R, "Upgrade mounting error!  No suitable hardpoint detected!")
		to_chat(user, "There's no mounting point for the module!")
		return FALSE
	return TRUE

/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/R, user = usr)
	if (!(src in R.upgrades))
		return FALSE
	return TRUE

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	var/heldname = ""
	one_use = TRUE

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	heldname = stripped_input(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN)

/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		log_game("[key_name(user)] renamed [key_name(R)] to [heldname]")
		var/oldname = R.real_name
		R.custom_name = heldname
		R.updatename()
		if(oldname != R.real_name)
			R.notify_ai(RENAME, oldname, R.real_name)

/obj/item/borg/upgrade/restart
	name = "cyborg emergency reboot module"
	desc = "Used to force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon_state = "cyborg_upgrade1"
	one_use = TRUE

/obj/item/borg/upgrade/restart/action(mob/living/silicon/robot/R, user = usr)
	if(R.health < 0)
		to_chat(user, span_warning("You have to repair the cyborg before using this module!"))
		return FALSE

	if(R.mind)
		R.mind.grab_ghost()
		playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)

	R.revive()
	R.logevent("WARN -- System recovered from unexpected shutdown.")
	R.logevent("System brought online.")

/obj/item/borg/upgrade/panel_access_remover
	name = "cyborg firmware hack"
	desc = "Used to override the default firmware of a cyborg and disable panel access restrictions."
	icon_state = "cyborg_upgrade2"
	one_use = TRUE

/obj/item/borg/upgrade/panel_access_remover/action(mob/living/silicon/robot/R, user = usr)
	R.req_access = list()
	return TRUE //Makes sure we delete the upgrade since it's one_use

/obj/item/borg/upgrade/panel_access_remover/freeminer
	name = "free miner cyborg firmware hack"
	desc = "Used to override the default firmware of a cyborg with the freeminer version."
	icon_state = "cyborg_upgrade2"

/obj/item/borg/upgrade/panel_access_remover/freeminer/action(mob/living/silicon/robot/R, user = usr)
	R.req_access = list(ACCESS_FREEMINER_ENGINEER)
	new /obj/item/borg/upgrade/panel_access_remover/freeminer(R.drop_location())
	//This deletes the upgrade which is why we create a new one. This prevents the message "Upgrade Error" without a adding a once-used variable to every board
	return TRUE

/obj/item/borg/upgrade/vtec
	name = "cyborg VTEC module"
	desc = "Used to kick in a cyborg's VTEC systems, increasing their speed."
	icon_state = "cyborg_upgrade2"
	require_module = 1
	var/vtecequip = 0

/obj/item/borg/upgrade/vtec/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.has_movespeed_modifier("VTEC"))
			to_chat(R, span_notice("A VTEC unit is already installed!"))
			to_chat(user, span_notice("There's no room for another VTEC unit!"))
			return FALSE

		R.add_movespeed_modifier("VTEC", update=TRUE, priority=100, multiplicative_slowdown=-1, blacklisted_movetypes=(FLYING|FLOATING))

/obj/item/borg/upgrade/vtec/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.remove_movespeed_modifier("VTEC")

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
//	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	desc = "It used to give unspeakable power to security modules. Now it rests; broken, abandoned."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/security
	module_flags = BORG_MODULE_SECURITY

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
		if(!T)
			to_chat(user, span_notice("There's no disabler in this unit!"))
			return FALSE
		if(T.charge_delay <= 2)
			to_chat(R, span_notice("A cooling unit is already installed!"))
			to_chat(user, span_notice("There's no room for another cooling unit!"))
			return FALSE

		T.charge_delay = max(2 , T.charge_delay - 4)

/obj/item/borg/upgrade/disablercooler/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in R.module.modules
		if(!T)
			return FALSE
		T.charge_delay = initial(T.charge_delay)

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.ionpulse)
			to_chat(user, span_notice("This unit already has ion thrusters installed!"))
			return FALSE

		R.ionpulse = TRUE
		R.toggle_ionpulse() //Enabled by default

/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.ionpulse = FALSE

/obj/item/borg/upgrade/language
	name = "translation matrix upgrade"
	desc = "Increases the translation matrix to include all xeno languages"
	icon_state = "cyborg_upgrade2"
	var/list/languages = list(
		/datum/language/bonespeak,
		/datum/language/draconic,
		/datum/language/english,
		/datum/language/etherean,
		/datum/language/felinid,
		/datum/language/mothian,
		/datum/language/polysmorph,
		/datum/language/sylvan
	)

/obj/item/borg/upgrade/language/expanded
	name = "advanced translation matrix upgrade"
	desc = "Increases the translation matrix to include an even wider variety in langauges"
	languages = list(
		/datum/language/bonespeak,
		/datum/language/draconic,
		/datum/language/english,
		/datum/language/etherean,
		/datum/language/felinid,
		/datum/language/mothian,
		/datum/language/polysmorph,
		/datum/language/sylvan,
		/datum/language/aphasia,
		/datum/language/beachbum,
		/datum/language/egg,
		/datum/language/monkey,
		/datum/language/mouse,
		/datum/language/mushroom,
		/datum/language/slime
	)

/obj/item/borg/upgrade/language/omni
	name = "universal translation matrix upgrade"
	desc = "Allow the translation matrix to handle any language"
	languages = list()

/obj/item/borg/upgrade/language/omni/Initialize(mapload)
	. = ..()
	languages = subtypesof(/datum/language)

/obj/item/borg/upgrade/language/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/datum/language/lang as anything in languages)
			R.grant_language(lang, TRUE, TRUE, LANGUAGE_SOFTWARE)

/obj/item/borg/upgrade/language/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.remove_all_languages(LANGUAGE_SOFTWARE)

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining module's standard drill."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/miner
	module_flags = BORG_MODULE_MINER

/obj/item/borg/upgrade/ddrill/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/pickaxe/drill/cyborg/D in R.module)
			R.module.remove_module(D, TRUE)
		for(var/obj/item/shovel/S in R.module)
			R.module.remove_module(S, TRUE)

		var/obj/item/pickaxe/drill/cyborg/diamond/DD = new /obj/item/pickaxe/drill/cyborg/diamond(R.module)
		R.module.basic_modules += DD
		R.module.add_module(DD, FALSE, TRUE)

/obj/item/borg/upgrade/ddrill/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/pickaxe/drill/cyborg/diamond/DD in R.module)
			R.module.remove_module(DD, TRUE)

		var/obj/item/pickaxe/drill/cyborg/D = new (R.module)
		R.module.basic_modules += D
		R.module.add_module(D, FALSE, TRUE)
		var/obj/item/shovel/S = new (R.module)
		R.module.basic_modules += S
		R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/miner
	module_flags = BORG_MODULE_MINER

/obj/item/borg/upgrade/soh/action(mob/living/silicon/robot/R , user = usr) //yogs single line
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/ore/cyborg/S in R.module)
			R.module.remove_module(S, TRUE)

		var/obj/item/storage/bag/ore/holding/H = locate() in R.module.modules  //yogs start
		if(H)
			to_chat(user, span_warning("This unit is already equipped with a satchel of holding."))
			return FALSE

		H = new /obj/item/storage/bag/ore/holding(R.module)  //yogs end
		R.module.basic_modules += H
		R.module.add_module(H, FALSE, TRUE)

/obj/item/borg/upgrade/soh/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/storage/bag/ore/holding/H in R.module)
			R.module.remove_module(H, TRUE)

		var/obj/item/storage/bag/ore/cyborg/S = new (R.module)
		R.module.basic_modules += S
		R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/tboh
	name = "janitor cyborg trash bag of holding"
	desc = "A trash bag of holding replacement for the janiborg's standard trash bag."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/janitor
	module_flags = BORG_MODULE_JANITOR

/obj/item/borg/upgrade/tboh/action(mob/living/silicon/robot/R, user = usr)//yogs single line
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/trash/cyborg/TB in R.module.modules)
			R.module.remove_module(TB, TRUE)

		var/obj/item/storage/bag/trash/bluespace/cyborg/B = locate() in R.module.modules //yogs start
		if(B)
			to_chat(user, span_warning("This unit is already equipped with a trash bag of holding."))
			return FALSE

		B = new /obj/item/storage/bag/trash/bluespace/cyborg(R.module) //yogs end
		R.module.basic_modules += B
		R.module.add_module(B, FALSE, TRUE)

/obj/item/borg/upgrade/tboh/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/storage/bag/trash/bluespace/cyborg/B in R.module.modules)
			R.module.remove_module(B, TRUE)

		var/obj/item/storage/bag/trash/cyborg/TB = new (R.module)
		R.module.basic_modules += TB
		R.module.add_module(TB, FALSE, TRUE)

/obj/item/borg/upgrade/amop
	name = "janitor cyborg advanced mop"
	desc = "An advanced mop replacement for the janiborg's standard mop."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/janitor
	module_flags = BORG_MODULE_JANITOR

/obj/item/borg/upgrade/amop/action(mob/living/silicon/robot/R, user = usr)//yogs single line
	. = ..()
	if(.)
		for(var/obj/item/mop/cyborg/M in R.module.modules)
			R.module.remove_module(M, TRUE)

		var/obj/item/mop/advanced/cyborg/A = locate() in R.module.modules  //yogs start
		if(A)
			to_chat(user, span_warning("This unit is already equipped with a advanced mop module."))
			return FALSE

		A = new /obj/item/mop/advanced/cyborg(R.module)  //yogs end
		R.module.basic_modules += A
		R.module.add_module(A, FALSE, TRUE)

/obj/item/borg/upgrade/amop/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/mop/advanced/cyborg/A in R.module.modules)
			R.module.remove_module(A, TRUE)

		var/obj/item/mop/cyborg/M = new (R.module)
		R.module.basic_modules += M
		R.module.add_module(M, FALSE, TRUE)

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"
	require_module = 1

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.emagged)
			return FALSE

		R.SetEmagged(1)
		R.logevent("WARN: hardware installed with missing security certificate!") //A bit of fluff to hint it was an illegal tech item
		R.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error

		return TRUE

/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.SetEmagged(FALSE)

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof tracks"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to mining cyborg tracks, enabling them to withstand exposure to molten rock."
	icon_state = "ash_plating"
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	require_module = 1
	module_type = /obj/item/robot_module/miner
	module_flags = BORG_MODULE_MINER

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		R.weather_immunities += WEATHER_LAVA

/obj/item/borg/upgrade/lavaproof/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		R.weather_immunities -= WEATHER_LAVA

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "cyborg_upgrade5"
	require_module = 1
	var/repair_amount = -1
	var/repair_tick = 1
	var/msg_cooldown = 0
	var/on = FALSE
	var/powercost = 10
	var/mob/living/silicon/robot/cyborg
	var/datum/action/toggle_action

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/borg/upgrade/selfrepair/U = locate() in R
		if(U)
			to_chat(user, span_warning("This unit is already equipped with a self-repair module."))
			return FALSE

		cyborg = R
		icon_state = "selfrepair_off"
		toggle_action = new /datum/action/item_action/toggle(src)
		toggle_action.Grant(R)

/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		toggle_action.Remove(cyborg)
		QDEL_NULL(toggle_action)
		cyborg = null
		deactivate_sr()

/obj/item/borg/upgrade/selfrepair/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/check_dropped), 1)

/obj/item/borg/upgrade/selfrepair/proc/check_dropped()
	if(loc != cyborg)
		toggle_action.Remove(cyborg)
		QDEL_NULL(toggle_action)
		cyborg = null
		deactivate_sr()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	on = !on
	if(on)
		to_chat(cyborg, span_notice("You activate the self-repair module."))
		START_PROCESSING(SSobj, src)
	else
		to_chat(cyborg, span_notice("You deactivate the self-repair module."))
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/item/borg/upgrade/selfrepair/update_icon()
	if(cyborg)
		icon_state = "selfrepair_[on ? "on" : "off"]"
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
	else
		icon_state = "cyborg_upgrade5"

/obj/item/borg/upgrade/selfrepair/proc/deactivate_sr()
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_icon()

/obj/item/borg/upgrade/selfrepair/process()
	if(!repair_tick)
		repair_tick = 1
		return

	if(cyborg && (cyborg.stat != DEAD) && on)
		if(!cyborg.cell)
			to_chat(cyborg, span_warning("Self-repair module deactivated. Please, insert the power cell."))
			deactivate_sr()
			return

		if(cyborg.cell.charge < powercost * 2)
			to_chat(cyborg, span_warning("Self-repair module deactivated. Please recharge."))
			deactivate_sr()
			return

		if(cyborg.health < cyborg.maxHealth)
			if(cyborg.health < 0)
				repair_amount = -2.5
				powercost = 30
			else
				repair_amount = -1
				powercost = 10
			cyborg.adjustBruteLoss(repair_amount)
			cyborg.adjustFireLoss(repair_amount)
			cyborg.updatehealth()
			cyborg.cell.use(powercost)
		else
			cyborg.cell.use(5)
		repair_tick = 0

		if((world.time - 2000) > msg_cooldown )
			var/msgmode = "standby"
			if(cyborg.health < 0)
				msgmode = "critical"
			else if(cyborg.health < cyborg.maxHealth)
				msgmode = "normal"
			to_chat(cyborg, span_notice("Self-repair is active in [span_boldnotice("[msgmode]")] mode."))
			msg_cooldown = world.time
	else
		deactivate_sr()

/obj/item/borg/upgrade/hypospray
	name = "medical cyborg hypospray advanced synthesiser"
	desc = "An upgrade to the Medical module cyborg's hypospray, allowing it \
		to produce more advanced and complex medical reagents."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/medical
	var/list/additional_reagents = list()
	module_flags = BORG_MODULE_MEDICAL

/obj/item/borg/upgrade/hypospray/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
			if(H.accepts_reagent_upgrades)
				for(var/re in additional_reagents)
					H.add_reagent(re)

/obj/item/borg/upgrade/hypospray/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
			if(H.accepts_reagent_upgrades)
				for(var/re in additional_reagents)
					H.del_reagent(re)

/obj/item/borg/upgrade/hypospray/expanded
	name = "medical cyborg expanded hypospray"
	desc = "An upgrade to the Medical module's hypospray, allowing it \
		to treat a wider range of conditions and problems."
	additional_reagents = list(/datum/reagent/medicine/mannitol, /datum/reagent/medicine/oculine, /datum/reagent/medicine/inacusiate,
		/datum/reagent/medicine/mutadone, /datum/reagent/medicine/haloperidol, /datum/reagent/medicine/oxandrolone, /datum/reagent/medicine/sal_acid, /datum/reagent/medicine/rezadone,
		/datum/reagent/medicine/pen_acid)

/obj/item/borg/upgrade/piercing_hypospray
	name = "cyborg piercing hypospray"
	desc = "An upgrade to a cyborg's hypospray, allowing it to \
		pierce armor and thick material."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/piercing_hypospray/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/found_hypo = FALSE
		for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
			if(H.bypass_protection == TRUE) //yogs start
				to_chat(user, span_warning("This unit is already equipped with a piercing hypospray module."))
				return FALSE  //yogs end

			H.bypass_protection = TRUE
			found_hypo = TRUE

		if(!found_hypo)
			return FALSE

/obj/item/borg/upgrade/piercing_hypospray/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/reagent_containers/borghypo/H in R.module.modules)
			H.bypass_protection = initial(H.bypass_protection)

/obj/item/borg/upgrade/defib
	name = "medical cyborg defibrillator"
	desc = "An upgrade to the Medical module, installing a built-in \
		defibrillator, for on the scene revival."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/medical
	module_flags = BORG_MODULE_MEDICAL

/obj/item/borg/upgrade/defib/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		var/obj/item/twohanded/shockpaddles/cyborg/S = locate() in R.module.modules //yogs start
		if(S)
			to_chat(user, span_warning("This unit is already equipped with a defibrillator module."))
			return FALSE

		S = new(R.module) //yogs end
		R.module.basic_modules += S
		R.module.add_module(S, FALSE, TRUE)

/obj/item/borg/upgrade/defib/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/twohanded/shockpaddles/cyborg/S in R.module.modules)
			R.module.remove_module(S, TRUE)

/obj/item/borg/upgrade/adv_analyzer
	name = "medical cyborg advanced health analyzer"
	desc = "An upgrade to the Medical module, loading a more advanced \
		health analyzer into the holder's module, \
		replacing the old one."
	icon_state = "cyborg_upgrade5"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical
	module_flags = BORG_MODULE_MEDICAL

/obj/item/borg/upgrade/adv_analyzer/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		/// Removes old analyzer
		for(var/obj/item/healthanalyzer/healthanalyzer in R.module.modules)
			R.module.remove_module(healthanalyzer, TRUE)

		var/obj/item/healthanalyzer/advanced/advancedanal = locate() in R.module.modules

		if(advancedanal)
			to_chat(user, span_warning("This unit is already equipped with an advanced health analyzer."))
			return FALSE

		/// Puts in new advanced analyzer
		advancedanal = new(R.module)
		R.module.basic_modules += advancedanal
		R.module.add_module(advancedanal, FALSE, TRUE)

/obj/item/borg/upgrade/adv_analyzer/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		/// Removes new advanced analyzer
		for(var/obj/item/healthanalyzer/advanced/advancedanal in R.module.modules)
			R.module.remove_module(advancedanal, TRUE)

		/// Puts in old analyzer
		var/obj/item/healthanalyzer/healthanalyzer = locate() in R.module.modules
		healthanalyzer = new(R.module)
		R.module.basic_modules += healthanalyzer
		R.module.add_module(healthanalyzer, FALSE, TRUE)

/obj/item/borg/upgrade/surgerykit
	name = "medical cyborg advanced surgical kit"
	desc = "An upgrade to the Medical module, loading a more advanced \
		array of surgical tools into the holder's module, \
		replacing the old ones."
	icon_state = "cyborg_upgrade5"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical
	module_flags = BORG_MODULE_MEDICAL

/obj/item/borg/upgrade/surgerykit/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		/// Removes old surgery tools
		for(var/obj/item/retractor/RT in R.module.modules) // the SC stands for shitcode
			R.module.remove_module(RT, TRUE)

		for(var/obj/item/hemostat/HS in R.module.modules)
			R.module.remove_module(HS, TRUE)

		for(var/obj/item/cautery/CT in R.module.modules)
			R.module.remove_module(CT, TRUE)

		for(var/obj/item/surgicaldrill/SD in R.module.modules)
			R.module.remove_module(SD, TRUE)

		for(var/obj/item/scalpel/SL in R.module.modules)
			R.module.remove_module(SL, TRUE)

		for(var/obj/item/circular_saw/CS in R.module.modules)
			R.module.remove_module(CS, TRUE)

		var/obj/item/scalpel/advanced/LS = locate() in R.module.modules
		var/obj/item/retractor/advanced/MP = locate() in R.module.modules
		var/obj/item/cautery/advanced/ST = locate() in R.module.modules
		if(LS || MP || ST)
			to_chat(user, span_warning("This unit is already equipped with an advanced surgical kit."))
			return FALSE

		/// Puts in new surgery tools
		LS = new(R.module)
		R.module.basic_modules += LS
		R.module.add_module(LS, FALSE, TRUE)

		MP = new(R.module)
		R.module.basic_modules += MP
		R.module.add_module(MP, FALSE, TRUE)

		ST = new(R.module)
		R.module.basic_modules += ST
		R.module.add_module(ST, FALSE, TRUE)

/obj/item/borg/upgrade/surgerykit/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		/// Removes new surgery tools
		for(var/obj/item/scalpel/advanced/SE in R.module.modules)
			R.module.remove_module(SE, TRUE)

		for(var/obj/item/retractor/advanced/RE in R.module.modules)
			R.module.remove_module(RE, TRUE)

		for(var/obj/item/cautery/advanced/CE in R.module.modules)
			R.module.remove_module(CE, TRUE)

		/// Puts in old surgery tools
		var/obj/item/retractor/RT = locate() in R.module.modules
		RT = new(R.module)
		R.module.basic_modules += RT
		R.module.add_module(RT, FALSE, TRUE)

		var/obj/item/hemostat/HS = locate() in R.module.modules
		HS = new(R.module)
		R.module.basic_modules += HS
		R.module.add_module(HS, FALSE, TRUE)

		var/obj/item/cautery/CT = locate() in R.module.modules
		CT = new(R.module)
		R.module.basic_modules += CT
		R.module.add_module(CT, FALSE, TRUE)

		var/obj/item/surgicaldrill/SD = locate() in R.module.modules
		SD = new(R.module)
		R.module.basic_modules += SD
		R.module.add_module(SD, FALSE, TRUE)

		var/obj/item/scalpel/SL = locate() in R.module.modules
		SL = new(R.module)
		R.module.basic_modules += SL
		R.module.add_module(SL, FALSE, TRUE)

		var/obj/item/circular_saw/CS = locate() in R.module.modules
		CS = new(R.module)
		R.module.basic_modules += CS
		R.module.add_module(CS, FALSE, TRUE)

/obj/item/borg/upgrade/ai
	name = "B.O.R.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon_state = "boris"

/obj/item/borg/upgrade/ai/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		if(R.shell)
			to_chat(user, span_warning("This unit is already an AI shell!"))
			return FALSE
		if(R.key) //You cannot replace a player unless the key is completely removed.
			to_chat(user, span_warning("Intelligence patterns detected in this [R.braintype]. Aborting."))
			return FALSE

		R.make_shell(src)

/obj/item/borg/upgrade/ai/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		if(R.shell)
			R.undeploy()
			R.notify_ai(AI_SHELL)

/obj/item/borg/upgrade/expand
	name = "borg expander"
	desc = "A cyborg resizer, it makes a cyborg huge."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/expand/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		if(R.expansion_count >= EXPANDER_MAXIMUM_STACK)
			to_chat(usr, span_notice("This unit has already expanded as much as it can!"))
			return FALSE

		R.notransform = TRUE
		var/prev_lockcharge = R.lockcharge
		R.SetLockdown(1)
		R.anchored = TRUE
		R.expansion_count++
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(1, R.loc)
		smoke.start()
		sleep(0.2 SECONDS)
		for(var/i in 1 to 4)
			playsound(R, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
			sleep(1.2 SECONDS)
		if(!prev_lockcharge)
			R.SetLockdown(0)
		R.anchored = FALSE
		R.notransform = FALSE
		R.resize = 2
		R.update_transform()

/obj/item/borg/upgrade/expand/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		while(R.expansion_count)
			R.resize = 0.5
			R.expansion_count--
			R.update_transform()

/obj/item/borg/upgrade/rped
	name = "engineering cyborg RPED"
	desc = "A rapid part exchange device for the engineering cyborg."
	icon = 'icons/obj/storage.dmi'
	icon_state = "borgrped"
	require_module = TRUE
	module_type = /obj/item/robot_module/engineering
	module_flags = BORG_MODULE_ENGINEERING

/obj/item/borg/upgrade/rped/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		var/obj/item/storage/part_replacer/cyborg/RPED = locate() in R.module.modules
		if(RPED)
			to_chat(user, span_warning("This unit is already equipped with a RPED module."))
			return FALSE

		RPED = new(R.module)
		R.module.basic_modules += RPED
		R.module.add_module(RPED, FALSE, TRUE)

/obj/item/borg/upgrade/rped/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/storage/part_replacer/cyborg/RPED in R.module.modules)
			R.module.remove_module(RPED, TRUE)

/obj/item/borg/upgrade/plasmacutter
	name = "mining cyborg plasma cutter"
	desc = "A plasma cutter module for the mining cyborg."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "adv_plasmacutter"
	require_module = TRUE
	module_type = /obj/item/robot_module/miner
	module_flags = BORG_MODULE_MINER

/obj/item/borg/upgrade/plasmacutter/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		var/obj/item/gun/energy/plasmacutter/adv/cyborg/PC = locate() in R.module.modules
		if(PC)
			to_chat(user, span_warning("This unit is already equipped with a plasma cutter module."))
			return FALSE

		PC = new(R.module)
		R.module.basic_modules += PC
		R.module.add_module(PC, FALSE, TRUE)

/obj/item/borg/upgrade/plasmacutter/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/gun/energy/plasmacutter/adv/cyborg/PC in R.module.modules)
			R.module.remove_module(PC, TRUE)

/obj/item/borg/upgrade/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg."
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer_crew"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical
	module_flags = BORG_MODULE_MEDICAL

/obj/item/borg/upgrade/pinpointer/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)

		var/obj/item/pinpointer/crew/PP = locate() in R.module.modules
		if(PP)
			to_chat(user, span_warning("This unit is already equipped with a pinpointer module."))
			return FALSE

		PP = new(R.module)
		R.module.basic_modules += PP
		R.module.add_module(PP, FALSE, TRUE)

/obj/item/borg/upgrade/pinpointer/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if (.)
		for(var/obj/item/pinpointer/crew/PP in R.module.modules)
			R.module.remove_module(PP, TRUE)

/obj/item/borg/upgrade/transform
	name = "borg module picker (Standard)"
	desc = "Allows you to turn a cyborg into a standard cyborg."
	icon_state = "cyborg_upgrade3"
	var/obj/item/robot_module/new_module = /obj/item/robot_module/standard

/obj/item/borg/upgrade/transform/action(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		R.module.transform_to(new_module)

/obj/item/borg/upgrade/transform/clown
	name = "borg module picker (Clown)"
	desc = "Allows you to turn a cyborg into a clown, honk."
	icon_state = "cyborg_upgrade3"
	new_module = /obj/item/robot_module/clown

/obj/item/borg/upgrade/transform/security
	name = "borg module picker (Security)"
	desc = "Allows you to turn a cyborg into a hunter, HALT!"
	icon_state = "cyborg_upgrade3"
	new_module = /obj/item/robot_module/security

/obj/item/borg/upgrade/transform/security/action(mob/living/silicon/robot/R, user = usr)
	if(CONFIG_GET(flag/disable_secborg))
		to_chat(user, span_warning("Nanotrasen policy disallows the use of weapons of mass destruction."))
		return FALSE
	if(is_banned_from(R.ckey, "Security Officer"))
		to_chat(user, span_warning("Nanotrasen has disallowed this unit from becoming this type of module."))
		return FALSE
	return ..()
