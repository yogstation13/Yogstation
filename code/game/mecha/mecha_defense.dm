/obj/mecha/proc/get_armour_facing(relative_dir)
	switch(abs(relative_dir))
		if(180) // BACKSTAB!
			return facing_modifiers[BACK_ARMOUR]
		if(0, 45)
			return facing_modifiers[FRONT_ARMOUR]
	return facing_modifiers[SIDE_ARMOUR] //always return non-0

/obj/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = TRUE, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && atom_integrity > 0)
		spark_system.start()
		switch(damage_flag)
			if(FIRE)
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL))
			if(MELEE)
				check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			else
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT))
		if(. >= 5 || prob(33))
			occupant_message(span_userdanger("Taking damage!"))
		log_message("Took [damage_amount] points of damage. Damage type: [damage_type]", LOG_MECHA)
		diag_hud_set_mechhealth()

/obj/mecha/repair_damage(amount)
	. = ..()
	diag_hud_set_mechhealth()

/obj/mecha/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	. = ..()
	if(!damage_amount)
		return 0
	var/deflection_modifier = 1
	var/damage_modifier = 1
	if(damage_flag == MELEE)
		if(attack_dir)
			var/facing_modifier = get_armour_facing(dir2angle(attack_dir) - dir2angle(dir))
			damage_modifier /= facing_modifier
			deflection_modifier *= facing_modifier
		if(prob(deflect_chance * deflection_modifier))
			visible_message(span_danger("[src]'s armour deflects the attack!"))
			log_message("Armor saved.", LOG_MECHA)
			return 0
		if(.)
			. *= damage_modifier


/obj/mecha/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE) // Ugh. Ideally we shouldn't be setting cooldowns outside of click code.
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, 1, -1)
	user.visible_message(span_danger("[user] hits [name]. Nothing happens."), null, null, COMBAT_MESSAGE_RANGE)
	log_message("Attack by hand/paw. Attacker - [user].", LOG_MECHA, color="red")

/obj/mecha/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/mecha/attack_alien(mob/living/user)
	log_message("Attack by alien. Attacker - [user].", LOG_MECHA, color="red")
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	attack_generic(user, 15, BRUTE, MELEE, 0)

/obj/mecha/attack_animal(mob/living/simple_animal/user)
	log_message("Attack by simple animal. Attacker - [user].", LOG_MECHA, color="red")
	if(!user.melee_damage_upper && !user.obj_damage)
		user.emote("custom", message = "[user.friendly] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(user.environment_smash)
			play_soundeffect = 0
			playsound(src, 'sound/effects/bang.ogg', 50, 1)
		var/animal_damage = rand(user.melee_damage_lower,user.melee_damage_upper)
		if(user.obj_damage)
			animal_damage = user.obj_damage
		animal_damage = min(animal_damage, 20*user.environment_smash)
		attack_generic(user, animal_damage, user.melee_damage_type, MELEE, play_soundeffect)
		log_combat(user, src, "attacked")
		return 1


/obj/mecha/hulk_damage()
	return 15

/obj/mecha/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(.)
		log_message("Attack by hulk. Attacker - [user].", LOG_MECHA, color="red")
		log_combat(user, src, "punched", "hulk powers")

/obj/mecha/blob_act(obj/structure/blob/B)
	take_damage(30, BRUTE, MELEE, 0, get_dir(src, B))

/obj/mecha/attack_tk()
	return

/obj/mecha/rust_heretic_act()
	take_damage(500,  BRUTE)

/obj/mecha/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum) //wrapper
	log_message("Hit by [AM].", LOG_MECHA, color="red")
	. = ..()

/obj/mecha/tesla_act(source, power, tesla_flags, shocked_targets)
	. = ..()
	if((tesla_flags & TESLA_MOB_DAMAGE|TESLA_OBJ_DAMAGE))
		var/effects_scaling = (power/160)**(1/3)
		take_damage(round(3 * effects_scaling), BURN, ELECTRIC)
		adjust_overheat(min(effects_scaling * (100 - armor.getRating(ELECTRIC)) / 100, OVERHEAT_EMP_MAX - overheat))
	if(wrecked && (tesla_flags & TESLA_MACHINE_EXPLOSIVE))
		ADD_TRAIT(src, TRAIT_TESLA_IGNORE, INNATE_TRAIT)
		detonate(2, FALSE)

