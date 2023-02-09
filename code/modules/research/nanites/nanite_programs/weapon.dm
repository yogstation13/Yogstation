//Programs specifically engineered to cause harm to either the user or its surroundings (as opposed to ones that only do it due to broken programming)
//Very dangerous!

/datum/nanite_program/flesh_eating
	name = "Cellular Breakdown"
	desc = "The nanites destroy cellular structures in the host's body, causing brute damage."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/necrotic)
	harmful = TRUE
	var/damage = 0.75

/datum/nanite_program/flesh_eating/active_effect()
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		C.take_bodypart_damage(damage, 0, 0)
	else
		host_mob.adjustBruteLoss(damage, TRUE)
	if(prob(3))
		to_chat(host_mob, span_warning("You feel a stab of pain from somewhere inside you."))

/datum/nanite_program/poison
	name = "Poisoning"
	desc = "The nanites deliver poisonous chemicals to the host's internal organs, causing toxin damage and vomiting."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/toxic)
	harmful = TRUE

/datum/nanite_program/poison/active_effect()
	host_mob.adjustToxLoss(1)
	if(prob(2))
		to_chat(host_mob, span_warning("You feel nauseous."))
		if(iscarbon(host_mob))
			var/mob/living/carbon/C = host_mob
			C.vomit(20)

/datum/nanite_program/memory_leak
	name = "Memory Leak"
	desc = "This program invades the memory space used by other programs, causing frequent corruptions and errors."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/toxic)
	harmful = TRUE

/datum/nanite_program/memory_leak/active_effect()
	if(prob(6))
		var/datum/nanite_program/target = pick(nanites.programs)
		if(target == src)
			return
		target.software_error()

/datum/nanite_program/aggressive_replication
	name = "Aggressive Replication"
	desc = "Nanites will consume organic matter to improve their replication rate, damaging the host. The efficiency increases with the volume of nanites, requiring 200 to break even."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/necrotic)
	harmful = TRUE

/datum/nanite_program/aggressive_replication/active_effect()
	var/extra_regen = round(nanites.nanite_volume / 200, 0.1)
	nanites.adjust_nanites(null,extra_regen)
	host_mob.adjustBruteLoss(extra_regen / 2, TRUE)

/datum/nanite_program/meltdown
	name = "Meltdown"
	desc = "Causes an internal meltdown inside the nanites, causing internal burns inside the host as well as rapidly destroying the nanite population.\
			Sets the nanites' safety threshold to 0 when activated."
	use_rate = 10
	rogue_types = list(/datum/nanite_program/glitch)
	harmful = TRUE
	var/damage = 2.5

/datum/nanite_program/meltdown/active_effect()
	host_mob.adjustFireLoss(damage)

/datum/nanite_program/meltdown/enable_passive_effect()
	. = ..()
	to_chat(host_mob, span_userdanger("Your blood is burning!"))
	nanites.safety_threshold = 0

/datum/nanite_program/meltdown/disable_passive_effect()
	. = ..()
	to_chat(host_mob, span_warning("Your blood cools down, and the pain gradually fades."))

/datum/nanite_program/triggered/explosive
	name = "Chain Detonation"
	desc = "Detonates all the nanites inside the host in a chain reaction when triggered."
	trigger_cost = 50
	trigger_cooldown = 1 MINUTES //No spamming explosions, give the poor sap a break
	rogue_types = list(/datum/nanite_program/toxic)
	harmful = TRUE

/datum/nanite_program/triggered/explosive/trigger()
	if(!..())
		return
	host_mob.visible_message(span_warning("[host_mob] starts emitting a high-pitched buzzing, and [host_mob.p_their()] skin begins to glow..."),\
							span_userdanger("You start emitting a high-pitched buzzing, and your skin begins to glow..."))
	addtimer(CALLBACK(src, .proc/boom), 30 SECONDS) //You have 30 seconds to live

/datum/nanite_program/triggered/explosive/proc/boom()
	var/nanite_amount = nanites.nanite_volume
	host_mob.adjustBruteLoss(nanite_amount/5) //Instead of gibbing we'll just do an asston of damage
	var/light_range = FLOOR(nanite_amount/50, 1) - 1
	explosion(host_mob, 0, 0, light_range)

//TODO make it defuse if triggered again

/datum/nanite_program/triggered/heart_stop
	name = "Heart-Stopper"
	desc = "Stops the host's heart when triggered; restarts it if triggered again."
	trigger_cost = 12
	trigger_cooldown = 10
	rogue_types = list(/datum/nanite_program/nerve_decay)
	harmful = TRUE

/datum/nanite_program/triggered/heart_stop/trigger()
	if(!..())
		return
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
		if(heart)
			if(heart.beating)
				heart.Stop()
			else
				heart.Restart()

/datum/nanite_program/triggered/emp
	name = "Electromagnetic Resonance"
	desc = "The nanites cause an elctromagnetic pulse around the host when triggered. Will corrupt other nanite programs!"
	trigger_cost = 10
	program_flags = NANITE_EMP_IMMUNE
	rogue_types = list(/datum/nanite_program/toxic)
	harmful = TRUE

/datum/nanite_program/triggered/emp/trigger()
	if(!..())
		return
	empulse(host_mob, 1, 2)

/datum/nanite_program/pyro/active_effect()
	host_mob.adjust_fire_stacks(1)
	host_mob.IgniteMob()

/datum/nanite_program/pyro
	name = "Sub-Dermal Combustion"
	desc = "The nanites cause buildup of flammable fluids under the host's skin, then ignites them."
	use_rate = 3
	rogue_types = list(/datum/nanite_program/skin_decay, /datum/nanite_program/cryo)
	harmful = TRUE

/datum/nanite_program/pyro/check_conditions()
	if(host_mob.on_fire)
		return FALSE
	return ..()

/datum/nanite_program/pyro/active_effect()
	host_mob.adjust_fire_stacks(1)
	host_mob.IgniteMob()

/datum/nanite_program/cryo
	name = "Cryogenic Treatment"
	desc = "The nanites rapidly sink heat through the host's skin, lowering their temperature."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/skin_decay, /datum/nanite_program/pyro)
	harmful = TRUE

/datum/nanite_program/cryo/check_conditions()
	if(host_mob.bodytemperature <= 70)
		return FALSE
	return ..()

/datum/nanite_program/cryo/active_effect()
	host_mob.adjust_bodytemperature(-rand(15,25), 50)
