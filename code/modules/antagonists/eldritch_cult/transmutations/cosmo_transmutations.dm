/datum/eldritch_transmutation/cosmic_knife
	name = "Cosmic Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/stack/sheet/mineral/plasma)
	result_atoms = list(/obj/item/melee/sickly_blade/cosmic)
	required_shit_list = "A pierce of plasma and a knife."

/datum/eldritch_transmutation/final/cosmic_final
	name = "Creators's Gift"
	required_atoms = list(/mob/living/carbon/human)
	required_shit_list = "Three dead bodies."

/datum/eldritch_transmutation/final/cosmic_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/alert_ = tgui_alert(user, "Do you want to ascend as a Star Gazer? Rejecting this power will empower yourself and summon one as an ally.", "...", list("Yes","No"))
	user.SetImmobilized(10 HOURS) // no way someone will stand 10 hours in a spot, just so he can move while the alert is still showing.
	switch(alert_)
		if("No")
			var/mob/living/summoned = new /mob/living/simple_animal/hostile/eldritch/star_gazer(loc)
			message_admins("[summoned.name] is being summoned by [user.real_name] in [loc].")
			var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [summoned.real_name]?", ROLE_HERETIC, null, ROLE_HERETIC, 100,summoned)
			user.SetImmobilized(0)
			if(LAZYLEN(candidates) == 0)
				to_chat(user,span_warning("No ghost could be found..."))
				qdel(summoned)
				return FALSE
			var/mob/living/carbon/human/H = user
			H.physiology.brute_mod *= 0.5
			H.physiology.burn_mod *= 0.5
			H.physiology.stamina_mod = 0
			H.physiology.stun_mod = 0

			ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, MAGIC_TRAIT)
			ADD_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, MAGIC_TRAIT)
			ADD_TRAIT(user, TRAIT_NOBREATH, MAGIC_TRAIT)
			var/mob/dead/observer/ghost_candidate = pick(candidates)
			priority_announce("Immense destabilization of the bluespace veil has been observed. Our scanners report two entitites of immeasurable power. Beginning sector purge. Immediate evacuation is advised.", "Anomaly Alert", ANNOUNCER_SPANOMALIES)

			log_game("[key_name_admin(ghost_candidate)] has taken control of ([key_name_admin(summoned)]).")
			summoned.ghostize(FALSE)
			summoned.key = ghost_candidate.key
			summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
			var/datum/antagonist/heretic_monster/monster = summoned.mind.has_antag_datum(/datum/antagonist/heretic_monster)
			var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
			monster.set_owner(master)
			master.ascended = TRUE
		if("Yes")
			var/mob/living/summoned = new /mob/living/simple_animal/hostile/eldritch/star_gazer(loc,TRUE,10)
			summoned.ghostize(0)
			user.SetImmobilized(0)
			for(var/datum/action/cooldown/spell/spells in user.actions)
				if(istype(spells, /datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash)) //I dont want big mobs to be able to use ash jaunt
					spells.Remove(user)
					qdel(spells)
			priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the cosmos, for The Creator has ascended! Unmake all of reality! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
			var/atom/movable/gravity_lens/shockwave = new(get_turf(user))
			SSsecurity_level.set_level(SEC_LEVEL_GAMMA)

			shockwave.transform = matrix().Scale(0.5)
			shockwave.pixel_x = -240
			shockwave.pixel_y = -240
			animate(shockwave, alpha = 0, transform = matrix().Scale(20), time = 10 SECONDS, easing = QUAD_EASING)
			QDEL_IN(shockwave, 10.5 SECONDS)
			log_game("[user.real_name] ascended as [summoned.real_name].")
			var/mob/living/carbon/carbon_user = user
			var/datum/antagonist/heretic/ascension = carbon_user.mind.has_antag_datum(/datum/antagonist/heretic)
			ascension.ascended = TRUE
			ascension.transformed = TRUE
			carbon_user.mind.transfer_to(summoned, TRUE)
			carbon_user.gib()

	return ..()