/obj/mecha/bullet_act(obj/projectile/incoming)
	if((!enclosed || incoming.penetration_flags & PENETRATE_OBJECTS) && occupant && !silicon_pilot && !incoming.force_hit && (incoming.def_zone == BODY_ZONE_HEAD || incoming.def_zone == BODY_ZONE_CHEST)) //allows bullets to hit the pilot of open-canopy mechs
		occupant.bullet_act(incoming) //If the sides are open, the occupant can be hit
	if(istype(incoming, /obj/projectile/ion))
		return ..()
	var/deflection_modifier = 1
	var/damage_modifier = 1
	var/attack_dir = get_dir(src, incoming)
	if(attack_dir)
		var/facing_modifier = get_armour_facing(dir2angle(attack_dir) - dir2angle(dir))
		damage_modifier /= facing_modifier
		deflection_modifier *= facing_modifier
	if(prob(deflect_chance * deflection_modifier))
		visible_message(span_danger("[src]'s armour deflects the attack!"))
		if(super_deflects)
			incoming.firer = src
			incoming.setAngle(rand(0, 360))	//PTING
			return BULLET_ACT_FORCE_PIERCE
		else
			incoming.damage = 0	//Armor has stopped the projectile effectively, if it has other effects that's another issue
			return BULLET_ACT_BLOCK

	incoming.damage *= damage_modifier	//If you manage to shoot THROUGH a mech with something, the bullet wont be fully intact
	if(!HAS_TRAIT(incoming, TRAIT_SHIELDBUSTER)) // Exceptionally strong projectiles do the full damage
		incoming.demolition_mod = (1 + incoming.demolition_mod) / 2

	log_message("Hit by projectile. Type: [incoming.name]([incoming.armor_flag]).", LOG_MECHA, color="red")
	return ..()

/obj/mecha/ex_act(severity, target)
	log_message("Affected by explosion of severity: [severity].", LOG_MECHA, color="red")
	if(prob(deflect_chance))
		severity++
		log_message("Armor saved, changing severity to [severity]", LOG_MECHA)
	. = ..()

/obj/mecha/contents_explosion(severity, target)
	severity++
	for(var/X in equipment)
		var/obj/item/mecha_parts/mecha_equipment/ME = X
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += ME
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += ME
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += ME
	for(var/Y in trackers)
		var/obj/item/mecha_parts/mecha_tracking/MT = Y
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += MT
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += MT
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += MT
	if(occupant)
		occupant.ex_act(severity,target)

/obj/mecha/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		icon_state = initial(icon_state)+"-open"
		setDir(dir_in)

/obj/mecha/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	severity -= EMP_HEAVY * armor.getRating(ENERGY) / 100 // energy armor is subtractive so that it's less effective against stronger EMPs and more against weaker ones
	if(severity <= 0)
		return
	if(get_charge())
		use_power(cell.charge * severity / 40)
	if(overheat < OVERHEAT_EMP_MAX)
		adjust_overheat(min(severity, OVERHEAT_EMP_MAX - overheat))

	take_damage(2 * severity, BURN, ENERGY, 1)
	log_message("EMP detected", LOG_MECHA, color="red")

	if(severity <= EMP_LIGHT || overheat < OVERHEAT_WARNING / 2)
		return // only a light EMP, equipment is still fine

	if(istype(src, /obj/mecha/combat))
		mouse_pointer = 'icons/mecha/mecha_mouse-disable.dmi'
		occupant?.update_mouse_pointer()
	if(!equipment_disabled && occupant) //prevent spamming this message with back-to-back EMPs
		to_chat(occupant, "<span=danger>Error -- Connection to equipment control unit has been lost.</span>")
	overload_action.Activate(FALSE)
	addtimer(CALLBACK(src, /obj/mecha/proc/restore_equipment), (overheat / OVERHEAT_WARNING) SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE) // up to 3 seconds based on heat
	equipment_disabled = TRUE

/obj/mecha/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature>max_temperature)
		log_message("Exposed to dangerous temperature.", LOG_MECHA, color="red")
		take_damage(5, BURN, 0, 1)

/obj/mecha/tool_act(mob/living/user, obj/item/tool, tool_type, params)
	if(istype(tool, /obj/item/mecha_parts/mecha_equipment) && !ismecha(tool.loc))
		return FALSE
	return ..()

