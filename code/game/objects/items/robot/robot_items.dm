/**********************************************************************
						Cyborg Spec Items
***********************************************************************/
/obj/item/borg
	icon = 'icons/mob/robot_items.dmi'

/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	var/charge_cost = 750
	var/stunforce = 100
	var/stamina_damage = 90

/obj/item/borg/stun/attack(mob/living/M, mob/living/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.check_shields(src, 0, "[M]'s [name]", MELEE_ATTACK))
			playsound(M, 'sound/weapons/genhit.ogg', 50, 1)
			return FALSE
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(charge_cost))
			return

	user.do_attack_animation(M)

	var/obj/item/bodypart/affecting = M.get_bodypart(user.zone_selected)
	var/armor_block = M.run_armor_check(affecting, ENERGY)
	M.apply_damage(stamina_damage, STAMINA, user.zone_selected, armor_block)
	SEND_SIGNAL(M, COMSIG_LIVING_MINOR_SHOCK)
	var/current_stamina_damage = M.getStaminaLoss()

	if(current_stamina_damage >= 90)
		if(!M.IsParalyzed())
			to_chat(M, span_warning("You muscles seize, making you collapse!"))
		else
			M.Paralyze(stunforce)
		M.adjust_jitter(20 SECONDS)
		M.adjust_confusion_up_to(8 SECONDS, 40 SECONDS)
		M.apply_effect(EFFECT_STUTTER, stunforce)
	else if(current_stamina_damage > 70)
		M.adjust_jitter(10 SECONDS)
		M.adjust_confusion_up_to(8 SECONDS, 40 SECONDS)
		M.apply_effect(EFFECT_STUTTER, stunforce)
	else if(current_stamina_damage >= 20)
		M.adjust_jitter(5 SECONDS)
		M.apply_effect(EFFECT_STUTTER, stunforce)

	M.visible_message(span_danger("[user] has prodded [M] with [src]!"), \
					span_userdanger("[user] has prodded you with [src]!"))

	playsound(loc, 'sound/weapons/egloves.ogg', 50, 1, -1)

	log_combat(user, M, "stunned", src, "(INTENT: [uppertext(user.a_intent)])")

/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	var/mode = 0 //0 = Hugs 1 = "Hug" 2 = Shock 3 = CRUSH
	var/ccooldown = 0
	var/scooldown = 0
	var/shockallowed = FALSE//Can it be a stunarm when emagged. Only PK borgs get this by default.
	var/boop = FALSE

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/P = user
		if(P.emagged&&shockallowed == 1)
			if(mode < 3)
				mode++
			else
				mode = 0
		else if(mode < 1)
			mode++
		else
			mode = 0
	switch(mode)
		if(0)
			to_chat(user, "Power reset. Hugs!")
		if(1)
			to_chat(user, "Power increased!")
		if(2)
			to_chat(user, "BZZT. Electrifying arms...")
		if(3)
			to_chat(user, "ERROR: ARM ACTUATORS OVERLOADED.")

/obj/item/borg/cyborghug/attack(mob/living/M, mob/living/silicon/robot/user)
	if(M == user)
		return
	switch(mode)
		if(0)
			if(M.health >= 0)
				if(user.zone_selected == BODY_ZONE_HEAD)
					user.visible_message(span_notice("[user] playfully boops [M] on the head!"), \
									span_notice("You playfully boop [M] on the head!"))
					user.do_attack_animation(M, ATTACK_EFFECT_BOOP)
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
				else if(ishuman(M))
					if(!(M.mobility_flags & MOBILITY_STAND))
						user.visible_message(span_notice("[user] shakes [M] trying to get [M.p_them()] up!"), \
										span_notice("You shake [M] trying to get [M.p_them()] up!"))
					else
						user.visible_message(span_notice("[user] hugs [M] to make [M.p_them()] feel better!"), \
								span_notice("You hug [M] to make [M.p_them()] feel better!"))
					if(M.resting)
						M.set_resting(FALSE, TRUE)
				else
					user.visible_message(span_notice("[user] pets [M]!"), \
							span_notice("You pet [M]!"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		if(1)
			if(M.health >= 0)
				if(ishuman(M))
					M.adjust_status_effects_on_shake_up()
					if(!(M.mobility_flags & MOBILITY_STAND))
						user.visible_message(span_notice("[user] shakes [M] trying to get [M.p_them()] up!"), \
										span_notice("You shake [M] trying to get [M.p_them()] up!"))
					else if(user.zone_selected == BODY_ZONE_HEAD)
						user.visible_message(span_warning("[user] bops [M] on the head!"), \
										span_warning("You bop [M] on the head!"))
						user.do_attack_animation(M, ATTACK_EFFECT_PUNCH)
					else
						user.visible_message(span_warning("[user] hugs [M] in a firm bear-hug! [M] looks uncomfortable..."), \
								span_warning("You hug [M] firmly to make [M.p_them()] feel better! [M] looks uncomfortable..."))
					if(M.resting)
						M.set_resting(FALSE, TRUE)
				else
					user.visible_message(span_warning("[user] bops [M] on the head!"), \
							span_warning("You bop [M] on the head!"))
				playsound(loc, 'sound/weapons/tap.ogg', 50, 1, -1)
		if(2)
			if(scooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M)||ismonkey(M))
						M.electrocute_act(5, "[user]", zone=user.zone_selected, tesla_shock = 1)
						user.visible_message(span_userdanger("[user] electrocutes [M] with [user.p_their()] touch!"), \
							span_danger("You electrocute [M] with your touch!"))
						M.update_mobility()
					else
						if(!iscyborg(M))
							M.adjustFireLoss(10)
							user.visible_message(span_userdanger("[user] shocks [M]!"), \
								span_danger("You shock [M]!"))
						else
							user.visible_message(span_userdanger("[user] shocks [M]. It does not seem to have an effect"), \
								span_danger("You shock [M] to no effect."))
					playsound(loc, 'sound/effects/sparks2.ogg', 50, 1, -1)
					user.cell.charge -= 500
					scooldown = world.time + 20
		if(3)
			if(ccooldown < world.time)
				if(M.health >= 0)
					if(ishuman(M))
						user.visible_message(span_userdanger("[user] crushes [M] in [user.p_their()] grip!"), \
							span_danger("You crush [M] in your grip!"))
					else
						user.visible_message(span_userdanger("[user] crushes [M]!"), \
								span_danger("You crush [M]!"))
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1, -1)
					M.adjustBruteLoss(15)
					user.cell.charge -= 300
					ccooldown = world.time + 10

