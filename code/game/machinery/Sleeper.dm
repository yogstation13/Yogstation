#define SLEEPER_TEND		"Treat Injuries"
#define SLEEPER_ORGANS		"Repair Organs"
#define SLEEPER_CHEMPURGE	"Purge Toxins"
#define SLEEPER_HEAL_RATE 2

/obj/machinery/sleep_console
	name = "sleeper console"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "console"
	density = FALSE

/obj/machinery/sleeper
	name = "sleeper"
	desc = "An enclosed machine used to stabilize and heal patients."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	density = FALSE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/sleeper

	///efficiency, used to increase the effect of some healing methods
	var/efficiency = 1
	///treatments currently available for use
	var/list/available_treatments
	///if the patient is able to use the sleeper's controls
	var/controls_inside = FALSE
	///treatments unlocked by manipulator by tier
	var/list/treatments = list(
		list(SLEEPER_TEND),
		list(SLEEPER_ORGANS),
		list(SLEEPER_CHEMPURGE),
		list()
	)
	///the current active treatment
	var/active_treatment = null
	///if the sleeper puts its patient into stasis
	var/stasis = FALSE
	var/enter_message = "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.</b></span>"
	var/open_sound = 'sound/machines/podopen.ogg'
	var/close_sound = 'sound/machines/podclose.ogg'
	payment_department = ACCOUNT_MED
	fair_market_price = 5

/obj/machinery/sleeper/Initialize()
	. = ..()
	occupant_typecache = GLOB.typecache_living
	update_icon()

/obj/machinery/sleeper/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		E += B.rating
	var/I
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		I += M.rating

	efficiency = initial(efficiency)* E
	available_treatments = list()
	for(var/i in 1 to I)
		if(!length(treatments[i]))
			continue
		available_treatments |= treatments[i]
	stasis = (I >= 4)

/obj/machinery/sleeper/update_icon()
	if(state_open)
		icon_state = "[initial(icon_state)]-open"
	else
		icon_state = initial(icon_state)

/obj/machinery/sleeper/container_resist(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/sleeper/Exited(atom/movable/user)
	if (!state_open && user == occupant)
		container_resist(user)

/obj/machinery/sleeper/relaymove(mob/user)
	if (!state_open)
		container_resist(user)

/obj/machinery/sleeper/open_machine()
	if(!state_open && !panel_open)
		active_treatment = null
		var/mob/living/mob_occupant = occupant
		if(mob_occupant)
			mob_occupant.remove_status_effect(STATUS_EFFECT_STASIS)
		flick("[initial(icon_state)]-anim", src)
		if(open_sound)
			playsound(src, open_sound, 40)
		..()

/obj/machinery/sleeper/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		flick("[initial(icon_state)]-anim", src)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, "[enter_message]")
		if(mob_occupant && stasis)
			mob_occupant.ExtinguishMob()
		if(close_sound)
			playsound(src, close_sound, 40)

/obj/machinery/sleeper/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(is_operational() && occupant)
		open_machine()

/obj/machinery/sleeper/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	to_chat(user, span_danger("You disable the chemical injection inhibitors on the sleeper..."))
	obj_flags |= EMAGGED

/obj/machinery/sleeper/MouseDrop_T(mob/target, mob/user)
	if(user.stat || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_STAND))
			return
	close_machine(target)

/obj/machinery/sleeper/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(..())
		return
	if(occupant)
		to_chat(user, span_warning("[src] is currently occupied!"))
		return
	if(state_open)
		to_chat(user, span_warning("[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!"))
		return
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		return
	return FALSE

/obj/machinery/sleeper/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_change_direction_wrench(user, I))
		return TRUE

