/datum/eldritch_transmutation/ash_knife
	name = "Ashen Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/match)
	result_atoms = list(/obj/item/melee/sickly_blade/ash)
	required_shit_list = "A pile of ash and a knife."

/datum/eldritch_transmutation/ashen_eyes
	name = "Ashen Eyes"
	required_atoms = list(/obj/item/organ/eyes,/obj/item/shard)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	required_shit_list = "A glass shard and a pair of eyes."

/datum/eldritch_transmutation/curse/blindness
	name = "Curse of Blindness"
	required_atoms = list(/obj/item/organ/eyes,/obj/item/screwdriver,/obj/effect/decal/cleanable/blood)
	timer = 2 MINUTES
	required_shit_list = "A pair of eyes, a screwdriver, and a pool of blood. Requires an item touched by the to-be victim."

/datum/eldritch_transmutation/curse/blindness/curse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.become_blind(MAGIC_TRAIT)

/datum/eldritch_transmutation/curse/blindness/uncurse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.cure_blind(MAGIC_TRAIT)

/datum/eldritch_transmutation/curse/corrosion
	name = "Curse of Corrosion"
	required_atoms = list(/obj/item/wirecutters,/obj/effect/decal/cleanable/blood,/obj/item/organ/heart,/obj/item/bodypart/l_arm,/obj/item/bodypart/r_arm)
	timer = 2 MINUTES
	required_shit_list = "Wirecutters, a pool of blood, a heart, and a left and right arm. Requires an item touched by the to-be victim."

/datum/eldritch_transmutation/curse/corrosion/curse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)

/datum/eldritch_transmutation/curse/corrosion/uncurse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)

/datum/eldritch_transmutation/curse/paralysis
	name = "Curse of Paralysis"
	required_atoms = list(/obj/item/kitchen/knife,/obj/effect/decal/cleanable/blood,/obj/item/bodypart/l_leg,/obj/item/bodypart/r_leg,/obj/item/hatchet)
	timer = 5 MINUTES
	required_shit_list = "A knife, a pool of blood, a left and right leg, and a hatchet. Requires an item touched by the to-be victim."

/datum/eldritch_transmutation/curse/paralysis/curse(mob/living/chosen_mob)
	. = ..()
	ADD_TRAIT(chosen_mob,TRAIT_PARALYSIS_L_LEG,MAGIC_TRAIT)
	ADD_TRAIT(chosen_mob,TRAIT_PARALYSIS_R_LEG,MAGIC_TRAIT)
	chosen_mob.update_mobility()

/datum/eldritch_transmutation/curse/paralysis/uncurse(mob/living/chosen_mob)
	. = ..()
	REMOVE_TRAIT(chosen_mob,TRAIT_PARALYSIS_L_LEG,MAGIC_TRAIT)
	REMOVE_TRAIT(chosen_mob,TRAIT_PARALYSIS_R_LEG,MAGIC_TRAIT)
	chosen_mob.update_mobility()

/datum/eldritch_transmutation/final/ash_final
	name = "Ashlord's Rite"
	required_atoms = list(/mob/living/carbon/human)
	var/list/trait_list = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_NOFIRE,TRAIT_RADIMMUNE,TRAIT_GENELESS,TRAIT_PIERCEIMMUNE,TRAIT_NODISMEMBER,TRAIT_BOMBIMMUNE)
	required_shit_list = "Three dead bodies."

/datum/eldritch_transmutation/final/ash_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear The Blaze, for Ashbringer [user.real_name] has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/ai/spanomalies.ogg')
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/fire_cascade/big)
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/fire_sworn)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.physiology.stamina_mod = 0
	H.physiology.stun_mod = 0
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
	for(var/X in trait_list)
		ADD_TRAIT(user,X,MAGIC_TRAIT)
	return ..()

/datum/eldritch_transmutation/final/ash_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return
	var/turf/L = get_turf(user)
	var/datum/gas_mixture/env = L.return_air()
	var/current_temp = env.return_temperature()
	for(var/turf/T in range(1,user))
		env = T.return_air()
		current_temp = env.return_temperature()
		env.set_temperature(current_temp+25)
		T.air_update_turf()
	L.air_update_turf()