/obj/item/borg/cyborghug/peacekeeper
	shockallowed = TRUE

/obj/item/borg/cyborghug/medical
	boop = TRUE

/obj/item/borg/charger
	name = "power connector"
	icon_state = "charger_draw"
	item_flags = NOBLUDGEON
	var/mode = "draw"
	var/static/list/charge_machines = typecacheof(list(/obj/machinery/cell_charger, /obj/machinery/recharger, /obj/machinery/recharge_station, /obj/machinery/mech_bay_recharge_port))
	var/static/list/charge_items = typecacheof(list(/obj/item/stock_parts/cell, /obj/item/gun/energy))

/obj/item/borg/charger/update_icon_state()
	. = ..()
	icon_state = "charger_[mode]"

/obj/item/borg/charger/attack_self(mob/user)
	if(mode == "draw")
		mode = "charge"
	else
		mode = "draw"
	to_chat(user, span_notice("You toggle [src] to \"[mode]\" mode."))
	update_appearance(UPDATE_ICON)

/obj/item/borg/charger/afterattack(obj/item/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !iscyborg(user))
		return
	if(mode == "draw")
		if(is_type_in_list(target, charge_machines))
			var/obj/machinery/M = target
			if((M.stat & (NOPOWER|BROKEN)) || !M.anchored)
				to_chat(user, span_warning("[M] is unpowered!"))
				return

			to_chat(user, span_notice("You connect to [M]'s power line..."))
			while(do_after(user, 1.5 SECONDS, M, progress = FALSE))
				if(!user || !user.cell || mode != "draw")
					return

				if((M.stat & (NOPOWER|BROKEN)) || !M.anchored)
					break

				if(!user.cell.give(150))
					break

				M.use_power(200)

			to_chat(user, span_notice("You stop charging yourself."))

		else if(is_type_in_list(target, charge_items))
			var/obj/item/stock_parts/cell/cell = target
			if(!istype(cell))
				cell = locate(/obj/item/stock_parts/cell) in target
			if(!cell)
				to_chat(user, span_warning("[target] has no power cell!"))
				return

			if(istype(target, /obj/item/gun/energy))
				var/obj/item/gun/energy/E = target
				if(!E.can_charge)
					to_chat(user, span_warning("[target] has no power port!"))
					return

			if(!cell.charge)
				to_chat(user, span_warning("[target] has no power!"))


			to_chat(user, span_notice("You connect to [target]'s power port..."))

			while(do_after(user, 1.5 SECONDS, target, progress = FALSE))
				if(!user || !user.cell || mode != "draw")
					return

				if(!cell || !target)
					return

				if(cell != target && cell.loc != target)
					return

				var/draw = min(cell.charge, cell.chargerate*0.5, user.cell.maxcharge-user.cell.charge)
				if(!cell.use(draw))
					break
				if(!user.cell.give(draw))
					break
				target.update_appearance(UPDATE_ICON)

			to_chat(user, span_notice("You stop charging yourself."))

	else if(is_type_in_list(target, charge_items))
		var/obj/item/stock_parts/cell/cell = target
		if(!istype(cell))
			cell = locate(/obj/item/stock_parts/cell) in target
		if(!cell)
			to_chat(user, span_warning("[target] has no power cell!"))
			return

		if(istype(target, /obj/item/gun/energy))
			var/obj/item/gun/energy/E = target
			if(!E.can_charge)
				to_chat(user, span_warning("[target] has no power port!"))
				return

		if(cell.charge >= cell.maxcharge)
			to_chat(user, span_warning("[target] is already charged!"))

		to_chat(user, span_notice("You connect to [target]'s power port..."))

		while(do_after(user, 1.5 SECONDS, target, progress = FALSE))
			if(!user || !user.cell || mode != "charge")
				return

			if(!cell || !target)
				return

			if(cell != target && cell.loc != target)
				return

			var/draw = min(user.cell.charge, cell.chargerate*0.5, cell.maxcharge-cell.charge)
			if(!user.cell.use(draw))
				break
			if(!cell.give(draw))
				break
			target.update_appearance(UPDATE_ICON)

		to_chat(user, span_notice("You stop charging [target]."))