/obj/machinery/sleeper/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_pry_open(I))
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/sleeper/default_pry_open(obj/item/I) //wew
	. = !(state_open || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message(span_notice("[usr] pries open [src]."), span_notice("You pry open [src]."))
		open_machine()

/obj/machinery/sleeper/ui_state(mob/user)
	if(controls_inside)
		return GLOB.default_state
	return GLOB.notcontained_state

/obj/machinery/sleeper/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Sleeper", name)
		ui.open()

/obj/machinery/sleeper/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/sleeper/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to [state_open ? "close" : "open"] it.")

/obj/machinery/sleeper/process()
	..()
	check_nap_violations()
	if(issilicon(occupant))
		return
	var/mob/living/carbon/C = occupant
	if(C)
		if(stasis && (C.stat == DEAD || C.health < 0))
			C.apply_status_effect(STATUS_EFFECT_STASIS, null, TRUE)
		else
			C.remove_status_effect(STATUS_EFFECT_STASIS)
		if(obj_flags & EMAGGED)
			var/existing = C.reagents.get_reagent_amount(/datum/reagent/toxin/amanitin)
			C.reagents.add_reagent(/datum/reagent/toxin/amanitin, max(0, 1.5 - existing)) //this should be enough that you immediately eat shit on exiting but not before
		switch(active_treatment)
			if(SLEEPER_TEND)
				C.heal_bodypart_damage(SLEEPER_HEAL_RATE,SLEEPER_HEAL_RATE) //this is slow as hell, use the rest of medbay you chumps
			if(SLEEPER_ORGANS)
				var/heal_reps = efficiency * 2
				var/list/organs = list(ORGAN_SLOT_EARS,ORGAN_SLOT_EYES,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_HEART)
				for(var/i in 1 to heal_reps)
					organs = shuffle(organs)
					for(var/o in organs)
						var/healed = FALSE
						var/obj/item/organ/heal_target = C.getorganslot(o)
						if(heal_target?.damage >= 1)
							var/organ_healing = C.stat == DEAD ? 0.05 : 0.2
							heal_target.applyOrganDamage(-organ_healing)
							healed = TRUE
						if(healed)
							break
			if(SLEEPER_CHEMPURGE)
				C.adjustToxLoss(-SLEEPER_HEAL_RATE)
				if(obj_flags & EMAGGED)
					return
				var/purge_rate = 0.5 * efficiency
				for(var/datum/reagent/R in C.reagents.reagent_list)
					if(istype(R, /datum/reagent/toxin))
						C.reagents.remove_reagent(R.type,purge_rate)
					if(R.overdosed)
						C.reagents.remove_reagent(R.type,purge_rate)
			else
				active_treatment = null

/obj/machinery/sleeper/nap_violation(mob/violator)
	open_machine()

/obj/machinery/sleeper/ui_data(mob/user)
	var/list/data = list()
	data["knowledge"] = IS_MEDICAL(user)
	data["occupied"] = occupant ? 1 : 0
	data["open"] = state_open
	data["active_treatment"] = active_treatment
	data["can_sedate"] = can_sedate()

	data["treatments"] = list()
	for(var/T in available_treatments)
		data["treatments"] += T
	/*data["chems"] = list()
	for(var/chem in available_chems)
		var/datum/reagent/R = GLOB.chemical_reagents_list[chem]
		data["chems"] += list(list("name" = R.name, "id" = R.type, "allowed" = chem_allowed(chem), "desc" = R.description))*/

	data["occupant"] = list()
	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		data["occupant"]["name"] = mob_occupant.name
		switch(mob_occupant.stat)
			if(CONSCIOUS)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "good"
			if(SOFT_CRIT)
				data["occupant"]["stat"] = "Conscious"
				data["occupant"]["statstate"] = "average"
			if(UNCONSCIOUS)
				data["occupant"]["stat"] = "Unconscious"
				data["occupant"]["statstate"] = "average"
			if(DEAD)
				data["occupant"]["stat"] = "Dead"
				data["occupant"]["statstate"] = "bad"
		data["occupant"]["health"] = mob_occupant.health
		data["occupant"]["maxHealth"] = mob_occupant.maxHealth
		data["occupant"]["minHealth"] = HEALTH_THRESHOLD_DEAD
		data["occupant"]["bruteLoss"] = mob_occupant.getBruteLoss()
		data["occupant"]["oxyLoss"] = mob_occupant.getOxyLoss()
		data["occupant"]["toxLoss"] = mob_occupant.getToxLoss()
		data["occupant"]["fireLoss"] = mob_occupant.getFireLoss()
		data["occupant"]["cloneLoss"] = mob_occupant.getCloneLoss()
		data["occupant"]["brainLoss"] = mob_occupant.getOrganLoss(ORGAN_SLOT_BRAIN)
		data["occupant"]["reagents"] = list()
		if(mob_occupant.reagents && mob_occupant.reagents.reagent_list.len)
			for(var/datum/reagent/R in mob_occupant.reagents.reagent_list)
				data["occupant"]["reagents"] += list(list("name" = R.name, "volume" = R.volume))
	return data

/obj/machinery/sleeper/ui_act(action, params)
	if(..())
		return
	var/mob/living/mob_occupant = occupant
	check_nap_violations()
	switch(action)
		if("door")
			if(state_open)
				close_machine()
			else
				open_machine()
			. = TRUE
		if("set")
			var/treatment = params["treatment"]
			if(!is_operational() || !mob_occupant || isnull(treatment))
				return
			active_treatment = treatment
			. = TRUE
		if("sedate")
			if(can_sedate())
				mob_occupant.reagents.add_reagent(/datum/reagent/medicine/morphine, 10)
				if(usr)
					log_combat(usr,occupant, "injected morphine into", addition = "via [src]")
				. = TRUE

/obj/machinery/sleeper/proc/can_sedate()
	var/mob/living/mob_occupant = occupant
	if(!mob_occupant || !mob_occupant.reagents)
		return
	return mob_occupant.reagents.get_reagent_amount(/datum/reagent/medicine/morphine) + 10 <= 20

/obj/machinery/sleeper/syndie
	icon_state = "sleeper_s"
	controls_inside = TRUE

/obj/machinery/sleeper/syndie/fullupgrade/Initialize()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	RefreshParts()

/obj/machinery/sleeper/clockwork
	name = "soothing sleeper"
	desc = "A large cryogenics unit built from brass. Its surface is pleasantly cool the touch."
	icon_state = "sleeper_clockwork"
	enter_message = "<span class='bold inathneq_small'>You hear the gentle hum and click of machinery, and are lulled into a sense of peace.</span>"
	efficiency = 3
	available_treatments = list(SLEEPER_TEND, SLEEPER_ORGANS, SLEEPER_CHEMPURGE)
	stasis = TRUE

/obj/machinery/sleeper/clockwork/process()
	if(occupant && isliving(occupant))
		var/mob/living/L = occupant
		if(GLOB.clockwork_vitality) //If there's Vitality, the sleeper has passive healing
			GLOB.clockwork_vitality = max(0, GLOB.clockwork_vitality - 1)
			L.adjustBruteLoss(-1)
			L.adjustFireLoss(-1)
			L.adjustOxyLoss(-5)

/obj/machinery/sleeper/clockwork/RefreshParts()
	return

/obj/machinery/sleeper/old
	icon_state = "oldpod"

#undef SLEEPER_TEND
#undef SLEEPER_ORGANS
#undef SLEEPER_CHEMPURGE
#undef SLEEPER_HEAL_RATE
