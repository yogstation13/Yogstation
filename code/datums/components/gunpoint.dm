#define GUNPOINT_SHOOTER_STRAY_RANGE 3
#define GUNPOINT_DELAY_STAGE_2 20
#define GUNPOINT_DELAY_STAGE_3 80 // cumulative with past stages, so 100 deciseconds
#define GUNPOINT_MULT_STAGE_1 1
#define GUNPOINT_MULT_STAGE_2 2
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
	RegisterSignal(targ, list(COMSIG_MOB_ATTACK_HAND, COMSIG_MOB_ITEM_ATTACK, COMSIG_MOB_THROW, COMSIG_MOB_FIRED_GUN, COMSIG_MOVABLE_MOVED), .proc/trigger_reaction)
	RegisterSignal(weapon, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), .proc/cancel)

	shooter.visible_message("<span class='danger'>[shooter] aims [weapon] point blank at [target]!</span>", \
		"<span class='danger'>You aim [weapon] point blank at [target]!</span>", target)
	to_chat(target, "<span class='userdanger'>[shooter] aims [weapon] point blank at you!</span>")
	if(!target.has_status_effect(STATUS_EFFECT_NOTSCARED))
		target.Immobilize(2) //short immobilize to let them know they're getting shot at without totally stopping them from fighting
		target.apply_status_effect(STATUS_EFFECT_NOTSCARED)//this can only trigger once per minute so you can't use it to meme people a bunch in a fight

	status_hold_up = shooter.apply_status_effect(STATUS_EFFECT_HOLDUP)
	status_held_up = target.apply_status_effect(STATUS_EFFECT_HELDUP)

	addtimer(CALLBACK(src, .proc/update_stage, 2), GUNPOINT_DELAY_STAGE_2)

	check_deescalate() //telekinesis can start this so make sure the user is in range

/datum/component/gunpoint/Destroy(force, silent)
	QDEL_NULL(status_hold_up)
	QDEL_NULL(status_held_up)
	return ..()

/datum/component/gunpoint/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/check_deescalate)
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE, .proc/flinch)
	RegisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOB_THROW, COMSIG_MOB_FIRED_GUN, COMSIG_MOB_TABLING), .proc/noshooted)

/datum/component/gunpoint/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(parent, COMSIG_MOB_APPLY_DAMAGE)
	UnregisterSignal(parent, COMSIG_MOVABLE_BUMP)
	UnregisterSignal(parent, COMSIG_MOB_THROW)
	UnregisterSignal(parent, COMSIG_MOB_FIRED_GUN)

// if you're gonna try to break away from a holdup, better to do it right away
/datum/component/gunpoint/proc/update_stage(new_stage)
	stage = new_stage
	if(stage == 2)
		to_chat(parent, "<span class='danger'>You steady [weapon] on [target].</span>")
		to_chat(target, "<span class='userdanger'>[parent] has steadied [weapon] on you!</span>")
		damage_mult = GUNPOINT_MULT_STAGE_2
		addtimer(CALLBACK(src, .proc/update_stage, 3), GUNPOINT_DELAY_STAGE_3)
	else if(stage == 3)
		to_chat(parent, "<span class='danger'>You have fully steadied [weapon] on [target].</span>")
		to_chat(target, "<span class='userdanger'>[parent] has fully steadied [weapon] on you!</span>")
		damage_mult = GUNPOINT_MULT_STAGE_3

/datum/component/gunpoint/proc/check_deescalate()
	if(!can_see(parent, target, GUNPOINT_SHOOTER_STRAY_RANGE - 1))
		cancel()

/datum/component/gunpoint/proc/trigger_reaction(var/flinch)
	var/mob/living/shooter = parent

	if(flinch != TRUE && shooter.pulling == target) //target won't get shot if they're being moved by the shooter
		return
	if(disrupted)
		return
	if(point_of_no_return)
		return
	point_of_no_return = TRUE

	if(!weapon.can_shoot() || !weapon.can_trigger_gun(shooter) || (weapon.weapon_weight == WEAPON_HEAVY && shooter.get_inactive_held_item()))
		shooter.visible_message("<span class='danger'>[shooter] fumbles [weapon]!</span>", \
			"<span class='danger'>You fumble [weapon] and fail to fire at [target]!</span>", target)
		to_chat(target, "<span class='userdanger'>[shooter] fumbles [weapon] and fails to fire at you!</span>")
		qdel(src)
		return
	if(weapon.check_botched(shooter))
		return
	if(weapon.chambered && weapon.chambered.BB)
		weapon.chambered.BB.damage *= damage_mult

	weapon.process_fire(target, shooter)
	qdel(src)

/datum/component/gunpoint/proc/noshooted()
	if(!disrupted)
		disrupted = TRUE
		addtimer(CALLBACK(src, .proc/reshooted), 5)
		to_chat(parent, "<span class='boldwarning'>You lose your aim for a second, try not to bump into things or throw stuff.</span>")

/datum/component/gunpoint/proc/reshooted()
	disrupted = FALSE

/datum/component/gunpoint/proc/cancel()
	var/mob/living/shooter = parent
	shooter.visible_message("<span class='danger'>[shooter] breaks [shooter.p_their()] aim on [target]!</span>", \
		"<span class='danger'>You are no longer aiming [weapon] at [target].</span>", target)
	to_chat(target, "<span class='userdanger'>[shooter] breaks [shooter.p_their()] aim on you!</span>")
	qdel(src)

/datum/component/gunpoint/proc/flinch(damage, damagetype, def_zone)
	var/mob/living/shooter = parent

	var/flinch_chance = 50
	var/gun_hand = LEFT_HANDS

	if(shooter.held_items[RIGHT_HANDS] == weapon)
		gun_hand = RIGHT_HANDS

	if((def_zone == BODY_ZONE_L_ARM && gun_hand == LEFT_HANDS) || (def_zone == BODY_ZONE_R_ARM && gun_hand == RIGHT_HANDS))
		flinch_chance = 80

	if(prob(flinch_chance))
		shooter.visible_message("<span class='danger'>[shooter] flinches!</span>", \
			"<span class='danger'>You flinch!</span>")
		trigger_reaction(flinch = TRUE) //flinching will always result in firing at the target

#undef GUNPOINT_SHOOTER_STRAY_RANGE
#undef GUNPOINT_DELAY_STAGE_2
#undef GUNPOINT_DELAY_STAGE_3
#undef GUNPOINT_MULT_STAGE_1
#undef GUNPOINT_MULT_STAGE_2
#undef GUNPOINT_MULT_STAGE_3