/obj/item/harmalarm
	name = "\improper Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	var/cooldown = 0

/obj/item/harmalarm/emag_act(mob/user, obj/item/card/emag/emag_card)
	obj_flags ^= EMAGGED
	if(user)
		if(obj_flags & EMAGGED)
			to_chat(user, "<font color='red'>You short out the safeties on [src]!</font>")
		else
			to_chat(user, "<font color='red'>You reset the safeties on [src]!</font>")
	return TRUE

/obj/item/harmalarm/attack_self(mob/user)
	var/safety = !(obj_flags & EMAGGED)
	if(cooldown > world.time)
		to_chat(user, "<font color='red'>The device is still recharging!</font>")
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell || R.cell.charge < 1200)
			to_chat(user, "<font color='red'>You don't have enough charge to do this!</font>")
			return
		R.cell.charge -= 1000
		if(R.emagged)
			safety = FALSE

	if(safety == TRUE)
		user.visible_message("<font color='red' size='2'>[user] blares out a near-deafening siren from its speakers!</font>", \
			span_userdanger("Your siren blares around [iscyborg(user) ? "you" : "and confuses you"]!"), \
			span_danger("The siren pierces your hearing!"))
		for(var/mob/living/carbon/M in get_hearers_in_view(9, user))
			if(M.get_ear_protection() == FALSE)
				M.adjust_confusion(6 SECONDS)
		audible_message("<font color='red' size='7'>HUMAN HARM</font>")
		playsound(get_turf(src), 'sound/ai/default/harmalarm.ogg', 70, 3)
		cooldown = world.time + 200
		log_game("[key_name(user)] used a Cyborg Harm Alarm in [AREACOORD(user)]")
		if(iscyborg(user))
			var/mob/living/silicon/robot/R = user
			to_chat(R.connected_ai, "<br>[span_notice("NOTICE - Peacekeeping 'HARM ALARM' used by: [user]")]<br>")

		return

	if(safety == FALSE)
		user.audible_message("<font color='red' size='7'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</font>")
		for(var/mob/living/carbon/C in get_hearers_in_view(9, user))
			var/bang_effect = C.soundbang_act(2, 0, 0, 5)
			switch(bang_effect)
				if(1)
					C.adjust_confusion(5 SECONDS)
					C.adjust_stutter(10 SECONDS)
					C.adjust_jitter(10 SECONDS)
				if(2)
					C.Paralyze(4 SECONDS)
					C.adjust_confusion(10 SECONDS)
					C.adjust_stutter(15 SECONDS)
					C.adjust_jitter(25 SECONDS)
		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 130, 3)
		cooldown = world.time + 1 MINUTES
		log_game("[key_name(user)] used an emagged Cyborg Harm Alarm in [AREACOORD(user)]")

// TODO: Re-add vanilla ice cream once someone figures that out.
/obj/item/borg_snack_dispenser
	name = "\improper Automated Borg Snack Dispenser"
	desc = "Has the ability to automatically print many different forms of snacks. Now Vuulek approved!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rsf"
	// Contains the PATH of the selected snack
	var/atom/selected_snack
	// Whether snacks are launched when targeted at a distance
	var/launch_mode = FALSE
	/// A list of all valid snacks
	var/list/valid_snacks = list(
		/obj/item/reagent_containers/food/snacks/cookie,
		/obj/item/reagent_containers/food/snacks/cookie/bacon,
		/obj/item/reagent_containers/food/snacks/cookie/cloth,
		/obj/item/reagent_containers/food/snacks/lollipop,
		/obj/item/reagent_containers/food/snacks/gumball,
		/obj/item/reagent_containers/food/snacks/icecream // Becomes vanilla icecream down the line.
	)
	// A list of surfaces that we are allowed to place things on.
	var/list/allowed_surfaces = list(/obj/structure/table, /turf/open/floor)
	// Minimum amount of charge a borg can have before snack printing is disallowed
	var/borg_charge_cutoff = 200
	// The amount of charge used per print of a snack
	var/borg_charge_usage = 50
	// How long until they can use it again? 0.3 is just about how fast mediborg can use their default lollipop launcher.
	var/cooldown = 0.3 SECONDS
	COOLDOWN_DECLARE(last_snack_disp)

