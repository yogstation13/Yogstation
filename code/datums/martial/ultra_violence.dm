#define IPCMARTIAL "ipcmartialtrait"
#define GUN_HAND "HG"
#define BLOOD_BURST "HH"
#define MAX_DASH_DIST 4
#define DASH_SPEED 2

#define STYLE_REVOLVER "revolver"
#define STYLE_SHOTGUN "shotgun"
#define STYLE_PUNCH "punch"
#define STYLE_TYPES list(STYLE_REVOLVER, STYLE_SHOTGUN, STYLE_PUNCH)

/datum/martial_art/ultra_violence
	name = "Ultra Violence"
	id = MARTIALART_ULTRAVIOLENCE
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/ultra_violence_help
	gun_exceptions = list(/obj/item/gun/ballistic/revolver/ipcmartial)
	no_gun_message = "This gun is not compliant with Ultra Violence standards."
	martial_traits = list(TRAIT_NOSOFTCRIT, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_NOLIMBDISABLE, TRAIT_NO_STUN_WEAPONS, TRAIT_NO_PUNCH_STUN, TRAIT_NO_BLOCKING, TRAIT_NODISMEMBER, TRAIT_STUNIMMUNE, TRAIT_SLEEPIMMUNE, TRAIT_NO_HOLDUP)
	///used to keep track of the dash stuff
	var/dashing = FALSE
	var/dashes = 3
	var/dash_timer = null
	var/style = 1
	var/list/freshness = list(STYLE_REVOLVER = 1.5, STYLE_SHOTGUN = 1.5, STYLE_PUNCH = 1.5)
	var/hard_damage = 0 // temporary reduction to max health when you take damage
	COOLDOWN_DECLARE(next_parry) // so you can't just spam it

/datum/martial_art/ultra_violence/can_use(mob/living/carbon/human/H)
	if(H.stat == DEAD || H.IsUnconscious() || H.incapacitated(TRUE, TRUE) || HAS_TRAIT(H, TRAIT_PACIFISM))//extra pacifism check because it does weird shit
		return FALSE
	return isipc(H)

/datum/martial_art/ultra_violence/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)//A is user, D is target
	if(!can_use(A) || D.stat == DEAD)//stop hitting a corpse
		return FALSE

	if(A == D)
		return FALSE

	if(findtext(streak, BLOOD_BURST))
		streak = ""
		blood_burst(A,D)
		return TRUE

	if(findtext(streak, GUN_HAND))
		streak = ""
		gun_hand(A, D)
		return TRUE

/datum/martial_art/ultra_violence/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return TRUE  //no disarming

/datum/martial_art/ultra_violence/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	check_streak(A,D)
	if(D.stat != DEAD)//feedback to know the click landed, but only if it's actually able to do something
		playsound(A, 'sound/items/change_jaws.ogg', 20, FALSE)//changed to be distinct from new IPC walk sound
	return TRUE //no grabbing either

/datum/martial_art/ultra_violence/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	check_streak(A,D)
	if(A != D) // why are you hitting yourself
		handle_style(A, 0.1, STYLE_PUNCH)
	return FALSE

/datum/martial_art/ultra_violence/proc/on_click(mob/living/carbon/human/H, atom/target, params) //moved this here because it's not just for dashing anymore
	var/list/modifiers = params2list(params)
	if(!can_use(H) || modifiers[SHIFT_CLICK] || modifiers[CTRL_CLICK] || modifiers[ALT_CLICK])
		return NONE

	H.face_atom(target)
	if(modifiers[RIGHT_CLICK])
		if(H == target)
			pocket_pistol(H, target) // right click yourself to pull out your gun
			return COMSIG_MOB_CANCEL_CLICKON
		else if(get_dist(H, target) <= 1 && ishuman(target))
			if(H.next_move <= world.time)
				grab_act(H, target) // right click in melee to complete gun hand combo
				check_streak(H, target)
				return COMSIG_MOB_CANCEL_CLICKON
		else
			dash(H, target) // right click at range for dash
			return COMSIG_MOB_CANCEL_CLICKON
	else if(H.combat_mode && get_turf(H) != get_turf(target) && !H.get_active_held_item() && !isitem(target))
		parry(H, target) // left click for parry
		return COMSIG_MOB_CANCEL_CLICKON
	return NONE

