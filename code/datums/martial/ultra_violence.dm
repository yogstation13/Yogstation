#define IPCMARTIAL "ipcmartialtrait"
#define GUN_HAND "GH"
#define POCKET_PISTOL "GG"
#define SUPERKILL "HHHH"
#define HOOK "PP" //the P is for graPPle
#define MAX_DASH_DIST 4
#define DASH_SPEED 2

/datum/martial_art/ultra_violence
	name = "Ultra Violence"
	id = MARTIALART_ULTRAVIOLENCE
	no_guns = TRUE
	deflection_chance = 0
	reroute_deflection = TRUE
	help_verb = /mob/living/carbon/human/proc/ultra_violence_help
	var/datum/action/cooldown/ultrakill_clearstuns/button = new /datum/action/cooldown/ultrakill_clearstuns()
	///used to keep track of the dash stuff
	var/recalibration = /mob/living/carbon/human/proc/violence_recalibration
	var/dashing = FALSE
	var/dashes = 3
	var/dash_timer = null

/datum/action/cooldown/ultrakill_clearstuns
	name = "Clear Stuns"
	desc = "Spend a dash charge to clear all stuns."
	cooldown_time = 10 SECONDS
	button_icon_state = "adrenal"
	var/mob/living/carbon/human/user

/datum/action/cooldown/ultrakill_clearstuns/Activate()
	var/datum/martial_art/ultra_violence/martial_art = user.mind.martial_art
	if(martial_art.dashes < 1)
		return
	user.SetStun(0)
	user.SetKnockdown(0)
	user.SetUnconscious(0)
	user.SetParalyzed(0)
	user.SetImmobilized(0)
	user.adjustStaminaLoss(-75)
	user.set_resting(FALSE)
	user.update_mobility()
	martial_art.dashes -= 1
	user.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, martial_art.dashes)

/datum/martial_art/ultra_violence/can_use(mob/living/carbon/human/H)
	return isipc(H)

/datum/martial_art/ultra_violence/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)//A is user, D is target
	if(!can_use(A) || D.stat == DEAD)//stop hitting a corpse
		return FALSE

	if(findtext(streak, POCKET_PISTOL))
		streak = ""
		pocket_pistol(A,D)
		speed_boost(A, -0.2, "pocketpistol")
		return TRUE

	if(findtext(streak, HOOK) && A == D) //to prevent accidents
		streak = ""
		grapple_hook(A)
		return TRUE

	if(A == D) //you can pull your gun out by "grabbing" yourself, or your hook
		return FALSE

	if(findtext(streak, SUPERKILL))
		streak = ""
		superkill(A,D)
		speed_boost(A, -0.5, "bloodburst")
		return TRUE

	if(findtext(streak, GUN_HAND))
		streak = ""
		gun_hand(A, D)
		speed_boost(A, -0.5, "gunhand")
		return TRUE

/datum/martial_art/ultra_violence/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("P",D)
	check_streak(A,D)
	if(D.stat != DEAD)
		playsound(A, 'sound/effects/snap.ogg', 20, FALSE)
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
	return FALSE

