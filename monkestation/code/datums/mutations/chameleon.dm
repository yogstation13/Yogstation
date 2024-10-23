/datum/mutation/human/chameleon/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_attack_item))
	START_PROCESSING(SSfastprocess, src)

/datum/mutation/human/chameleon/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_ITEM_ATTACK)
	STOP_PROCESSING(SSfastprocess, src)

/datum/mutation/human/chameleon/proc/on_attack_item(mob/living/carbon/human/owner, mob/target, mob/user, params, obj/item/weapon)
	SIGNAL_HANDLER
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
