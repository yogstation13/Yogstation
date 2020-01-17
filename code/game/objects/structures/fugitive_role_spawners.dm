

/obj/effect/mob_spawn/human/fugitive
	assignedrole = "Fugitive Hunter"
	flavour_text = "" //the flavor text will be the backstory argument called on the antagonist's greet, see hunter.dm for details
	roundstart = FALSE
	death = FALSE
	random = TRUE
	show_flavour = FALSE
	density = TRUE
	var/back_story = "error"

/obj/effect/mob_spawn/human/fugitive/Initialize(mapload)
	. = ..()
	notify_ghosts("Hunters are waking up looking for refugees!", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_FUGITIVE)

/obj/effect/mob_spawn/human/fugitive/special(mob/living/new_spawn)
	var/datum/antagonist/fugitive_hunter/fughunter = new
	fughunter.backstory = back_story
	new_spawn.mind.add_antag_datum(fughunter)
	fughunter.greet()
	message_admins("[ADMIN_LOOKUPFLW(new_spawn)] has been made into a Fugitive Hunter by an event.")
	log_game("[key_name(new_spawn)] was spawned as a Fugitive Hunter by an event.")

/obj/effect/mob_spawn/human/fugitive/spacepol
	name = "police pod"
	desc = "A small sleeper typically used to put people to sleep for briefing on the mission."
	mob_name = "a spacepol officer"
	flavour_text = "Justice has arrived. I am a member of the Spacepol!"
	back_story = "space cop"
	outfit = /datum/outfit/spacepol
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/human/fugitive/russian
	name = "russian pod"
	flavour_text = "Ay blyat. I am a space-russian smuggler! We were mid-flight when our cargo was beamed off our ship!"
	short_desc = "&#x411;&#x43E;&#x431; &#x420;&#x43E;&#x431;&#x435;&#x440;&#x442;&#x441; &#x431;&#x44B;&#x43B; &#x437;&#x434;&#x435;&#x441;&#x44C; &#x432;&#x43E;&#x434;&#x43A;&#x430; &#x43F;&#x440;&#x438;&#x432;&#x435;&#x442; &#x432;&#x435;&#x441;&#x435;&#x43B;&#x43E; &#x43F;&#x435;&#x440;&#x435;&#x432;&#x435;&#x441;&#x442;&#x438; &#x44D;&#x442;&#x43E;"
	back_story = "russian"
	desc = "A small sleeper typically used to make long distance travel a bit more bearable."
	mob_name = "russian"
	outfit = /datum/outfit/russiancorpse
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