/*---------------------------------------------------------------

	start of blood burst section

---------------------------------------------------------------*/
/datum/martial_art/ultra_violence/proc/blood_burst(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.add_mob_blood(D)
	D.apply_damage(16, BRUTE, A.zone_selected, wound_bonus = 5, bare_wound_bonus = 5, sharpness = SHARP_EDGED)//between 21 and 30 brute damage, 16 of which is sharp and can wound
	D.bleed(20)
	D.add_splatter_floor(D.loc, TRUE)

	new /obj/effect/gibspawner/generic(D.loc)

	if(D.health <= HEALTH_THRESHOLD_FULLCRIT)
		D.bleed(130)
		D.death()
		A.balloon_alert(A, "+SPLATTERED")
		handle_style(A, 1) // gain an additional style level on execution
		blood_heal(A, 40) //bonus healing to incentivise execution
		new /obj/effect/gibspawner/generic(D.loc)
	handle_style(A, 0.4, STYLE_PUNCH)

/datum/martial_art/ultra_violence/proc/blood_heal(mob/living/carbon/human/H, amount)
	var/heal_amt = clamp(amount, 0, H.getBruteLoss() + H.getFireLoss() - hard_damage) //now introducing hard damage, a reason to actually dodge and parry things
	H.heal_ordered_damage(heal_amt / 2, list(BRUTE, BURN), BODYPART_ANY) // splits the damage between brute and burn as evenly as possible
	H.heal_ordered_damage(heal_amt / 2, list(BURN, BRUTE), BODYPART_ANY)
	H.set_nutrition(min(H.nutrition + (amount / 2), NUTRITION_LEVEL_ALMOST_FULL)) // BLOOD IS FUEL

/*---------------------------------------------------------------

	end of blood burst section

---------------------------------------------------------------*/
/*---------------------------------------------------------------

	start of pocket pistol section

---------------------------------------------------------------*/
/datum/martial_art/ultra_violence/proc/pocket_pistol(mob/living/carbon/human/A)
	var/obj/item/gun/ballistic/revolver/ipcmartial/gun = locate() in A // check if they already had one
	playsound(A, 'sound/items/change_jaws.ogg', 20, FALSE)//changed to be distinct from new IPC walk sound
	if(gun)
		to_chat(A, span_notice("You reload your revolver."))
		gun.magazine.top_off()
	if(style >= 8 || !gun) // can dual wield at the max style level
		gun = new(A)   ///I don't check does the user have an item in a hand, because it is a martial art action, and to use it... you need to have a empty hand
		to_chat(A, span_notice("You whip out your revolver."))
		gun.gun_owner = A
	A.put_in_hands(gun)
	streak = ""

/obj/item/gun/ballistic/revolver/ipcmartial
	desc = "Your trusty revolver."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/ipcmartial
	can_be_sawn_off  = FALSE
	var/mob/gun_owner
	spread = 0
	semi_auto_spread = 0
	slot_flags = 0 // so it doesn't get stuck on your belt

/obj/item/ammo_box/magazine/internal/cylinder/ipcmartial
	name = "\improper Piercer cylinder"
	ammo_type = /obj/item/ammo_casing/ipcmartial
	caliber = CALIBER_357MAG
	max_ammo = 3

/obj/item/ammo_casing/ipcmartial
	name = ".357 sharpshooter bullet casing"
	desc = "A .357 sharpshooter bullet casing."
	caliber = CALIBER_357MAG
	projectile_type = /obj/projectile/bullet/ipcmartial
	click_cooldown_override = 0.1 //this gun shoots faster

/obj/projectile/bullet/ipcmartial //literally just default 357 with mob piercing
	name = ".357 sharpshooter bullet"
	damage = 30 // can't 3-shot against sec armor
	armour_penetration = 15
	wound_bonus = -45
	wound_falloff_tile = -2.5
	ricochets_max = 1 // so you can't use it in a small room to obliterate everyone inside
	ricochet_chance = INFINITY // ALWAYS ricochet
	penetrations = INFINITY
	can_ricoshot = ALWAYS_RICOSHOT // +RICOSHOT

/obj/projectile/bullet/ipcmartial/on_hit(atom/target, blocked)
	. = ..()
	if(!isliving(target)) // don't gain style from hitting an object
		return .
	var/mob/living/L = target
	if(L.stat == DEAD)
		return . // no using dead bodies to gain style, that's boring and uncool KILL SOME REAL THINGS
	if(ishuman(firer) && firer != target) // WHY ARE YOU SHOOTING YOURSELF
		var/mob/living/carbon/human/H = firer
		if(H.mind?.has_martialart(MARTIALART_ULTRAVIOLENCE))
			var/datum/martial_art/ultra_violence/UV = H.mind.martial_art
			if(ricochets) // the most powerful weapon: coins
				UV.handle_style(H, 1)
				H.balloon_alert(H, "+RICOSHOT")
			UV.handle_style(H, 0.1 * damage / initial(damage), STYLE_REVOLVER)
	if(ishuman(target) && !blocked)
		var/mob/living/carbon/human/H = target
		H.add_splatter_floor(H.loc, TRUE)//janitors everywhere cry when they hear that an ipc is going off
	ricochets = ricochets_max // so you can't shoot through someone to ricochet and hit them twice for 70 damage in one shot
	damage -= 20
	if(damage <= 0)
		qdel(src)

/obj/projectile/bullet/ipcmartial/on_ricochet(atom/A)
	damage += 10 // more damage if you ricochet it, good luck hitting it consistently though
	speed *= 0.5 // faster so it can hit more reliably
	penetrations = 0
	return ..()

/obj/projectile/bullet/ipcmartial/check_ricochet()
	return TRUE

/obj/projectile/bullet/ipcmartial/check_ricochet_flag(atom/A)
	return !ismob(A) // don't ricochet off of mobs, that would be weird

/obj/item/gun/ballistic/revolver/ipcmartial/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "martial")
	RegisterSignal(src, COMSIG_ITEM_PREDROPPED, PROC_REF(on_drop))

