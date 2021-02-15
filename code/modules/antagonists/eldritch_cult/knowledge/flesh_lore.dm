/datum/eldritch_knowledge/base_flesh
	name = "Principle of Hunger"
	desc = "Opens up the path of flesh to you. Allows you to transmute a pool of blood with a knife into a Flesh Blade"
	gain_text = "Hundreds of us starved, but I.. I found the strength in my greed."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/ash_final,/datum/eldritch_knowledge/rust_final)
	next_knowledge = list(/datum/eldritch_knowledge/flesh_grasp)
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/flesh_blade)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Allows you to resurrect the dead as voiceless dead by sacrificing them on the transmutation rune with a poppy. Voiceless dead are mute and have 50 HP. You can only have 2 at a time."
	gain_text = "I found notes.. notes of a ritual, it was unfinished and yet I still did it."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/ashen_eyes)
	unlocked_transmutations = list(/datum/eldritch_transmutation/voiceless_dead)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_grasp
	name = "Grasp of Flesh"
	gain_text = "My newfound desire, it drove me to do great things! To revoke the grasp of death! The Priest said."
	desc = "Empowers your mansus grasp to be able to create a single ghoul out of a dead person. Ghouls have only 25 HP and become husked."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/flesh_ghoul)
	var/ghoul_amt = 1
	var/list/spooky_scaries
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target) || target == user)
		return
	var/mob/living/carbon/human/human_target = target
	var/datum/status_effect/eldritch/eldritch_effect = human_target.has_status_effect(/datum/status_effect/eldritch/rust) || human_target.has_status_effect(/datum/status_effect/eldritch/ash) || human_target.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(eldritch_effect)
		. = TRUE
		eldritch_effect.on_effect()
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.bleed_rate += 7

	if(QDELETED(human_target) || human_target.stat != DEAD)
		return

	human_target.grab_ghost()

	if(!human_target.mind || !human_target.client)
		to_chat(user, "<span class='warning'>There is no soul connected to this body...</span>")
		return

	if(HAS_TRAIT(human_target, TRAIT_HUSK))
		to_chat(user, "<span class='warning'>The body is too damaged to be revived this way!</span>")
		return

	if(HAS_TRAIT(human_target, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='warning'>Their connection to this realm is too strong!</span>")
		return

	if(LAZYLEN(spooky_scaries) >= ghoul_amt)
		to_chat(user, "<span class='warning'>Your Patron cannot support more ghouls on this plane!</span>")
		return

	LAZYADD(spooky_scaries, human_target)
	log_game("[key_name_admin(human_target)] has become a ghoul, their master is [user.real_name]")
	//we change it to true only after we know they passed all the checks
	. = TRUE
	RegisterSignal(human_target,COMSIG_MOB_DEATH,.proc/remove_ghoul)
	human_target.revive(full_heal = TRUE, admin_revive = TRUE)
	human_target.setMaxHealth(25)
	human_target.health = 25
	human_target.become_husk()
	human_target.faction |= "heretics"
	var/datum/antagonist/heretic_monster/heretic_monster = human_target.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	return


/datum/eldritch_knowledge/flesh_grasp/proc/remove_ghoul(datum/source)
	var/mob/living/carbon/human/humie = source
	spooky_scaries -= humie
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source, COMSIG_MOB_DEATH)

/datum/eldritch_knowledge/flesh_mark
	name = "Mark of flesh"
	gain_text = "I saw them, the Marked ones. The screams.. the silence."
	desc = "Your sickly blade now applies mark of flesh status effect. To activate the mark, use your mansus grasp on the marked. Mark of flesh when procced causeds additional bleeding."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/raw_prophet)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/ash_mark)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_mark/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/flesh)

/datum/eldritch_knowledge/flesh_blade_upgrade
	name = "Bleeding Steel"
	gain_text = "It rained blood, that's when I understood The Gravekeeper's advice."
	desc = "Your blade will now cause additional bleeding."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/stalker)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed_rate += 3

/datum/eldritch_knowledge/raw_prophet
	name = "Raw Ritual"
	gain_text = "I saw the mirror-sheen in their dead eyes. It could be put to use."
	desc = "You can now summon a Raw Prophet by transmuting eyes, a left arm and a right arm. Raw prophets have a massive sight range, X-ray, and can sustain a telepathic network, but are very fragile and weak."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/blood_siphon,/datum/eldritch_knowledge/paralysis)
	unlocked_transmutations = list(/datum/eldritch_transmutation/summon/raw_prophet)
	route = PATH_FLESH

/datum/eldritch_knowledge/stalker
	name = "Lonely Ritual"
	gain_text = " The Uncanny Man walks lonely in the Valley, I called for his aid."
	desc = "You can now summon a Stalker by transmuting a knife, a candle, a pen and a piece of paper. Stalkers can shapeshift into harmeless animals and have access to an EMP."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/ashy,/datum/eldritch_knowledge/rusty,/datum/eldritch_knowledge/flesh_final)
	unlocked_transmutations = list(/datum/eldritch_transmutation/summon/stalker)
	route = PATH_FLESH

/datum/eldritch_knowledge/ashy
	name = "Ashen Ritual"
	gain_text = "I combined the principle of Hunger with a desire for Destruction. The Eyeful Lords took notice."
	desc = "You can now summon an Ash Man by transmutating a pile of ash, a head and a book. Ash Men have powerful offensive abilities and access to the Ash Passage spell."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/stalker,/datum/eldritch_knowledge/flame_birth)
	unlocked_transmutations = list(/datum/eldritch_transmutation/summon/ashy)

/datum/eldritch_knowledge/rusty
	name = "Rusted Ritual"
	gain_text = "I combined the principle of Hunger with a desire of Corruption. The Rusted Hills call my name."
	desc = "You can now summon a Rust Walker transmutating vomit pool and a book. Rust Walkers are capable of spreading rust and have a decent but short ranged projectile attack."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/stalker,/datum/eldritch_knowledge/entropic_plume)
	unlocked_transmutations = list(/datum/eldritch_transmutation/summon/rusty)

/datum/eldritch_knowledge/blood_siphon
	name = "Blood Siphon"
	gain_text = "Our blood is one in the same, after all. The Owl told me."
	desc = "You gain a spell that drains enemies health and restores yours."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/touch/blood_siphon)
	next_knowledge = list(/datum/eldritch_knowledge/raw_prophet,/datum/eldritch_knowledge/area_conversion)

/datum/eldritch_knowledge/flesh_final
	name = "Priest's Final Hymn"
	gain_text = "Men of the world; Hear me! For the time of the Lord of Arms has come!"
	desc = "Bring 3 bodies onto a transmutation rune to either ascend as the King of the Night or summon a Terror of the Night and triple your ghoul maximum."
	cost = 3
	route = PATH_FLESH
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/flesh_final)
