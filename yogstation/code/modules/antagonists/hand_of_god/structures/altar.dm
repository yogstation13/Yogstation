/obj/structure/destructible/hog_structure/con_altar
	name = "conversion altar"
	desc = "an magical construction, capable of channeling otherworldy energies into mortal entities mind."
	break_message = span_warning("With a flash, the celestial forge fells appart!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield, /datum/hog_god_interaction/structure/research/weapons, /datum/hog_god_interaction/structure/research/armor)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	icon_originalname = "convertaltar"
	max_integrity = 100

/obj/structure/destructible/hog_structure/con_altar/special_interaction(var/mob/user)
	var/mob/living/carbon/C = locate() in get_turf(src)
	if(!C)
		return
	if(!C.mind || !C.client)
		to_chat(user,span_warning("Braindead cultist are not usefull to your cult!"))
		return
	if(!C.mind.hasSoul)
		to_chat(user,span_warning("[C]'s soul alredy belongs to someone else!"))
		return
	if(HAS_TRAIT(C, TRAIT_MINDSHIELD) || IS_BLOODSUCKER(C) || IS_MONSTERHUNTER(C)) 
		to_chat(user,span_warning("[C]'s mind is too powerfull to enslave!"))
		return
	if(IS_BLOODSUCKER(C) || IS_MONSTERHUNTER(C) || IS_HERETIC(C)) 
		to_chat(user,span_warning("[C]'s mind is too powerfull to enslave!"))
		to_chat(C,span_warning("Power of your will protects you from being enslved to the cult!"))
		return
	var/datum/antagonist/hog/dude = IS_HOG_CULTIST(C)
	if(dude)
		if(dude.cult == cult)
			to_chat(user,span_warning("[C] is alredy serving your god!"))        
		else
			to_chat(user,span_warning("Faith of [C] in his heretical idol protects him from being converted!"))
			to_chat(C,span_warning("Your faith into your god protects you from the heretical influence!"))
		return
	if(iscultist(C) || is_servant_of_ratvar(C))
		to_chat(user,span_warning("Faith of [C] in his heretical idol protects him from being converted!"))
		to_chat(C,span_warning("Your faith into your god protects you from the heretical influence!"))
		return
	if(cult.energy < cult.conversion_cost)
		to_chat(user,span_warning("Your cult doesn't have enough energy to influence [C]!"))
		return
	cult.change_energy_amount(-cult.conversion_cost)
	add_hog_cultist(user, cult, C.mind)
	to_chat(user,span_notice("You convert [C] to your cult!"))
	user.say("Ni eth anme of [cult.god], emobce one of su!", language = /datum/language/common, ignore_spam = TRUE, forced = "cult invocation")  //Yeah, i just used a website that shuffles letters in a sentence

/proc/add_hog_cultist(mob/user, datum/team/hog_cult/cult, datum/mind/cultist_mind)
	var/mob/living/carbon/C = cultist_mind.current
	C.silent = max(C.silent, 5)
	C.Knockdown(40)
	cultist_mind.add_antag_datum(/datum/antagonist/hog, cult)

/datum/hog_god_interaction/targeted/construction/lance
	name = "Construct a convertion altar"
	description = "Construct a convertion altar, that can convert non-believers into your cult."
	cost = 145
	time_builded = 20 SECONDS
	warp_name = "altar"
	warp_description = "a pulsating mass of energy in a form of an altar"
	structure_type = /obj/structure/destructible/hog_structure/forge
	max_constructible_health = 100
	integrity_per_process = 6
	icon_name = "forge_constructing"

/obj/structure/destructible/hog_structure/sac_altar
	name = "conversion altar"
	desc = "an magical construction, capable of channeling otherworldy energies into mortal entities mind."
	break_message = span_warning("With a flash, the celestial forge fells appart!") 
	god_actions_add = list(/datum/hog_god_interaction/structure/overcharge, /datum/hog_god_interaction/structure/shield, /datum/hog_god_interaction/structure/research/weapons, /datum/hog_god_interaction/structure/research/armor)
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	icon_originalname = "convertaltar"
	max_integrity = 100


#define ENERGY_REWARD_AMOUNT 145
#define STORAGE_REWARD_AMOUNT 60
#define REGEN_REWARD_AMOUNT 4

/obj/structure/destructible/hog_structure/sac_altar/special_interaction(var/mob/user)
	var/mob/living/carbon/C = locate() in get_turf(src)
	if(!C)
		return
	if(!C.mind.hasSoul || !C.mind)
		to_chat(user,span_warning("[C]'s soul alredy belongs to someone else!"))
		return
	var/datum/antagonist/hog/dude = IS_HOG_CULTIST(C)
	if(dude)
		if(dude.cult == cult)
			to_chat(user,span_warning("You can't sacrifice a fellow cultist!"))
			return           
		else
			C.mind.remove_antag_datum(/datum/antagonist/hog)
	if(HAS_TRAIT(C, TRAIT_MINDSHIELD)) 
		for(var/obj/item/implant/mindshield/L in C)
			if(L)
				qdel(L)
	if(is_servant_of_ratvar(C))
		C.mind.remove_antag_datum(/datum/antagonist/clockcult)
	if(iscultist(C))
		C.mind.remove_antag_datum(/datum/antagonist/cult)
	cult.change_energy_amount(ENERGY_REWARD_AMOUNT)
	cult.max_energy += STORAGE_REWARD_AMOUNT
	cult.permanent_regen += REGEN_REWARD_AMOUNT
	C.mind.hasSoul = FALSE
	C.health -= 20
	C.maxHealth -= 20
	C.apply_status_effect(STATUS_EFFECT_BRAZIL_PENANCE)
	to_chat(user,span_notice("You sacrifice [C] to your god!"))
	user.say("[cult.god], I iaierfcsc [C] ni rouy nmae!", language = /datum/language/common, ignore_spam = TRUE, forced = "cult invocation")  