/obj/item/gun/ballistic/revolver/ipcmartial/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	if(!magazine.ammo_count(FALSE))//if it's out of ammo delete it
		qdel(src)

/obj/item/gun/ballistic/revolver/ipcmartial/attack_self(mob/living/A)
	to_chat(A, span_notice("You stash your revolver away."))
	qdel(src)

/obj/item/gun/ballistic/revolver/ipcmartial/proc/on_drop()//to let people drop it early with Q rather than attack self
	var/mob/living/carbon/human/holder = src.loc
	if(istype(holder))
		to_chat(holder, span_notice("You relax your gun hand."))
	qdel(src)

/*---------------------------------------------------------------

	end of pocket pistol section

---------------------------------------------------------------*/
/*---------------------------------------------------------------

	start of shotgun punch section

---------------------------------------------------------------*/

/datum/martial_art/ultra_violence/proc/gun_hand(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/obj/item/ammo_casing/a357/ironfeather/ammo = new /obj/item/ammo_casing/a357/ironfeather()
	A.put_in_active_hand(ammo)
	ammo.fire_casing(D, A)
	if(!QDELETED(ammo))
		ammo.moveToNullspace()//get rid of the spent casing
		QDEL_NULL(ammo)

	handle_style(A, 0.5, STYLE_SHOTGUN)
	playsound(A, "sound/weapons/shotgunshot.ogg", 90, FALSE)
	to_chat(A, span_notice("You shoot [D] with your gun hand."))
	D.add_splatter_floor(D.loc, TRUE)
	streak = ""

/*---------------------------------------------------------------

	end of shotgun punch section

---------------------------------------------------------------*/
/*---------------------------------------------------------------
	start of dash section
	i know, it's super snowflakey to do it this way instead of just making it an ability
	however, i want it to be more fluid by having it be in place of an intent
---------------------------------------------------------------*/

/datum/martial_art/ultra_violence/proc/regen_dash(mob/living/carbon/human/H)
	dashes += 1
	dashes = clamp(dashes, 0, 3)
	if(dashes == 3)
		deltimer(dash_timer)//stop regen when full
	H.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)

