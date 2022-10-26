#define SIN_GLUTTONY "gluttony"
#define SIN_GREED "greed"
#define SIN_SLOTH "sloth"
#define SIN_WRATH "wrath"
#define SIN_ENVY "envy"
#define SIN_PRIDE "pride"

/mob/living/carbon/human/Life()
	. = ..()
	if(is_sinfuldemon(src))
		var/datum/antagonist/sinfuldemon/demon = mind.has_antag_datum(/datum/antagonist/sinfuldemon)
		demon.sinfuldemon_life()

/datum/antagonist/sinfuldemon
	name = "Sinful Demon"
	roundend_category = "demons of sin"
	antagpanel_category = "Demon"
	job_rank = ROLE_SINFULDEMON
	show_to_ghosts = TRUE
	///The sin a specific demon is assigned to. Defines what objectives and powers they'll receive.
	var/demonsin
	///The list of choosable sins for demons. One will be assigned to a demon when spawned naturally.
	var/static/list/demonsins = list(SIN_GLUTTONY, SIN_GREED, SIN_WRATH, SIN_ENVY, SIN_PRIDE)
	var/static/list/demon_spells = typecacheof(list(
		/obj/effect/proc_holder/spell/targeted/shapeshift/demon,
		/obj/effect/proc_holder/spell/targeted/shapeshift/demon/gluttony,
		/obj/effect/proc_holder/spell/targeted/shapeshift/demon/wrath,
		/obj/effect/proc_holder/spell/targeted/forcewall/gluttony,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/summon_greedslots,
		/obj/effect/proc_holder/spell/targeted/inflict_handler/ignite,
		/obj/effect/proc_holder/spell/targeted/touch/envy,
		/obj/effect/proc_holder/spell/aoe_turf/conjure/summon_mirror))

	var/static/list/sinfuldemon_traits = list(
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOCRITDAMAGE,
	)

/datum/antagonist/sinfuldemon/proc/sinfuldemon_life()
	var/mob/living/carbon/C = owner.current
	if(!C)
		return
	if(istype(get_area(C), /area/chapel))
		demon_burn()

///Handles burning and hurting sinful demons while they're in the chapel.
/datum/antagonist/sinfuldemon/proc/demon_burn() //sinful demons are even more vulnerable to the chapel than vampires, but can turn into their true form to negate this.
	var/mob/living/L = owner.current
	if(!L)
		return
	if(L.stat != DEAD) //demons however wont dust from the chapel so this needs to be a check to avoid spam while they're already dead
		if(prob(50) && L.health >= 50)
			switch(L.health)
				if(85 to 100)
					L.visible_message(span_warning("[L]'s skin begins to heat up and darken!"), span_danger("Your flesh begins to sear..."))
				if(60 to 85)
					L.visible_message(span_warning("[L]'s skin begins to melt apart!"), span_danger("Your skin is melting!"), "You hear sizzling.")
			L.adjustFireLoss(5)
		else if(L.health < 60)
			if(!L.on_fire)
				L.visible_message(span_warning("[L] lights up in a holy blaze!"), span_danger("Your skin catches fire!"))
				L.emote("scream")
			else
				L.visible_message(span_warning("[L] continues to burn!"), span_danger("You continue to burn!"))
			L.adjust_fire_stacks(5)
			L.IgniteMob()
	return

/datum/antagonist/sinfuldemon/New()
	. = ..()
	demonsin = pick(demonsins)

/datum/antagonist/sinfuldemon/proc/forge_objectives()
	var/datum/objective/demon/O
	switch(demonsin)//the 5 most interesting of the 8 sins. Left out sloth because it sounds boring, couldn't think of a good enough objective/power for acedia, and lust for obvious reasons.
		if(SIN_GLUTTONY)
			O = new /datum/objective/demon/gluttony
		if(SIN_GREED)
			O = new /datum/objective/demon/greed
		if(SIN_WRATH)
			O = new /datum/objective/demon/wrath
			if(prob(50))
				var/N = pick(/datum/objective/assassinate, /datum/objective/assassinate/cloned, /datum/objective/assassinate/once)
				var/datum/objective/assassinate/kill_objective = new N
				kill_objective.owner = owner
				kill_objective.find_target()
				objectives += kill_objective
		if(SIN_ENVY)
			O = new /datum/objective/demon/envy
		if(SIN_PRIDE)
			O = new /datum/objective/demon/pride
	objectives += O

