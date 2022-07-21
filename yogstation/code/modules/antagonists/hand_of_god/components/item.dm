/datum/component/hog_item
    var/datum/team/hog_cult/cult

/datum/component/hog_item/Initialize(var/datum/team/hog_cult/team)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	cult = team
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/try_punish)
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/try_punish)
	RegisterSignal(parent, COMSIG_HOG_ACT, .proc/try_change_cult)

/datum/component/hog_item/proc/try_punish(obj/item/source, mob/user, slot)
    if(!isliving(user))
		return
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(cultie && cultie.cult == cult)
		return
	to_chat(user, span_cultlarge("No."))
	if(isliving(user))
		var/mob/living/L = user
		L.dropItemToGround(source, TRUE)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.vomit(20)

/datum/component/hog_item/proc/try_change_cult(atom/source, datum/team/hog_cult/act_cult)
	if(act_cult == cult)
		return
	cult = act_cult


	
