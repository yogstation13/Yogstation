/obj/item/organ/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and viscera."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_ZOMBIE
	icon_state = "blacktumor"
	var/causes_damage = TRUE
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 30
	var/converts_living = FALSE

	var/revive_time_min = 450
	var/revive_time_max = 700
	var/timer_id

	var/damage_caused = 1

/obj/item/organ/zombie_infection/Initialize()
	. = ..()
	if(iscarbon(loc))
		Insert(loc)
	GLOB.zombie_infection_list += src

/obj/item/organ/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/zombie_infection/Insert(var/mob/living/carbon/M, special = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/zombie_infection/Remove(mob/living/carbon/M, special = 0)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(iszombie(M) && old_species)
		M.set_species(old_species)
	if(timer_id)
		deltimer(timer_id)

/obj/item/organ/zombie_infection/on_find(mob/living/finder)
	to_chat(finder, "<span class='warning'>Inside the head is a disgusting black \
		web of pus and viscera, bound tightly around the brain like some \
		biological harness.</span>")

/obj/item/organ/zombie_infection/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		Remove(owner)
	if (causes_damage && !iszombie(owner) && owner.stat != DEAD)
		if(owner.dna.species.id == "pod")
			owner.adjustToxLoss(damage_caused + 0.5)	//So they cant passively out-heal it
		else
			owner.adjustToxLoss(damage_caused)
		if (prob(10))
			to_chat(owner, span_danger("You feel sick..."))
	if(timer_id)
		return
	if(owner.suiciding)
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if(!owner.getorgan(/obj/item/organ/brain))
		return
	if(!iszombie(owner))
		to_chat(owner, "<span class='cultlarge'>You can feel your heart stopping, but something isn't right... \
		life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
		not even  can stop, you will rise again!</span>")
	var/revive_time = rand(revive_time_min, revive_time_max)
	var/flags = TIMER_STOPPABLE
	timer_id = addtimer(CALLBACK(src, .proc/zombify), revive_time, flags)

/obj/item/organ/zombie_infection/proc/zombify()
	timer_id = null

	if(!converts_living && owner.stat != DEAD)
		return

	if(!iszombie(owner))
		old_species = owner.dna.species.type
		owner.set_species(/datum/species/zombie/infectious)

	var/stand_up = (owner.stat == DEAD) || (owner.stat == UNCONSCIOUS)

	//Fully heal the zombie's damage the first time they rise
	owner.setToxLoss(0, 0)
	owner.setOxyLoss(0, 0)
	owner.heal_overall_damage(INFINITY, INFINITY, INFINITY, null, TRUE)

	if(!owner.revive())
		return

	owner.grab_ghost()
	owner.visible_message(span_danger("[owner] suddenly convulses, as [owner.p_they()][stand_up ? " stagger to [owner.p_their()] feet and" : ""] gain a ravenous hunger in [owner.p_their()] eyes!"), span_alien("You HUNGER!"))
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	owner.do_jitter_animation(living_transformation_time)
	owner.Stun(living_transformation_time)
	to_chat(owner, span_alertalien("You are now a zombie!"))


/obj/item/organ/zombie_infection/nodamage
	causes_damage = FALSE

/obj/item/organ/zombie_infection/gamemode
	damage_caused = 3

/obj/item/organ/zombie_infection/gamemode/zombify()
	timer_id = null

	if(!converts_living && owner.stat != DEAD)
		return

	if(!iszombie(owner))
		old_species = owner.dna.species.type
		owner.set_species(/datum/species/zombie/infectious/gamemode)

	var/stand_up = (owner.stat == DEAD) || (owner.stat == UNCONSCIOUS)

	//Fully heal the zombie's damage the first time they rise
	owner.setToxLoss(0, 0)
	owner.setOxyLoss(0, 0)
	owner.heal_overall_damage(INFINITY, INFINITY, INFINITY, null, TRUE)

	if(!owner.revive())
		return

	owner.grab_ghost()
	owner.visible_message(span_danger("[owner] suddenly convulses, as [owner.p_they()][stand_up ? " stagger to [owner.p_their()] feet and" : ""] gain a ravenous hunger in [owner.p_their()] eyes!"), span_alien("You HUNGER!"))
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	owner.do_jitter_animation(living_transformation_time)
	owner.Stun(living_transformation_time)
	to_chat(owner, span_alertalien("You are now a zombie! Help your fellow allies take over the station!"))


	if(!isinfected(owner)) //Makes them the *actual* antag, instead of just a zombie.
		var/datum/game_mode/zombie/GM = SSticker.mode
		if(!istype(GM))
			return
		GM.add_zombie(owner.mind)

	var/datum/antagonist/zombie/Z = locate() in owner.mind.antag_datums
	if(!Z.evolution.owner)
		Z.evolution.Grant(owner)

	if(owner.handcuffed)
		var/obj/O = owner.get_item_by_slot(SLOT_HANDCUFFED)
		qdel(O)
