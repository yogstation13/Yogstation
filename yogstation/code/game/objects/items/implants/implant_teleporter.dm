/obj/item/implant/teleporter
	var/list/whitelist = list()
	var/list/blacklist = list()
	var/pointofreturn = null //where to return them to if they go out of bounds
	var/usewhitelist = FALSE
	var/useblacklist = TRUE
	var/on = FALSE
	var/retrievalmessage = "Retrieval complete."
	var/punishment = FALSE
	var/punishment_damage = 0

/obj/item/implant/teleporter/Initialize(mapload)
	START_PROCESSING(SSobj, src)
	.=..()

/obj/item/implant/teleporter/process()

	if(usewhitelist)
		useblacklist = FALSE

	if(imp_in)
		var/turf/T = get_turf_global(imp_in)
		if(!is_centcom_level(T.z)) //teleporting doesn't work on centcom

			if(blacklist.len && useblacklist)
				var/i = 0
				for(var/zlevel in blacklist)
					i++
					if(zlevel == T.z)
						if(on && pointofreturn)
							retrieve_exile()
						else
							break //we're on a blacklisted z but not on (e.g. station prior to being exiled) so stop
					else
						if(!on && i >= blacklist.len)  //we've just arrived on a non-blacklisted z, start blocking
							on = TRUE
							pointofreturn = T //we'll teleport back here if we go out of bounds

			if(whitelist.len && usewhitelist)
				for(var/zlevel in whitelist)
					if(zlevel == T.z)
						if(!on)
							on = TRUE //we're on a whitelisted z, start blocking
							pointofreturn = T //we'll teleport back here if we go out of bounds
						return // we're allowed here, stop
				if(on && pointofreturn)
					retrieve_exile()

/obj/item/implant/teleporter/proc/retrieve_exile()
	var/turf/T = get_turf_global(imp_in)
	if(!is_centcom_level(T.z))
		do_teleport(imp_in, pointofreturn, 0, channel = TELEPORT_CHANNEL_WORMHOLE)
		say(retrievalmessage)
		if(punishment == TRUE)
			imp_in.adjustFireLoss(punishment_damage)

/obj/item/implant/teleporter/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	LAZYINITLIST(target.implants)
	if(!target.can_be_implanted() || !can_be_implanted_in(target))
		return 0
	for(var/X in target.implants)
		if(istype(X, type))
			var/obj/item/implant/imp_e = X
			if(!allow_multiple)
				if(imp_e.uses < initial(imp_e.uses)*2)
					if(uses == -1)
						imp_e.uses = -1
					else
						imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses)*2)
					qdel(src)
					return 1
				else
					return 0

	src.forceMove(target)
	imp_in = target
	target.implants += src
	for(var/datum/action/A as anything in actions)
		A.Grant(target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.sec_hud_set_implants()

	if(user)
		log_combat(user, target, "implanted", object="[name]")
	var/turf/T = get_turf_global(imp_in)
	if(useblacklist && !blacklist.len)
		blacklist += T.z

	if(usewhitelist && !whitelist.len)
		whitelist += T.z
		pointofreturn = T
	return 1

/obj/item/implant/teleporter/removed(mob/living/source, silent = 0, special = 0)
	..()
	say("Implant tampering detected.")
	source.gib()

/obj/item/implant/teleporter/ghost_role
	name = "employee retrieval implant"
	usewhitelist = TRUE
	retrievalmessage = "Employee retrieval complete."

/obj/item/implant/teleporter/gasclerk
	pointofreturn = /area/ruin/powered/gasstation //for some reason it does not teleport them back to lavaland so I did this to fix it lets just say the gas station clerks implant is a older module
	usewhitelist = TRUE
	retrievalmessage = "Employee retrieval complete."

/obj/item/implant/teleporter/innkeeper
	pointofreturn = /area/ruin/powered/inn
	usewhitelist = TRUE
	retrievalmessage = "Safety retrieval complete."

/obj/item/implant/teleporter/syndicate_icemoon
	pointofreturn = /area/ruin/syndicate_icemoon
	usewhitelist = TRUE
	retrievalmessage = "Agent retrieval complete."

/obj/item/implant/teleporter/syndicate_lavaland
	pointofreturn = /area/ruin/powered/syndicate_lava_base
	usewhitelist = TRUE
	retrievalmessage = "Agent retrieval complete."

/obj/item/implant/teleporter/syndicate_listening_post
	pointofreturn = /area/ruin/space/has_grav/listeningstation
	usewhitelist = TRUE
	retrievalmessage = "Agent retrieval complete."

/obj/item/implant/teleporter/demon
	pointofreturn = /area/ruin/powered/sinden
	usewhitelist = TRUE
	punishment = TRUE
	punishment_damage = 50
	retrievalmessage = "You think you can just abandon your contract?"
