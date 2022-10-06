#define GUN_HAND "GHG"
#define BLOOD_BURST "HHH"
#define MAX_DASH_DIST 3

/datum/martial_art/ultra_violence
	name = "Ultra Violence"
	id = MARTIALART_ULTRAVIOLENCE
	no_guns = FALSE
	deflection_chance = 0 //no block unless throwmode is on
	reroute_deflection = TRUE
	help_verb = /mob/living/carbon/human/proc/ultra_violence_help
	///used to keep track of the dash stuff
	var/dashing = FALSE
	var/dashes = 3
	var/dash_timer = null

/datum/martial_art/ultra_violence/can_use(mob/living/carbon/human/H)
	return isipc(H)

/datum/martial_art/ultra_violence/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A == D || D.stat == DEAD) //stop hitting yourself or a corpse
		return FALSE

	if(findtext(streak, GUN_HAND))
		streak = ""
		gun_hand(A)
		speed_boost(A)
		return TRUE
	if(findtext(streak, BLOOD_BURST))
		streak = ""
		blood_burst(A,D)
		speed_boost(A)
		return TRUE

/datum/martial_art/ultra_violence/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return TRUE  //no disarming

/datum/martial_art/ultra_violence/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return TRUE //no grabbing either

/datum/martial_art/ultra_violence/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return FALSE
	return FALSE

/datum/martial_art/ultra_violence/proc/speed_boost(mob/living/carbon/human/A)
	A.add_movespeed_modifier("ipc martial", update=TRUE, priority=101, multiplicative_slowdown = -0.5, blacklisted_movetypes=(FLYING|FLOATING))
	addtimer(CALLBACK(src, .proc/remove_boost, A), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/martial_art/ultra_violence/proc/remove_boost(mob/living/carbon/human/A)
	A.remove_movespeed_modifier("ipc martial")

/datum/martial_art/ultra_violence/proc/blood_burst(mob/living/carbon/human/A, mob/living/carbon/human/D)
	D.bleed(30)
	D.add_splatter_floor(D.loc, TRUE)
	
	if(D.health <= HEALTH_THRESHOLD_FULLCRIT)
		D.bleed(300)
		D.death()
		var/obj/effect/gibspawner/blood = new /obj/effect/gibspawner/generic(D.loc)
		blood.throw_at(get_edge_target_turf(blood, pick(GLOB.alldirs)), rand(1,2), 5)
		var/obj/effect/gibspawner/moreblood = new /obj/effect/gibspawner/generic(D.loc)
		moreblood.throw_at(get_edge_target_turf(moreblood, pick(GLOB.alldirs)), rand(1,2), 5)

/*---------------------------------------------------------------

	start of shotgun punch section

---------------------------------------------------------------*/

/datum/martial_art/ultra_violence/proc/gun_hand(mob/living/carbon/human/A)
	var/obj/item/gun/ballistic/shotgun/martial/gun = new /obj/item/gun/ballistic/shotgun/martial (A)   ///I don't check does the user have an item in a hand, because it is a martial art action, and to use it... you need to have a empty hand
	gun.gun_owner = A
	A.put_in_hands(gun)
	to_chat(A, span_notice("You ready your gun hand."))	
	streak = ""

/obj/item/gun/ballistic/shotgun/martial
	desc = "Your hand is also a shotgun."
	lefthand_file = null  ///We don't want it to be visible inhands because it is your hand
	righthand_file = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal/martial
	can_be_sawn_off  = FALSE
	var/mob/gun_owner

/obj/item/gun/ballistic/shotgun/martial/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "martial")

/obj/item/gun/ballistic/shotgun/martial/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	qdel(src)

/obj/item/gun/ballistic/shotgun/martial/rack()
	qdel(src)

/obj/item/ammo_box/magazine/internal/shot/lethal/martial
	max_ammo = 1

/*---------------------------------------------------------------

	end of shotgun punch section

---------------------------------------------------------------*/

