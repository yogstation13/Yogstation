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
	switch(rand(1,9)) //keep this consistent with the amount of loadouts.

		if(1) //5x jaunt
			SpellAdd(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt, 4)

		if(2) //5x blink
			SpellAdd(/obj/effect/proc_holder/spell/targeted/turf_teleport/blink, 4)

		if(3) //2x smoke, 2x blind, and 2x barnyard :)
			SpellAdd(/obj/effect/proc_holder/spell/targeted/smoke, 1)
			SpellAdd(/obj/effect/proc_holder/spell/pointed/trigger/blind, 1)
			SpellAdd(/obj/effect/proc_holder/spell/targeted/barnyardcurse, 1)

		if(4) //5x summon guns - no
			SpellAdd(/obj/effect/proc_holder/spell/targeted/infinite_guns, 4, "Greater Summon Guns")

		if(5)
			//1x space-time distortion, 2x knock, and 2x blink
			SpellAdd(/obj/effect/proc_holder/spell/spacetime_dist)
			SpellAdd(/obj/effect/proc_holder/spell/aoe_turf/knock, 1)
			SpellAdd(/obj/effect/proc_holder/spell/targeted/turf_teleport/blink, 1)

		if(6) //5x forcewall, and 5x repulse (AKA the safe space loadout)
			SpellAdd(/obj/effect/proc_holder/spell/targeted/forcewall, 4)
			SpellAdd(/obj/effect/proc_holder/spell/aoe_turf/repulse, 4)

		if(7) //5x Cluwne Curse and 2x blink
			SpellAdd(/obj/effect/proc_holder/spell/targeted/cluwnecurse, 4)
			SpellAdd(/obj/effect/proc_holder/spell/targeted/turf_teleport/blink, 1)

		if(8) // 5x Flesh to stone 5x Animation Spell 2x Blind (Weeping Angels)
			SpellAdd(/obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone, 4)
			SpellAdd(/obj/effect/proc_holder/spell/aimed/animation, 4)
			SpellAdd(/obj/effect/proc_holder/spell/pointed/trigger/blind, 1)

		if(9) // 5x Mouse Shapeshift 5x Mindswap (From Men to Mice)
			SpellAdd(/obj/effect/proc_holder/spell/targeted/shapeshift/mouse, 4)
			SpellAdd(/obj/effect/proc_holder/spell/targeted/mind_transfer, 4)

/datum/antagonist/wizard/meme/proc/SpellAdd(spellType, level = 0, custom_name) //0 is the first level (cause logic (arrays start at one))
	var/obj/effect/proc_holder/spell/S = new spellType
	owner.AddSpell(S)
	if(level)
		S.spell_level = level
		S.charge_max = round(initial(S.charge_max) - S.spell_level * (initial(S.charge_max) - S.cooldown_min)/ S.level_max)
		if(S.charge_max < S.charge_counter)
			S.charge_counter = S.charge_max
	if(custom_name)
		S.name = custom_name
	else
		S.name = "Instant [S.name]"
	to_chat(owner, "[S.name]")
