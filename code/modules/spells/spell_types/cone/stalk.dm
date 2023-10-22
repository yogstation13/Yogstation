/datum/action/cooldown/spell/cone/stalk
	name = "Stalk"
	desc = "Shoots out a freezing cone in front of you."
	background_icon_state = "bg_default"
	button_icon = 'icons/mob/actions/actions_hive.dmi'
	button_icon_state = "see"
	overlay_icon_state = "bg_demon_border"
	sound = 'yogstation/sound/magic/sacrament_heartbeat_01.ogg'
	panel = null
	antimagic_flags = null
	spell_requirements = null

	cooldown_time = 1 SECONDS
	cone_levels = 10


	var/list/atom/victims = list()
	var/look_counter = 0
	var/look_per_tier = 60 //1 second per look for a total of 60 seconds per tier if spending a long time looking
	var/tier = 0
	var/max_tier = 3 //3 total tiers, meaning 3 minutes to get to max tier of LOOKING
	var/list/traits = list( //they get a LOT of traits
		TRAIT_NOHARDCRIT,
		TRAIT_NOSOFTCRIT,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_NOBREATH,
		TRAIT_STUNIMMUNE,
		TRAIT_BOMBIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_TOXIMMUNE,
		TRAIT_NOLIMBDISABLE,
		TRAIT_PUSHIMMUNE,
		TRAIT_SLEEPIMMUNE, 
		TRAIT_FREERUNNING,
		TRAIT_HARDLY_WOUNDED)


/datum/action/cooldown/spell/cone/stalk/Grant(mob/grant_to)
	. = ..()
	for(var/trait in traits)
		ADD_TRAIT(owner, trait, type)
	owner.add_movespeed_modifier(type, TRUE, 101, override=TRUE , multiplicative_slowdown = 3)
	if(ishuman(owner))
		var/mob/living/carbon/human/dude = owner
		dude.physiology.damage_resistance += 90
		dude.physiology.do_after_speed *= 0.5

/datum/action/cooldown/spell/cone/stalk/Remove(mob/living/remove_from)
	for(var/trait in traits)
		REMOVE_TRAIT(owner, trait, type)
	owner.remove_movespeed_modifier(type)
	if(ishuman(owner))
		var/mob/living/carbon/human/dude = owner
		dude.physiology.damage_resistance -= 90
		dude.physiology.do_after_speed /= 0.5
	. = ..()

/datum/action/cooldown/spell/cone/stalk/before_cast(atom/cast_on)
	. = ..()
	victims = list() //wipe the list

/datum/action/cooldown/spell/cone/stalk/cast(atom/cast_on)
	. = ..()
	if(tier < max_tier)
		looking()

/datum/action/cooldown/spell/cone/stalk/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	if(target_mob == caster)
		return
	if(!target_mod.client)
		return
	if(!can_see(owner, target_mob, cone_levels))
		return

	if(tier < max_tier)
		victims += target_mob
	else
		target_mob.apply_status_effect(STATUS_EFFECT_SPEEDBOOST, 0.5, 1 SECONDS, type) //changes into a different ability at full stacks


/datum/action/cooldown/spell/cone/stalk/proc/looking()
	if(!LAZYLEN(victims) || tier >= max_tier)//if you didn't get anyone, don't start (also, stop working if you're at max tier)
		return

	if(!do_after(owner, 1 SECONDS, owner))
		return

	for(var/atom/thing in victims)
		if(can_see(owner, thing, cone_levels))
			continue
		victims -= thing

	if(!LAZYLEN(victims))//if no one is left, don't continue
		return

	look_counter++
	if(look_counter > look_per_tier)
		look_counter = 0
		increase_tier()
	looking()
		
	
/datum/action/cooldown/spell/cone/stalk/proc/increase_tier()
	tier++
	to_chat(owner, span_danger("Tiered up to [tier]"))
	switch(tier)
		if(1)
			owner.add_movespeed_modifier(type, TRUE, 101, override=TRUE , multiplicative_slowdown = 1.5)
			sound = 'yogstation/sound/magic/sacrament_heartbeat_02.ogg'
		if(2)
			owner.add_movespeed_modifier(type, TRUE, 101, override=TRUE , multiplicative_slowdown = 0.5)
			sound = 'yogstation/sound/magic/sacrament_heartbeat_03.ogg'
		if(3)
			owner.add_movespeed_modifier(type, TRUE, 101, override=TRUE , multiplicative_slowdown = -0.3) //he WILL gain on you
			cooldown_time = 10 SECONDS
			sound = 'sound/spookoween/insane_low_laugh.ogg'