/obj/item/borg_snack_dispenser/Initialize(mapload)
	. = ..()
	selected_snack = selected_snack || LAZYACCESS(valid_snacks, 1)

/obj/item/borg_snack_dispenser/examine(mob/user)
	. = ..()
	. += "It is currently set to dispense [initial(selected_snack.name)]."
	. += "You can AltClick it to [(launch_mode ? "disable" : "enable")] launch mode."

/obj/item/borg_snack_dispenser/attack_self(mob/user, modifiers)
	var/list/choices = list()
	for(var/atom/snack as anything in valid_snacks)
		if(snack == /obj/item/reagent_containers/food/snacks/icecream)
			choices["vanilla icecream"] = snack // Would be "ice cream cone" in the menu otherwise.
		else
			choices[initial(snack.name)] = snack
	if(!length(choices))
		to_chat(user, span_warning("No valid snacks in database."))
	if(length(choices) == 1)
		selected_snack = choices[choices[1]] // choices[1] gets the snack.name and then choices[choices[1]] gets the actual snack
	else
		var/selected = tgui_input_list(user, "Select Snack", "Snack Selection", choices)
		if(!selected)
			return
		selected_snack = choices[selected]

	var/snack_name = initial(selected_snack.name)
	to_chat(user, span_notice("[src] is now dispensing [snack_name]."))

/obj/item/borg_snack_dispenser/attack(mob/living/patron, mob/living/silicon/robot/user, params)
	if(!COOLDOWN_FINISHED(src, last_snack_disp))
		to_chat(user, span_warning("The snack dispenser is recharging!"))
		return
	if(!selected_snack)
		to_chat(user, span_warning("No snack selected."))
		return
	var/empty_hand = LAZYACCESS(patron.get_empty_held_indexes(), 1)
	if(!empty_hand)
		to_chat(user, span_warning("[patron] has no free hands!"))
		return
	if(issilicon(patron))
		return
	if(!istype(user))
		CRASH("[src] being used by non borg [user]")
	if(user.cell.charge < borg_charge_cutoff)
		to_chat(user, span_danger("Automated Safety Measures restrict the operation of [src] while under [borg_charge_cutoff]!"))
		return
	if(!user.cell.use(borg_charge_usage))
		to_chat(user, span_danger("Failure printing snack: power failure!"))
		return
	COOLDOWN_START(src, last_snack_disp, cooldown)
	var/atom/snack = new selected_snack(src)
	patron.put_in_hand(snack, empty_hand)
	user.do_item_attack_animation(patron, null, snack)
	playsound(loc, 'sound/machines/click.ogg', 10, TRUE)

	// Vanilla Icecream & Setting 'snack.name' Early
	if(istype(snack, /obj/item/reagent_containers/food/snacks/icecream))
		var/obj/item/reagent_containers/food/snacks/icecream/icecream = snack
		icecream.add_ice_cream("vanilla")
		icecream.desc = "Eat the ice cream."
		
	to_chat(patron, span_notice("[user] dispenses a [snack.name] into your empty hand and you reflexively grasp it."))
	to_chat(user, span_notice("You dispense a [snack.name] into the hand of [patron]."))

/obj/item/borg_snack_dispenser/AltClick(mob/user)
	launch_mode = !launch_mode
	to_chat(user, span_notice("[src] is [(launch_mode ? "now" : "no longer")] launching snacks at a distance."))

