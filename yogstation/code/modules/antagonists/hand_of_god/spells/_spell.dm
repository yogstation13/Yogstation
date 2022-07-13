/datum/action/innate/hog_cult
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	var/datum/antagonist/hog/antag_datum

/datum/action/innate/hog_cult/IsAvailable()
	if(!IS_HOG_CULTIST(owner) || IS_HOG_CULTIST(owner) != datum || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/hog_cult/Grant(mob/living/owner, datum/antagonist/hog/ownr)
	antag_datum = ownr
	..()
	button.locked = TRUE
	button.ordered = FALSE

/datum/action/innate/hog_cult/Remove()
	if(antag_datum)
		antag_datum.magic -= src
	..()

/datum/hog_spell_preparation
	var/name = "Prepare Nothing"
	var/description = "Kinda useless thingie it doesn't prepare anything don't do this please it will be just a waste of time and your energy."
	var/cost = 40
	var/p_time = 3 SECONDS 
	var/datum/action/innate/hog_cult/poggy = /datum/action/innate/hog_cult

/datum/hog_spell_preparation/proc/confirm(mob/user, datum/antagonist/hog/antag_datum)
	var/confirm = alert(user, "[description] It will cost [cost] energy.", "[name]", "Yes", "No")
	if(confirm == "No")
		return FALSE
	if(cost > antag_datum.energy)
			to_chat(user,span_warning("You don't have enough energy to prepare this spell!"))
		return FALSE
	return TRUE

/datum/hog_spell_preparation/proc/on_prepared(mob/user, datum/antagonist/hog/antag_datum, obj/item/hog_item/book/tome)
	if(cost > antag_datum.energy)
		return
	antag_datum.get_energy(-cost)
	give_spell(user, antag_datum)

/datum/hog_spell_preparation/proc/give_spell(mob/user, datum/antagonist/hog/antag_datum)
	var/datum/action/innate/hog_cult/new_spell = new poggy(user)
	new_spell.Grant(user, antag_datum)
	antag_datum.magic += new_spell
