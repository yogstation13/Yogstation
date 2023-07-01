/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, kind = "", datum/mind/user)
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return


///////////WIZARD

/obj/item/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/polling = FALSE

/obj/item/antag_spawner/contract/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(polling)
		balloon_alert(user, "already calling an apprentice!")
		return FALSE

/obj/item/antag_spawner/contract/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ApprenticeContract", name)
		ui.open()

/obj/item/antag_spawner/contract/ui_state(mob/user)
	if(used)
		return GLOB.never_state
	return GLOB.default_state

/obj/item/antag_spawner/contract/ui_assets(mob/user)
	. = ..()
	return list(
		get_asset_datum(/datum/asset/simple/contracts),
	)

/obj/item/antag_spawner/contract/ui_act(action, list/params)
	. = ..()
	if(used || polling || !ishuman(usr))
		return
	INVOKE_ASYNC(src, PROC_REF(poll_for_student), usr, params["school"])
	SStgui.close_uis(src)

/obj/item/antag_spawner/contract/proc/poll_for_student(mob/living/carbon/human/teacher, apprentice_school)
	balloon_alert(teacher, "contacting apprentice...")
	polling = TRUE
	var/list/candidates = pollCandidatesForMob("Do you want to play as a wizard's [apprentice_school] apprentice?", ROLE_WIZARD, null, ROLE_WIZARD, 15 SECONDS, src)
	polling = FALSE
	if(!LAZYLEN(candidates))
		to_chat(teacher, span_warning("Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later."))
		return
	if(QDELETED(src) || used)
		return
	used = TRUE
	var/mob/dead/observer/student = pick(candidates)
	spawn_antag(student.client, get_turf(src), apprentice_school, teacher.mind)

/obj/item/antag_spawner/contract/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	new /obj/effect/particle_effect/fluid/smoke(T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.apply_prefs_to(M)
	M.key = C.key
	var/datum/mind/app_mind = M.mind

	var/datum/antagonist/wizard/apprentice/app = new()
	app.master = user
	app.school = kind

	var/datum/antagonist/wizard/master_wizard = user.has_antag_datum(/datum/antagonist/wizard)
	if(master_wizard)
		if(!master_wizard.wiz_team)
			master_wizard.create_wiz_team()
		app.wiz_team = master_wizard.wiz_team
		master_wizard.wiz_team.add_member(app_mind)
	app_mind.add_antag_datum(app)
	app_mind.assigned_role = "Apprentice"
	app_mind.special_role = "apprentice"
	SEND_SOUND(M, sound('sound/effects/magic.ogg'))

///////////BORGS AND OPERATIVES


/obj/item/antag_spawner/nuke_ops
	name = "syndicate operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		to_chat(user, span_warning("[src] is out of power!"))
		return FALSE
	if(!(is_nukeop(user) || is_battleroyale(user)))//also let it work in battle royales
		to_chat(user, span_danger("AUTHENTICATION FAILURE. ACCESS DENIED."))
		return FALSE
	if(!(user.onSyndieBase() || is_battleroyale(user)))
		to_chat(user, span_warning("[src] is out of range! It can only be used at your base!"))
		return FALSE
	return TRUE


/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	to_chat(user, span_notice("You activate [src] and wait for confirmation."))
	var/list/nuke_candidates = pollGhostCandidates("Do you want to play as a syndicate [borg_to_spawn ? "[lowertext(borg_to_spawn)] cyborg":"operative"]?", ROLE_OPERATIVE, null, ROLE_OPERATIVE, 150, POLL_IGNORE_SYNDICATE)
	if(LAZYLEN(nuke_candidates))
		if(QDELETED(src) || !check_usability(user))
			return
		used = TRUE
		var/mob/dead/observer/G = pick(nuke_candidates)
		spawn_antag(G.client, get_turf(src), "syndieborg", user.mind)
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		to_chat(user, span_warning("Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded."))

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.apply_prefs_to(M)
	M.key = C.key

	var/datum/antagonist/nukeop/new_op = new()
	new_op.send_to_spawnpoint = FALSE
	new_op.nukeop_outfit = /datum/outfit/syndicate/no_crystals

	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	if(creator_op)
		M.mind.add_antag_datum(new_op,creator_op.nuke_team)
		M.mind.special_role = "Nuclear Operative"

//////CLOWN OP
/obj/item/antag_spawner/nuke_ops/clown
	name = "clown operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce clown operatives in the field."

/obj/item/antag_spawner/nuke_ops/clown/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.apply_prefs_to(M)
	M.key = C.key

	var/datum/antagonist/nukeop/clownop/new_op = new /datum/antagonist/nukeop/clownop()
	new_op.send_to_spawnpoint = FALSE
	new_op.nukeop_outfit = /datum/outfit/syndicate/clownop/no_crystals

	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop/clownop,TRUE)
	if(creator_op)
		M.mind.add_antag_datum(new_op, creator_op.nuke_team)
		M.mind.special_role = "Clown Operative"


