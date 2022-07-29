/// How many tiles around the target the shooter can roam without losing their shot
#define GUNPOINT_SHOOTER_STRAY_RANGE 2
/// How long it takes from the gunpoint is initiated to reach stage 2
#define GUNPOINT_DELAY_STAGE_2 2.5 SECONDS
/// How long it takes from stage 2 starting to move up to stage 3
#define GUNPOINT_DELAY_STAGE_3 7.5 SECONDS
/// If the projectile doesn't have a wound_bonus of CANT_WOUND, we add (this * the stage mult) to their wound_bonus and bare_wound_bonus upon triggering
#define GUNPOINT_BASE_WOUND_BONUS	5
/// How much the damage and wound bonus mod is multiplied when you're on stage 1
#define GUNPOINT_MULT_STAGE_1 1
/// As above, for stage 2
#define GUNPOINT_MULT_STAGE_2 2
/// As above, for stage 3
#define GUNPOINT_MULT_STAGE_3 2.5


/datum/component/gunpoint
	dupe_mode = COMPONENT_DUPE_ALLOWED

	var/mob/living/target
	var/obj/item/gun/weapon

	var/stage = 1
	var/datum/status_effect/status_hold_up
	var/datum/status_effect/status_held_up
	var/damage_mult = GUNPOINT_MULT_STAGE_1

	var/point_of_no_return = FALSE

	var/disrupted = FALSE

// *extremely bad russian accent* no!
/datum/component/gunpoint/Initialize(mob/living/targ, obj/item/gun/wep)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/shooter = parent
	target = targ
	weapon = wep
	RegisterSignal(targ, COMSIG_MOVABLE_MOVED, .proc/check_movement, FALSE) //except this one
	RegisterSignal(targ, list(COMSIG_MOB_ATTACK_HAND, COMSIG_MOB_FIRED_GUN, COMSIG_MOB_THROW, COMSIG_MOB_ITEM_ATTACK), .proc/trigger_reaction, TRUE) //any actions by the hostage will trigger the shot no exceptions
	RegisterSignal(weapon, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), .proc/cancel)

	shooter.visible_message(span_danger("[shooter] aims [weapon] point blank at [target]!"), \
		span_danger("You aim [weapon] point blank at [target]!"), target)
	to_chat(target, span_userdanger("[shooter] aims [weapon] point blank at you!"))
	if(!target.has_status_effect(STATUS_EFFECT_NOTSCARED))
		target.Immobilize(10) //short immobilize to let them know they're getting shot at
		target.apply_status_effect(STATUS_EFFECT_NOTSCARED)//this can only trigger once per minute so you can't use it to meme people a bunch in a fight

	status_hold_up = shooter.apply_status_effect(STATUS_EFFECT_HOLDUP)
	status_held_up = target.apply_status_effect(STATUS_EFFECT_HELDUP)
	SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "gunpoint", /datum/mood_event/gunpoint)

	addtimer(CALLBACK(src, .proc/update_stage, 2), GUNPOINT_DELAY_STAGE_2)

	check_deescalate() //telekinesis can start this so make sure the user is in range

/datum/component/gunpoint/Destroy(force, silent)
	QDEL_NULL(status_hold_up)
	QDEL_NULL(status_held_up)
	return ..()

/datum/component/gunpoint/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_deescalate)
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, .proc/flinch)
	RegisterSignal(parent, COMSIG_HUMAN_DISARM_HIT, .proc/flinch_disarm)
	RegisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOB_THROW, COMSIG_MOB_FIRED_GUN, COMSIG_MOB_TABLING), .proc/noshooted)

/datum/component/gunpoint/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(parent, COMSIG_HUMAN_DISARM_HIT)
	UnregisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOB_THROW, COMSIG_MOB_FIRED_GUN, COMSIG_MOB_TABLING))

///Update the damage multiplier for whatever stage we're entering into
/datum/component/gunpoint/proc/update_stage(new_stage)
	stage = new_stage
	if(stage == 2)
		to_chat(parent, span_danger("You steady [weapon] on [target]."))
		to_chat(target, span_userdanger("[parent] has steadied [weapon] on you!"))
		damage_mult = GUNPOINT_MULT_STAGE_2
		addtimer(CALLBACK(src, .proc/update_stage, 3), GUNPOINT_DELAY_STAGE_3)
	else if(stage == 3)
		to_chat(parent, span_danger("You have fully steadied [weapon] on [target]."))
		to_chat(target, span_userdanger("[parent] has fully steadied [weapon] on you!"))
		damage_mult = GUNPOINT_MULT_STAGE_3

/datum/component/gunpoint/proc/check_deescalate()
	if(!can_see(parent, target, GUNPOINT_SHOOTER_STRAY_RANGE - 1))
		cancel()

