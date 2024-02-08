/obj/item/antag_spawner/nuke_ops
	/// Do we use a random subtype of the outfit?
	var/use_subtypes = TRUE
	/// The applied outfit
	var/datum/outfit/syndicate/outfit = /datum/outfit/syndicate/no_crystals

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.apply_prefs_to(M)
	M.key = C.key

	var/datum/antagonist/nukeop/new_op = new()
	new_op.send_to_spawnpoint = FALSE
	new_op.nukeop_outfit = use_subtypes ? pick(subtypesof(outfit)) : outfit

	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(creator_op)
		M.playsound_local(get_turf(M), 'sound/ambience/antag/ops.ogg',100,0)
		M.mind.add_antag_datum(new_op,creator_op.nuke_team)
		M.mind.special_role = "Nuclear Operative"

/obj/item/antag_spawner/nuke_ops/clown
	use_subtypes = FALSE

/obj/item/antag_spawner/nuke_ops/borg_tele
	use_subtypes = FALSE