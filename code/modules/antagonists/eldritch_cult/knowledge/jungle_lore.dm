/datum/eldritch_knowledge/base_jungle
	name = "Xibalba's oath"
	desc = "Pledges yourself to the path of Jungle. Allows you to summon an Eldritch Bola for a portion of your health. Additionally, empowers your Mansus grasp to immobilize your victims, as well as healing you. You will also become more resistant to brute."
	gain_text = "The deep and dense jungle swallows all who enter, never to return."
	cost = 1
	route = PATH_JUNGLE
	tier = TIER_PATH

/datum/eldritch_knowledge/base_jungle/on_gain(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.physiology.brute_mod *= 0.9

	var/datum/action/cooldown/spell/basic_jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/basic) in user.actions
	if(basic_jaunt)
		basic_jaunt.Remove(user)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jungle/jungle_jaunt = new(user)
	jungle_jaunt.Grant(user)

	var/datum/action/cooldown/spell/conjure_item/eldritch_bola/bola_summon = new(user)
	bola_summon.Grant(user)

	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/base_jungle/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

datum/eldritch_knowledge/base_jungle/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	///SIGNAL_HANDLER dont uncomment this it gets angy

	if(!ishuman(target))
		return COMPONENT_BLOCK_HAND_USE
	var/mob/living/carbon/human/human_target = target
	human_target.Immobilize(1 SECONDS)
	var/mob/living/carbon/human/heretic_self = source
	heretic_self.adjustBruteLoss(-10)
	heretic_self.adjustFireLoss(-10)
	heretic_self.adjustToxLoss(-10)

/datum/eldritch_knowledge/eldritch_shield
	name = "T1 - Xibalba's Protection"
	gain_text = "Your patron offers you a gift, his left hand to protect you in your time of need."
	desc = "Transmute a plank of wood, a packet of seeds, and metal rods to create an Eldritch Shield."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/vine_shield)
	route = PATH_JUNGLE
	tier = TIER_1

/datum/eldritch_knowledge/jungle_mark
	name = "Grasp Mark - Xibalba's Embrace"
	gain_text = "Your patron offers you their embrace, soothing the endless pain and guilt you feel, freeing your soul and mind, making it ever so much lighter."
	desc = "Upgrade your very soul, making you lighter on your feet."
	cost = 2
	route = PATH_JUNGLE
	tier = TIER_MARK

/datum/eldritch_knowledge/jungle_mark/on_gain(mob/user)
	. = ..()
	user.add_movespeed_modifier(update=TRUE, priority=100, multiplicative_slowdown=-0.5, blacklisted_movetypes=(FLYING|FLOATING))

/datum/eldritch_knowledge/spell/vine_wall
	name = "T2 - Xibalba's Foresight"
	gain_text = "Your patron knows the battles you'll fight before even you do, take their boon and ready yourself for the storm."
	desc = "Create a wall of vines to block passage from heathens."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/forcewall/vines
	route = PATH_JUNGLE
	tier = TIER_2	

/datum/eldritch_knowledge/jungle_blade_upgrade
	name = "Bola Upgrade - Xibalba's Devotion"
	gain_text = "Your patron's words grow louder, reverberatting in your head with each and every footstep, your ascension grows closer."
	desc = "Your Eldritch Bola cooldown is reduced greatly."
	cost = 2
	route = PATH_JUNGLE
	tier = TIER_BLADE

/datum/eldritch_knowledge/jungle_blade_upgrade/on_gain(mob/user)
	. = ..()
	var/datum/action/cooldown/spell/conjure_item/eldritch_bola/bola_spell = locate() in user.actions
	bola_spell?.cooldown_time /= 2


/datum/eldritch_knowledge/spell/vine_wall
	name = "T3 - Xibalba's Wrath"
	gain_text = "Xibalba's anger causes even the mightiest of trees to bend and break, take a piece of it and use it upon thy enemies."
	desc = "Fire an array of thorns."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/spell_cards/thorns
	route = PATH_JUNGLE
	tier = TIER_3	


/datum/eldritch_knowledge/jungle_final
	name = "Ascension Rite - Xibalba's Truth"
	gain_text = "It was a rigged game from the start, these powers were not yours, they were his, and now your body is his to use forevermore."
	desc = "The ascension ritual of the Path of Truncatis. \
		Bring 3 corpses to a transmutation rune to complete the ritual. \
		When completed, you may transform into the Herald of Xibalba. \
		The Herald has several powerful spells to aid it. \
		Optionally, you may summon a Herald of Xibalba as an Ally instead, and gain damage reduction, stun immunity, and space immunity."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/jungle_final)
	route = PATH_JUNGLE
	tier = TIER_ASCEND
