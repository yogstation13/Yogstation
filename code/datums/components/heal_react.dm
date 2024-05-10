/datum/component/heal_react


/datum/component/heal_react/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/heal_react/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_APPLY_HEALING, PROC_REF(on_heal))
	RegisterSignal(parent, COMSIG_BODYPART_HEALED, PROC_REF(on_heal_limb))

/datum/component/heal_react/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_APPLY_HEALING)
	UnregisterSignal(parent, COMSIG_BODYPART_HEALED)

/datum/component/heal_react/proc/on_heal(var/mob/living/target,amount,damtype)

/datum/component/heal_react/proc/on_heal_limb(var/mob/living/carbon/target,amount,damtype,var/obj/item/bodypart/BP)

/datum/component/heal_react/boost
	///multiplicitive boost to incoming healing
	var/boost_amount = 1
	///types of damage this will effect
	var/list/applies_to = list(BRUTE,BURN,TOX,OXY,CLONE,STAMINA)
	///internal check for if we are being healed by ourselves, no double dipping
	var/idiotcooldown = FALSE

/datum/component/heal_react/boost/Initialize(boost_set, list/damtype_set)
	if(boost_set)
		boost_amount = boost_set
	if(damtype_set)
		applies_to = damtype_set
	return ..()

/datum/component/heal_react/boost/on_heal_limb(var/mob/living/carbon/target,amount,damtype,def_zone) //used to target the specific limb being healed, giving the impression it's getting healed more rather than twice
	if(!(damtype in applies_to))
		return
	if(idiotcooldown)
		return
	idiotcooldown = TRUE
	var/obj/item/bodypart/BP = target.get_bodypart(def_zone)
	var/heal_amount = min(amount * boost_amount, BP.get_damage())
	target.apply_damage(-heal_amount, damtype, def_zone)
	idiotcooldown = FALSE
	return heal_amount

/datum/component/heal_react/boost/on_heal(var/mob/living/target,amount,damtype)
	if(!(damtype in applies_to))
		return
	if(idiotcooldown)
		return
	idiotcooldown = TRUE
	var/heal_amount = min(-amount * boost_amount, target.maxHealth - target.health)
	if(damtype != TOX)
		target.apply_damage_type(-heal_amount, damtype, BODYPART_ANY)
	else
		target.adjustToxLoss(-heal_amount, forced = TRUE) // HELLO xenobio
	idiotcooldown = FALSE
	return heal_amount

/datum/component/heal_react/boost/holylight
		applies_to = list(BRUTE,BURN,TOX,CLONE)

/datum/component/heal_react/boost/holylight/on_heal_limb(var/mob/living/carbon/target,amount,damtype,var/obj/item/bodypart/BP)
	if(istype(get_area(target), /area/chapel))
		boost_amount *= GLOB.religious_sect.chapel_buff_coeff
	var/favor = ..()
	boost_amount = initial(boost_amount)
	if(favor)
		GLOB.religious_sect.adjust_favor(round(favor/2, 0.1))

/datum/component/heal_react/boost/holylight/on_heal(var/mob/living/target,amount,damtype)
	if(istype(get_area(target), /area/chapel))
		boost_amount *= GLOB.religious_sect.chapel_buff_coeff
	var/favor = ..()
	boost_amount = initial(boost_amount)
	if(favor)
		GLOB.religious_sect.adjust_favor(round(favor/2, 0.1))
