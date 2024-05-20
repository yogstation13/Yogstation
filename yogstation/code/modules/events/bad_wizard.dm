/datum/round_event_control/bad_wizard
	name = "Bad Wizard"
	typepath = /datum/round_event/ghost_role/bad_wizard
	gamemode_blacklist = list("wizard")
	max_occurrences = 1
	min_players = 20
	weight = 5

/datum/round_event/ghost_role/bad_wizard
	minimum_required = 1
	role_name = "Wizard Federation Diplomat"

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
	to_chat(owner, span_boldannounce("You are the Space Wizard!"))
	to_chat(owner, "<B>The Space Wizards Federation has given you the following tasks:</B>")
	owner.announce_objectives()
	to_chat(owner, "In your pockets you will find a teleport scroll. Use it as needed.")
	to_chat(owner, "You have received the following spellset:")
	make_spells()

/datum/antagonist/wizard/meme/proc/make_spells()
	switch(rand(1,9)) //keep this consistent with the amount of loadouts.

		if(1) //5x jaunt
			SpellAdd(/datum/action/cooldown/spell/jaunt/ethereal_jaunt, 5)

		if(2) //5x blink
			SpellAdd(/datum/action/cooldown/spell/teleport/radius_turf/blink, 5)

		if(3) //2x smoke, 2x blind, and 2x barnyard :)
			SpellAdd(/datum/action/cooldown/spell/smoke, 2)
			SpellAdd(/datum/action/cooldown/spell/aoe/blindness, 2)
			SpellAdd(/datum/action/cooldown/spell/pointed/barnyardcurse, 2)

		if(4) //5x summon guns - no
			SpellAdd(/datum/action/cooldown/spell/conjure_item/infinite_guns/gun, 5, "Greater Summon Guns")

		if(5)
			//1x space-time distortion, 2x knock, and 2x blink
			SpellAdd(/datum/action/cooldown/spell/spacetime_dist)
			SpellAdd(/datum/action/cooldown/spell/aoe/knock, 2)
			SpellAdd(/datum/action/cooldown/spell/teleport/radius_turf/blink, 2)

		if(6) //5x forcewall, and 5x repulse (AKA the safe space loadout)
			SpellAdd(/datum/action/cooldown/spell/forcewall, 5)
			SpellAdd(/datum/action/cooldown/spell/aoe/repulse/wizard, 5)

		if(7) //5x Slip 5x Appendicitis, and 2x blink (god have mercy, for this wizard has none)
			SpellAdd(/datum/action/cooldown/spell/aoe/slip, 5)
			SpellAdd(/datum/action/cooldown/spell/pointed/appendicitis, 5)
			SpellAdd(/datum/action/cooldown/spell/teleport/radius_turf/blink, 2)

		if(8) // 5x Flesh to stone 5x Animation Spell 2x Blind (Weeping Angels)
			SpellAdd(/datum/action/cooldown/spell/touch/flesh_to_stone, 5)
			SpellAdd(/datum/action/cooldown/spell/pointed/projectile/animation, 5)
			SpellAdd(/datum/action/cooldown/spell/pointed/blind, 2)

		if(9) // 5x Mouse Shapeshift 5x Mindswap (From Men to Mice) //may that video rest in peace
			SpellAdd(/datum/action/cooldown/spell/shapeshift/mouse, 5)
			SpellAdd(/datum/action/cooldown/spell/pointed/mind_transfer, 5)

/datum/antagonist/wizard/meme/proc/SpellAdd(spellType, level = 1, custom_name = "") //0 is the first level (cause logic (arrays start at one))
	var/datum/action/cooldown/spell/spell_to_add = new spellType(owner)
	spell_to_add.Grant(owner.current)
	spell_to_add.spell_level = level
	spell_to_add.name = length(custom_name) ? custom_name : "Instant [spell_to_add.name]"
	to_chat(owner, "[spell_to_add.name]")
