GLOBAL_LIST_EMPTY(all_rev_security_codes)

/**
  *
  * Contains the component code for rev security codes, used by heads to call in ERTs
  *
  */

/datum/component/revs_security_code
	var/code

/datum/component/revs_security_code/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	code = random_nukecode()

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

	GLOB.all_rev_security_codes += src

/datum/component/revs_security_code/Destroy()
	GLOB.all_rev_security_codes -= src
	..()

/**
  * Runs when the parent is examined
  * Arguments:
  * * datum/source - The source of the examine
  * * mob/user - The user examining
  *	* list/examine_list - The list of examines which we pass new ones to
  */
/datum/component/revs_security_code/proc/examine(datum/source, mob/user, list/examine_list)
	if(!locate(user.mind) in get_all_heads())
		return
	examine_list += "<span class='notice'>There's a note with a [code] scribbled on it...</span>"