//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg teleporter"
	borg_to_spawn = "Assault"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical teleporter"
	borg_to_spawn = "Medical"

/obj/item/antag_spawner/nuke_ops/borg_tele/saboteur
	name = "syndicate saboteur teleporter"
	borg_to_spawn = "Saboteur"

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T, kind, datum/mind/user)
	var/mob/living/silicon/robot/R
	var/datum/antagonist/nukeop/creator_op = user.has_antag_datum(/datum/antagonist/nukeop,TRUE)
	var/royaler = user.has_antag_datum(/datum/antagonist/battleroyale, TRUE)
	if(!creator_op && !royaler)
		return

	switch(borg_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/modules/syndicate/medical(T)
		if("Saboteur")
			R = new /mob/living/silicon/robot/modules/syndicate/saboteur(T)
		else
			R = new /mob/living/silicon/robot/modules/syndicate(T) //Assault borg by default

	var/brainfirstname = pick(GLOB.first_names_male)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
	var/brainopslastname = pick(GLOB.last_names)
	if(!royaler && creator_op.nuke_team.syndicate_name)  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = creator_op.nuke_team.syndicate_name
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	R.mmi.name = "[initial(R.mmi.name)]: [brainopsname]"
	R.mmi.brain.name = "[brainopsname]'s brain"
	R.mmi.brainmob.real_name = brainopsname
	R.mmi.brainmob.name = brainopsname
	R.real_name = R.name

	R.key = C.key

	var/datum/antagonist/nukeop/new_borg = new()
	new_borg.send_to_spawnpoint = FALSE
	R.mind.add_antag_datum(new_borg,creator_op.nuke_team)
	R.mind.special_role = "Syndicate Cyborg"

///////////SLAUGHTER DEMON

/obj/item/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

	var/shatter_msg = span_notice("You shatter the bottle, no turning back now!")
	var/veil_msg = span_warning("You sense a dark presence lurking just beyond the veil...")
	var/mob/living/demon_type = /mob/living/simple_animal/slaughter
	var/antag_type = /datum/antagonist/slaughter


/obj/item/antag_spawner/slaughter_demon/attack_self(mob/user)
	if(!is_station_level(user.z))
		to_chat(user, span_notice("You should probably wait until you reach the station."))
		return
	if(used)
		return
	var/list/candidates = pollCandidatesForMob("Do you want to play as a [initial(demon_type.name)]?", ROLE_ALIEN, null, ROLE_ALIEN, 50, src)
	if(LAZYLEN(candidates))
		if(used || QDELETED(src))
			return
		used = TRUE
		var/mob/dead/observer/C = pick(candidates)
		spawn_antag(C.client, get_turf(src), initial(demon_type.name),user.mind)
		to_chat(user, shatter_msg)
		to_chat(user, veil_msg)
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
		qdel(src)
	else
		to_chat(user, span_notice("You can't seem to work up the nerve to shatter the bottle. Perhaps you should try again later."))


/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, kind = "", datum/mind/user)
	var/mob/living/simple_animal/slaughter/S = new demon_type(T)
	new /obj/effect/dummy/phased_mob(T, S)

	S.key = C.key
	S.mind.assigned_role = S.name
	S.mind.special_role = S.name
	S.mind.add_antag_datum(antag_type)
	to_chat(S, S.playstyle_string)
	to_chat(S, span_bold("You are currently not currently in the same plane of existence as the station. \
		Use your Blood Crawl ability near a pool of blood to manifest and wreak havoc.")) //fuck you

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from countless hugging attacks. Used in funny rituals to attract adorable creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	color = "#FF69B4" // HOT PINK

	veil_msg = span_warning("You sense an adorable presence lurking just beyond the veil...")
	demon_type = /mob/living/simple_animal/slaughter/laughter
	antag_type = /datum/antagonist/slaughter/laughter