/obj/item/borg_snack_dispenser/afterattack(atom/target, mob/living/silicon/robot/user, proximity_flag, click_parameters)
	if(!COOLDOWN_FINISHED(src, last_snack_disp))
		to_chat(user, span_warning("The snack dispenser is recharging!"))
		return
	if(!selected_snack)
		to_chat(user, span_warning("No snack selected."))
		return
	if(user.cell.charge < borg_charge_cutoff)
		to_chat(user, span_danger("Automated Safety Measures restrict the operation of [src] while under [borg_charge_cutoff]!"))
		return
	if(!user.cell.use(borg_charge_usage))
		to_chat(user, span_danger("Failure printing snack: power failure!"))
		return
	if(!istype(user))
		CRASH("[src] being used by non borg [user]")
	var/atom/movable/snack
	if(launch_mode)
		COOLDOWN_START(src, last_snack_disp, cooldown)
		snack = new selected_snack(get_turf(src))
		if(user.emagged)
			snack.throwforce = 3
			RegisterSignal(snack, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(post_throw))
		snack.throw_at(target, 7, 2, user, TRUE, FALSE)
		playsound(loc, 'sound/machines/click.ogg', 10, TRUE)
		if(istype(snack, /obj/item/reagent_containers/food/snacks/icecream))
			var/obj/item/reagent_containers/food/snacks/icecream/icecream = snack
			icecream.add_ice_cream("vanilla")
			icecream.desc = "Eat the ice cream."
		user.visible_message(span_notice("[src] launches a [snack.name] at [target]!"))
		user.newtonian_move(get_dir(target, user)) // For no gravity.
	else if(user.Adjacent(target) && is_allowed(target, user))
		COOLDOWN_START(src, last_snack_disp, cooldown)
		snack = new selected_snack(get_turf(target))
		playsound(loc, 'sound/machines/click.ogg', 10, TRUE)
		if(istype(snack, /obj/item/reagent_containers/food/snacks/icecream))
			var/obj/item/reagent_containers/food/snacks/icecream/icecream = snack
			icecream.add_ice_cream("vanilla")
			icecream.desc = "Eat the ice cream."
		user.visible_message(span_notice("[user] dispenses a [snack.name]."))

	if(snack && user.emagged && istype(snack, /obj/item/reagent_containers/food/snacks/cookie))
		var/obj/item/reagent_containers/food/snacks/cookie/cookie = snack
		cookie.list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/toxin/chloralhydrate = 10)

/obj/item/borg_snack_dispenser/proc/post_throw(atom/movable/thrown_snack)
	SIGNAL_HANDLER
	thrown_snack.throwforce = 0

/obj/item/borg_snack_dispenser/proc/is_allowed(atom/to_check, mob/user)
	for(var/sort in allowed_surfaces)
		if(istype(to_check, sort))
			return TRUE
	return FALSE

/obj/item/borg_snack_dispenser/peacekeeper
	name = "\improper Peacekeeper Borg Snack Dispenser"
	desc = "A dispenser that dispenses only cookies!"
	valid_snacks = list(/obj/item/reagent_containers/food/snacks/cookie)

/obj/item/borg_snack_dispenser/medical
	name = "\improper Treat Borg Snack Dispenser" // Not calling this "Medical Borg Snack Dispenser" since Service & Clown Cyborgs use this too.
	desc = "A dispenser that dispenses treats such as lollipops and gumballs!"
	valid_snacks = list(/obj/item/reagent_containers/food/snacks/lollipop, /obj/item/reagent_containers/food/snacks/gumball, /obj/item/reagent_containers/food/snacks/icecream)

#define PKBORG_DAMPEN_CYCLE_DELAY 20

//Peacekeeper Cyborg Projectile Dampenening Field
/obj/item/borg/projectile_dampen
	name = "\improper Hyperkinetic Dampening projector"
	desc = "A device that projects a dampening field that weakens kinetic energy above a certain threshold. <span class='boldnotice'>Projects a field that drains power per second while active, that will weaken and slow damaging projectiles inside its field.</span> Still being a prototype, it tends to induce a charge on ungrounded metallic surfaces."
	icon = 'icons/obj/device.dmi'
	icon_state = "shield"
	var/maxenergy = 1500
	var/energy = 1500
	var/energy_recharge = 37.5
	var/energy_recharge_cyborg_drain_coefficient = 0.4
	var/cyborg_cell_critical_percentage = 0.05
	var/mob/living/silicon/robot/host = null
	var/datum/proximity_monitor/advanced/dampening_field
	var/projectile_damage_coefficient = 0.5
	var/projectile_damage_tick_ecost_coefficient = 10	//Lasers get half their damage chopped off, drains 50 power/tick. Note that fields are processed 5 times per second.
	var/projectile_speed_coefficient = 1.5		//Higher the coefficient slower the projectile.
	var/projectile_tick_speed_ecost = 75
	var/list/obj/projectile/tracked
	var/image/projectile_effect
	var/field_radius = 3
	var/active = FALSE
	var/cycle_delay = 0

/obj/item/borg/projectile_dampen/debug
	maxenergy = 50000
	energy = 50000
	energy_recharge = 5000

/obj/item/borg/projectile_dampen/Initialize(mapload)
	. = ..()
	projectile_effect = image('icons/effects/fields.dmi', "projectile_dampen_effect")
	tracked = list()
	icon_state = "shield0"
	START_PROCESSING(SSfastprocess, src)
	host = loc

