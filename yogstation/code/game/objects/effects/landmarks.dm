/obj/effect/landmark/start/yogs
	icon = 'yogstation/icons/mob/landmarks.dmi'

/obj/effect/landmark/start/yogs/mining_medic
	name = "Mining Medic"
	icon_state = "Mining Medic"

/obj/effect/landmark/start/yogs/signal_technician
	name = "Signal Technician"
	icon_state = "Signal Technician"

/obj/effect/landmark/start/yogs/clerk
	name = "Clerk"
	icon_state = "Clerk"

/obj/effect/landmark/start/yogs/paramedic
	name = "Paramedic"
	icon_state = "Paramedic"

/obj/effect/landmark/start/yogs/psychiatrist
	name = "Psychiatrist"
	icon_state = "Psychiatrist"

/obj/effect/landmark/start/yogs/tourist
	name = "Tourist"
	icon_state = "Tourist"

/obj/effect/landmark/stationroom
	var/list/template_names = list()
	layer = BULLET_HOLE_LAYER

/obj/effect/landmark/stationroom/New()
	..()
	GLOB.stationroom_landmarks += src

/obj/effect/landmark/stationroom/Destroy()
	if(src in GLOB.stationroom_landmarks)
		GLOB.stationroom_landmarks -= src
	return ..()

/obj/effect/landmark/stationroom/proc/load(template_name)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(!template_name)
		for(var/t in template_names)
			if(!SSmapping.station_room_templates[t])
				log_world("Station room spawner placed at ([T.x], [T.y], [T.z]) has invalid ruin name of \"[t]\" in its list")
				template_names -= t
		template_name = safepick(template_names)
	if(!template_name)
		GLOB.stationroom_landmarks -= src
		qdel(src)
		return FALSE
	var/datum/map_template/template = SSmapping.station_room_templates[template_name]
	if(!template)
		return FALSE
	log_world("Ruin \"[template_name]\" placed at ([T.x], [T.y], [T.z])")
	template.load(T, centered = FALSE)
	template.loaded++
	GLOB.stationroom_landmarks -= src
	qdel(src)
	return TRUE

/obj/effect/landmark/stationroom/box/bar
	template_names = list("Bar Trek", "Bar Spacious", "Bar Box", "Bar Casino", "Bar Conveyor", "Bar Diner", "Bar Disco", "Bar Purple")
	icon = 'yogstation/icons/rooms/box/bar.dmi'
	icon_state = "bar_box"

/obj/effect/landmark/stationroom/box/engine
	template_names = list("Engine SM", "Engine Singulo")
	icon = 'yogstation/icons/rooms/box/engine.dmi'

/obj/effect/landmark/stationroom/box/foreportmaint1
	template_names = list("Maintenance Surgery")

/obj/effect/landmark/event_spawn/proc/spawnroyale(drop = FALSE)
	if(drop)
		new /obj/effect/DPtarget(src, /obj/structure/closet/crate/royale, 0)
		priority_announce("Supply drop located in [get_area(src)]", "Nanotrasen Battle Royale Committee")
	else
		var/droptype = rand(1, 32)
		switch(droptype)

			if(1) //double barreled shotgun and 2 rubbershots
				new /obj/item/gun/ballistic/revolver/doublebarrel(src.loc)
				new /obj/item/ammo_casing/shotgun/rubbershot(src.loc)
				new /obj/item/ammo_casing/shotgun/rubbershot(src.loc)

			if(2) //miniature energy gun
				new /obj/item/gun/energy/e_gun/mini(src.loc)

			if(3) //snare launcher
				new /obj/item/gun/energy/e_gun/dragnet/snare(src.loc)

			if(4) //syringe gun, morphine and two syringes
				new /obj/item/gun/syringe(src.loc)
				new /obj/item/reagent_containers/glass/bottle/morphine(src.loc)
				new /obj/item/reagent_containers/syringe(src.loc)
				new /obj/item/reagent_containers/syringe(src.loc)

			if(5) //syndicate toolbox
				new /obj/item/storage/toolbox/syndicate(src.loc)

			if(6) //medkit
				new /obj/item/storage/firstaid/regular(src.loc)

			if(7) //stechkin
				new /obj/item/gun/ballistic/automatic/pistol(src.loc)

			if(8) //ammo and silencer for the stechkin
				new /obj/item/ammo_box/magazine/m10mm(src.loc)
				new /obj/item/ammo_box/magazine/m10mm(src.loc)
				new /obj/item/suppressor(src.loc)

			if(9) //fire medkit
				new /obj/item/storage/firstaid/fire(src.loc)

			if(10) //toxins medkit
				new /obj/item/storage/firstaid/toxin(src.loc)

			if(11) //o2 medkit
				new /obj/item/storage/firstaid/o2(src.loc)

			if(12) //brute medikit
				new /obj/item/storage/firstaid/brute

			if(13) //bulletproof armour
				new /obj/item/clothing/suit/armor/bulletproof(src.loc)

			if(14) //bulletproof helmet
				new /obj/item/clothing/head/helmet/alt(src.loc)

			if(15) //mosin and 5 bulets
				new /obj/item/gun/ballistic/shotgun/boltaction(src.loc)
				new /obj/item/ammo_casing/a762(src.loc)
				new /obj/item/ammo_casing/a762(src.loc)
				new /obj/item/ammo_casing/a762(src.loc)
				new /obj/item/ammo_casing/a762(src.loc)
				new /obj/item/ammo_casing/a762(src.loc)

			if(16) //m1911
				new /obj/item/gun/ballistic/automatic/pistol/m1911(src.loc)

			if(17) // two mags for the m1911
				new /obj/item/ammo_box/magazine/m45(src.loc)
				new /obj/item/ammo_box/magazine/m45(src.loc)

			if(18) //beartrap
				new /obj/item/restraints/legcuffs/beartrap(src.loc)

			if(19) //wood
				new /obj/item/stack/sheet/mineral/wood/fifty(src.loc)

			if(20) //sandbags
				new /obj/item/stack/sheet/mineral/sandbags(src.loc)

			if(21) //flashbang and sunglasses (intentionally doesn't have a bowman)
				new /obj/item/grenade/flashbang(src.loc)
				new /obj/item/clothing/glasses/sunglasses(src.loc)

			if(22) //EMP grenade
				new /obj/item/grenade/empgrenade(src.loc)

			if(23) //minibomb
				new /obj/item/grenade/syndieminibomb(src.loc)

			if(24) //c4
				new /obj/item/grenade/plastic/c4(src.loc)

			if(25) //syndie soap
				new /obj/item/soap/syndie(src.loc)

			if(26) //thermals
				new /obj/item/clothing/glasses/thermal/syndi(src.loc)

			if(27) //agent ID
				new /obj/item/card/id/syndicate(src.loc)

			if(28) //powersink
				new /obj/item/sbeacondrop/powersink(src.loc)

			if(29) //syndiekey
				new /obj/item/encryptionkey/syndicate(src.loc)

			if(30) //doorcharge
				new /obj/item/doorCharge(src.loc)

			if(31) //pizzabomb
				new /obj/item/pizzabox/bomb(src.loc)

			if(32) //ninja throwing star
				new /obj/item/throwing_star(src.loc)