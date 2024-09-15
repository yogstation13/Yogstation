/datum/component/charge_adjuster
	///The typepath of atom to give charges to
	var/type_to_charge_to
	///How many charges to give
	var/charges_given = 1
	///TYPE_PROC_REF() to call on the hit item if its type_to_charge_to, proc MUST take amount to get adjusted by as first arg
	var/called_proc_name

/datum/component/charge_adjuster/Initialize(type_to_charge_to, charges_given = 1, called_proc_name)
	if(!isitem(parent) || !type_to_charge_to || !called_proc_name)
		return COMPONENT_INCOMPATIBLE

	src.type_to_charge_to = type_to_charge_to
	src.charges_given = charges_given
	src.called_proc_name = called_proc_name

/datum/component/charge_adjuster/Destroy(force, silent)
	called_proc_name = null
	return ..()

/datum/component/charge_adjuster/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(check_hit_atom))

/datum/component/charge_adjuster/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)

/datum/component/charge_adjuster/proc/check_hit_atom(obj/item/source, atom/target, mob/user, proximity_flag)
	SIGNAL_HANDLER
	if(!proximity_flag || !istype(target, type_to_charge_to))
		return

	if(!call(target, called_proc_name)(charges_given))
		return

	to_chat(user, span_notice("You insert \the [source] in \the [target]."))
	qdel(parent)
	return COMPONENT_CANCEL_ATTACK_CHAIN
