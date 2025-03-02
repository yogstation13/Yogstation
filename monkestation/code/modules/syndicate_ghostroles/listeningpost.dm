
//role

///asteroid comms agent

//job datum

/datum/job/lavaland_syndicate/space //prevent admin confusion (getting bwoinked while squatting on a space ruin)
	title = ROLE_SPACE_SYNDICATE

//spawner itself

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms/space
	you_are_text = "You are a syndicate agent, assigned to a small listening post station situated near your hated enemy's top secret research facility: Space Station 13."
	flavour_text = "Monitor enemy activity as best you can, and try to keep a low profile. Use the communication equipment to provide support to any field agents, and sow disinformation to throw Nanotrasen off your trail. Do not let the base fall into enemy hands!"
	important_text = "DO NOT leave the base. You are not a field agent, and are not permitted to do their job for them."
	spawner_job_path = /datum/job/lavaland_syndicate/space



/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms/space/anderson //the last agent according to lore, spawns rarely, has some flavour text, should start blinded
	name = "sleeper"
	desc = "A standard medicinal sleeper used to treat small and major injuries alike. It appears to be locked up, and you can see a gas mask through the fogged-up windows..."
	icon_state = "sleeper"
	you_are_text = "You are a Syndicate reconnaisance agent who went blind in an accident..."
	flavour_text = "Your painkillers are running low, your memories are getting foggy, and all you can remember is the codename 'Anderson'. You were about to hurl yourself out into space, but you heard the intercom announce that the backup was getting unfrozen... maybe you'll see again?"
	important_text = "DO NOT leave the base, you're inevitably doomed without it!"
	outfit = /datum/outfit/lavaland_syndicate/comms/anderson

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms/space/anderson/Initialize(mapload)
	. = ..()
	if(prob(85)) //only has a 15% chance of existing, otherwise it'll just be a regular (self-control) sleeper
		return INITIALIZE_HINT_QDEL //the destroy() code already handles sleeper spawning

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms/space/anderson/Destroy()
	var/obj/machinery/sleeper/self_control/anderson = new(drop_location()) //one guy cmon
	anderson.setDir(dir)
	return ..()

/datum/outfit/lavaland_syndicate/comms/anderson
	name = "'Anderson' Comms Agent"
	r_hand = /obj/item/storage/pill_bottle //empty pillbottle
	l_hand = /obj/item/knife/combat/survival //no esword, but still a knife
	head = /obj/item/clothing/head/soft/black

/obj/effect/mob_spawn/ghost_role/human/lavaland_syndicate/comms/space/anderson/special(mob/living/new_spawn)
	. = ..()
	new_spawn.grant_language(/datum/language/codespeak, TRUE, TRUE, LANGUAGE_MIND)
	new_spawn.adjustOrganLoss(ORGAN_SLOT_EYES, 100) //AAAARGH MY EYES
	new_spawn.adjustOrganLoss(ORGAN_SLOT_LIVER, 35) //not completely out, but it's not having a good day
