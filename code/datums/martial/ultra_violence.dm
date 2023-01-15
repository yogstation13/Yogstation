#define GUN_HAND "GHG"
#define POCKET_PISTOl "GG"
#define BLOOD_BURST "HHH"
#define MAX_DASH_DIST 3

/datum/martial_art/ultra_violence
	name = "Ultra Violence"
	id = MARTIALART_ULTRAVIOLENCE
	no_guns = FALSE
	deflection_chance = 0
	reroute_deflection = TRUE
	help_verb = /mob/living/carbon/human/proc/ultra_violence_help
	///used to keep track of the dash stuff
	var/dashing = FALSE
	var/dashes = 3
	var/dash_timer = null

/datum/martial_art/ultra_violence/can_use(mob/living/carbon/human/H)
	return isipc(H)

/datum/martial_art/ultra_violence/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)//A is user, D is target
	if(!can_use(A) || D.stat == DEAD)//stop hitting a corpse
		return FALSE

	if(findtext(streak, POCKET_PISTOl))
		streak = ""
		pocket_pistol(A,D)
		speed_boost(A, 2 SECONDS, "pocketpistol")
		return TRUE

	if(A == D) //you can pull your gun out by "grabbing" yourself
		return FALSE

	if(findtext(streak, BLOOD_BURST))
		streak = ""
		blood_burst(A,D)
		speed_boost(A, 6 SECONDS, "bloodburst")
		return TRUE

	if(D.health <= HEALTH_THRESHOLD_FULLCRIT) //no getting shotguns off people that aren't fighting back
		return FALSE

	if(findtext(streak, GUN_HAND))
		streak = ""
		gun_hand(A)
		speed_boost(A, 6 SECONDS, "gunhand")
		return TRUE

/datum/martial_art/ultra_violence/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return TRUE  //no disarming

/datum/martial_art/ultra_violence/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	check_streak(A,D)
	if(D.stat != DEAD)//feedback to know the click landed, but only if it's actually able to do something
		playsound(A, 'sound/effects/servostep.ogg', 110, FALSE, -1)//this sound is annoyingly quiet
	return TRUE //no grabbing either

/datum/martial_art/ultra_violence/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	check_streak(A,D)
	return FALSE

/datum/martial_art/ultra_violence/proc/speed_boost(mob/living/carbon/human/A, duration, tag)
	A.add_movespeed_modifier(tag, update=TRUE, priority=101, multiplicative_slowdown = -0.5, blacklisted_movetypes=(FLYING|FLOATING))
	addtimer(CALLBACK(src, .proc/remove_boost, A, tag), duration, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/martial_art/ultra_violence/proc/remove_boost(mob/living/carbon/human/A, tag)
	A.remove_movespeed_modifier(tag)

/datum/martial_art/ultra_violence/proc/blood_burst(mob/living/carbon/human/A, mob/living/carbon/human/D)

	A.add_mob_blood(D)
	D.apply_damage( 6, BRUTE, A.zone_selected, wound_bonus = 5, bare_wound_bonus = 5, sharpness = SHARP_EDGED)//between 11 and 20 brute damage, 6 of which is sharp and can wound
	D.bleed(20)
	D.add_splatter_floor(D.loc, TRUE)

	new /obj/effect/gibspawner/generic(D.loc)

	if(D.health <= HEALTH_THRESHOLD_FULLCRIT)
		D.bleed(130)
		D.death()
		A.adjustBruteLoss(-40, FALSE, FALSE, BODYPART_ANY)
		A.adjustFireLoss(-40, FALSE, FALSE, BODYPART_ANY) //incentivising execution
		new /obj/effect/gibspawner/generic(D.loc)

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
	to_chat(usr, span_notice("You will deflect emps while throwmode is enabled, throwing a lightning bolt if your hands are empty."))
	to_chat(usr, span_notice("After deflecting, or getting hit by an emp you will be immune to more for 5 seconds."))
	to_chat(usr, span_warning("Your disarm has been replaced with a charged-based dash system."))
	to_chat(usr, span_warning("You cannot grab either, JUST KILL THEM!")) //seriously, no pushing or clinching, that's boring, just kill
	to_chat(usr, span_notice("<b>Getting covered in blood will heal you.</b>"))
	
	to_chat(usr, "[span_notice("Disarm Intent")]: Dash in a direction.")
	to_chat(usr, "[span_notice("Pocket Revolver")]: Grab Grab. Puts a loaded revolver in your hand for one shot. Target must be living, but can be yourself.")
	to_chat(usr, "[span_notice("Gun Hand")]: Grab Harm Grab. Puts a loaded shotgun in your hand for one shot. Target must be living and not in crit.")
	to_chat(usr, "[span_notice("Blood Burst")]: Harm Harm Harm. Explodes blood from the target, covering you in blood and healing for a bit. Executes people in hardcrit exploding more blood everywhere.")
	to_chat(usr, span_notice("Completing any combo will give a speed buff with a duration scaling based on combo difficulty."))

/datum/martial_art/ultra_violence/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	H.dna.species.attack_sound = 'sound/weapons/shotgunshot.ogg'
	H.dna.species.punchdamagelow += 4
	H.dna.species.punchdamagehigh += 4 //no fancy comboes, just punches
	H.dna.species.punchstunthreshold += 4
	ADD_TRAIT(H, TRAIT_NOSOFTCRIT, "martial")
	ADD_TRAIT(H, TRAIT_NOLIMBDISABLE, "martial")
	ADD_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, "martial")
	ADD_TRAIT(H, TRAIT_NO_STUN_WEAPONS, "martial")
	ADD_TRAIT(H, TRAIT_NODISMEMBER, "martial")
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, "martial")///mainly so emps don't end you instantly, they still do damage though
	H.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)
	usr.click_intercept = src //probably breaks something, don't know what though
	H.dna.species.GiveSpeciesFlight(H)//because... c'mon