/datum/martial_art/ultra_violence/proc/speed_boost(mob/living/carbon/human/A, strength, tag)
	A.add_movespeed_modifier(tag, update=TRUE, priority=101, multiplicative_slowdown = strength, blacklisted_movetypes=(FLOATING))
	addtimer(CALLBACK(src, PROC_REF(remove_boost), A, tag), 6 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/martial_art/ultra_violence/proc/remove_boost(mob/living/carbon/human/A, tag)
	A.remove_movespeed_modifier(tag)

/*---------------------------------------------------------------

	start of blood burst section 

---------------------------------------------------------------*/
/datum/martial_art/ultra_violence/proc/superkill(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/obj/item/ammo_casing/shotgun/buckshot/syndie/ammo = new /obj/item/ammo_casing/shotgun/buckshot/syndie()
	A.put_in_active_hand(ammo)
	ammo.fire_casing(D, A)
	if(!QDELETED(ammo))
		ammo.moveToNullspace()//get rid of the spent casing
		QDEL_NULL(ammo)

	playsound(A, "sound/weapons/shotgunshot.ogg", 90, FALSE)
	to_chat(A, span_notice("You blast [D] with your gun hand."))

	new /obj/effect/gibspawner/generic(D.loc)

	if(D.health <= HEALTH_THRESHOLD_FULLCRIT)
		D.bleed(130)
		D.death()
		//bonus healing to incentivise execution
		var/heal_amt = 40 //heals brute first, then burn with any excess
		var/brute_before = A.getBruteLoss()
		A.adjustBruteLoss(-heal_amt, FALSE, FALSE, BODYPART_ANY)
		heal_amt -= max(brute_before - A.getBruteLoss(), 0)
		A.adjustFireLoss(-heal_amt, FALSE, FALSE, BODYPART_ANY)
		new /obj/effect/gibspawner/generic(D.loc)
	regen_dash() //Fully recharges stamina

/*---------------------------------------------------------------

	end of blood burst section 

---------------------------------------------------------------*/
/*---------------------------------------------------------------

	start of pocket pistol section 

---------------------------------------------------------------*/
/datum/martial_art/ultra_violence/proc/pocket_pistol(mob/living/carbon/human/A)
	if(dashes < 1)
		to_chat(A, span_notice("You're out of stamina!"))
		return
	if(A.is_holding_item_of_type(/obj/item/gun/ballistic/revolver/ipcmartial))
		to_chat(A, span_notice("You already have a revolver out!"))
		return
	dashes -= 1
	A.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)
	var/obj/item/gun/ballistic/revolver/ipcmartial/gun = new /obj/item/gun/ballistic/revolver/ipcmartial (A)   ///I don't check does the user have an item in a hand, because it is a martial art action, and to use it... you need to have a empty hand
	gun.gun_owner = A
	A.put_in_hands(gun)
	to_chat(A, span_notice("You whip out your revolver."))	
	streak = ""
	
/obj/item/gun/ballistic/revolver/ipcmartial
	desc = "Your trusty revolver."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/ipcmartial
	can_be_sawn_off  = FALSE
	var/mob/gun_owner
	spread = 0
	semi_auto_spread = 0

/obj/item/ammo_box/magazine/internal/cylinder/ipcmartial
	name = "\improper Piercer cylinder"
	ammo_type = /obj/item/ammo_casing/ipcmartial
	caliber = "357"
	max_ammo = 3

/obj/item/ammo_casing/ipcmartial
	name = ".357 piercer bullet casing"
	desc = "A .357 piercer bullet casing."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet/ipcmartial

/obj/item/projectile/bullet/ipcmartial
	name = ".357 piercer bullet"
	damage = 30 //no dumbass the ultrakill revolver doesn't do a fuck ton of damage
	armour_penetration = 0 //to disincentivize spamming from range against tough enemies (maurice reference)
	wound_bonus = -40
	wound_falloff_tile = -2.5
	penetrating = TRUE

/obj/item/projectile/bullet/ipcmartial/on_hit(atom/target, blocked)
	. = ..()
	if(ishuman(target) && !blocked)
		var/mob/living/carbon/human/H = target
		H.add_splatter_floor(H.loc, TRUE)//janitors everywhere cry when they hear that an ipc is going off

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

	playsound(A, "sound/weapons/shotgunshot.ogg", 90, FALSE)
	to_chat(A, span_notice("You shoot [D] with your gun hand."))
	D.add_splatter_floor(D.loc, TRUE)
	dashes += 1
	A.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes + 1)
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
	dashes=3
	H.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)

/datum/martial_art/ultra_violence/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/A)
	if(H.a_intent != INTENT_DISARM || H.stat == DEAD || H.IsUnconscious() || H.IsFrozen() || H.get_active_held_item() || A == H)
		return
	dash(H, A)