/obj/mecha/welder_act(mob/living/user, obj/item/tool, modifiers)
	if(user.combat_mode)
		return FALSE
	if(wrecked)
		try_repair(tool, user)
	else if(atom_integrity < max_integrity)
		while(atom_integrity < max_integrity && tool.use_tool(src, user, 1 SECONDS, volume=50, amount=1, skill_check = SKILL_MECHANICAL))
			if(internal_damage & MECHA_INT_TANK_BREACH)
				clearInternalDamage(MECHA_INT_TANK_BREACH)
				to_chat(user, span_notice("You repair the damaged gas tank."))
			user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to [src]."))
			repair_damage(10)
			if(atom_integrity == max_integrity)
				to_chat(user, span_notice("It looks to be fully repaired now."))
	else
		to_chat(user, span_warning("The [name] is at full integrity!"))
	return TRUE

/obj/mecha/attackby(obj/item/W, mob/living/user, params)
	if(user.combat_mode)
		return ..()

	if(wrecked)
		return try_repair(W, user)

	if(istype(W, /obj/item/mmi))
		if(mmi_move_inside(W,user))
			to_chat(user, "[src]-[W] interface initialized successfully.")
		else
			to_chat(user, "[src]-[W] interface initialization failed.")
		return

	if(istype(W, /obj/item/mecha_ammo))
		ammo_resupply(W, user)
		return
	
	if(istype(W, /obj/item/stack) || istype(W, /obj/item/rcd_ammo) || istype(W, /obj/item/rcd_upgrade))
		if(matter_resupply(W, user))
			return

	if(istype(W, /obj/item/mecha_parts))
		var/obj/item/mecha_parts/P = W
		P.try_attach_part(user, src)
		return

	if(W.GetID())
		if(add_req_access || maint_access)
			if(internals_access_allowed(user))
				output_maintenance_dialog(W.GetID(), user)
				return
			else
				to_chat(user, span_warning("Invalid ID: Access denied."))
		else
			to_chat(user, span_warning("Maintenance protocols disabled by operator."))
	else if(W.tool_behaviour == TOOL_WRENCH)
		if(state==1)
			state = 2
			to_chat(user, span_notice("You undo the securing bolts."))
		else if(state==2)
			state = 1
			to_chat(user, span_notice("You tighten the securing bolts."))
		return
	else if(W.tool_behaviour == TOOL_CROWBAR)
		if(state==2)
			state = 3
			to_chat(user, span_notice("You open the hatch to the power unit."))
		else if(state==3)
			state=2
			to_chat(user, span_notice("You close the hatch to the power unit."))
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		if(state == 3 && (internal_damage & MECHA_INT_SHORT_CIRCUIT))
			var/obj/item/stack/cable_coil/CC = W
			if(CC.use(2))
				clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
				to_chat(user, span_notice("You replace the fused wires."))
			else
				to_chat(user, span_warning("You need two lengths of cable to fix this mech!"))
		return

	else if(istype(W, /obj/item/stock_parts/cell))
		if(state==3)
			if(!cell)
				if(!user.transferItemToLoc(W, src, silent = FALSE))
					return
				var/obj/item/stock_parts/cell/C = W
				to_chat(user, span_notice("You install the power cell."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				cell = C
				log_message("Powercell installed", LOG_MECHA)
			else
				to_chat(user, span_notice("There's already a power cell installed."))
		return

	if(istype(W, /obj/item/stock_parts/scanning_module))
		if(state == 3)
			if(!scanmod)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, span_notice("You install the scanning module."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				scanmod = W
				log_message("[W] installed", LOG_MECHA)
			else
				to_chat(user, span_notice("There's already a scanning module installed."))
		return

	if(istype(W, /obj/item/stock_parts/capacitor))
		if(state == 3)
			if(!capacitor)
				if(!user.transferItemToLoc(W, src))
					return
				to_chat(user, span_notice("You install the capacitor."))
				playsound(src, 'sound/items/screwdriver2.ogg', 50, FALSE)
				capacitor = W
				log_message("[W] installed", LOG_MECHA)
			else
				to_chat(user, span_notice("There's already a capacitor installed."))
		return

	else if(istype(W, /obj/item/airlock_scanner))		//yogs start
		var/obj/item/airlock_scanner/S = W
		S.show_access(src, user)					//yogs end

	else
		return ..()

/obj/mecha/proc/try_repair(obj/item/I, mob/living/user)
	if(!(capacitor || user.skill_check(SKILL_TECHNICAL, EXP_GENIUS) || user.skill_check(SKILL_MECHANICAL, EXP_GENIUS))) // with enough technical wizardry, you can repair ANY mech
		to_chat(user, span_warning("[src] is damaged beyond repair, there is nothing you can do."))
		return
	
	var/effective_skill = user.get_skill(SKILL_MECHANICAL) + capacitor?.rating

	switch(repair_state)
		if(MECHA_WRECK_CUT)
			if(I.tool_behaviour == TOOL_WELDER && !user.combat_mode)
				user.visible_message(
					span_notice("[user] begins to weld together \the [src]'s broken parts..."),
					span_notice("You begin welding together \the [src]'s broken parts..."),
				)
				if(I.use_tool(src, user, 20 SECONDS / effective_skill, amount = 5, volume = 100, skill_check = SKILL_MECHANICAL))
					repair_state = MECHA_WRECK_DENTED
					repair_hint = span_notice("The chassis has suffered major damage and will require the dents to be smoothed out with a <b>welder</b>.")
					to_chat(user, span_notice("The parts are loosely reattached, but are dented wildly out of place."))

		if(MECHA_WRECK_DENTED)
			if(I.tool_behaviour == TOOL_WELDER && !user.combat_mode)
				user.visible_message(
					span_notice("[user] welds out the many, many dents in \the [src]'s chassis..."),
					span_notice("You weld out the many, many dents in \the [src]'s chassis..."),
				)
				if(I.use_tool(src, user, 20 SECONDS / effective_skill, amount = 5, volume = 100, skill_check = SKILL_MECHANICAL))
					repair_state = MECHA_WRECK_LOOSE
					repair_hint = span_notice("The mecha wouldn't make it two steps before falling apart. The bolts must be tightened with a <b>wrench</b>.")
					to_chat(user, span_notice("The chassis has been repaired, but the bolts are incredibly loose and need to be tightened."))

		if(MECHA_WRECK_LOOSE)
			if(I.tool_behaviour == TOOL_WRENCH)
				user.visible_message(
					span_notice("[user] slowly tightens the bolts of \the [src]..."),
					span_notice("You slowly tighten the bolts of \the [src]..."),
				)
				if(I.use_tool(src, user, 18 SECONDS / effective_skill, volume = 50, skill_check = SKILL_MECHANICAL))
					repair_state = MECHA_WRECK_UNWIRED
					repair_hint = span_notice("The mech is nearly ready, but the <b>wiring</b> has been fried and needs repair.")
					to_chat(user, span_notice("The bolts are tightened and the mecha is looking as good as new, but the wiring was fried in the destruction and needs repair."))

		if(MECHA_WRECK_UNWIRED)
			if(istype(I, /obj/item/stack/cable_coil) && I.tool_start_check(user, amount=5))
				user.visible_message(
					span_notice("[user] starts repairing the wiring on \the [src]..."),
					span_notice("You start repairing the wiring on \the [src]..."),
				)
				if(I.use_tool(src, user, 12 SECONDS / effective_skill, amount = 5, volume = 50, skill_check = SKILL_MECHANICAL))
					repair_state = MECHA_WRECK_MISSING_CAPACITOR
					repair_hint = span_notice("The wiring is functional, but its <b>capacitor</b> needs to be replaced.")

		if(MECHA_WRECK_MISSING_CAPACITOR)
			if(istype(I, /obj/item/stock_parts/capacitor))
				if(capacitor)
					QDEL_NULL(capacitor)
				capacitor = I
				I.forceMove(src)
				user.visible_message(span_notice("[user] replaces the capacitor of \the [src]."))
				repair_state = MECHA_WRECK_UNSECURED_CAPACITOR
				repair_hint = span_notice("The capacitor has been replaced and needs to be <b>secured</b>.")

		if(MECHA_WRECK_UNSECURED_CAPACITOR)
			if(I.tool_behaviour == TOOL_SCREWDRIVER)
				I.play_tool_sound()
				user.visible_message(
					span_notice("[user] finishes repairing \the [src]!"),
					span_notice("You finish repairing \the [src]!"),
				)
				atom_fix()

/obj/mecha/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!attacking_item.force)
		return

	log_message("Attacked by [attacking_item]. Attacker - [user]", LOG_MECHA)
	var/attack_direction = get_dir(src, user)
	var/demolition_mult = attacking_item.demolition_mod
	if(!HAS_TRAIT(attacking_item, TRAIT_SHIELDBUSTER)) // Supercharged vxtvul hammer cares not for your "armor"
		demolition_mult = istype(src, /obj/mecha/combat) ? min((1 + demolition_mult) / 2, 2) : ((1 + demolition_mult) / 2) // combat mechs capped at 2x modifier
	var/damage = take_damage(attacking_item.force * demolition_mult, attacking_item.damtype, MELEE, 1, attack_direction, armour_penetration = attacking_item.armour_penetration)
	var/damage_verb = "hit"
	if(demolition_mult > 1 && damage)
		damage_verb = "pulverized"
	else if(demolition_mult < 1)
		damage_verb = "ineffectively pierced"

	visible_message(span_danger("[user] [damage_verb] [src] with [attacking_item][damage ? "" : ", without leaving a mark"]!"), null, null, COMBAT_MESSAGE_RANGE)
	//only witnesses close by and the victim see a hit message.
	log_combat(user, src, "attacked", attacking_item)

/obj/mecha/proc/mech_toxin_damage(mob/living/target)
	playsound(src, 'sound/effects/spray2.ogg', 50, 1)
	if(target.reagents)
		if(target.reagents.get_reagent_amount(/datum/reagent/cryptobiolin) + force < force*2)
			target.reagents.add_reagent(/datum/reagent/cryptobiolin, force/2)
		if(target.reagents.get_reagent_amount(/datum/reagent/toxin) + force < force*2)
			target.reagents.add_reagent(/datum/reagent/toxin, force/2.5)


/obj/mecha/mech_melee_attack(obj/mecha/M, punch_force, equip_allowed = TRUE)
	log_combat(M.occupant, src, "attacked", M, "(COMBAT MODE: [M.occupant.combat_mode ? "ON" : "OFF"]) (DAMTYPE: [uppertext(M.damtype)])")
	return ..(M, punch_force / 2, equip_allowed)

/obj/mecha/proc/full_repair(charge_cell)
	update_integrity(max_integrity)
	if(cell && charge_cell)
		cell.charge = cell.maxcharge
	if(internal_damage & MECHA_INT_FIRE)
		clearInternalDamage(MECHA_INT_FIRE)
	if(internal_damage & MECHA_INT_TEMP_CONTROL)
		clearInternalDamage(MECHA_INT_TEMP_CONTROL)
	if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
		clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
	if(internal_damage & MECHA_INT_TANK_BREACH)
		clearInternalDamage(MECHA_INT_TANK_BREACH)
	if(internal_damage & MECHA_INT_CONTROL_LOST)
		clearInternalDamage(MECHA_INT_CONTROL_LOST)

/obj/mecha/narsie_act()
	emp_act(EMP_HEAVY)

/obj/mecha/ratvar_act()
	if((GLOB.ratvar_awakens || GLOB.clockwork_gateway_activated) && occupant)
		if(is_servant_of_ratvar(occupant)) //reward the minion that got a mech by repairing it
			full_repair(TRUE)
		else
			var/mob/living/L = occupant
			go_out(TRUE)
			if(L)
				L.ratvar_act()

/obj/mecha/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect)
		if(selected)
			used_item = selected
		else if(!visual_effect_icon)
			visual_effect_icon = ATTACK_EFFECT_SMASH
			if(damtype == BURN)
				visual_effect_icon = ATTACK_EFFECT_MECHFIRE
			else if(damtype == TOX)
				visual_effect_icon = ATTACK_EFFECT_MECHTOXIN
	return ..()

/obj/mecha/atom_break(damage_flag)
	. = ..()
	wrecked = TRUE
	repair_state = MECHA_WRECK_CUT
	repair_hint = span_notice("The parts are scattered apart, but can be <b>welded</b> back together.")
	move_resist = MOVE_RESIST_DEFAULT
	atom_integrity = integrity_failure // don't skip the wreckage state
	force_eject_occupant()
	update_appearance(UPDATE_ICON)
	if(self_destruct)
		audible_message("*beep* *beep* *beep*")
		playsound(src, 'sound/machines/triple_beep.ogg', 75, TRUE)
		addtimer(CALLBACK(src, PROC_REF(detonate), self_destruct), 0.5 SECONDS)

/obj/mecha/proc/detonate(explosion_size, self_delete = TRUE)
	if(QDELETED(src))
		return
	explosion(get_turf(src), round(explosion_size / 4), round(explosion_size / 2), round(explosion_size))
	if(self_delete)
		qdel(src)

/obj/mecha/atom_fix()
	. = ..()
	if(!wrecked)
		return
	wrecked = FALSE
	repair_state = 0
	repair_hint = ""
	move_resist = initial(move_resist)
	update_integrity(max_integrity)
	update_appearance(UPDATE_ICON)
