/datum/component/hog_item
	var/datum/team/hog_cult/cult

/datum/component/hog_item/Initialize(var/datum/team/hog_cult/team)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(team)
		cult = team
		cult.objects += parent

/datum/component/hog_item/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/try_punish)
	RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/try_punish)
	RegisterSignal(parent, COMSIG_HOG_ACT, .proc/try_change_cult)

/datum/component/hog_item/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_PICKUP, COMSIG_HOG_ACT, COMSIG_ITEM_EQUIPPED))
	cult.objects -= parent

/datum/component/hog_item/proc/try_punish(obj/item/source, mob/user, slot)
	if(!cult)
		punish(source,user)
		return
	if(!isliving(user))
		return
	var/datum/antagonist/hog/cultie = IS_HOG_CULTIST(user)
	if(cultie && cultie.cult == cult)
		return
	to_chat(user, span_cultlarge("No."))
	punish(source,user)

/datum/component/hog_item/punish(obj/item/source, mob/user)
	if(isliving(user))
		var/mob/living/L = user
		L.dropItemToGround(source, TRUE)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.vomit(20)

/datum/component/hog_item/proc/try_change_cult(atom/source, datum/team/hog_cult/act_cult)
	if(act_cult == cult)
		return
	cult.objects -= parent
	cult = act_cult
	act_cult.objects += parent
	for(var/datum/hog_research/R in act_cult.upgrades)
		if(!(parent.type in R.affected_objects))
			continue
		R.apply_research_effects(parent)	


	