/datum/martial_art/ultra_violence/proc/dash(mob/living/carbon/human/H, atom/A)
	if(dashing)
		return

	if(dashes <= 0)
		to_chat(H, span_alertsyndie("You are out of dash charges!"))
		return

	else
		H.apply_status_effect(STATUS_EFFECT_DODGING)
		playsound(H, 'sound/effects/dodge.ogg', 50)
		H.Immobilize(1 SECONDS, ignore_canstun = TRUE) //to prevent cancelling the dash
		dashing = TRUE
		H.throw_at(A, MAX_DASH_DIST, DASH_SPEED, H, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(dash_end), H))
		dashes -= 1
		H.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)

/datum/martial_art/ultra_violence/proc/dash_end(mob/living/carbon/human/H)
	dashing = FALSE
	H.SetImmobilized(0 SECONDS, ignore_canstun = TRUE)

/datum/martial_art/ultra_violence/handle_throw(atom/hit_atom, mob/living/carbon/human/A)
	if(!dashing)
		return ..()
	return TRUE

/*---------------------------------------------------------------

	end of dash section

---------------------------------------------------------------*/

//GRAPPLE HOOK, uses a subtype of nut buster wiresnatcher
/obj/item/gun/magic/wire/ultrakiller
	name = "whiplash"
	desc = "A grappling hook built into your arm."
	max_charges = 1
	ammo_type = /obj/item/ammo_casing/magic/wire/ultrakiller
	var/mob/gun_owner

/obj/item/ammo_casing/magic/wire/ultrakiller
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/item/projectile/wire/ultrakiller
	caliber = "hook"
	icon_state = "hook"

/obj/item/projectile/wire/ultrakiller/on_hit(atom/target)
	var/mob/living/carbon/human/H = firer
	if(!H)
		return
	if(isobj(target)) // If it's an object
		var/obj/item/I = target
		if(!I?.anchored) // Give it to us if it's not anchored
			I.throw_at(get_step_towards(H,I), 8, 2)
			H.visible_message(span_danger("[I] is pulled by [H]'s wire!"))
			if(istype(I, /obj/item/clothing/head))
				H.equip_to_slot_if_possible(I, SLOT_HEAD)
				H.visible_message(span_danger("[H] pulls [I] onto [H.p_their()] head!"))
			else
				H.put_in_hands(I)
			return
		zip(H, target) // Pull us towards it if it's anchored
	if(isliving(target)) // If it's somebody
		var/mob/living/victim = target
		victim.Immobilize(2 SECONDS) //can get some combo going on them
		zip(H, victim)
	if(iswallturf(target)) // If we hit a wall, pull us to it
		var/turf/W = target
		zip(H, W)

/datum/martial_art/ultra_violence/proc/grapple_hook(mob/living/carbon/human/A)
	if(dashes < 1)
		to_chat(A, span_notice("You're out of stamina!"))
		return
	dashes -= 1
	var/obj/item/gun/magic/wire/ultrakiller/gun = new()
	gun.gun_owner = A
	to_chat(A, span_notice("You prepare to use the whiplash."))
	A.put_in_active_hand(gun)

/*---------------------------------------------------------------

	training related section

---------------------------------------------------------------*/
/mob/living/carbon/human/proc/ultra_violence_help()
	set name = "Cyber Grind"
	set desc = "You mentally practice the teachings of Ultra Violence."
	set category = "Ultra Violence"
	to_chat(usr, "<b><i>You search your data banks for techniques of Ultra Violence.</i></b>")

	to_chat(usr, span_notice("This module has made you a hell-bound killing machine."))
	to_chat(usr, span_notice("You cannot be slowed by damage."))
	to_chat(usr, span_notice("You will deflect emps while throwmode is enabled, releasing the energy into anyone nearby."))
	to_chat(usr, span_warning("Your disarm has been replaced with a charged-based dash system."))
	to_chat(usr, span_warning("You cannot grab either, JUST KILL THEM!")) //seriously, no pushing or clinching, that's boring, just kill
	to_chat(usr, span_notice("<b>Getting covered in blood will heal you.</b>"))
	
	to_chat(usr, "[span_notice("Disarm Intent")]: Dash in a direction granting brief invulnerability.")
	to_chat(usr, "[span_notice("Whiplash")]")
	to_chat(usr, "[span_notice("Pocket Revolver")]: Grab Grab. Puts a loaded revolver in your hand for three shots. Target must be living, but can be yourself. Consumes one dash charge.")
	to_chat(usr, "[span_notice("Gun Hand")]: Harm Grab. Shoots the target with a weak shotgun shell. Restores one dash charge.")
	to_chat(usr, "[span_notice("Ultrakill")]: Harm Harm Harm Harm. Blasts the target with a strong shotgun shell, and explodes blood from the target, covering you in blood and healing for a bit. Executes people in hardcrit exploding more blood everywhere. Fully recharges stamina.")
	to_chat(usr, span_notice("Completing any combo will give a speed buff with the strength of the Pocket Revolver speed boost being weaker."))
	to_chat(usr, span_notice("Should your dash cease functioning, use the 'Reinitialize Module' function."))

