
/**
  * #Eldritch Knwoledge
  *
  * Datum that makes eldritch cultist interesting.
  *
  * Eldritch knowledge aren't instantiated anywhere roundstart, and are initalized and destroyed as the round goes on.
  */
/datum/eldritch_knowledge
	///Name of the knowledge
	var/name = "Basic knowledge"
	///Description of the knowledge
	var/desc = "Basic knowledge of forbidden arts."
	///What shows up
	var/gain_text = ""
	///Cost of knowledge in souls
	var/cost = 0
	///Next knowledge in the research tree
	var/list/next_knowledge = list()
	///What knowledge is incompatible with this. This will simply make it impossible to research knowledges that are in banned_knowledge once this gets researched.
	var/list/banned_knowledge = list()
	///What path is this on defaults to "Side"
	var/route = PATH_SIDE
	var/list/unlocked_transmutations = list()

/**
  * What happens when this is assigned to an antag datum
  *
  * This proc is called whenever a new eldritch knowledge is added to an antag datum
  */
/datum/eldritch_knowledge/proc/on_gain(mob/user)
	to_chat(user, "<span class='warning'>[gain_text]</span>")
	var/datum/antagonist/heretic/EC = user.mind?.has_antag_datum(/datum/antagonist/heretic)
	for(var/X in unlocked_transmutations)
		var/datum/eldritch_transmutation/ET = new X
		EC.transmutations |= ET
	return
/**
  * What happens when you lose this
  *
  * This proc is called whenever antagonist looses his antag datum, put cleanup code in here
  */
/datum/eldritch_knowledge/proc/on_lose(mob/user)
	return
/**
  * What happens every tick
  *
  * This proc is called on SSprocess in eldritch cultist antag datum. SSprocess happens roughly every second
  */
/datum/eldritch_knowledge/proc/on_life(mob/user)
	return



/**
  * Mansus grasp act
  *
  * Gives addtional effects to mansus grasp spell
  */
/datum/eldritch_knowledge/proc/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	return FALSE


/**
  * Sickly blade act
  *
  * Gives addtional effects to sickly blade weapon
  */
/datum/eldritch_knowledge/proc/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	return

//////////////
///Subtypes///
//////////////

/datum/eldritch_knowledge/spell
	var/list/obj/effect/proc_holder/spell/spells_to_add = list()

/datum/eldritch_knowledge/spell/on_gain(mob/user)
	for(var/obj/effect/proc_holder/spell/S in spells_to_add)
		S = new
		user.mind.AddSpell(S)
	return ..()

/datum/eldritch_knowledge/spell/on_lose(mob/user)
	for(var/obj/effect/proc_holder/spell/S in spells_to_add)
		user.mind.RemoveSpell(S)
	return ..()

///////////////
///Base lore///
///////////////

/datum/eldritch_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Starts your journey in the mansus. Allows you to select a target using a living heart on a transmutation rune."
	gain_text = "Gates of mansus open up to your mind."
	next_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh)
	cost = 0
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp)
	unlocked_transmutations = list(/datum/eldritch_transmutation/attune_heart, /datum/eldritch_transmutation/living_heart, /datum/eldritch_transmutation/codex_cicatrix, /datum/eldritch_transmutation/recall)
	route = "Start"