/obj/item/borg/projectile_dampen/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/borg/projectile_dampen/attack_self(mob/user)
	if(cycle_delay > world.time)
		to_chat(user, span_boldwarning("[src] is still recycling its projectors!"))
		return
	cycle_delay = world.time + PKBORG_DAMPEN_CYCLE_DELAY
	if(!active)
		if(!user.has_buckled_mobs())
			activate_field()
		else
			to_chat(user, span_warning("[src]'s safety cutoff prevents you from activating it due to living beings being ontop of you!"))
	else
		deactivate_field()
	update_appearance(UPDATE_ICON)
	to_chat(user, span_boldnotice("You [active? "activate":"deactivate"] [src]."))

/obj/item/borg/projectile_dampen/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][active]"

/obj/item/borg/projectile_dampen/proc/activate_field()
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	dampening_field = make_field(/datum/proximity_monitor/advanced/peaceborg_dampener, list("current_range" = field_radius, "host" = src, "projector" = src))
	var/mob/living/silicon/robot/owner = get_host()
	if(owner)
		owner.module.allow_riding = FALSE
	active = TRUE

/obj/item/borg/projectile_dampen/proc/deactivate_field()
	QDEL_NULL(dampening_field)
	visible_message(span_warning("\The [src] shuts off!"))
	for(var/P in tracked)
		restore_projectile(P)
	active = FALSE

	var/mob/living/silicon/robot/owner = get_host()
	if(owner)
		owner.module.allow_riding = TRUE

/obj/item/borg/projectile_dampen/proc/get_host()
	if(istype(host))
		return host
	else
		if(iscyborg(host.loc))
			return host.loc
	return null

/obj/item/borg/projectile_dampen/dropped()
	. = ..()
	host = loc

/obj/item/borg/projectile_dampen/equipped()
	. = ..()
	host = loc

/obj/item/borg/projectile_dampen/on_mob_death()
	deactivate_field()
	. = ..()

/obj/item/borg/projectile_dampen/process(delta_time)
	process_recharge(delta_time)
	process_usage(delta_time)
	update_location()

/obj/item/borg/projectile_dampen/proc/update_location()
	if(dampening_field)
		dampening_field.HandleMove()

/obj/item/borg/projectile_dampen/proc/process_usage(delta_time)
	var/usage = 0
	for(var/I in tracked)
		var/obj/projectile/P = I
		if(!P.stun && P.nodamage)	//No damage
			continue
		usage += projectile_tick_speed_ecost * delta_time
		usage += tracked[I] * projectile_damage_tick_ecost_coefficient * delta_time
	energy = clamp(energy - usage, 0, maxenergy)
	if(energy <= 0)
		deactivate_field()
		visible_message(span_warning("[src] blinks \"ENERGY DEPLETED\"."))

/obj/item/borg/projectile_dampen/proc/process_recharge(delta_time)
	if(!istype(host))
		if(iscyborg(host.loc))
			host = host.loc
		else
			energy = clamp(energy + (energy_recharge * delta_time), 0, maxenergy)
		return
	if(host.cell && (host.cell.charge >= (host.cell.maxcharge * cyborg_cell_critical_percentage)) && (energy < maxenergy))
		host.cell.use(energy_recharge * delta_time * energy_recharge_cyborg_drain_coefficient)
		energy += energy_recharge * delta_time

/obj/item/borg/projectile_dampen/proc/dampen_projectile(obj/projectile/P, track_projectile = TRUE)
	if(tracked[P])
		return
	if(track_projectile)
		tracked[P] = P.damage
	P.damage *= projectile_damage_coefficient
	P.speed *= projectile_speed_coefficient
	P.add_overlay(projectile_effect)

/obj/item/borg/projectile_dampen/proc/restore_projectile(obj/projectile/P)
	tracked -= P
	P.damage *= (1/projectile_damage_coefficient)
	P.speed *= (1/projectile_speed_coefficient)
	P.cut_overlay(projectile_effect)

/obj/item/borg/cookbook
	name = "Codex Cibus Mechanicus"
	desc = "It's a robot cookbook!"
	icon = 'icons/obj/library.dmi'
	icon_state = "cooked_book"
	item_flags = NOBLUDGEON
	var/datum/component/personal_crafting/cooking

/obj/item/borg/cookbook/Initialize(mapload)
	. = ..()
	cooking = AddComponent(/datum/component/personal_crafting)
	cooking.forced_mode = TRUE
	cooking.mode = TRUE // Cooking mode.

/obj/item/borg/cookbook/attack_self(mob/user, modifiers)
	. = ..()
	cooking.ui_interact(user)

/obj/item/borg/cookbook/dropped(mob/user, silent)
	SStgui.close_uis(cooking)
	return ..()

/obj/item/borg/cookbook/cyborg_unequip(mob/user)
	SStgui.close_uis(cooking)
	return ..()

/obj/item/borg/floor_autocleaner
	name = "floor autocleaner"
	desc = "Automatically cleans the floor under you!"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "upgrade"
	item_flags = NOBLUDGEON
	var/toggled = FALSE