/mob/living/carbon/human/proc/violence_recalibration()
	set name = "Reinitialize Module"
	set desc = "Turn your Ultra Violence module off and on again to fix problems."
	set category = "Ultra Violence"
	var/list/combined_msg = list()
	combined_msg +=  "<b><i>You reboot your Ultra Violence module to remove any runtime errors.</i></b>"
	to_chat(usr, examine_block(combined_msg.Join("\n")))

	usr.click_intercept = usr.mind.martial_art

/datum/martial_art/ultra_violence/teach(mob/living/carbon/human/H, make_temporary=0)//brace your eyes for this mess of buffs
	..()
	H.dna.species.attack_sound = 'sound/weapons/shotgunshot.ogg'
	H.dna.species.punchdamagelow += 4
	H.dna.species.punchdamagehigh += 4 //no fancy comboes, just punches
	H.dna.species.punchstunthreshold += 50 //disables punch stuns
	ADD_TRAIT(H, TRAIT_NOSOFTCRIT, IPCMARTIAL) //so it's sorta possible to be arrested, counterracts the damage modifiers
	ADD_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, IPCMARTIAL)
	ADD_TRAIT(H, TRAIT_NOLIMBDISABLE, IPCMARTIAL)
	ADD_TRAIT(H, TRAIT_NO_STUN_WEAPONS, IPCMARTIAL)
	ADD_TRAIT(H, TRAIT_NODISMEMBER, IPCMARTIAL)
	H.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)
	add_verb(H, recalibration)
	usr.click_intercept = src //probably breaks something, don't know what though
	H.dna.species.GiveSpeciesFlight(H)//because... c'mon
	button.Grant(H)
	button.user = H

/datum/martial_art/ultra_violence/on_remove(mob/living/carbon/human/H)
	..()
	H.dna.species.attack_sound = initial(H.dna.species.attack_sound) //back to flimsy tin tray punches
	H.dna.species.punchdamagelow -= 4
	H.dna.species.punchdamagehigh -= 4 
	H.dna.species.punchstunthreshold -= 50
	H.dna.species.staminamod = initial(H.dna.species.staminamod)
	REMOVE_TRAIT(H, TRAIT_NOSOFTCRIT, IPCMARTIAL)
	REMOVE_TRAIT(H, TRAIT_NOHARDCRIT, IPCMARTIAL)
	REMOVE_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, IPCMARTIAL)
	REMOVE_TRAIT(H, TRAIT_NOLIMBDISABLE, IPCMARTIAL)
	REMOVE_TRAIT(H, TRAIT_NO_STUN_WEAPONS, IPCMARTIAL)
	REMOVE_TRAIT(H, TRAIT_NODISMEMBER, IPCMARTIAL)
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, IPCMARTIAL)
	deltimer(dash_timer)
	H.clear_alert("dash_charge")
	remove_verb(H, recalibration)
	usr.click_intercept = null //un-breaks the thing that i don't know is broken
	button.Remove(H)
	//not likely they'll lose the martial art i guess, so i guess they can keep the wings since i don't know how to remove them

#undef GUN_HAND
#undef POCKET_PISTOL
#undef BLOOD_BURST
#undef MAX_DASH_DIST
#undef DASH_SPEED
#undef IPCMARTIAL
