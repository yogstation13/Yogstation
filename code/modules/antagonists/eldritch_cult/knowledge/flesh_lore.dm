/datum/eldritch_knowledge/base_flesh
	name = "Principle of Hunger"
	desc = "Pledges yourself to the path of Flesh. Allows you to transmute a pool of blood with a knife into a flesh blade. Additionally, your Mansus grasp now raises dead humanoids into subservient ghouls if they are not mindshielded or husked. It will husk the person it's used on."
	gain_text = "The Priest has seduced countless into his flock. He will entice countless more with the Glorious Feast. You knelt before his statue and swore the Red Oath."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/ash_final,/datum/eldritch_knowledge/rust_final)
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/flesh_blade)
	route = PATH_FLESH
	tier = TIER_PATH
	var/ghoul_amt = 1
	var/list/spooky_scaries

/datum/eldritch_knowledge/base_flesh/on_gain(mob/user)
	. = ..()
	var/obj/realknife = new /obj/item/gun/magic/hook/sickly_blade/flesh
	user.put_in_hands(realknife)

/datum/eldritch_knowledge/base_flesh/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target) || target == user)
		return
	var/mob/living/carbon/human/human_target = target

	if(QDELETED(human_target) || human_target.stat != DEAD)
		return

	human_target.grab_ghost()

	if(!human_target.mind || !human_target.client)
		to_chat(user, span_warning("There is no soul connected to this body..."))
		return

	if(HAS_TRAIT(human_target, TRAIT_HUSK))
		to_chat(user, span_warning("The body is too damaged to be revived this way!"))
		return

	if(HAS_TRAIT(human_target, TRAIT_MINDSHIELD))
		to_chat(user, span_warning("Their will cannot be malformed to obey your own!"))
		return

	if(LAZYLEN(spooky_scaries) >= ghoul_amt)
		to_chat(user, span_warning("Your Oath cannot support more ghouls on this plane!"))
		return

	LAZYADD(spooky_scaries, human_target)
	log_game("[key_name_admin(human_target)] has become a ghoul, their master is [user.real_name]")
	//we change it to true only after we know they passed all the checks
	. = TRUE
	RegisterSignal(human_target,COMSIG_GLOB_MOB_DEATH,.proc/remove_ghoul)
	human_target.revive(full_heal = TRUE, admin_revive = TRUE)
	human_target.setMaxHealth(25)
	human_target.health = 25
	human_target.become_husk()
	human_target.faction |= "heretics"
	var/datum/antagonist/heretic_monster/heretic_monster = human_target.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	return

/datum/eldritch_knowledge/base_flesh/proc/remove_ghoul(datum/source)
	var/mob/living/carbon/human/humie = source
	spooky_scaries -= humie
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source, COMSIG_GLOB_MOB_DEATH)

/datum/eldritch_knowledge/base_flesh/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/human_target = target
	var/datum/status_effect/eldritch/eldritch_effect = human_target.has_status_effect(/datum/status_effect/eldritch/rust) || human_target.has_status_effect(/datum/status_effect/eldritch/ash) || human_target.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(eldritch_effect)
		eldritch_effect.on_effect()
		if(iscarbon(target))
			var/mob/living/carbon/carbon_target = target
			var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
			var/datum/wound/slash/severe/crit_wound = new
			crit_wound.apply_wound(bodypart)

/datum/eldritch_knowledge/flesh_ghoul
	name = "Imperfect Ritual"
	gain_text = "The rite requests an indulgence from the Crimson Church, erasing the victim's freedom and granting them life anew."
	desc = "Allows you to resurrect a humanoid body as a Voiceless Dead by transmuting them with a poppy. Voiceless Dead are mute and have 50 HP. You can only have two at a time."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/voiceless_dead)
	route = PATH_FLESH
	tier = TIER_1

/datum/eldritch_knowledge/flesh_mark
	name = "Lover's Exsanguination"
	gain_text = "She revels and laughs when life begins to flow. Her kiss rips and feasts on flesh alike. This imitates her touch."
	desc = "Your Mansus grasp now applies a mark on hit. Use your flesh blade to detonate the mark, which causes significant bleeding on the target."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/ash_mark)
	route = PATH_FLESH
	tier = TIER_MARK

/datum/eldritch_knowledge/flesh_mark/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isliving(target))
		. = TRUE
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/flesh)

/datum/eldritch_knowledge/raw_prophet
	name = "Raw Ritual"
	gain_text = "The Glorious Feast is not kind to all who are blessed with participation. Those who see less-fortunate metamorphosis are exiled to the Sunless Wastes, from where they can be offered food for service."
	desc = "Allows you to summon a Raw Prophet by transmuting a pair of eyes, a left arm and a right arm. Raw Prophets have massive sight range with X-ray, and they can sustain a telepathic network. However, they are very fragile and weak."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/summon/raw_prophet)
	route = PATH_FLESH
	tier = TIER_2

/datum/eldritch_knowledge/blood_siphon
	name = "Blood Siphon"
	gain_text = "The meat of another being is a delicacy that many enjoy. The Gravekeeper's hunger may be decadent, but you will come to know the strength it yields."
	desc = "A touch spell that drains a target's health and restores yours."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/touch/blood_siphon)
	tier = TIER_2

/datum/eldritch_knowledge/flesh_blade_upgrade
	name = "Talons of the Sworn"
	gain_text = "Ebis, the Owl, was the second to take the Red Oath. They still grant the gift of their steel to those powerful enough to resist their incursions."
	desc = "Your flesh blade will now cause additional bleeding on hit."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade)
	route = PATH_FLESH
	tier = TIER_BLADE

/datum/eldritch_knowledge/flesh_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/obj/item/bodypart/bodypart = pick(carbon_target.bodyparts)
		var/datum/wound/slash/moderate/crit_wound = new
		crit_wound.apply_wound(bodypart)

/datum/eldritch_knowledge/stalker
	name = "Lonely Ritual"
	gain_text = "The Uncanny Man walks lonely in the Valley. I called for his aid."
	desc = "Allows you to summon a Stalker by transmuting a knife, a candle, a pen, and a piece of paper. Stalkers can shapeshift into harmless animals and emit EMPs."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/summon/stalker)
	route = PATH_FLESH
	tier = TIER_3

/datum/eldritch_knowledge/ashy
	name = "Ashen Ritual"
	gain_text = "I combined the principle of Hunger with a desire for Destruction. The Eyeful Lords took notice."
	desc = "You can now summon an Ashman by transmutating a pile of ash, a head, and a book. Ashmen have powerful offensive abilities and access to the Ash Passage spell."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/summon/ashy)
	tier = TIER_3

/datum/eldritch_knowledge/rusty
	name = "Rusted Ritual"
	gain_text = "I combined the principle of Hunger with a desire of Corruption. The Rusted Hills call my name."
	desc = "You can now summon a Rustwalker transmutating a vomit pool and a book. Rustwalkers are capable of spreading rust and have strong, short-ranged projectile attack."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/summon/rusty)
	tier = TIER_3

/datum/eldritch_knowledge/flesh_final
	name = "Priest's Final Hymn"
	gain_text = "Men of the world; Hear me! For the time of the Lord of Arms has come!"
	desc = "Transmute three corpses to ascend by metamorphisizing as the King of the Night, or instead summon a Terror of the Night, triple your ghoul maximum, and become incredibly resilient to damage."
	cost = 3
	route = PATH_FLESH
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/flesh_final)
	tier = TIER_ASCEND
