/datum/component/heal_react


/datum/component/heal_react/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE


/datum/component/heal_react/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_APPLY_HEALING, PROC_REF(on_heal))

/datum/component/heal_react/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_APPLY_HEALING)

/datum/component/heal_react/proc/on_heal(amount, damtype)

/datum/component/heal_react/boost
	///multiplicitive boost to incoming healing
	var/boost_amount = 0.2
	///types of damage this will effect
	var/list/applies_to = list(BRUTE,BURN,TOX,OXY,CLONE,STAMINA)
	///internal check for if we are being healed by ourselves, no double dipping
	var/idiotcooldown = FALSE

/datum/component/heal_react/boost/Initialize(boost_set, var/list/damtype_set)
	if(boost_set)
		boost_amount = boost_set
	if(damtype_set)
		applies_to = damtype_set
	return ..()

/datum/component/heal_react/boost/on_heal(amount, damtype)
	if(!(damtype in applies_to))
		return
	if(idiotcooldown)
		return
	idiotcooldown = TRUE
	var/mob/living/owner = parent
	var/heal_amount = min(amount * boost_amount, owner.maxHealth - owner.health)
	if(damtype != TOX)
		owner.apply_damage_type(-heal_amount, damtype, BODYPART_ANY)
	else
		owner.adjustToxLoss(-heal_amount, forced = TRUE) // I am going to kill slimepeopel I am going to MURDER slime people I haTE
	idiotcooldown = FALSE
	return heal_amount

/datum/component/heal_react/boost/holyshit
		applies_to = list(BRUTE,BURN,TOX,CLONE)

/datum/component/heal_react/boost/holyshit/on_heal(amount, damtype)
	var/mob/living/owner = parent
	if(istype(get_area(owner), /area/chapel))
		boost_amount *= GLOB.religious_sect.chapel_buff_coeff
	var/favor = ..()
	boost_amount = initial(boost_amount)
	if(.)
		GLOB.religious_sect.adjust_favor(round(min(favor, 40), 0.1))