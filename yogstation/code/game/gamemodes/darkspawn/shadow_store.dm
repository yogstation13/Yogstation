
#define SCOUT (1<<0)
#define FIGHTER (1<<1)
#define WARLOCK (1<<2)

/datum/shadow_store
	///Name of the effect
	var/name = "Basic knowledge"
	///Description of the effect
	var/desc = "Basic knowledge of forbidden arts."
	///Icon that gets displayed
	var/icon = ""
	///Cost of knowledge in souls
	var/cost = 0
	///What specialization can buy this
	var/shadow_flags = NONE

///Check to see if they should be shown the ability
/datum/shadow_store/proc/check_show(mob/user)
	SHOULD_CALL_PARENT(TRUE) //for now
	var/datum/antagonist/darkspawn/edgy= user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!edgy)
		return FALSE
	if(!(edgy.specialization & shadow_flags))
		return FALSE
	return TRUE

///When the button to purchase is clicked
/datum/shadow_store/proc/on_purchase(mob/user)
	var/datum/antagonist/darkspawn/edgy= user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(!edgy)
		return FALSE
	if(!(edgy.specialization & shadow_flags))//they shouldn't even be shown it in the first place, but just in case
		return FALSE
	if(edgy.lucidity < cost)
		return FALSE

	edgy.lucidity -= cost
	activate(user)
	return TRUE

///If the purchase goes through, this gets called
/datum/shadow_store/proc/activate(mob/user)
	return


/*
	Purchases to select spec
*/
/datum/shadow_store/scout
	name = "shadow step"
	desc = "shadow step"

/datum/shadow_store/scout/activate(mob/user)
	user.LoadComponent(/datum/component/walk/shadow)
	user.AddComponent(/datum/component/shadow_step)
	var/datum/antagonist/darkspawn/edgy = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(edgy)//there's NO way they get here without it
		edgy.specialization = SCOUT


/datum/shadow_store/fighter
	name = "shadow step"
	desc = "shadow step"

/datum/shadow_store/fighter/activate(mob/user)
	var/datum/antagonist/darkspawn/edgy = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(edgy)//there's NO way they get here without it
		edgy.specialization = FIGHTER

/datum/shadow_store/warlock
	name = "shadow step"
	desc = "shadow step"

/datum/shadow_store/warlock/activate(mob/user)
	var/datum/antagonist/darkspawn/edgy = user.mind?.has_antag_datum(/datum/antagonist/darkspawn)
	if(edgy)//there's NO way they get here without it ... right?
		edgy.specialization = WARLOCK
