/datum/round_event_control/bad_wizard
	name = "Bad Wizard"
	typepath = /datum/round_event/ghost_role/bad_wizard
	gamemode_blacklist = list("wizard")
	max_occurrences = 1
	min_players = 20
	weight = 5

/datum/round_event/ghost_role/bad_wizard
	minimum_required = 1
	role_name = "Wizard Foundation Diplomat"

/datum/round_event/ghost_role/bad_wizard/spawn_role()
	var/list/mob/dead/observer/candidates = get_candidates(ROLE_WIZARD, null, ROLE_WIZARD)

	if(candidates.len < 1)
		return NOT_ENOUGH_PLAYERS

	var/mob/living/carbon/human/wizard = makeBody(pick_n_take(candidates))

	wizard.mind.special_role = ROLE_WIZARD
	wizard.mind.assigned_role = ROLE_WIZARD
	wizard.mind.add_antag_datum(/datum/antagonist/wizard/meme)
	spawned_mobs += wizard
	return SUCCESSFUL_SPAWN

/datum/antagonist/wizard/meme
	outfit_type = /datum/outfit/memewiznerd

/datum/antagonist/wizard/meme/greet()
	to_chat(owner, "<span class='boldannounce'>You are the Space Wizard!</span>")
	to_chat(owner, "<B>The Space Wizards Federation has given you the following tasks:</B>")
	owner.announce_objectives()
	to_chat(owner, "In your pockets you will find a teleport scroll. Use it as needed.")
	to_chat(owner, "You have received the following spellset:")
	make_spells()

/datum/antagonist/wizard/meme/proc/make_spells()
	switch(rand(1)) //keep this consistent with the amount of loadouts.

		if(1) //5x jaunt
			var/obj/effect/proc_holder/spell/S = new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
			owner.AddSpell(S)
			S.spell_level = 4
			S.charge_max = round(initial(S.charge_max) - S.spell_level * (initial(S.charge_max) - S.cooldown_min)/ S.level_max)
			if(S.charge_max < S.charge_counter)
				S.charge_counter = S.charge_max
			S.name = "Instant [S.name]"
			to_chat(owner, "[S.name]")