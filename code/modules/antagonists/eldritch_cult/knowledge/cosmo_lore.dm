/datum/eldritch_knowledge/base_cosmic
	name = "Eternal Gate"
	desc = "Opens up the Path of Cosmos to you. \ Allows you to transmute a sheet of plasma and a knife into an Cosmic Blade. \
			Additionally your grasp will now cause a cosmic ring on your targets, which are affected by your abilities."
	gain_text = "A nebula appeared in the sky, its infernal birth shone upon me. This was the start of a great transcendence."
	unlocked_transmutations = list(/datum/eldritch_transmutation/cosmic_knife)
	cost = 1
	route = PATH_COSMIC
	tier = TIER_PATH

/datum/eldritch_knowledge/base_cosmic/on_gain(mob/user)
	. = ..()
	var/obj/realknife = new /obj/item/melee/sickly_blade/cosmic
	user.put_in_hands(realknife)

	///use is if you want to swap out a spell they get upon becoming their certain type of heretic
	var/datum/action/cooldown/spell/basic_jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/basic) in user.actions
	if(basic_jaunt)
		basic_jaunt.Remove(user)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/cosmic/cosmic_jaunt = new(user)
	cosmic_jaunt.Grant(user)
	
	ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, INNATE_TRAIT)
	ADD_TRAIT(user, TRAIT_RESISTCOLD, INNATE_TRAIT)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/base_cosmic/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/// Aplies the effect of the mansus grasp when it hits a target.
/datum/eldritch_knowledge/base_cosmic/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!ishuman(target))
		return COMPONENT_BLOCK_HAND_USE
	var/mob/living/carbon/human/human_target = target
	to_chat(target, span_danger("A cosmic ring appeared above your head!"))
	human_target.apply_status_effect(/datum/status_effect/star_mark, source)
	new /obj/effect/forcefield/cosmic_field(get_turf(source))

/datum/eldritch_knowledge/spell/cosmic_runes
	name = "T1 - Cosmic Runes"
	desc = "Grants you Cosmic Runes, a spell that creates two runes linked with each other for easy teleportation. \
		Only the entity activating the rune will get transported, and it can be used by anyone without a star mark. \
		However, people with a star mark will get transported along with another person using the rune."
	gain_text = "The distant stars crept into my dreams, roaring and screaming without reason. \
		I spoke, and heard my own words echoed back."
	spell_to_add = /datum/action/cooldown/spell/cosmic_rune
	cost = 1
	route = PATH_COSMIC
	tier = TIER_1

/datum/eldritch_knowledge/cosmic_mark
	name = "Grasp Mark - Mark of Cosmos"
	desc = "Your Mansus Grasp now applies the Mark of Cosmos. The mark is triggered from an attack with your Cosmic Blade. \
		When triggered, the victim is returned to the location where the mark was originally applied to them. \
		They will then be paralyzed for 2 seconds."
	gain_text = "The Beast now whispered to me occasionally, only small tidbits of their circumstances. \
		I can help them, I have to help them."
	route = PATH_COSMIC
	tier = TIER_MARK

/datum/eldritch_knowledge/cosmic_mark/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/cosmic_mark/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/cosmic_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/cosmic, 1)

/datum/eldritch_knowledge/base_cosmic/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh) || H.has_status_effect(/datum/status_effect/eldritch/void) || H.has_status_effect(/datum/status_effect/eldritch/cosmic)
		if(E)
			E.on_effect()

/datum/eldritch_knowledge/spell/star_blast
	name = "T2 - Star Blast"
	desc = "Fires a projectile that moves very slowly and creates cosmic fields on impact. \
		Anyone hit by the projectile will receive burn damage, a knockdown, and give people in a three tile range a star mark."
	gain_text = "The Beast was behind me now at all times, with each sacrifice words of affirmation coursed through me."
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/star_blast
	cost = 1
	route = PATH_COSMIC
	tier = TIER_2

/datum/eldritch_knowledge/cosmic_blade_upgrade
	name = "Blade Upgrade - Stellar Sublimation"
	desc = "Your blade now deals damage to people's cells through cosmic radiation."
	gain_text = "The Beast took my blades in their hand, I kneeled and felt a sharp pain. \
		The blades now glistened with fragmented power. I fell to the ground and wept at the beast's feet."
	route = PATH_COSMIC
	tier = TIER_BLADE

/datum/eldritch_knowledge/cosmic_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjustCloneLoss(4)

/datum/eldritch_knowledge/spell/cosmic_expansion
	name = "T3- Cosmic Expansion"
	desc = "Grants you Cosmic Expansion, a spell that creates a 3x3 area of cosmic fields around you. \
		Nearby beings will also receive a star mark."
	gain_text = "The ground now shook beneath me. The Beast inhabited me, and their voice was intoxicating."
	spell_to_add = /datum/action/cooldown/spell/conjure/cosmic_expansion
	cost = 1
	route = PATH_COSMIC
	tier = TIER_3

/datum/eldritch_knowledge/cosmic_final
	name = "Ascension Rite - Creator's Gift"
	desc = "The ascension ritual of the Path of Cosmos. \
		Bring 3 corpses to a transmutation rune to complete the ritual. \
		When completed, you may transform into a Star Gazer. \
		The Star Gazer has an aura that will heal you and damage opponents. \
		Optionally, you may summon a Star Gazer Ally instead, and gain damage reduction, stun immunity, and space immunity."
	gain_text = "The Beast held out its hand, I grabbed hold and they pulled me to them. Their body was towering, but it seemed so small and feeble after all their tales compiled in my head. \
		I clung on to them, they would protect me, and I would protect it. \
		I closed my eyes with my head laid against their form. I was safe. \
		WITNESS MY ASCENSION!"
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/cosmic_final)
	route = PATH_COSMIC
	tier = TIER_ASCEND
