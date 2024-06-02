/// See code/controllers/subsystem/vr_pvp.dm
/obj/machinery/vr_sleeper/pvp
	desc = "A sleeper modified to alter the subconscious state of the user, allowing them to visit virtual worlds. This one was designed to simulate combat scenarios."
	vr_category = "pvp"

/obj/machinery/vr_sleeper/pvp/ui_act(action, params)
	. = ..()
	switch(action)
		if("vr_connect")
			if(!vr_human)
				return
			vr_human.real_name = usr.real_name
			vr_human.name = usr.name
			SSvr_pvp.join(vr_human)

/obj/effect/landmark/vr_spawn/pvp_spectating
	vr_category = "pvp"

/obj/effect/landmark/vr_start_ffa
	name = "free-for-all spawn point"
	icon_state = "snukeop_leader_spawn"

/obj/effect/landmark/vr_start_tdm_red
	name = "TDM red team spawn point"
	icon_state = "snukeop_spawn"

/obj/effect/landmark/vr_start_tdm_blue
	name = "TDM blue team spawn point"
	icon_state = "ert_spawn"

/datum/outfit/vr_lone_wolf
	name = "VR Lone Wolf"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/fireproof
	belt = /obj/item/gun/ballistic/automatic/pistol
	l_hand = /obj/item/uplink/restricted
	backpack_contents = list(
		/obj/item/clothing/mask/breath=1,
		/obj/item/tank/internals/emergency_oxygen/engi=1,
		/obj/item/reagent_containers/autoinjector/medipen=1,
		/obj/item/switchblade/backstab=1
	)

/datum/outfit/vr_redteam
	name = "VR Nukie"
	glasses = /obj/item/clothing/glasses/night
	mask = /obj/item/clothing/mask/gas/syndicate
	belt = /obj/item/storage/belt/military
	l_hand = /obj/item/uplink/nuclear_restricted
	r_hand = /obj/item/gun/ballistic/automatic/pistol
	backpack_contents = list(
		/obj/item/clothing/mask/breath=1,
		/obj/item/tank/internals/emergency_oxygen/engi=1,
		/obj/item/reagent_containers/autoinjector/medipen=1,
		/obj/item/switchblade/backstab=1 // Spy among us
	)

/datum/outfit/vr_blueteam
	name = "VR ERT"
	uniform = /obj/item/clothing/under/rank/centcom/officer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	implants = list(/obj/item/implant/mindshield)
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	back = /obj/item/storage/backpack/ert
	belt = /obj/item/storage/belt/security/full
	mask = /obj/item/clothing/mask/gas/sechailer
	l_hand = /obj/item/ntuplink/blue
	r_hand = /obj/item/gun/energy/e_gun
	backpack_contents = list(
		/obj/item/clothing/mask/breath=1,
		/obj/item/tank/internals/emergency_oxygen/engi=1,
		/obj/item/reagent_containers/autoinjector/medipen=1,
		/obj/item/melee/baton/loaded=1
	)

/datum/outfit/vr_redteam_alt
	name = "VR Shitsec"
	uniform = /obj/item/clothing/under/rank/security/officer
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/sec
	suit = /obj/item/clothing/suit/armor/vest/alt
	shoes = /obj/item/clothing/shoes/jackboots
	l_hand = /obj/item/melee/baton // Intentionally unloaded
	r_hand = /obj/item/melee/baton // Intentionally unloaded
	back = /obj/item/storage/backpack/security
	backpack_contents = list(
		/obj/item/clothing/mask/breath=1,
		/obj/item/tank/internals/emergency_oxygen/engi=1,
		/obj/item/reagent_containers/autoinjector/medipen=1
	)

/datum/outfit/vr_blueteam_alt
	name = "VR Greytider"
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/sneakers/black
	l_hand = /obj/item/storage/toolbox
	r_hand = /obj/item/storage/toolbox
	backpack_contents = list(
		/obj/item/clothing/mask/breath=1,
		/obj/item/tank/internals/emergency_oxygen/engi=1,
		/obj/item/reagent_containers/autoinjector/medipen=1
	)

/// This should encompass the ARENA, not the spectator area
/area/vr_pvp
	name = "VR PVP"
	icon_state = "centcom"
	static_lighting = TRUE
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	noteleport = TRUE
	blob_allowed = FALSE
	flags_1 = NONE

/obj/item/paper/vr_pvp
	name = "video game instructions"

/obj/item/paper/vr_pvp/Initialize(mapload)
	info = {"<p><b>Instructions:</b></p>

			<p>Team Deathmatch (RED VS BLUE) = Blast the other guys!</p>

			<p>Free-For-All = Blast everyone else!</p>

			<p>Remember to confirm your kills and revive your teammates with an <b>epipen</b>!</p>

			<p>Tip: If you spawn in with an uplink, make sure to use it!</p>

			<p>Tip: You can pick up enemy gear and use it or even disguise yourself as the enemy!</p>"}

	return ..()
