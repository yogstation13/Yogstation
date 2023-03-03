GLOBAL_LIST_INIT(guardian_precision_speedup, list(
	1 = -0.5,
	2 = -0.75,
	3 = -1,
	4 = -1.25,
	5 = -1.5
)) //doing this for consistency's sake

/mob/living/simple_animal/hostile/guardian/ClickOn(atom/A, params)
	if(istype(loc, /obj/item/gun/ballistic/revolver/emperor))
		var/obj/item/gun/ballistic/revolver/emperor/gun = loc
		var/turf/turf_to_throw_gun = get_ranged_target_turf(gun, get_dir(A, gun), 1)
		if(gun.process_fire(A, src, TRUE, params) && range > 1) //melee cannot go further if they get dropped on the ground
			gun.throw_at(turf_to_throw_gun, 1, 1, src)
		//gun.afterattack(A, src, 0, params)
	. = ..()

/mob/living/simple_animal/hostile/guardian/moveToNullspace()
	if(stats.ability == /datum/guardian_ability/major/precision)
		var/datum/guardian_ability/major/precision/ability = stats.ability
		QDEL_NULL(ability.gun_form)
	. = ..()

/datum/guardian_ability/major/precision
	name = "Precision"
	desc = "The guardian takes the form of a gun, able to fire precise shots. Recalling boosts your summoner's speed."
	cost = 3
	has_mode = TRUE
	mode_on_msg = span_danger("<B>You transform yourself into your gun form.</B>")
	mode_off_msg = span_danger("<B>You transform yourself into your holoform.</B>")
	arrow_weight = 0.9
	COOLDOWN_DECLARE(runcdindex)
	var/runcooldown = 0
	var/bulletcooldown = 0
	var/obj/item/gun/ballistic/revolver/emperor/gun_form

/datum/guardian_ability/major/precision/Apply()
	. = ..()
	runcooldown = 20 SECONDS / master_stats.speed

/datum/guardian_ability/major/precision/Recall()
	Mode(TRUE)
	. = ..()
	if(COOLDOWN_FINISHED(src, runcdindex))
		guardian.summoner.current.add_movespeed_modifier("I'm out of here", update=TRUE, priority=102, multiplicative_slowdown=GLOB.guardian_precision_speedup[guardian.stats.speed])
		addtimer(CALLBACK(guardian.summoner.current, /mob.proc/remove_movespeed_modifier, "I'm out of here"), master_stats.potential * 2 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
		COOLDOWN_START(src, runcdindex, runcooldown)

/datum/guardian_ability/major/precision/Mode(forced = FALSE)
	if(forced && gun_form)
		REMOVE_TRAIT(guardian, TRAIT_ADVANCEDTOOLUSER, GUARDIAN_TRAIT)
		QDEL_NULL(gun_form)
		guardian.temp_anchored_to_owner = initial(guardian.temp_anchored_to_owner)
		guardian.do_temp_anchor = initial(guardian.do_temp_anchor)
		return
	if(mode)
		ADD_TRAIT(guardian, TRAIT_ADVANCEDTOOLUSER, GUARDIAN_TRAIT)
		guardian.temp_anchored_to_owner = FALSE
		guardian.do_temp_anchor = FALSE
		gun_form = new /obj/item/gun/ballistic/revolver/emperor(get_turf(guardian))
		gun_form.linked_guardian = guardian
		gun_form.name = guardian.name
		guardian.forceMove(gun_form)
		if(guardian.summoner?.current?.Adjacent(get_turf(gun_form)))
			guardian.summoner.current.put_in_active_hand(gun_form)
	else
		REMOVE_TRAIT(guardian, TRAIT_ADVANCEDTOOLUSER, GUARDIAN_TRAIT)
		guardian.forceMove(get_turf(gun_form))
		guardian.temp_anchored_to_owner = initial(guardian.temp_anchored_to_owner)
		guardian.do_temp_anchor = initial(guardian.do_temp_anchor)
		QDEL_NULL(gun_form)

/obj/item/gun/ballistic/revolver/emperor
	name = "Emperor"
	desc = "The gun is mightier than the sword!"
	icon_state = "emperor"
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/emperor
	var/mob/living/simple_animal/hostile/guardian/linked_guardian //ourselves

/obj/item/gun/ballistic/revolver/emperor/Initialize()
	. = ..()
	if(linked_guardian)
		RegisterSignal(linked_guardian, COMSIG_GLOB_MOB_DEATH, .proc/on_guardian_death)
		fire_delay = 10 / linked_guardian.stats.potential

/obj/item/gun/ballistic/revolver/emperor/proc/on_guardian_death()
	UnregisterSignal(linked_guardian, COMSIG_GLOB_MOB_DEATH)
	qdel(src)

/obj/item/gun/ballistic/revolver/emperor/Destroy()
	linked_guardian = null
	return ..()

/obj/item/gun/ballistic/revolver/emperor/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0,cd_override = FALSE)
	. = ..()
	magazine.top_off() //mind bullets baby
	
/obj/item/ammo_box/magazine/internal/cylinder/emperor
	name = "emperor cylinder"
	ammo_type = /obj/item/ammo_casing/a357/emperor

/obj/item/ammo_casing/a357/emperor
	projectile_type = /obj/item/projectile/bullet/a357/emperor

/obj/item/projectile/bullet/a357/emperor
	wound_bonus = -20
	wound_falloff_tile = -2
	penetrating = TRUE
	var/mob/living/simple_animal/hostile/guardian/linked_guardian

/obj/item/projectile/bullet/a357/emperor/Initialize()
	. = ..()
	if(linked_guardian)
		damage = 10 * linked_guardian.stats.damage
		armour_penetration = 5 * linked_guardian.stats.damage
		penetrations = linked_guardian.stats.defense - 1 //sturdy bullet, F defense will not penetrate anything
		penetration_type = FLOOR(linked_guardian.stats.defense / 2, 1) // A & B defense can penetrate mobs, F cannot penetrate and C & D penetrate objects