/obj/item/borg/floor_autocleaner/attack_self(mob/user, modifiers)
	if(!issilicon(user))
		return FALSE

	toggled = !toggled
	if(toggled)
		user.AddElement(/datum/element/cleaning)
		user.balloon_alert(user, "cleaning enabled")
	else
		user.RemoveElement(/datum/element/cleaning)
		user.balloon_alert(user, "cleaning disabled")

/obj/item/borg/floor_autocleaner/cyborg_equip(mob/user)
	if(toggled)
		user.AddElement(/datum/element/cleaning)
		user.balloon_alert(user, "cleaning enabled")
	
/obj/item/borg/floor_autocleaner/cyborg_unequip(mob/user)
	if(toggled)
		user.RemoveElement(/datum/element/cleaning)
		user.balloon_alert(user, "cleaning disabled")

/**********************************************************************
						HUD/SIGHT things
***********************************************************************/
/obj/item/borg/sight
	var/sight_mode = null

/obj/item/borg/sight/xray
	name = "\proper X-ray vision"
	icon = 'icons/obj/decals.dmi'
	icon_state = "securearea"
	sight_mode = BORGXRAY

/obj/item/borg/sight/xray/truesight_lens
	name = "truesight lens"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "truesight_lens"

/obj/item/borg/sight/thermal
	name = "\proper thermal vision"
	sight_mode = BORGTHERM
	icon_state = "thermal"

/obj/item/borg/sight/meson
	name = "\proper meson vision"
	sight_mode = BORGMESON
	icon_state = "meson"

/obj/item/borg/sight/meson/nightvision
	name = "\proper night vision meson vision"
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "nvgmeson"
	sight_mode = BORGMESON
	
/obj/item/borg/sight/material
	name = "\proper material vision"
	sight_mode = BORGMATERIAL
	icon_state = "material"

/obj/item/borg/sight/hud
	name = "hud"
	var/obj/item/clothing/glasses/hud/hud = null

/obj/item/borg/sight/hud/med
	name = "medical hud"
	icon_state = "healthhud"

/obj/item/borg/sight/hud/med/Initialize(mapload)
	. = ..()
	hud = new /obj/item/clothing/glasses/hud/health(src)

/obj/item/borg/sight/hud/sec
	name = "security hud"
	icon_state = "securityhud"

/obj/item/borg/sight/hud/sec/Initialize(mapload)
	. = ..()
	hud = new /obj/item/clothing/glasses/hud/security(src)

/**********************************************************************
						Grippers
***********************************************************************/
/obj/item/borg/gripper
	name = "cyborg gripper"
	desc = "A simple grasping tool for interacting with various items."
	icon = 'icons/obj/device.dmi'
	icon_state = "gripper"
	item_flags = NOBLUDGEON
	/// Whitelist of items types that can be held.
	var/list/can_hold = list()
	/// Blacklist of item subtypes that should not be held unless emagged.
	var/list/cannot_hold = list()
	/// Item currently being held if any.
	var/obj/item/wrapped = null

/// Drops held item if possible.
/obj/item/borg/gripper/proc/drop_held(silent = FALSE)
	if(wrapped)
		if(!silent)
			to_chat(usr, span_notice("You drop \the [wrapped]."))
		wrapped.forceMove(get_turf(wrapped)) // The rest is handled in Exited().
		return TRUE
	return FALSE

/obj/item/borg/gripper/Exited(atom/movable/gone, direction)
	if(gone == wrapped) // Sanity check.
		UnregisterSignal(wrapped, COMSIG_ATOM_UPDATED_ICON)
		wrapped = null
	update_appearance()
	return ..()

/// Pick up item if possible.
/obj/item/borg/gripper/proc/take_item(obj/item/item, silent = FALSE)
	if(!wrapped)
		if(!silent)
			to_chat(usr, span_notice("You collect \the [item]."))
		// Recentering the item.
		item.pixel_x = initial(item.pixel_x)
		item.pixel_y = initial(item.pixel_y)
		item.transform = initial(item.transform)

		usr.transferItemToLoc(item, src)
		wrapped = item
		RegisterSignal(wrapped, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_wrapped_updated_icon))
		update_appearance()
		return TRUE
	return FALSE

/obj/item/borg/gripper/proc/on_wrapped_updated_icon(datum/source, updates)
	SIGNAL_HANDLER
	update_appearance()
	return NONE

/obj/item/borg/gripper/pre_attack(atom/target, mob/living/silicon/robot/user, params)
	if(!wrapped) // Checking if we have an item, but somehow didn't set it to be the wrapped variable.
		for(var/obj/item/thing in src.contents)
			wrapped = thing
			break
	if(wrapped) // Currently holding an item.
		wrapped.melee_attack_chain(user, target, params)
		return TRUE
	if(isitem(target)) // Not holding an item, but want to grab an item.
		var/obj/item/item = target
		if(is_holdable(item))
			take_item(item)
			return TRUE
	return ..()

