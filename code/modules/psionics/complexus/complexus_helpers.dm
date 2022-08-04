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

/datum/psi_complexus/proc/can_use(var/incapacitation_flags)
	return (owner.stat == CONSCIOUS &&  !suppressed && !stun && world.time >= next_power_use)

/datum/psi_complexus/proc/spend_power(value = 0, check_incapacitated)
	. = FALSE
	if(can_use())
		value = max(1, CEILING(value * cost_modifier, 1))
		if(value <= stamina)
			stamina -= value
			ui.update_icon()
			. = TRUE
		else
			backblast(abs(stamina - value))
			stamina = 0
			. = FALSE
		ui.update_icon()

/datum/psi_complexus/proc/hide_auras()
	if(owner.client)
		for(var/thing in SSpsi.all_aura_images)
			owner.client.images -= thing

/datum/psi_complexus/proc/show_auras()
	if(owner.client)
		for(var/image/I in SSpsi.all_aura_images)
			owner.client.images |= I

/datum/psi_complexus/proc/backblast(value)

	// Can't backblast if you're controlling your power.
	if(!owner || suppressed)
		return FALSE

	SEND_SOUND(owner, sound('sound/effects/psi/power_feedback.ogg'))
	to_chat(owner, span_danger("<font size=3>Wild energistic feedback blasts across your psyche!</font>"))
	stunned(value * 2)
	set_cooldown(value * 100)

	if(prob(value*10)) owner.emote("scream")

	// Your head asplode.
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, value)
	//owner.adjustHalLoss(value * 25) //Ouch.
	if(ishuman(owner))
		var/mob/living/carbon/human/pop = owner
		var/obj/item/organ/brain/sponge = pop.getorganslot(ORGAN_SLOT_BRAIN)
		if(sponge && pop.getOrganLoss(ORGAN_SLOT_BRAIN) >= sponge.maxHealth)
			pop.ghostize()
			sponge.Remove(owner)
			qdel(sponge)

			/* Need to fix this later
			var/obj/item/organ/external/affecting = pop.get_organ(sponge.parent_organ)
			if(affecting && !affecting.is_stump())
				affecting.droplimb(0, DROPLIMB_BLUNT)
				if(sponge) qdel(sponge)
			*/

/datum/psi_complexus/proc/reset()
	aura_color = initial(aura_color)
	ranks = base_ranks ? base_ranks.Copy() : null
	max_stamina = initial(max_stamina)
	stamina = min(stamina, max_stamina)
	cancel()
	update()
