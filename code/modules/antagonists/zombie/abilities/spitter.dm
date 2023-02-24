/////////////////\\\\\\\\\\\\\\
////						\\\\
////  STARTING ABILITIES 	\\\\
////						\\\\
////\\\\\\\\\\\\///////////\\\\

/datum/action/innate/zombie/default/overclock
	name = "Overclock Heart"
	desc = "Overwork your heart, generating more acid in the short term but slowly losing when you get too tired. It is hard to get a grip on."
	button_icon_state = "overclock"
	ability_type = ZOMBIE_TOGGLEABLE
	var/tiredness = 0

/datum/action/innate/zombie/default/overclock/Activate()
	if(tiredness)
		to_chat(owner, span_warning("You are still too tired to overwork your heart again."))
		return
	. = ..()
	var/datum/antagonist/zombie/zombie_owner = owner.mind.has_antag_datum(/datum/antagonist/zombie)
	for(var/datum/action/innate/zombie/ability as anything in zombie_owner.zombie_abilities)
		if(ability?.cooldown <= 5 SECONDS)
			continue
		ability.cooldown -= 5 SECONDS

	if(!isspitter(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/zombie/infectious/gamemode/spitter/spitter = H.dna?.species
	spitter.infection_regen = initial(spitter.infection_regen) * 2
	for(var/obj/item/zombie_hand/gamemode/spitter/zombie_hand in H.contents)
		zombie_hand.cooldown = initial(zombie_hand.cooldown) / 2

/datum/action/innate/zombie/default/overclock/process()
	. = ..()
	tiredness += 0.01
	var/datum/antagonist/zombie/zombie_owner = owner.mind.has_antag_datum(/datum/antagonist/zombie)
	for(var/datum/action/innate/zombie/ability as anything in zombie_owner.zombie_abilities)
		ability?.cooldown += tiredness / 20
	if(!isspitter(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/zombie/infectious/gamemode/spitter/spitter = H.dna.species
	spitter.infection_regen -= tiredness / 20
	for(var/obj/item/zombie_hand/gamemode/spitter/zombie_hand in H.contents)
		zombie_hand.cooldown = initial(zombie_hand.cooldown) / 2

/datum/action/innate/zombie/default/overclock/Deactivate()
	. = ..()
	var/datum/antagonist/zombie/zombie_owner = owner.mind.has_antag_datum(/datum/antagonist/zombie)
	for(var/datum/action/innate/zombie/ability as anything in zombie_owner.zombie_abilities)
		ability?.cooldown = initial(ability.cooldown)
	if(!isspitter(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/datum/species/zombie/infectious/gamemode/spitter/spitter = H.dna?.species
	spitter.infection_regen = initial(spitter.infection_regen)
	for(var/obj/item/zombie_hand/gamemode/spitter/zombie_hand in H.contents)
		zombie_hand.cooldown = initial(zombie_hand.cooldown)
	addtimer(CALLBACK(src, .proc/heal_tiredness), 5 SECONDS)

/datum/action/innate/zombie/default/overclock/proc/heal_tiredness()
	tiredness = 0

/datum/action/innate/zombie/default/spit //most spitter abilities are default since you pay to use them instead of paying to use your actual default action
	name = "Spit Acid"
	desc = "Use acid to make neurotoxin to spit at a target, paralyzing them for a while."
	button_icon_state = "spit"
	ability_type = ZOMBIE_FIREABLE
	cooldown = 15 SECONDS
	cost = 20
	custom_mouse_icon = 'icons/effects/mouse_pointers/zombie_spit.dmi'

/datum/action/innate/zombie/default/spit/UseFireableAbility(atom/target_atom)
	. = ..()
	if(!isturf(owner.loc))
		return
	var/turf/current_turf = get_turf(owner)
	var/turf/directional_turf = get_step(owner, owner.dir)

	owner.visible_message(span_danger("[owner] spits a blob of neurotoxin!"), span_warning("You spit neurotoxin[isliving(target_atom) ? " at [target_atom]" : ""]."))
	var/obj/item/projectile/bullet/neurotoxin/A = new /obj/item/projectile/bullet/neurotoxin(get_turf(owner))
	A.preparePixelProjectile(target_atom, owner)
	A.firer = owner
	A.fire()
	owner.newtonian_move(get_dir(directional_turf, current_turf))

/////////////////\\\\\\\\\\\\\\
////						\\\\
////  PURCHASABLE ABILITIES \\\\
////						\\\\
////\\\\\\\\\\\\///////////\\\\

/datum/action/innate/zombie/default/bubble
	name = "Bubble Bomb"
	desc = "Spill acid in the area around you."
	button_icon_state = "bubble"
	ability_type = ZOMBIE_INSTANT
	cooldown = 20 SECONDS
	cost = 50

/datum/action/innate/zombie/default/bubble/Activate()
	. = ..()
	for(var/atom/movable/thing in oview(1, owner))
		thing.acid_act(100, 50)

/datum/action/innate/zombie/default/puke
	name = "Puke Puddle"
	desc = "Puke a puddle of powerful acid on someone or something, coating anyone that walks over it."
	button_icon_state = "puke"
	ability_type = ZOMBIE_FIREABLE
	cooldown = 10 SECONDS
	cost = 100 //pricey!
	custom_mouse_icon = 'icons/effects/mouse_pointers/vomit.dmi'

/datum/action/innate/zombie/default/puke/IsTargetable(atom/target_atom)
	return isopenturf(target_atom) || isliving(target_atom)

/datum/action/innate/zombie/default/puke/UseFireableAbility(atom/target_atom)
	. = ..()
	if(isliving(target_atom))
		var/mob/living/L = target_atom
		L.apply_status_effect(STATUS_EFFECT_ZOMBIE_ACID)
	if(isopenturf(target_atom))
		new /obj/effect/acid_puddle(get_turf(target_atom))
