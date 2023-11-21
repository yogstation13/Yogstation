
/**
  * #Eldritch Knowledge
  *
  * Datum that makes eldritch cultist interesting.
  *
  * Eldritch knowledge isn't instantiated anywhere roundstart, and is initalized and destroyed as the round goes on.
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
	///tier of the spell, 3 of any tier is required to purchase the next ugprade knowledge, and upgrades unlock the next tier. TIER_NONE will not advance anything.
	var/tier = TIER_NONE
	///What path is this on defaults to "Side"
	var/route = PATH_SIDE
	///transmutation recipes unlocked by this knowledge
	var/list/unlocked_transmutations = list()
	

/** The Lores and their Thematic Representation
 * 
 * 	Ash is the principle of spirit and ambition, and the everlasting flame that burns bright with the kindling of life
 * 	Blade is the principle of violence and tradition, and the fundamental conflicts that arise from proximity
 * 	Bronze is the principle of time and empire, and the unstoppable force of innovation
 * 	Flesh is the principle of temptation and obedience, and the malformation of will
 * 	Rust is the principle of that which makes and unmakes, and the slow decline of all things civilized
 * 	Void is the principle of the inevitable end, and the darkness which will claim all light
 * 
 */

/**
  * What happens when this is assigned to an antag datum
  *
  * This proc is called whenever a new eldritch knowledge is added to an antag datum
  */
/datum/eldritch_knowledge/proc/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	SHOULD_CALL_PARENT(TRUE) //for now
	var/datum/antagonist/heretic/EC = user.mind?.has_antag_datum(/datum/antagonist/heretic)
	for(var/X in unlocked_transmutations)
		var/datum/eldritch_transmutation/ET = new X
		EC.transmutations |= ET

/**
  * What happens when you lose this
  *
  * This proc is called whenever antagonist looses his antag datum, put cleanup code in here
  */
/datum/eldritch_knowledge/proc/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	return

/**
  * What happens every tick
  *
  * This proc is called on SSprocess in eldritch cultist antag datum. SSprocess happens roughly every second
  */
/datum/eldritch_knowledge/proc/on_life(mob/user)
	return

/**
 * A knowledge subtype that grants the heretic a certain spell.
 */
/datum/eldritch_knowledge/spell
	/// Spell path we add to the heretic. Type-path.
	var/datum/action/cooldown/spell/spell_to_add
	/// The spell we actually created.
	var/datum/weakref/created_spell_ref
	///Spell path we add to the heretic to add a second spell (the first one only lets you add 1 lol!) this is such shit code

/datum/eldritch_knowledge/spell/Destroy()
	QDEL_NULL(created_spell_ref)
	return ..()

/datum/eldritch_knowledge/spell/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	// Added spells are tracked on the body, and not the mind,
	// because we handle heretic mind transfers
	// via the antag datum (on_gain and on_lose).
	var/datum/action/cooldown/spell/created_spell = created_spell_ref?.resolve() || new spell_to_add(user) 
	created_spell.Grant(user)
	created_spell_ref = WEAKREF(created_spell)
	. = ..()

/datum/eldritch_knowledge/spell/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	var/datum/action/cooldown/spell/created_spell = created_spell_ref?.resolve()
	created_spell?.Remove(user)

/**
  * Sickly blade act
  *
  * Gives addtional effects to sickly blade weapon
  */
/datum/eldritch_knowledge/proc/on_eldritch_blade(atom/target,mob/user,proximity_flag,click_parameters)
	return

///////////////
///Base lore///
///////////////

/datum/eldritch_knowledge/spell/basic
	name = "Break of Dawn"
	desc = "Begins your journey in the Mansus. Allows you to select a target transmuting a living heart on a transmutation rune, create new living hearts by transmuting a heart, poppy, and pool of blood, and create new Codex Cicatrixes by transmuting human skin, a bible, a poppy and a pen."
	gain_text = "Gates to the Mansus open in your mind's passion."
	cost = 0
	spell_to_add = /datum/action/cooldown/spell/touch/mansus_grasp
	unlocked_transmutations = list(
		/datum/eldritch_transmutation/basic, 
		/datum/eldritch_transmutation/living_heart, 
		/datum/eldritch_transmutation/codex_cicatrix,
		/datum/eldritch_transmutation/knowledge_ritual)
	route = "Start"

/datum/eldritch_knowledge/spell/basic_jaunt
	name = "Rising Sun"
	desc = "As your journey begins, you'll need a way to shift between realms easily, this movement ability will allow you to travel a small range and assist in escaping emergencies"
	gain_text = "Your body's connection to this realm feels weakened, for better or worse."
	cost = 0
	spell_to_add = /datum/action/cooldown/spell/jaunt/ethereal_jaunt/basic
	route = "Start"
