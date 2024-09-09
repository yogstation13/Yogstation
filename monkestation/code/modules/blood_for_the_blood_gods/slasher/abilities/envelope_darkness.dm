/datum/action/cooldown/slasher/envelope_darkness
	name = "Darkness Shroud"
	desc = "Become masked in the light and visible in the dark."
	button_icon_state = "incorporealize"
	cooldown_time = 20 SECONDS


/datum/action/cooldown/slasher/envelope_darkness/Activate(atom/target)
	var/offset = GET_Z_PLANE_OFFSET(owner.z)
	var/render = OFFSET_RENDER_TARGET(O_LIGHTING_VISUAL_RENDER_TARGET, offset)
	owner.add_filter("envelope", 1,  alpha_mask_filter(render, flags = MASK_INVERSE))
	RegisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(break_envelope))
	RegisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(bullet_impact))

/datum/action/cooldown/slasher/envelope_darkness/Remove(mob/living/remove_from)
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
	owner.remove_filter("envelope")

/datum/action/cooldown/slasher/envelope_darkness/proc/break_envelope(datum/source, damage, damagetype)
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	UnregisterSignal(owner, COMSIG_ATOM_PRE_BULLET_ACT)
	if(damage < 5)
		return

	var/mob/living/owner_mob = owner
	for(var/i = 1 to 4)
		owner_mob.blood_particles(2, max_deviation = rand(-120, 120), min_pixel_z = rand(-4, 12), max_pixel_z = rand(-4, 12))


	var/datum/antagonist/slasher/slasher = owner_mob.mind?.has_antag_datum(/datum/antagonist/slasher)

	slasher?.reduce_fear_area(15, 4)
	owner.remove_filter("envelope")

/datum/action/cooldown/slasher/envelope_darkness/proc/bullet_impact(mob/living/carbon/human/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER
	return COMPONENT_BULLET_PIERCED