/mob/living/carbon/human/proc/ultra_violence_help()
	set name = "Cyber Grind"
	set desc = "You mentally practice the teachings of Ultra Violence."
	set category = "Ultra Violence"
	to_chat(usr, "<b><i>You search your data banks for techniques of Ultra Violence.</i></b>")

	to_chat(usr, span_notice("This module has made you a hell-bound killing machine."))
	to_chat(usr, span_notice("You are immune to stuns and cannot be slowed by damage."))
	to_chat(usr, span_notice("You will deflect emps while throwmode is enabled."))
	to_chat(usr, span_warning("Your disarm has been replaced with a charged-based dash system."))
	to_chat(usr, span_warning("You cannot grab either, JUST KILL THEM!")) //seriously, no pushing or clinching, that's boring, just kill
	to_chat(usr, span_notice("<b>Getting covered in blood will heal you.</b>"))
	
	to_chat(usr, "[span_notice("Disarm Intent")]: Dash in a direction.")
	to_chat(usr, "[span_notice("Gun Hand")]: Grab Harm Grab. Puts a loaded shotgun in your hand for one shot.")
	to_chat(usr, "[span_notice("Bloodsplosion")]: Harm Harm Harm. Explodes blood from the target, executes people in hardcrit exploding blood everywhere.")
	to_chat(usr, span_notice("Completing either combo will give a short duration speed buff."))

/datum/martial_art/ultra_violence/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	H.dna.species.attack_sound = 'sound/weapons/shotgunshot.ogg'
	H.dna.species.punchdamagehigh += 4 //no fancy comboes, just punches
	H.dna.species.punchstunthreshold += 4
	ADD_TRAIT(H, TRAIT_NOSOFTCRIT, "martial")
	ADD_TRAIT(H, TRAIT_NOLIMBDISABLE, "martial")
	ADD_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, "martial")
	ADD_TRAIT(H, TRAIT_NO_STUN_WEAPONS, "martial")
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, "martial")///mainly so emps don't end you instantly, they still do damage though
	H.throw_alert("dash_charge", /obj/screen/alert/ipcmartial, dashes+1)
	usr.click_intercept = src //probably breaks something, don't know what though
	H.dna.species.GiveSpeciesFlight(C)//because... c'mon

/datum/martial_art/ultra_violence/on_remove(mob/living/carbon/human/H)
	..()
	H.dna.species.attack_sound = 'sound/items/trayhit1.ogg'
	H.dna.species.punchdamagehigh -= 4 //back to flimsy tin tray punches
	H.dna.species.punchstunthreshold -= 4
	REMOVE_TRAIT(H, TRAIT_NOSOFTCRIT, "martial")
	REMOVE_TRAIT(H, TRAIT_NOLIMBDISABLE, "martial")
	REMOVE_TRAIT(H, TRAIT_IGNOREDAMAGESLOWDOWN, "martial")
	REMOVE_TRAIT(H, TRAIT_NO_STUN_WEAPONS, "martial")
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, "martial")
	deltimer(dash_timer)
	H.clear_alert("dash_charge")
	usr.click_intercept = null //un-breaks the thing that i don't know is broken
	//not likely they'll lose the martial art i guess, so i guess they can keep the wings

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
	H.throw_alert("dash_charge", /obj/screen/alert/ipcmartial, dashes+1)

/datum/martial_art/ultra_violence/proc/InterceptClickOn(mob/living/carbon/human/H, params, atom/A)
	if(H.a_intent == INTENT_DISARM && AB_CHECK_CONSCIOUS)
		dash(H, A)
		
	. = ..()

/datum/martial_art/ultra_violence/proc/dash(mob/living/carbon/human/H, atom/A)
	if(dashing)
		return

	if(dashes <= 0)
		to_chat(H, span_alertsyndie("You are out of dash charges!"))
		return

	else
		dash_timer = addtimer(CALLBACK(src, .proc/regen_dash, H), 4 SECONDS, TIMER_LOOP|TIMER_UNIQUE|TIMER_STOPPABLE)//start regen
		REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, "martial") //can't immobilize if has stun immune, technically means they can be stunned mid-dash
		H.Immobilize(30 SECONDS) //to prevent cancelling the dash
		dashing = TRUE
		H.throw_at(A, MAX_DASH_DIST, 2, H, FALSE, TRUE, callback = CALLBACK(src, .proc/dash_end, H))
		dashes -= 1
		H.throw_alert("dash_charge", /obj/screen/alert/ipcmartial, dashes+1)

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
#undef BLOOD_BURST
#undef MAX_DASH_DIST
