/datum/eldritch_transmutation/flesh_blade
	name = "Flesh Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/effect/decal/cleanable/blood)
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	required_shit_list = "A pool of blood and a knife."

/datum/eldritch_transmutation/voiceless_dead
	name = "Raise Voiceless Dead"
	required_atoms = list(/mob/living/carbon/human,/obj/item/reagent_containers/food/snacks/grown/poppy)
	var/max_amt = 2
	var/current_amt = 0
	var/list/ghouls = list()
	required_shit_list = "A poppy and your deceased to rise."

/datum/eldritch_transmutation/voiceless_dead/on_finished_recipe(mob/living/user,list/atoms,loc)
	var/mob/living/carbon/human/humie = locate() in atoms
	if(QDELETED(humie) || humie.stat != DEAD)
		return

	if(length(ghouls) >= max_amt)
		return

	if(HAS_TRAIT(humie,TRAIT_HUSK))
		return

	if(HAS_TRAIT(humie, TRAIT_MINDSHIELD))
		return

	humie.grab_ghost()

	if(!humie.mind || !humie.client)
		var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [humie.real_name], a voiceless dead", ROLE_HERETIC, null, ROLE_HERETIC, 50,humie)
		if(!LAZYLEN(candidates))
			return
		var/mob/dead/observer/C = pick(candidates)
		message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(humie)]) to replace an AFK player.")
		humie.ghostize(0)
		humie.key = C.key

	ADD_TRAIT(humie,TRAIT_MUTE,MAGIC_TRAIT)
	log_game("[key_name_admin(humie)] has become a voiceless dead, their master is [user.real_name]")
	humie.revive(full_heal = TRUE, admin_revive = TRUE)
	humie.setMaxHealth(50)
	humie.health = 50 // Voiceless dead are much tougher than ghouls
	humie.become_husk()
	humie.faction |= "heretics"

	var/datum/antagonist/heretic_monster/heretic_monster = humie.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	atoms -= humie
	RegisterSignal(humie,COMSIG_MOB_,.proc/remove_ghoul)
	ghouls += humie

/datum/eldritch_transmutation/voiceless_dead/proc/remove_ghoul(datum/source)
	var/mob/living/carbon/human/humie = source
	ghouls -= humie
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source,COMSIG_MOB_)

/datum/eldritch_transmutation/summon/raw_prophet
	name = "Summon Raw Prophet"
	required_atoms = list(/obj/item/organ/eyes,/obj/item/bodypart/l_arm,/obj/item/bodypart/r_arm)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/raw_prophet
	required_shit_list = "A knife, a candle, a pen, and a piece of paper."

/datum/eldritch_transmutation/summon/stalker
	name = "Summon Stalker"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/candle,/obj/item/pen,/obj/item/paper)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/stalker
	required_shit_list = "A knife, a candle, and a piece of paper."

/datum/eldritch_transmutation/summon/ashy
	name = "Summon Ashman"
	required_atoms = list(/obj/effect/decal/cleanable/ash,/obj/item/bodypart/head,/obj/item/book)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/ash_spirit
	required_shit_list = "A pile of ash, a head and a book."

/datum/eldritch_transmutation/summon/rusty
	name = "Summon Rust Walker"
	required_atoms = list(/obj/effect/decal/cleanable/vomit,,/obj/item/book)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/rust_spirit
	required_shit_list = "A pool of vomit and a book."

/datum/eldritch_transmutation/final/flesh_final
	name = "Priest's Final Hymn"
	required_atoms = list(/mob/living/carbon/human)
	required_shit_list = "Three dead bodies."

/datum/eldritch_transmutation/final/flesh_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/alert_ = alert(user,"Do you want to ascend as the Lord of the Night or empower yourself and summon a Terror of the Night?","...","Yes","No")
	user.SetImmobilized(10 HOURS) // no way someone will stand 10 hours in a spot, just so he can move while the alert is still showing.
	switch(alert_)
		if("No")
			var/mob/living/summoned = new /mob/living/simple_animal/hostile/eldritch/armsy(loc)
			message_admins("[summoned.name] is being summoned by [user.real_name] in [loc]")
			var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [summoned.real_name]", ROLE_HERETIC, null, ROLE_HERETIC, 100,summoned)
			user.SetImmobilized(0)
			if(LAZYLEN(candidates) == 0)
				to_chat(user,span_warning("No ghost could be found..."))
				qdel(summoned)
				return FALSE
			var/mob/living/carbon/human/H = user
			H.physiology.brute_mod *= 0.5
			H.physiology.burn_mod *= 0.5
			var/datum/antagonist/heretic/heretic = user.mind.has_antag_datum(/datum/antagonist/heretic)
			var/datum/eldritch_knowledge/base_flesh/ghoul1 = heretic.get_knowledge(/datum/eldritch_knowledge/base_flesh)
			ghoul1.ghoul_amt *= 3
			var/datum/eldritch_transmutation/voiceless_dead/ghoul2 = heretic.get_transmutation(/datum/eldritch_transmutation/voiceless_dead)
			ghoul2.max_amt *= 3
			var/mob/dead/observer/ghost_candidate = pick(candidates)
			priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the dark, for Vassal of Arms has ascended! The Terror of the Night has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
			set_security_level(SEC_LEVEL_GAMMA)
			log_game("[key_name_admin(ghost_candidate)] has taken control of ([key_name_admin(summoned)]).")
			summoned.ghostize(FALSE)
			summoned.key = ghost_candidate.key
			summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
			var/datum/antagonist/heretic_monster/monster = summoned.mind.has_antag_datum(/datum/antagonist/heretic_monster)
			var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
			monster.set_owner(master)
			master.ascended = TRUE
		if("Yes")
			var/mob/living/summoned = new /mob/living/simple_animal/hostile/eldritch/armsy/prime(loc,TRUE,10)
			summoned.ghostize(0)
			user.SetImmobilized(0)
			for(var/obj/effect/proc_holder/spell/S in user.mind.spell_list)
				if(istype(S, /obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash)) //vitally important since ashen passage breaks the shit out of armsy
					user.mind.spell_list.Remove(S)
					qdel(S)
			priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the dark, for King of Arms has ascended! Our Lord of the Night has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
			set_security_level(SEC_LEVEL_GAMMA)
			log_game("[user.real_name] ascended as [summoned.real_name]")
			var/mob/living/carbon/carbon_user = user
			var/datum/antagonist/heretic/ascension = carbon_user.mind.has_antag_datum(/datum/antagonist/heretic)
			ascension.ascended = TRUE
			carbon_user.mind.transfer_to(summoned, TRUE)
			carbon_user.gib()

	return ..()
