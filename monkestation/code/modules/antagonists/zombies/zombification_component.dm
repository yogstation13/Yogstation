/datum/component/zombified
	var/obj/item/organ/internal/zombie_infection/tumor

///The component given to zombified mobs
/datum/component/zombified/Initialize(obj/item/organ/internal/zombie_infection/_tumor)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	tumor = _tumor

/datum/component/zombified/RegisterWithParent()

/datum/component/zombified/UnregisterFromParent()


/datum/component/zombified/proc/signalproc(datum/source)
	SIGNAL_HANDLER
	send_to_playing_players("[source] signaled [src]!")

/*
/datum/component/zombified/InheritComponent(datum/component/zombified/old, i_am_original, list/arguments)
	myvar = old.myvar

	if(i_am_original)
		send_to_playing_players("No parent should have to bury their child")
*/

/*
/datum/component/zombified/PreTransfer()
	send_to_playing_players("Goodbye [parent], I'm getting adopted")

/datum/component/zombified/PostTransfer()
	send_to_playing_players("Hello my new parent, [parent]! It's nice to meet you!")
*/

/*
/datum/component/zombified/CheckDupeComponent(datum/zombified/new, myargone, myargtwo)
	if(myargone == myvar)
		return TRUE
*/
