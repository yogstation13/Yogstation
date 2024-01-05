/**********************Mining Scanners**********************/
/obj/item/mining_scanner
	desc = "A scanner that checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations.\nIt has a speaker that can be toggled with <b>alt+click</b>"
	name = "manual mining scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "miningmanual"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0
	var/speaker = TRUE // Speaker that plays a sound when pulsed.

/obj/item/mining_scanner/AltClick(mob/user)
	speaker = !speaker
	to_chat(user, "<span class='notice'>You toggle [src]'s speaker to [speaker ? "<b>ON</b>" : "<b>OFF</b>"].</span>")

/obj/item/mining_scanner/attack_self(mob/user)
	if(!user.client)
		return
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		mineral_scan_pulse(get_turf(user))
		if(speaker)
			playsound(src, 'sound/effects/ping.ogg', 15)

//Debug item to identify all ore spread quickly
/obj/item/mining_scanner/admin

/obj/item/mining_scanner/admin/attack_self(mob/user)
	for(var/turf/closed/mineral/M in world)
		if(M.scan_state)
			M.icon_state = M.scan_state
	qdel(src)

/obj/item/t_scanner/adv_mining_scanner
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations. This one has an extended range.\nIt has a speaker that can be toggled with <b>alt+click</b>"
	name = "advanced automatic mining scanner"
	icon_state = "adv_mining0"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	var/cooldown = 35
	var/current_cooldown = 0
	var/range = 7
	var/speaker = TRUE // Speaker that plays a sound when pulsed.

/obj/item/t_scanner/adv_mining_scanner/AltClick(mob/user)
	speaker = !speaker
	to_chat(user, "<span class='notice'>You toggle [src]'s speaker to [speaker ? "<b>ON</b>" : "<b>OFF</b>"].</span>")

/obj/item/t_scanner/adv_mining_scanner/cyborg/Initialize(mapload)
	. = ..()
	toggle_on()

/obj/item/t_scanner/adv_mining_scanner/lesser
	name = "automatic mining scanner"
	icon_state = "mining0"
	desc = "A scanner that automatically checks surrounding rock for useful minerals; it can also be used to stop gibtonite detonations."
	range = 4
	cooldown = 50

/obj/item/t_scanner/adv_mining_scanner/goat_scanner
	desc = "An advanced scanner used by the goat king to sate his appetite for explosions; It allows the user to always receive high potency gibtonite after defusing them."
	name = "goat king's scanner"
	icon_state = "goat_mining0"
	cooldown = 20

/obj/item/t_scanner/adv_mining_scanner/scan()
	if(current_cooldown <= world.time)
		current_cooldown = world.time + cooldown
		var/turf/t = get_turf(src)
		mineral_scan_pulse(t, range)
		if(speaker)
			playsound(src, 'sound/effects/ping.ogg', 15)

/proc/mineral_scan_pulse(turf/T, range = world.view)
	var/list/minerals = list()
	for(var/turf/closed/mineral/M in range(range, T))
		if(M.scan_state)
			minerals += M
	//yogs edit
	for(var/turf/open/floor/plating/dirt/jungleland/JG in range(range, T))
		if(JG.ore_present == ORE_EMPTY || !JG.can_spawn_ore)
			continue
		var/datum/ore_patch/ore = GLOB.jungle_ores[JG.ore_present]
		var/state = initial(ore.overlay_state)
		var/obj/effect/temp_visual/mining_overlay/oldC = locate(/obj/effect/temp_visual/mining_overlay) in JG
		if(oldC)
			qdel(oldC)
		var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(JG)
		C.icon_state = state
	//yogs end
	if(LAZYLEN(minerals))
		for(var/turf/closed/mineral/M in minerals)
			var/obj/effect/temp_visual/mining_overlay/oldC = locate(/obj/effect/temp_visual/mining_overlay) in M
			if(oldC)
				qdel(oldC)
			var/obj/effect/temp_visual/mining_overlay/C = new /obj/effect/temp_visual/mining_overlay(M)
			C.icon_state = M.scan_state

/obj/effect/temp_visual/mining_overlay
	plane = FULLSCREEN_PLANE
	layer = FLASH_LAYER
	icon = 'icons/effects/ore_visuals.dmi'
	appearance_flags = 0 //to avoid having TILE_BOUND in the flags, so that the 480x480 icon states let you see it no matter where you are
	duration = 3.5 SECONDS
	pixel_x = -224
	pixel_y = -224

/obj/effect/temp_visual/mining_overlay/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = EASE_IN)