/datum/martial_art/ultra_violence/on_remove(mob/living/carbon/human/H)
	..()
	H.dna.species.attack_sound = initial(H.dna.species.attack_sound) //back to flimsy tin tray punches
	H.dna.species.punchdamagelow -= 4
	H.dna.species.punchdamagehigh -= 4 
	H.dna.species.punchstunthreshold -= 4
	REMOVE_TRAIT(H, TRAIT_NOSOFTCRIT, "martial")
	REMOVE_TRAIT(H, TRAIT_NOLIMBDISABLE, "martial")
	REMOVE_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, "martial")
	REMOVE_TRAIT(H, TRAIT_NO_STUN_WEAPONS, "martial")
	REMOVE_TRAIT(H, TRAIT_NODISMEMBER, "martial")
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, "martial")
	deltimer(dash_timer)
	H.clear_alert("dash_charge")
	usr.click_intercept = null //un-breaks the thing that i don't know is broken
	//not likely they'll lose the martial art i guess, so i guess they can keep the wings since i don't know how to remove them

/*---------------------------------------------------------------

	start of pocket pistol section 

---------------------------------------------------------------*/
/datum/martial_art/ultra_violence/proc/pocket_pistol(mob/living/carbon/human/A)
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
	item_flags = DROPDEL

/obj/item/ammo_box/magazine/internal/cylinder/ipcmartial
	name = "\improper Piercer cylinder"
	ammo_type = /obj/item/ammo_casing/ipcmartial
	caliber = "357"
	max_ammo = 1

/obj/item/ammo_casing/ipcmartial
	name = ".357 piercer bullet casing"
	desc = "A .357 piercer bullet casing."
	caliber = "357"
	projectile_type = /obj/item/projectile/bullet/ipcmartial

/obj/item/projectile/bullet/ipcmartial	//one shot, make it count
	name = ".357 piercer bullet"
	damage = 40
	armour_penetration = 40
	wound_bonus = -30	//more wounds
	penetrating = TRUE

/obj/item/projectile/bullet/ipcmartial/on_hit(atom/target, blocked)
	. = ..()
	if(ishuman(target) && !blocked)
		var/mob/living/carbon/human/H = target
		H.add_splatter_floor(H.loc, TRUE)//janitors everywhere cry when they hear that an ipc is going off

/obj/item/gun/ballistic/revolver/ipcmartial/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "martial")

/obj/item/gun/ballistic/revolver/ipcmartial/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	qdel(src)

/obj/item/gun/ballistic/revolver/ipcmartial/attack_self(mob/living/A)
	to_chat(A, span_notice("You stash your revolver away."))	
	qdel(src)
