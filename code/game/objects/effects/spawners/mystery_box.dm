/obj/structure/closet/crate/mystery_box
	name = "mystery box"
	desc = "A mysterious box that seems to contain limitless guns, for a price."
	icon_state = "trashcart"
	color = "#644a11"
	var/guncost = 950
	var/list/gunlist = list()
	var/opening = FALSE

/obj/structure/closet/crate/mystery_box/Initialize(mapload)
	. = ..()
	gunlist |= subtypesof(/obj/item/gun) //huge fucking list, don't spawn too many of these @hisa

/obj/structure/closet/crate/mystery_box/examine(mob/user)
	. = ..()
	. += span_notice("It costs [guncost ? "[guncost] credits" : "nothing"] to open.")

/obj/structure/closet/crate/mystery_box/open(mob/living/user)
	welded = FALSE 
	if(opened || !can_open(user) || !ishuman(user) || opening)
		return

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/id_card = H.get_idcard()
	if(!id_card)
		H.balloon_alert(H, "Need an id card")
		return
	if(!id_card.registered_account)
		H.balloon_alert(H, "Need a bank account")
		return
	if(!id_card.registered_account.account_balance < guncost)
		H.balloon_alert(H, "Not enough money")
		return

	opening = TRUE
	playsound(src, 'yogstation/sound/effects/mysterybox.ogg', 60, FALSE)
	sleep(5 SECONDS)
	opening = FALSE

	id_card.registered_account.account_balance -= guncost
	var/gunpath = pick(gunlist)
	var/obj/item/gun/thing = new gunpath(src)
	thing.no_pin_required = TRUE

	playsound(loc, open_sound, 15, 1, -3)
	opened = TRUE
	dump_contents()
	animate_door(FALSE)
	update_appearance(UPDATE_ICON)
	update_airtightness()

	addtimer(CALLBACK(src, PROC_REF(userless_close)), 5 SECONDS, TIMER_UNIQUE)
	
//can't close
/obj/structure/closet/crate/mystery_box/close(mob/living/user)
	return FALSE

/obj/structure/closet/crate/mystery_box/proc/userless_close()
	playsound(loc, close_sound, 15, 1, -3)
	opened = FALSE
	density = TRUE
	animate_door(TRUE)
	update_appearance(UPDATE_ICON)
	update_airtightness()

//The zombie in question
#define REGENERATION_DELAY 6 SECONDS  // After taking damage, how long it takes for automatic regeneration to begin
/datum/species/preternis/zombie
	name = "Low-Functioning Preternis"
	id = "preterniszombie"
	limbs_id = "preternis"
	inherent_traits = list(TRAIT_NOHUNGER, TRAIT_RADIMMUNE, TRAIT_MEDICALIGNORE, TRAIT_NO_BLOOD_REGEN, TRAIT_STABLELIVER, TRAIT_STABLEHEART, TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE, TRAIT_FAKEDEATH, TRAIT_STUNIMMUNE, TRAIT_NODEATH)
	mutanthands = /obj/item/zombie_hand
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	armor = 20
	speedmod = 1.6
	var/heal_rate = 1
	var/regen_cooldown = 0

/datum/species/preternis/zombie/check_roundstart_eligible()
	return FALSE

/datum/species/preternis/zombie/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, attack_direction = null)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/datum/species/preternis/zombie/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW

	//Zombies never actually die, they just fall down until they regenerate enough to rise back up.
	//They must be restrained, beheaded or gibbed to stop being a threat.
	if(regen_cooldown < world.time)
		var/heal_amt = heal_rate
		if(C.InCritical())
			heal_amt *= 2
		C.heal_overall_damage(heal_amt,heal_amt, 0, BODYPART_ANY)
		C.adjustToxLoss(-heal_amt)
		for(var/i in C.all_wounds)
			var/datum/wound/iter_wound = i
			if(prob(4-iter_wound.severity))
				iter_wound.remove_wound()
	if(!C.InCritical() && prob(5))
		playsound(C, pick(spooks), 50, TRUE, 10)

#undef REGENERATION_DELAY
