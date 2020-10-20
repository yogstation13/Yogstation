/datum/antagonist/nukeop/mentor
	name = "Mentor Operative"
	nukeop_outfit = /datum/outfit/syndicate/mentor

/datum/antagonist/nukeop/mentor/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/misc/nootnoot.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/nukeop/leader/mentor
	name = "Mentor Operative Leader"
	nukeop_outfit = /datum/outfit/syndicate/mentor/leader

/datum/antagonist/nukeop/leader/mentor/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/misc/nootnoot.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/nukeop/leader/mentor/give_alias()
	owner.current.real_name = owner.current.ckey

/datum/antagonist/nukeop/mentor/give_alias()
	owner.current.real_name = owner.current.ckey