/datum/component/gunpoint/proc/trigger_reaction()
	SEND_SIGNAL(target, COMSIG_CLEAR_MOOD_EVENT, "gunpoint")
	var/mob/living/shooter = parent
	if(disrupted)
		return
	if(point_of_no_return)
		return
	point_of_no_return = TRUE
	shooter.remove_status_effect(STATUS_EFFECT_HOLDUP) // try doing these before the trigger gets pulled since the target (or shooter even) may not exist after pulling the trigger, dig?
	target.remove_status_effect(STATUS_EFFECT_HELDUP)

	if(!weapon.can_shoot() || !weapon.can_trigger_gun(shooter) || (weapon.weapon_weight == WEAPON_HEAVY && shooter.get_inactive_held_item()))
		shooter.visible_message(span_danger("[shooter] fumbles [weapon]!"), \
			span_danger("You fumble [weapon] and fail to fire at [target]!"), target)
		to_chat(target, span_userdanger("[shooter] fumbles [weapon] and fails to fire at you!"))
		qdel(src)
		return
	if(weapon.check_botched(shooter))
		return
	if(weapon.chambered && weapon.chambered.BB)
		weapon.chambered.BB.damage *= damage_mult
		weapon.chambered.BB.stamina *= damage_mult
		if(weapon.chambered.BB.wound_bonus != CANT_WOUND)
			weapon.chambered.BB.wound_bonus += damage_mult * GUNPOINT_BASE_WOUND_BONUS
			weapon.chambered.BB.bare_wound_bonus += damage_mult * GUNPOINT_BASE_WOUND_BONUS

	var/fired = weapon.process_fire(target, shooter)
	if(!fired && weapon.chambered?.BB)
		weapon.chambered.BB.damage /= damage_mult
		if(weapon.chambered.BB.wound_bonus != CANT_WOUND)
			weapon.chambered.BB.wound_bonus -= damage_mult * GUNPOINT_BASE_WOUND_BONUS
			weapon.chambered.BB.bare_wound_bonus -= damage_mult * GUNPOINT_BASE_WOUND_BONUS
		SEND_SIGNAL(target, COMSIG_CLEAR_MOOD_EVENT, "gunpoint")
	qdel(src)

///called if the shooter does anything that would cause the target to move, preventing a charged shot from being fired for a short duration
/datum/component/gunpoint/proc/noshooted()
	if(!disrupted)
		disrupted = TRUE
		addtimer(CALLBACK(src, .proc/reshooted), 5)
		to_chat(parent, span_boldwarning("You lose your aim for a second, try not to bump into things or throw stuff."))

/datum/component/gunpoint/proc/reshooted()
	disrupted = FALSE

/datum/component/gunpoint/proc/cancel()
	var/mob/living/shooter = parent
	shooter.visible_message(span_danger("[shooter] breaks [shooter.p_their()] aim on [target]!"), \
		span_danger("You are no longer aiming [weapon] at [target]."), target)
	to_chat(target, span_userdanger("[shooter] breaks [shooter.p_their()] aim on you!"))
	qdel(src)

/datum/component/gunpoint/proc/check_movement()
	var/mob/living/shooter = parent
	if(!(shooter.pulling == target)) //target won't get shot if they're being moved by the shooter
		trigger_reaction()

///If the shooter is hit by an attack, they have a 50% chance to flinch and fire. If it hit the arm holding the trigger, it's an 80% chance to fire instead
/datum/component/gunpoint/proc/flinch(attacker, damage, damagetype, def_zone)
	var/mob/living/shooter = parent
	if(attacker == shooter)
		return // somehow this wasn't checked for months but no one tried punching themselves to initiate the shot, amazing

	var/flinch_chance = 50
	var/gun_hand = LEFT_HANDS

	if(shooter.held_items[RIGHT_HANDS] == weapon)
		gun_hand = RIGHT_HANDS

	if((def_zone == BODY_ZONE_L_ARM && gun_hand == LEFT_HANDS) || (def_zone == BODY_ZONE_R_ARM && gun_hand == RIGHT_HANDS))
		flinch_chance = 80

	if(prob(flinch_chance))
		shooter.visible_message(span_danger("[shooter] flinches!"), \
			span_danger("You flinch!"))
		trigger_reaction() //flinching will always result in firing at the target

/datum/component/gunpoint/proc/flinch_disarm(attacker,zone_targeted)
	var/mob/living/shooter = parent

	var/flinch_chance = 50
	var/gun_hand = LEFT_HANDS

	if(shooter.held_items[RIGHT_HANDS] == weapon)
		gun_hand = RIGHT_HANDS

	if((zone_targeted == BODY_ZONE_L_ARM && gun_hand == LEFT_HANDS) || (zone_targeted == BODY_ZONE_R_ARM && gun_hand == RIGHT_HANDS))
		flinch_chance = 80

	if(prob(flinch_chance))
		shooter.visible_message(span_danger("[shooter] flinches!"), \
			span_danger("You flinch!"))
		trigger_reaction(TRUE) //flinching will always result in firing at the target

#undef GUNPOINT_SHOOTER_STRAY_RANGE
#undef GUNPOINT_DELAY_STAGE_2
#undef GUNPOINT_DELAY_STAGE_3
#undef GUNPOINT_BASE_WOUND_BONUS
#undef GUNPOINT_MULT_STAGE_1
#undef GUNPOINT_MULT_STAGE_2
#undef GUNPOINT_MULT_STAGE_3
