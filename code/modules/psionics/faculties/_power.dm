/datum/psionic_power
	/// Name. If null, psipower won't be generated on roundstart.
	var/name
	/// Associated psi faculty.
	var/faculty
	/// Minimum psi rank to use this power.
	var/min_rank
	/// Base psi stamina cost for using this power.
	var/cost
	/// Base heat gained for using this power.
	var/heat
	/// Deciseconds cooldown after using this power.
	var/cooldown
	/// Whether or not using this power prints an admin attack log.
	var/admin_log = TRUE
	/// This power functions from a distance.
	var/use_ranged    
	/// This power functions at melee range.
	var/use_melee
	/// This power manifests an item in the user's hands.       
	var/use_manifest
	/// A short description of how to use this power, shown via assay.
	var/use_description
	/// A sound effect to play when the power is used.
	var/use_sound = 'sound/effects/psi/power_used.ogg'

/datum/psionic_power/proc/invoke(mob/living/user, atom/target)

	if(!user.psi)
		return FALSE

	if(faculty && min_rank)
		var/user_rank = user.psi.get_rank(faculty)
		if(user_rank < min_rank)
			return FALSE

	if(cost && !user.psi.spend_power(cost, heat))
		return FALSE

	var/user_psi_leech = user.do_psionics_check(cost, user)
	if(user_psi_leech)
		to_chat(user, span_warning("Your power is leeched away by \the [user_psi_leech] as fast as you can focus it..."))
		return FALSE

	if(target.do_psionics_check(cost, user))
		to_chat(user, span_warning("Your power skates across \the [target], but cannot get a grip..."))
		return FALSE

	return TRUE

/datum/psionic_power/proc/handle_post_power(mob/living/user, atom/target)
	if(cooldown)
		user.psi.set_cooldown(cooldown)
	if(admin_log && ismob(user) && ismob(target))
		log_attack("[user] Used psipower ([name]) on [target]")
	if(use_sound)
		playsound(user.loc, use_sound, 75)
