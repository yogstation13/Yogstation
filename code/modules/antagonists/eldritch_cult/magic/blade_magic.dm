/datum/action/cooldown/spell/jaunt/ethereal_jaunt/blade
	name = "Shadow Passage"
	desc = "A short range spell that allows you to pass unimpeded through walls."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "shadow"
	sound = null

	school = SCHOOL_FORBIDDEN
	cooldown_time = 15 SECONDS

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	exit_jaunt_sound = null
	jaunt_duration = 1.5 SECONDS
	jaunt_in_time = 0.5 SECONDS
	jaunt_out_time = 0.5 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/shadow_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/shadow_shift/out

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/blade/do_steam_effects()
	return

/obj/effect/temp_visual/dir_setting/shadow_shift
	name = "shadow_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadow"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/dir_setting/shadow_shift/out
	icon_state = "uncloak"

/datum/action/cooldown/spell/pointed/projectile/furious_steel
	name = "Furious Steel"
	desc = "Summon three silver blades which orbit you. \
		While orbiting you, these blades will protect you from from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "furious_steel"
	sound = 'sound/weapons/guillotine.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 60 SECONDS
	invocation = "F'LSH'NG S'LV'R!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You summon forth three blades of furious silver."
	deactive_msg = "You conceal the blades of furious silver."
	cast_range = 20
	projectile_type = /obj/projectile/floating_blade
	projectile_amount = 3

	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect

/// Signal proc for [SIGNAL_REMOVETRAIT], via [TRAIT_ALLOW_HERETIC_CASTING], to remove the effect when we lose the focus trait
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_focus_lost(mob/source)
	SIGNAL_HANDLER

	unset_click_ability(source, refund_cooldown = TRUE)

/datum/action/cooldown/spell/pointed/projectile/furious_steel/InterceptClickOn(mob/living/caller, params, atom/target)
	// Let the caster prioritize using items like guns over blade casts
	if(caller.get_active_held_item())
		return FALSE
	// Let the caster prioritize melee attacks like punches and shoves over blade casts
	if(get_dist(caller, target) <= 1)
		return FALSE

	return ..()

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_activation(mob/on_who)
	. = ..()
	if(!.)
		return

	if(!isliving(on_who))
		return
	// Delete existing
	if(blade_effect)
		stack_trace("[type] had an existing blade effect in on_activation. This might be an exploit, and should be investigated.")
		UnregisterSignal(blade_effect, COMSIG_QDELETING)
		QDEL_NULL(blade_effect)

	var/mob/living/living_user = on_who
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, null, projectile_amount, 25, 0.66 SECONDS)
	RegisterSignal(blade_effect, COMSIG_QDELETING, PROC_REF(on_status_effect_deleted))

/datum/action/cooldown/spell/pointed/projectile/furious_steel/on_deactivation(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	QDEL_NULL(blade_effect)

/datum/action/cooldown/spell/pointed/projectile/furious_steel/before_cast(atom/cast_on)
	if(isnull(blade_effect) || !length(blade_effect.blades))
		unset_click_ability(owner, refund_cooldown = TRUE)
		return SPELL_CANCEL_CAST

	return ..()

/datum/action/cooldown/spell/pointed/projectile/furious_steel/fire_projectile(mob/living/user, atom/target)
	. = ..()
	qdel(blade_effect.blades[1])

/datum/action/cooldown/spell/pointed/projectile/furious_steel/ready_projectile(obj/projectile/to_launch, atom/target, mob/user, iteration)
	. = ..()
	to_launch.def_zone = check_zone(user.zone_selected)

/// If our blade status effect is deleted, clear our refs and deactivate
/datum/action/cooldown/spell/pointed/projectile/furious_steel/proc/on_status_effect_deleted(datum/status_effect/protective_blades/source)
	SIGNAL_HANDLER

	blade_effect = null
	on_deactivation()

/obj/projectile/floating_blade
	name = "blade"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	speed = 2
	damage = 25
	armour_penetration = 100
	sharpness = SHARP_EDGED
	wound_bonus = 15
	pass_flags = PASSTABLE

/obj/projectile/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("knife", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 1))

/obj/projectile/floating_blade/on_hit(atom/hit)
	if(isliving(hit) && isliving(firer))
		var/mob/living/caster = firer
		var/mob/living/victim = hit
		if(caster == victim)
			return BULLET_ACT_FORCE_PIERCE

		if(caster.mind)
			var/datum/antagonist/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
			if(monster?.master == caster.mind)
				return BULLET_ACT_FORCE_PIERCE

		if(victim.can_block_magic(MAGIC_RESISTANCE))
			visible_message(span_warning("[src] drops to the ground and melts on contact [victim]!"))
			return BULLET_ACT_FORCE_PIERCE

	return ..()


// Realignment. It's like Fleshmend but solely for stamina damage and stuns. Sec meta
/datum/action/cooldown/spell/realignment
	name = "Realignment"
	desc = "Realign yourself, rapidly regenerating stamina and reducing any stuns or knockdowns. \
		You cannot attack while realigning. Can be casted multiple times in short succession, but each cast lengthens the cooldown."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/obj/implants.dmi'
	button_icon_state = "adrenal"
	// sound = 'sound/magic/whistlereset.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 6 SECONDS
	cooldown_reduction_per_rank = -6 SECONDS // we're not a wizard spell but we use the levelling mechanic
	spell_max_level = 10 // we can get up to / over a minute duration cd time

	invocation = "R'S'T."
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION | SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/realignment/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/realignment/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/realignment)
	to_chat(cast_on, span_notice("We begin to realign ourselves."))

/datum/action/cooldown/spell/realignment/after_cast(atom/cast_on)
	. = ..()
	// With every cast, our spell level increases for a short time, which goes back down after a period
	// and with every spell level, the cooldown duration of the spell goes up
	if(level_spell())
		var/reduction_timer = max(cooldown_time * spell_max_level * 0.5, 1.5 MINUTES)
		addtimer(CALLBACK(src, PROC_REF(delevel_spell)), reduction_timer)

/datum/action/cooldown/spell/realignment/get_spell_title()
	switch(spell_level)
		if(1, 2)
			return "Hasty " // Hasty Realignment
		if(3, 4)
			return "" // Realignment
		if(5, 6, 7)
			return "Slowed " // Slowed Realignment
		if(8, 9, 10)
			return "Laborious " // Laborious Realignment (don't reach here)

	return ""

/datum/status_effect/realignment
	id = "realigment"
	status_type = STATUS_EFFECT_REFRESH
	duration = 8 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/realignment
	tick_interval = 0.2 SECONDS

/datum/status_effect/realignment/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, id)
	owner.add_filter(id, 2, list("type" = "outline", "color" = "#d6e3e7", "size" = 2))
	var/filter = owner.get_filter(id)
	animate(filter, alpha = 127, time = 1 SECONDS, loop = -1)
	animate(alpha = 63, time = 2 SECONDS)
	return TRUE

/datum/status_effect/realignment/on_remove()
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, id)
	owner.remove_filter(id)

/datum/status_effect/realignment/tick(seconds_between_ticks)
	owner.adjustStaminaLoss(-15)
	owner.AdjustAllImmobility(-0.5 SECONDS)

/atom/movable/screen/alert/status_effect/realignment
	name = "Realignment"
	desc = "You're realignment yourself. You cannot attack, but are rapidly regenerating stamina."
	icon_state = "realignment"
