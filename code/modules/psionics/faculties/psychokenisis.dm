/datum/psionic_faculty/psychokinesis
	id = PSI_PSYCHOKINESIS
	name = "Psychokinesis"
	armour_types = list(MELEE, BULLET)

/datum/psionic_power/psychokinesis
	faculty = PSI_PSYCHOKINESIS
	use_sound = null

/datum/psionic_power/psychokinesis/psiblade
	name =            "Psiblade/Psibaton"
	cost =            10
	cooldown =        3 SECONDS
	min_rank =        PSI_RANK_OPERANT
	icon_state = "psy_blade"
	use_description = "Summon a psiblade or psibaton, if the user is a pacifist. The power the blade/baton will vary based on your mastery of the faculty."
	use_sound = 'sound/effects/psi/power_fabrication.ogg'
	admin_log = FALSE

/datum/psionic_power/psychokinesis/psiblade/invoke(mob/living/user, mob/living/target, proximity, parameters)
	return FALSE

/datum/psionic_power/psychokinesis/psiblade/on_select(mob/living/user)
	. = ..()
	if(.)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			var/obj/item/melee/classic_baton/psychic_power/psibaton/baton = new /obj/item/melee/classic_baton/psychic_power/psibaton(user, user)
			user.put_in_hands(baton)
			switch(user.psi.get_rank(faculty))
				if(PSI_RANK_PARAMOUNT)
					baton.stamina_damage = 50
				if(PSI_RANK_GRANDMASTER)
					baton.stamina_damage = 40
				if(PSI_RANK_MASTER)
					baton.stamina_damage = 25
				else
					baton.stamina_damage = 15
			return baton
		else
			var/obj/item/psychic_power/psiblade/blade = new /obj/item/psychic_power/psiblade(user, user)
			user.put_in_hands(blade)
			switch(user.psi.get_rank(faculty))
				if(PSI_RANK_PARAMOUNT)
					blade.can_break_wall = TRUE
					blade.wall_break_time = 3 SECONDS
					blade.force = 40
					blade.armour_penetration = 30
				if(PSI_RANK_GRANDMASTER)
					blade.can_break_wall = TRUE
					blade.force = 24
					blade.armour_penetration = 30
				if(PSI_RANK_MASTER)
					blade.force = 18
				else
					blade.force = 12
			return blade

/datum/psionic_power/psychokinesis/tinker
	name =            "Tinker"
	cost =            5
	cooldown =        10
	min_rank =        PSI_RANK_OPERANT
	icon_state = "psy_tinker"
	use_description = "Summon a psychokinetic tool. Use it in-hand to switch between tool types, different tools are available at different psi levels."
	use_sound = 'sound/effects/psi/power_fabrication.ogg'
	admin_log = FALSE

/datum/psionic_power/psychokinesis/tinker/invoke(mob/living/user, mob/living/target, proximity, parameters)
	return FALSE

/datum/psionic_power/psychokinesis/tinker/on_select(mob/living/user)
	. = ..()
	if(.)
		var/obj/item/psychic_power/tinker/tool = new(user)
		user.put_in_hands(tool)
		switch(user.psi.get_rank(faculty))
			if(PSI_RANK_PARAMOUNT)
				tool.possible_tools = list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH, TOOL_WIRECUTTER, TOOL_WELDER, TOOL_MULTITOOL, TOOL_SCALPEL, TOOL_HEMOSTAT, TOOL_RETRACTOR, TOOL_CAUTERY, TOOL_SAW, TOOL_DRILL, TOOL_BONESET, TOOL_MINING, TOOL_SHOVEL, TOOL_HATCHET)
				tool.toolspeed = 0.25
			if(PSI_RANK_GRANDMASTER)
				tool.possible_tools = list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH, TOOL_WIRECUTTER, TOOL_SCALPEL, TOOL_HEMOSTAT, TOOL_RETRACTOR, TOOL_CAUTERY, TOOL_SAW, TOOL_DRILL, TOOL_MINING, TOOL_SHOVEL, TOOL_HATCHET)
				tool.toolspeed = 0.5
			if(PSI_RANK_MASTER)
				tool.possible_tools = list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH, TOOL_WIRECUTTER, TOOL_SCALPEL, TOOL_HEMOSTAT, TOOL_CAUTERY, TOOL_MINING, TOOL_SHOVEL, TOOL_HATCHET)
				tool.toolspeed = 1
			if(PSI_RANK_OPERANT)
				tool.possible_tools = list(TOOL_SCREWDRIVER, TOOL_CROWBAR, TOOL_WRENCH, TOOL_MINING, TOOL_SHOVEL)
				tool.toolspeed = 1.5
		return tool

/datum/psionic_power/psychokinesis/telekinesis
	name =            "Telekinesis"
	cost =            5
	cooldown =        1 SECONDS
	min_rank =        PSI_RANK_GRANDMASTER
	icon_state = "psy_tele"
	use_description = "Click on a distant target while on grab intent to manifest a psychokinetic grip. Use it manipulate objects at a distance."
	admin_log = FALSE
	use_sound = 'sound/effects/psi/power_used.ogg'
	var/list/valid_types = list( //a list of all
		/obj/machinery/door,
		/obj/structure/window,
		/obj/structure/closet,
		/obj/structure/chair
	)

/datum/psionic_power/psychokinesis/telekinesis/New()
	. = ..()
	valid_types = typecacheof(valid_types)

/datum/psionic_power/psychokinesis/telekinesis/invoke(mob/living/user, atom/target, proximity, parameters)
	var/distance = get_dist(user, target)
	if(distance > (user.psi.get_rank(PSI_PSYCHOKINESIS) * 2))
		to_chat(user, span_warning("Your telekinetic power won't reach that far."))
		return FALSE
	if((istype(target, /obj/machinery) || istype(target, /obj/structure)) && !is_type_in_typecache(target, valid_types))
		return FALSE
	. = ..()
	if(.)
		if(istype(target, /obj/structure) || istype(target, /obj/machinery))
			user.visible_message(span_notice("\The [user] makes a strange gesture."))
			user.UnarmedAttack(target, TRUE)
			return TRUE
		else if(istype(target, /mob) || istype(target, /obj))
			var/obj/item/psychic_power/telekinesis/tk = new(user)
			user.put_in_hands(tk)
			if(tk.set_focus(target))
				tk.sparkle()
				user.visible_message(span_notice("\The [user] reaches out."))
				return TRUE
	return FALSE