/*---------------------------------------------------------------

	end of pocket pistol section

---------------------------------------------------------------*/
/*---------------------------------------------------------------

	start of shotgun punch section

---------------------------------------------------------------*/

/datum/martial_art/ultra_violence/proc/gun_hand(mob/living/carbon/human/A)
	var/obj/item/gun/ballistic/shotgun/ipcmartial/gun = new /obj/item/gun/ballistic/shotgun/ipcmartial (A)   ///I don't check does the user have an item in a hand, because it is a martial art action, and to use it... you need to have a empty hand
	gun.gun_owner = A
	A.put_in_hands(gun)
	to_chat(A, span_notice("You ready your gun hand."))	
	streak = ""

/obj/item/gun/ballistic/shotgun/ipcmartial
	desc = "Your hand is also a shotgun."
	lefthand_file = null  ///We don't want it to be visible inhands because it is your hand
	righthand_file = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal/ipcmartial
	can_be_sawn_off  = FALSE
	var/mob/gun_owner
	item_flags = DROPDEL

/obj/item/ammo_box/magazine/internal/shot/lethal/ipcmartial
	ammo_type = /obj/item/ammo_casing/shotgun/buckshot/ipcmartial

/obj/item/ammo_casing/shotgun/buckshot/ipcmartial
	projectile_type = /obj/item/projectile/bullet/pellet/ipcmartial
	pellets = 6
	variance = 15

/obj/item/projectile/bullet/pellet/ipcmartial //one shot, make it count
	name = "violence buckshot pellet"
	damage = 16 //don't let them point blank you
	wound_bonus = 5
	bare_wound_bonus = 5
	wound_falloff_tile = -1 // less wound falloff

/obj/item/projectile/bullet/pellet/ipcmartial/on_hit(atom/target, blocked)//the real reason i made a whole new ammo type
	. = ..()
	if(ishuman(target) && !blocked)
		var/mob/living/carbon/human/H = target
		H.add_splatter_floor(H.loc, TRUE)//janitors everywhere cry when they hear that an ipc is going off

/obj/item/gun/ballistic/shotgun/ipcmartial/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "martial")

/obj/item/gun/ballistic/shotgun/ipcmartial/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	qdel(src)

/obj/item/gun/ballistic/shotgun/ipcmartial/attack_self(mob/living/A)
	to_chat(A, span_notice("You relax your gun hand."))	
	qdel(src)
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

/datum/martial_art/ultra_violence/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/A)
	if(H.a_intent != INTENT_DISARM || H.stat == DEAD || H.IsUnconscious() || H.IsFrozen())
		return
	dash(H, A)

/datum/martial_art/ultra_violence/proc/dash(mob/living/carbon/human/H, atom/A)
	if(dashing)
		return

	if(dashes <= 0)
		to_chat(H, span_alertsyndie("You are out of dash charges!"))
		return

	else
		playsound(H, 'sound/effects/dodge.ogg', 50)
		dash_timer = addtimer(CALLBACK(src, .proc/regen_dash, H), 4 SECONDS, TIMER_LOOP|TIMER_UNIQUE|TIMER_STOPPABLE)//start regen
		REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, "martial") //can't immobilize if has stun immune, technically means they can be stunned mid-dash
		H.Immobilize(30 SECONDS) //to prevent cancelling the dash
		dashing = TRUE
		H.throw_at(A, MAX_DASH_DIST, 1.5, H, FALSE, TRUE, callback = CALLBACK(src, .proc/dash_end, H))
		dashes -= 1
		H.throw_alert("dash_charge", /atom/movable/screen/alert/ipcmartial, dashes+1)

/datum/martial_art/ultra_violence/proc/dash_end(mob/living/carbon/human/H)
	dashing = FALSE
	H.SetImmobilized(0 SECONDS)
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, "martial")

/datum/martial_art/ultra_violence/handle_throw(atom/hit_atom, mob/living/carbon/human/A)
	if(!dashing)
		return ..()
	return TRUE

/*---------------------------------------------------------------

	end of dash section

---------------------------------------------------------------*/

#undef GUN_HAND
#undef POCKET_PISTOl
#undef BLOOD_BURST
#undef MAX_DASH_DIST