/datum/martial_art/ultra_violence/proc/dash(mob/living/carbon/human/H, atom/A)
	if(dashing)
		return

	if(dashes <= 0)
		to_chat(H, span_alertsyndie("You are out of dash charges!"))
		return

	else
		H.apply_status_effect(STATUS_EFFECT_DODGING)
		playsound(H, 'sound/effects/dodge.ogg', 50)
		dash_timer = addtimer(CALLBACK(src, PROC_REF(regen_dash), H), 4 SECONDS, TIMER_LOOP|TIMER_UNIQUE|TIMER_STOPPABLE)//start regen
		H.Immobilize(1 SECONDS, ignore_canstun = TRUE) //to prevent cancelling the dash
		dashing = TRUE
		H.throw_at(A, MAX_DASH_DIST, DASH_SPEED, H, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(dash_end), H))
		dashes -= 1
		H.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)

/datum/martial_art/ultra_violence/proc/dash_end(mob/living/carbon/human/H)
	dashing = FALSE
	H.SetImmobilized(0 SECONDS, ignore_canstun = TRUE)

/datum/martial_art/ultra_violence/handle_throw(atom/hit_atom, mob/living/carbon/human/A, datum/thrownthing/throwingdatum)
	if(!dashing)
		return ..()
	return TRUE

/*---------------------------------------------------------------

	end of dash section

---------------------------------------------------------------*/
/*---------------------------------------------------------------

	start of parry section

---------------------------------------------------------------*/