/obj/item/borg/gripper/proc/is_holdable(obj/item/item, slient = FALSE)
	if(!loc || !issilicon(loc))
		return FALSE
	var/holdable = FALSE
	var/mob/living/silicon/robot/user = loc
	for(var/obj/module_item in user.module.modules) // Not doing `locate(item) in user.module.modules` because they may need to grab a duplicate item type.
		if(item == module_item)
			if(!slient)
				to_chat(user, span_danger("Your gripper cannot grab your own modules."))
			return FALSE
	if(is_type_in_list(item, can_hold))
		holdable = TRUE
		if(is_type_in_list(item, cannot_hold) && !user.emagged)
			holdable = FALSE
	if(!holdable && !slient)
		to_chat(user, span_danger("Your gripper cannot hold \the [item]."))
	return holdable

/obj/item/borg/gripper/attack_self(mob/user)
	if(wrapped)
		wrapped.attack_self(user)
		return
	. = ..()

/obj/item/borg/gripper/AltClick(mob/user)
	if(wrapped)
		wrapped.AltClick(user)
		return
	. = ..()

/obj/item/borg/gripper/CtrlClick(mob/user)
	if(wrapped)
		wrapped.CtrlClick(user)
		return
	. = ..()

/obj/item/borg/gripper/CtrlShiftClick(mob/user)
	if(wrapped)
		wrapped.CtrlShiftClick(user)
		return
	. = ..()

/// Resets overlays and adds a overlay if there is a held item.
/obj/item/borg/gripper/update_overlays()
	. = ..()
	if(wrapped)
		var/mutable_appearance/wrapped_appearance = mutable_appearance(wrapped.icon, wrapped.icon_state)
		wrapped_appearance.overlays = wrapped.overlays.Copy()
		// Shrinking it to 0.8 makes it a bit ugly, but this makes it obvious it is a held item.
		wrapped_appearance.transform = matrix(0.8,0,0,0,0.8,0)
		. += wrapped_appearance

// Make it clear what we can do with it.
/obj/item/borg/gripper/examine(mob/user)
	. = ..()
	if(wrapped)
		. += span_notice("It is holding [icon2html(wrapped, user)] [wrapped]." )
		. += span_notice("Attempting to drop the gripper will only drop [wrapped].")

// Drop the item if the gripper is unequipped.
/obj/item/borg/gripper/cyborg_unequip(mob/user)
	. = ..()
	if(wrapped)
		drop_held()

/obj/item/borg/gripper/engineering
	name = "engineering gripper"
	desc = "A simple grasping tool for interacting with a limited amount of engineering related items."
	can_hold = list(
		/obj/item/circuitboard,
		/obj/item/electronics,
		/obj/item/wallframe,
		/obj/item/stock_parts,
		/obj/item/tank/internals,
		/obj/item/conveyor_switch_construct,
		/obj/item/stack/conveyor,
		/obj/item/server_rack,
		/obj/item/ai_cpu,
	)

/obj/item/borg/gripper/medical
	name = "medical gripper"
	desc = "A simple grasping tool for interacting with various medical related items."
	can_hold = list(
		/obj/item/reagent_containers/medspray, // Without this, just syringe the content out and put it into a beaker to get around it.
		/obj/item/reagent_containers/blood, // To insert blood bags into IV drips.
		/obj/item/reagent_containers/food/snacks/lollipop, // Given that they have a snack dispenser, might as well.
		// All chemistry specific concerns:
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/pill, // Includes patches... because they're are pills too?
		/obj/item/reagent_containers/gummy,
		/obj/item/storage/bag/chemistry // QOL for moving a billion pills into the chemfridge.
	)
  
/obj/item/borg/gripper/service
	name = "service gripper"
	desc = "A simple grasping tool for interacting with various service related items and food."
	can_hold = list(
		// Items from the RSF.
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/plate,
		/obj/item/storage/pill_bottle/dice,
		/obj/item/dice,
		/obj/item/clothing/mask/cigarette,
		// Cooking purposes.
		/obj/item/kitchen/knife,
		/obj/item/kitchen/rollingpin,
		/obj/item/plate/oven_tray,
		/obj/item/storage/fancy/egg_box,
		// Holding most, if not all, foods. This includes drinking glasses and condiments.
		/obj/item/reagent_containers/food,
		// Additional.
		/obj/item/reagent_containers/glass/mixbowl, // Kitchen mixing bowl.
		/obj/item/kitchen/fork // Found in kitchen's vendor.
	)
	cannot_hold = list(
		// Non-standard dangerous knives.
		/obj/item/kitchen/knife/butcher,
		/obj/item/kitchen/knife/combat,
		/obj/item/kitchen/knife/envy,
		/obj/item/kitchen/knife/rainbowknife,
		/obj/item/kitchen/knife/ritual
	)

