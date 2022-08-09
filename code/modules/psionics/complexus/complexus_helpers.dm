/datum/psi_complexus/proc/cancel()
	SEND_SOUND(owner, sound('sound/effects/psi/power_fail.ogg'))
	if(LAZYLEN(manifested_items))
		for(var/thing in manifested_items)
			owner.dropItemToGround(thing)
			qdel(thing)
		manifested_items = null

/datum/psi_complexus/proc/stunned(amount)
	var/old_stun = stun
	stun = max(stun, amount)
	if(amount && !old_stun)
		to_chat(owner, span_danger("Your concentration has been shattered! You cannot focus your psi power!"))
		ui.update_icon()
	cancel()

/datum/psi_complexus/proc/get_armour(armourtype)
	if(can_use_passive())
		last_armor_check = world.time
		return round(clamp(clamp(4 * rating, 0, 20) * get_rank(SSpsi.armour_faculty_by_type[armourtype]), 0, 100) * (stamina/max_stamina))
	last_armor_check = 0
	return 0
		
/datum/psi_complexus/proc/handle_block_chance(obj/item/projectile/projectile)
	var/effective_rank
	var/chance = 0

	if(istype(projectile, /obj/item/projectile/beam) || istype(projectile, /obj/item/projectile/energy))
		effective_rank = get_rank(PSI_ENERGISTICS)
	else
		effective_rank = get_rank(PSI_PSYCHOKINESIS)
	
	switch(effective_rank)
		if(PSI_RANK_OPERANT)
			chance = 1
		if(PSI_RANK_MASTER)
			chance = 10
		if(PSI_RANK_GRANDMASTER)
			chance = 50
		if(PSI_RANK_PARAMOUNT)
			chance = 90
	
	return prob(chance)

/datum/psi_complexus/proc/get_rank(faculty)
	return LAZYACCESS(ranks, faculty)

/datum/psi_complexus/proc/set_rank(faculty, rank, defer_update, temporary)
	if(get_rank(faculty) != rank)
		LAZYSET(ranks, faculty, rank)
		if(!temporary)
			LAZYSET(base_ranks, faculty, rank)
		if(!defer_update)
			update()

/datum/psi_complexus/proc/set_cooldown(value)
	next_power_use = world.time + value
	ui.update_icon()

/datum/psi_complexus/proc/can_use_passive()
	return (owner.stat == CONSCIOUS && !suppressed && !stun)

/datum/psi_complexus/proc/can_use(incapacitation_flags)
	return (owner.stat == CONSCIOUS &&  !suppressed && !stun && world.time >= next_power_use)

/datum/psi_complexus/proc/spend_power(stamina_cost = 0, heat_cost = 0)
	. = FALSE
	if(!can_use())
		return FALSE
	
	// Focus
	stamina_cost = max(1, CEILING(stamina_cost * cost_modifier, 1))
	if(stamina < stamina_cost)
		return FALSE
	if((heat + heat_cost) >= limiter)
		return FALSE
	adjust_stamina(-stamina_cost)
	adjust_heat(heat_cost)
	handle_heat_effects()

	ui.update_icon()
	return TRUE

/datum/psi_complexus/proc/set_stamina(value = 0)
	stamina = clamp(value, 0, max_stamina)

/datum/psi_complexus/proc/adjust_stamina(value = 0)
	set_stamina(stamina + value)

/datum/psi_complexus/proc/set_heat(value = 0)
	heat = clamp(value, 0, max_heat)

/datum/psi_complexus/proc/adjust_heat(value = 0)
	set_heat(heat + value)

/datum/psi_complexus/proc/hide_auras()
	if(owner.client)
		for(var/image/I in SSpsi.all_aura_images)
			owner.client.images -= I

/datum/psi_complexus/proc/show_auras()
	if(owner.client)
		for(var/image/I in SSpsi.all_aura_images)
			owner.client.images |= I

/datum/psi_complexus/proc/handle_heat_effects(effective_heat)
	if(!owner)
		return FALSE
	if(!effective_heat)
		effective_heat = heat
	if(effective_heat < 100)
		return
	// The Fun Effects (500 heat)
	if(effective_heat >= max_heat)
		switch(pick(1, 2))
			//1, Your head asplode / you are gibbed
			if(1)
				if(iscarbon(owner))
					var/mob/living/carbon/C = owner
					C.explode_head()
				else
					owner.gib()
			//2, Your psi powers are too strained, causing them to disapear forever
			if(2)
				qdel(src)
	
	//Less fun effects
	switch(rand(1, effective_heat - 100))
		// Your nose bleeds a little.
		if(1 to 20)
			var/mob/living/carbon/human/H
			if(istype(H) && (H.dna.species.species_traits & NOBLOOD))
				return
			to_chat(owner,span_warning("Your nose begins to bleed..."))
			owner.add_splatter_floor(small_drip = TRUE)
		// Your get a headache. Yes this is stolen from disease code, sue me
		if(21 to effective_heat)
			switch(effective_heat)
				if(0 to 200)
					to_chat(owner, span_warning("[pick("Your head hurts.", "Your head pounds.")]"))
					adjust_stamina(rand(-5, -1))
				if(201 to 400)
					to_chat(owner, span_warning("[pick("Your head hurts a lot.", "Your head pounds incessantly.")]"))
					adjust_stamina(rand(-10, -5))
					owner.adjustStaminaLoss(25)
				if(401 to 500)
					to_chat(owner, span_userdanger("[pick("You feel a burning knife inside your brain!", "A wave of pain fills your head!")]"))
					adjust_stamina(rand(-15, -10))
					owner.Stun(3.5 SECONDS)
		
/datum/psi_complexus/proc/backblast(value)

	// Can't backblast if you're controlling your power.
	if(!owner || suppressed)
		return FALSE

	SEND_SOUND(owner, sound('sound/effects/psi/power_feedback.ogg'))
	to_chat(owner, span_danger("<font size=3>Wild energistic feedback blasts across your psyche!</font>"))
	stunned(value * 2)
	set_cooldown(value * 100)

	if(prob(value*10))
		owner.emote("scream")
	adjust_heat(value * 10)
	// Your head asplode.
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, value)
	if(ishuman(owner))
		var/mob/living/carbon/human/pop = owner
		var/obj/item/organ/brain/sponge = pop.getorganslot(ORGAN_SLOT_BRAIN)
		if(sponge && pop.getOrganLoss(ORGAN_SLOT_BRAIN) >= sponge.maxHealth)
			pop.explode_head()
	
/datum/psi_complexus/proc/reset()
	aura_color = initial(aura_color)
	ranks = base_ranks ? base_ranks.Copy() : null
	max_stamina = initial(max_stamina)
	set_stamina(stamina)
	set_heat(heat)
	cancel()
	update()