// really hard to pull off but it's cool as hell when you do
/datum/martial_art/ultra_violence/proc/parry(mob/living/carbon/human/H, atom/target)
	if(!COOLDOWN_FINISHED(src, next_parry))
		return
	var/parry_angle = round(get_angle(H, target), 45)
	var/turf/starting_turf = get_turf(H)
	var/turf/center_turf = get_step(starting_turf, angle2dir(parry_angle))
	var/list/parried_tiles = spiral_range_turfs(1, center_turf)
	var/successful_parry = FALSE

	// parry time
	var/list/punch_targets = list()
	for(var/turf/parried_tile in parried_tiles)
		for(var/thing in parried_tile.contents)
			if(ismob(thing) && H != thing && get_dist(H, thing) <= 1)
				punch_targets |= thing
			if(isprojectile(thing))
				var/obj/projectile/P = thing
				P.firer = H
				P.damage *= 1.5
				P.speed *= 0.5
				P.impacted = list()
				P.fire(get_angle(H, target)) // parry the projectile towards wherever you clicked
				successful_parry = TRUE
	
	// all roads lead to COMSIG_MOB_CANCEL_CLICKON so do the normal punch on the enemy in front of you
	if(punch_targets.len > 0) 
		var/mob/living/living_target = get_closest_atom(/mob/living, punch_targets, center_turf)
		if(living_target)
			H.UnarmedAttack(living_target, TRUE, list())

	// style bonus for successful parry
	if(successful_parry)
		H.visible_message(span_danger("[H] parries the projectile!"))
		H.balloon_alert(H, "+PARRY")
		handle_style(H, 0.5)
		playsound(H, 'sound/weapons/ricochet.ogg', 75, 1)
		COOLDOWN_START(src, next_parry, CLICK_CD_MELEE * H.next_move_modifier * 0.5)
	else
		playsound(H, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		COOLDOWN_START(src, next_parry, CLICK_CD_MELEE * H.next_move_modifier)
	H.do_attack_animation(center_turf)
	new /obj/effect/temp_visual/dir_setting/firing_effect/sweep_attack(get_turf(H), angle2dir(parry_angle))

/*---------------------------------------------------------------

	end of parry section

---------------------------------------------------------------*/
/*---------------------------------------------------------------

	SSSTYLE

---------------------------------------------------------------*/
/datum/martial_art/ultra_violence/proc/handle_style(mob/living/carbon/human/H, amount = 0, style_type = "")
	var/old_style = style

	//adjust the style gain based on weapon freshness
	if(amount)
		if(style_type in STYLE_TYPES)
			amount *= freshness[style_type]
		style = clamp(style + amount, 1, 8.99)
	else
		style = clamp(style - (0.01*round(style**1.5)), 1, 8.99) // style decays faster the more you have

	//now update the HUD and made adjustments based on style level
	if(round(style) != round(old_style))
		if(style <= 1)
			H.clear_alert("style_level")
		else
			H.throw_alert("style_level", /atom/movable/screen/alert/style, round(style))
		H.next_move_modifier /= (24 - round(old_style)) / 24
		H.next_move_modifier *= (24 - round(style)) / 24
		if(style >= 2)
			H.add_movespeed_modifier("style_speed", update=TRUE, priority=101, multiplicative_slowdown = style / -10, blacklisted_movetypes=(FLOATING))
		else
			H.remove_movespeed_modifier("style_speed")

	//reduce freshness of the weapon used and increase freshness of the other weapons
	for(var/fresh_type in STYLE_TYPES)
		if(fresh_type == style_type)
			freshness[fresh_type] = clamp(freshness[fresh_type] - (amount / 2), 0, 1.5)
		else
			freshness[fresh_type] = clamp(freshness[fresh_type] + max(0.02, (amount / 2) * style), 0, 1.5)

/*---------------------------------------------------------------

	end of style section

---------------------------------------------------------------*/
/*---------------------------------------------------------------

	training related section

---------------------------------------------------------------*/
/mob/living/carbon/human/proc/ultra_violence_help()
	set name = "Cyber Grind"
	set desc = "You mentally practice the teachings of Ultra Violence."
	set category = "Ultra Violence"
	to_chat(usr, "<b><i>You search your data banks for techniques of Ultra Violence.</i></b>")

	to_chat(usr, span_notice("This module has made you a hell-bound killing machine."))
	to_chat(usr, span_notice("You are immune to stuns and cannot be slowed by damage."))
	to_chat(usr, span_notice("You will deflect emps while throwmode is enabled, releases the energy into anyone nearby."))
	to_chat(usr, span_warning("Your disarm has been replaced with a charged-based dash system."))
	to_chat(usr, span_warning("Your punch now has the ability to parry projectiles in the direction of your click.")) //seriously, no pushing or clinching, that's boring, just kill
	to_chat(usr, span_notice("<b>Getting covered in blood will heal you, but taking too much damage will build up \"hard damage\" which cannot be healed and decays over time.</b>"))

	to_chat(usr, "[span_notice("Dash")]: Right click away from you to dash in a direction granting brief invulnerability.")
	to_chat(usr, "[span_notice("Pocket Revolver")]: Right-click yourself. Puts a loaded revolver in your hand for three shots. Target must be living, but can be yourself.")
	to_chat(usr, "[span_notice("Gun Hand")]: Punch, then shove. Shoots the target with the shotgun in your hand.")
	to_chat(usr, "[span_notice("Blood Burst")]: Punch twice. Explodes blood from the target, covering you in blood and healing for a bit. Executes people in hardcrit exploding more blood everywhere and giving a style bonus.")
	to_chat(usr, span_notice("Avoiding damage and using a variety of techniques will increase your style, which gives a speed boost and makes hard damage decay faster.")) // if you want to go fast you need to earn it
	to_chat(usr, span_notice("Should your dash cease functioning, use the 'Reinitialize Module' function."))

/datum/martial_art/ultra_violence/teach(mob/living/carbon/human/H, make_temporary=0)//brace your eyes for this mess of buffs
	..()
	H.dna.species.attack_sound = 'sound/weapons/shotgunshot.ogg'
	H.dna.species.punchdamagelow += 4
	H.dna.species.punchdamagehigh += 4 //no fancy comboes, just punches
	H.dna.species.staminamod = 0 //my god, why must you make me add all these additional things, stop trying to disable them, just kill them
	RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(on_click)) // death to click_intercept
	H.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)
	H.dna.species.GiveSpeciesFlight(H)//because... c'mon

/datum/martial_art/ultra_violence/on_remove(mob/living/carbon/human/H)
	..()
	H.dna.species.attack_sound = initial(H.dna.species.attack_sound) //back to flimsy tin tray punches
	H.dna.species.punchdamagelow -= 4
	H.dna.species.punchdamagehigh -= 4
	H.dna.species.staminamod = initial(H.dna.species.staminamod)
	UnregisterSignal(H, COMSIG_MOB_CLICKON)
	deltimer(dash_timer)
	H.clear_alert("dash_charge")
	//not likely they'll lose the martial art i guess, so i guess they can keep the wings since i don't know how to remove them

#undef GUN_HAND
#undef BLOOD_BURST
#undef MAX_DASH_DIST
#undef DASH_SPEED
#undef IPCMARTIAL
#undef STYLE_REVOLVER
#undef STYLE_SHOTGUN
#undef STYLE_PUNCH
#undef STYLE_TYPES
