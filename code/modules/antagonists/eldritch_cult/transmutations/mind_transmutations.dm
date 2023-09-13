/datum/eldritch_transmutation/mind_knife
	name = "Cerebral Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/book/random) 
	result_atoms = list(/obj/item/gun/magic/hook/sickly_blade/mind)
	required_shit_list = "A book and a knife."

/datum/eldritch_transmutation/eldritch_lantern 
	name = "Eldritch Lantern"
	required_atoms = list(/obj/structure/grille,/obj/item/flashlight) 
	result_atoms = list(/obj/item/flashlight/lantern/eldritch_lantern)
	required_shit_list = "A metal grille and a flashlight"

/datum/eldritch_transmutation/final/mind_final
	name = "Beyond All Knowldege Lies Despair"
	required_atoms = list(/mob/living/carbon/human)
	required_shit_list = "Three dead bodies."

/datum/eldritch_transmutation/final/mind_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.physiology.stamina_mod = 0
	H.physiology.stun_mod = 0
	priority_announce("Immense destabilization of the bluespace veil has been observed. Our scanners report significant and rapid decay of the station's infrastructure with a single entity as its source. Immediate evacuation is advised.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)
	set_security_level(SEC_LEVEL_GAMMA)
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
	return ..()

/datum/eldritch_transmutation/final/mind_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/mob/living/carbon/human/human_user = user
	human_user.adjustBruteLoss(-3, FALSE)
	human_user.adjustFireLoss(-3, FALSE)
	human_user.adjustToxLoss(-3, FALSE)
	human_user.adjustOxyLoss(-1, FALSE)
	human_user.adjustStaminaLoss(-10)
