#define SIN_GLUTTONY "gluttony"
#define SIN_GREED "greed"
#define SIN_SLOTH "sloth"
#define SIN_WRATH "wrath"
#define SIN_ENVY "envy"
#define SIN_PRIDE "pride"

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
		/datum/action/cooldown/spell/shapeshift/demon,
		/datum/action/cooldown/spell/shapeshift/demon/gluttony,
		/datum/action/cooldown/spell/shapeshift/demon/wrath,
		/datum/action/cooldown/spell/forcewall/gluttony,
		/datum/action/cooldown/spell/conjure/summon_greedslots,
		/datum/action/cooldown/spell/pointed/ignite,
		/datum/action/cooldown/spell/touch/envy,
		/datum/action/cooldown/spell/conjure/summon_mirror,
		/datum/action/cooldown/spell/touch/mend,
		/datum/action/cooldown/spell/touch/torment,
		/datum/action/cooldown/spell/conjure/cursed_item,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/sin,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/sin/wrath,
		))

	var/static/list/sinfuldemon_traits = list(
		TRAIT_GENELESS,
		TRAIT_STABLEHEART,
		TRAIT_NOSOFTCRIT,
		TRAIT_NOCRITDAMAGE,
	)

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
			L.ignite_mob()
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
	. = ..()

/datum/antagonist/sinfuldemon/on_gain()
	forge_objectives()
	owner.special_role = "sinfuldemon"
	owner.current.faction += "hell"
	for(var/all_traits in sinfuldemon_traits) ///adds demon traits
		ADD_TRAIT(owner.current, all_traits, SINFULDEMON_TRAIT)
	switch(demonsin) 
		if(SIN_GLUTTONY)
			var/datum/action/cooldown/spell/forcewall/gluttony/fat_wall = new(owner.current)
			fat_wall.Grant(owner.current)
			
			var/datum/action/cooldown/spell/shapeshift/demon/gluttony/fat_demon = new(owner.current)
			fat_demon.Grant(owner.current)

			var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/sin/jaunt = new(owner.current)
			jaunt.Grant(owner.current)

			ADD_TRAIT(owner.current, TRAIT_AGEUSIA, SINFULDEMON_TRAIT) // nothing disgusts you
			ADD_TRAIT(owner.current, TRAIT_EAT_MORE, SINFULDEMON_TRAIT) // 3x hunger rate
			ADD_TRAIT(owner.current, TRAIT_BOTTOMLESS_STOMACH, SINFULDEMON_TRAIT) // nutrition is capped for infinite eating
			ADD_TRAIT(owner.current, TRAIT_VORACIOUS, SINFULDEMON_TRAIT) // eat and drink faster & eat infinite snacks

		if(SIN_GREED) 
			var/datum/action/cooldown/spell/shapeshift/demon/demon_form = new(owner.current)
			demon_form.Grant(owner.current)

			var/datum/action/cooldown/spell/conjure/summon_greedslots/gambling_addiction = new(owner.current)
			gambling_addiction.Grant(owner.current)

			var/datum/action/cooldown/spell/conjure/cursed_item/immortal_temptation = new(owner.current)
			immortal_temptation.Grant(owner.current)

			var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/sin/jaunt = new(owner.current)
			jaunt.Grant(owner.current)

		if(SIN_WRATH)
			var/datum/action/cooldown/spell/shapeshift/demon/wrath/wrath_demon = new(owner.current)
			wrath_demon.Grant(owner.current)

			var/datum/action/cooldown/spell/pointed/ignite/not_fireball = new(owner.current)
			not_fireball.Grant(owner.current)

			var/datum/action/cooldown/spell/touch/torment/pain_hand = new(owner.current)
			pain_hand.Grant(owner.current)

			var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/sin/wrath/jaunt = new(owner.current)
			jaunt.Grant(owner.current)

		if(SIN_ENVY)
			var/datum/action/cooldown/spell/shapeshift/demon/demon_form = new(owner.current)
			demon_form.Grant(owner.current)

			var/datum/action/cooldown/spell/touch/envy/agent_id = new(owner.current)
			agent_id.Grant(owner.current)

			var/datum/action/cooldown/spell/touch/torment/pain_hand = new(owner.current)
			pain_hand.Grant(owner.current)

			var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/sin/jaunt = new(owner.current)
			jaunt.Grant(owner.current)

		if(SIN_PRIDE)
			var/datum/action/cooldown/spell/shapeshift/demon/demon_form = new(owner.current)
			demon_form.Grant(owner.current)

			var/datum/action/cooldown/spell/conjure/summon_mirror/space_hole = new(owner.current)
			space_hole.Grant(owner.current)

			var/datum/action/cooldown/spell/touch/mend/heal_hand = new(owner.current)
			heal_hand.Grant(owner.current)

			var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/sin/jaunt = new(owner.current)
			jaunt.Grant(owner.current)

	return ..()

/datum/antagonist/sinfuldemon/on_removal()
	owner.special_role = null
	owner.current.faction -= "hell"
	for(var/all_status_traits in owner.current._status_traits) //removes demon traits
		REMOVE_TRAIT(owner.current, all_status_traits, SINFULDEMON_TRAIT)
	for(var/datum/action/cooldown/spell/spell in owner.current.actions)
		if(spell.target == owner)
			qdel(spell)
			owner.current.actions -= spell
	to_chat(owner.current, span_userdanger("Your infernal link has been severed! You are no longer a demon!"))
	return ..()

/datum/antagonist/sinfuldemon/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	handle_clown_mutation(current_mob, mob_override ? null : "Your infernal nature has allowed you to overcome your clownishness.")
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(sinfuldemon_life))

/datum/antagonist/sinfuldemon/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	UnregisterSignal(current_mob, COMSIG_LIVING_LIFE)
	return ..()

/datum/antagonist/sinfuldemon/proc/sinfuldemon_life(mob/living/source, seconds_per_tick, times_fired)
	var/mob/living/carbon/carbon_source = source
	if(!carbon_source)
		return
	if(istype(get_area(carbon_source), /area/chapel))
		demon_burn()

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

/datum/antagonist/sinfuldemon/get_preview_icon()
	var/icon/sinfuldemon_icon = icon('icons/mob/mob.dmi', "lesserdaemon")

	sinfuldemon_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return sinfuldemon_icon