/datum/antagonist/sinfuldemon/can_be_owned(datum/mind/new_owner)
	. = ..()
	return . && (ishuman(new_owner.current) || iscyborg(new_owner.current))

/datum/antagonist/sinfuldemon/admin_add(datum/mind/new_owner,mob/admin)
	var/choices = demonsins + "Random"
	var/chosen_sin = input(admin,"What kind ?","Sin kind") as null|anything in choices
	if(!chosen_sin)
		return
	if(chosen_sin in demonsins)
		demonsin = chosen_sin
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has demonized [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has demonized [key_name(new_owner)].")

/datum/antagonist/sinfuldemon/antag_listing_name()
	return ..() + "(, demon of [demonsin])" // Boris Smith, demon of Wrath

/datum/antagonist/sinfuldemon/greet()
	to_chat(owner.current, span_warning("<b>You remember your link to the infernal. You are a demon of [demonsin] released from hell to spread sin amongst the living.</b>"))
	to_chat(owner.current, span_warning("<b>Your half demon, half human form grants you increased fortitude, allowing you to resist more damage before going down.</b>"))
	to_chat(owner.current, span_warning("<b>However, your infernal form is not without weaknesses.</b>"))
	to_chat(owner.current, "You are incredibly vulnerable to holy artifacts and influence.")
	to_chat(owner.current, "While blessed with the unholy ability to transform into your true form, this form is extremely obvious and vulnerable to holy weapons.")
	to_chat(owner.current, "[span_warning("Do your best to complete your objectives without unnessecary death, unless you are a wrathful demon.")]<br>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/ethereal_exit.ogg'))
	.=..()

/datum/antagonist/sinfuldemon/on_gain()
	forge_objectives()
	owner.special_role = "sinfuldemon"
	owner.current.faction += "hell"
	for(var/all_traits in sinfuldemon_traits) ///adds demon traits
		ADD_TRAIT(owner.current, all_traits, SINFULDEMON_TRAIT)
	if(owner.assigned_role == "Clown" && ishuman(owner.current))
		var/mob/living/carbon/human/S = owner.current
		to_chat(S, span_notice("Your infernal nature has allowed you to overcome your clownishness."))
		S.dna.remove_mutation(CLOWNMUT)
	switch(demonsin) 
		if(SIN_GLUTTONY)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/demon/gluttony)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall/gluttony)
			ADD_TRAIT(owner.current, TRAIT_EAT_MORE, SINFULDEMON_TRAIT) //gluttonous demons hunger thrice as fast, unique to just them.
		if(SIN_GREED)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/demon)
			owner.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/summon_greedslots)
		if(SIN_WRATH)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/demon/wrath)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/inflict_handler/ignite)
		if(SIN_ENVY)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/demon)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/touch/envy)
		if(SIN_PRIDE)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/shapeshift/demon)
			owner.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/summon_mirror)
	.=..()

/datum/antagonist/sinfuldemon/on_removal()
	owner.special_role = null
	owner.current.faction -= "hell"
	for(var/all_status_traits in owner.current.status_traits) //removes demon traits
		REMOVE_TRAIT(owner.current, all_status_traits, SINFULDEMON_TRAIT)
	remove_spells()
	to_chat(owner.current, span_userdanger("Your infernal link has been severed! You are no longer a demon!"))
	.=..()

/datum/antagonist/sinfuldemon/proc/remove_spells()
	for(var/X in owner.spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(is_type_in_typecache(S, demon_spells))
			owner.RemoveSpell(S)

/datum/antagonist/sinfuldemon/roundend_report()
	var/list/parts = list()
	parts += printplayer(owner)
	parts += printobjectives(objectives)
	return parts.Join("<br>")

#undef SIN_ENVY
#undef SIN_GLUTTONY
#undef SIN_GREED
#undef SIN_PRIDE
#undef SIN_SLOTH
#undef SIN_WRATH
