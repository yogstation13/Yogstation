/datum/element/virus_viewer

/datum/element/virus_viewer/Attach(mob/user)
	. = ..()
	if(!ismob(user))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(user, COMSIG_MOB_LOGIN, PROC_REF(enable_virus_view))
	RegisterSignal(user, COMSIG_MOB_LOGOUT, PROC_REF(disable_virus_view))

	enable_virus_view(user)

/datum/element/virus_viewer/Detach(mob/user)
	. = ..()

	UnregisterSignal(user, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT))

	disable_virus_view(user)

/datum/element/virus_viewer/proc/enable_virus_view(mob/user)
	SIGNAL_HANDLER

	if(!user.client)
		return

	GLOB.virus_viewers += user

	for(var/obj/item/item in GLOB.infected_items)
		if(item.pathogen)
			user.client.images |= item.pathogen
	for(var/mob/living/living_mob in GLOB.infected_contact_mobs)
		if(living_mob.pathogen)
			user.client.images |= living_mob.pathogen
	for(var/obj/effect/pathogen_cloud/cloud as anything in GLOB.pathogen_clouds)
		if(cloud.pathogen)
			user.client.images |= cloud.pathogen
	for(var/obj/effect/decal/cleanable/cleanable in GLOB.infected_cleanables)
		if(cleanable.pathogen)
			user.client.images |= cleanable.pathogen

/datum/element/virus_viewer/proc/disable_virus_view(mob/user)
	SIGNAL_HANDLER

	GLOB.virus_viewers -= user // Even if the user doesn't have a client anymore we need to make sure they're out of the list.

	if(!user.client)
		return

	for(var/obj/item/item in GLOB.infected_items)
		user.client.images -= item.pathogen
	for(var/mob/living/living_mob in GLOB.infected_contact_mobs)
		user.client.images -= living_mob.pathogen
	for(var/obj/effect/pathogen_cloud/cloud as anything in GLOB.pathogen_clouds)
		user.client.images -= cloud.pathogen
	for(var/obj/effect/decal/cleanable/cleanable in GLOB.infected_cleanables)
		user.client.images -= cleanable.pathogen
