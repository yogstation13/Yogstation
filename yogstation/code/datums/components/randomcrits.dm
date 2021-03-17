/datum/component/randomcrits
	var/crit_damage = 0
	var/crit_force = 0
	var/crit_rate = 5
	var/crit_rate_max = 70 //max % crit rate
	var/crit_rate_increase = 10 //% crit chance per hit
	var/crit_dropoff_coeff = 0.85 //% of crit chance remaining after dropoff

/datum/component/randomcrits/Initialize(force)
	crit_force = force
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/on_attack)
	crit_damage = crit_force * 2 //random crits deal 3x damage
	START_PROCESSING(SSobj,src)

/datum/component/randomcrits/proc/on_attack(datum/source, mob/living/target, mob/user)
	if(prob(crit_rate))
		target.apply_damage(crit_damage, BRUTE, user.zone_selected, 0)
		user.visible_message("<span class='danger'>[user]'s [parent] scores a random crit!!</span>")
		playsound(src, 'sound/effects/bang.ogg', 100, 0)
	if(!target.stat && target.ckey)
		crit_rate += crit_rate_increase
		if(crit_rate > crit_rate_max)
			crit_rate = crit_rate_max

/datum/component/randomcrits/process()
	crit_rate = crit_rate * crit_dropoff_coeff
	if(crit_rate < initial(crit_rate))
		crit_rate = initial(crit_rate)

/datum/component/randomcrits/guaranteed
	crit_rate = 100 //guaranteed crit
	crit_rate_max = 100 //max is 100
	crit_rate_increase = 0 //safekeeping
	crit_dropoff_coeff = 1 //stays until the component is gone

/datum/component/randomcrits/guaranteed/Initialize(force)
	..()
	parent.add_atom_colour(list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0), TEMPORARY_COLOUR_PRIORITY)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/RemoveComponent())
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/RemoveComponent())
