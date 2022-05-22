/obj/structure/destructible/cult
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/cult.dmi'
	light_power = 2
	var/cooldowntime = 0
	break_sound = 'sound/hallucinations/veryfar_noise.ogg'
	debris = list(/obj/item/stack/sheet/runed_metal = 1)
	var/is_endgame = FALSE //is the structure part of the endgame? stuff that can't be healed/moved have this set to TRUE

/obj/structure/destructible/cult/proc/conceal() //for spells that hide cult presence
	density = FALSE
	visible_message(span_danger("[src] fades away."))
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes
	light_range = 0
	light_power = 0
	update_light()
	STOP_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/cult/proc/reveal() //for spells that reveal cult presence
	density = initial(density)
	invisibility = 0
	visible_message(span_danger("[src] suddenly appears!"))
	alpha = initial(alpha)
	light_range = initial(light_range)
	light_power = initial(light_power)
	update_light()
	START_PROCESSING(SSfastprocess, src)


/obj/structure/destructible/cult/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] is [anchored ? "":"not "]secured to the floor.")
	if((iscultist(user) || isobserver(user)) && cooldowntime > world.time)
		. += "<span class='cult italic'>The magic in [src] is too weak, [p_they()] will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>"

/obj/structure/destructible/cult/examine_status(mob/user)
	if(iscultist(user) || isobserver(user))
		var/t_It = p_they(TRUE)
		var/t_is = p_are()
		return span_cult("[t_It] [t_is] at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability.")
	return ..()

/obj/structure/destructible/cult/attack_animal(mob/living/simple_animal/M)
	if(is_endgame && iscultist(M))
		return FALSE //no smash or healing
	if(istype(M, /mob/living/simple_animal/hostile/construct/builder))
		if(obj_integrity < max_integrity)
			M.changeNext_move(CLICK_CD_MELEE)
			obj_integrity = min(max_integrity, obj_integrity + 5)
			Beam(M, icon_state="sendbeam", time=4)
			M.visible_message(span_danger("[M] repairs \the <b>[src]</b>."), \
				span_cult("You repair <b>[src]</b>, leaving [p_they()] at <b>[round(obj_integrity * 100 / max_integrity)]%</b> stability."))
		else
			to_chat(M, span_cult("You cannot repair [src], as [p_theyre()] undamaged!"))
	else
		..()

/obj/structure/destructible/cult/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(iscultist(user) && is_endgame)
		return FALSE
	return ..()

/obj/structure/destructible/cult/attackby(obj/I, mob/user, params)
	if(is_endgame && iscultist(user))
		return FALSE
	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		anchored = !anchored
		to_chat(user, span_notice("You [anchored ? "":"un"]secure \the [src] [anchored ? "to":"from"] the floor."))
		if(!anchored)
			icon_state = "[initial(icon_state)]_off"
		else
			icon_state = initial(icon_state)
	else
		return ..()

/obj/structure/destructible/cult/ratvar_act()
	if(take_damage(rand(25, 50), BURN) && src) //if we still exist
		var/previouscolor = color
		color = "#FAE48C"
		animate(src, color = previouscolor, time = 0.8 SECONDS)
		addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 0.8 SECONDS)


/obj/structure/destructible/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie."
	icon_state = "talismanaltar"
	break_message = span_warning("The altar shatters, leaving only the wailing of the damned!")

/obj/structure/destructible/cult/talisman/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, span_warning("You're pretty sure you know exactly what this is used for and you can't seem to touch it."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	var/choice = alert(user,"You study the schematics etched into the altar...",,"Eldritch Whetstone","Construct Shell","Flask of Unholy Water")
	var/list/pickedtype = list()
	switch(choice)
		if("Eldritch Whetstone")
			pickedtype += /obj/item/sharpener/cult
		if("Construct Shell")
			pickedtype += /obj/structure/constructshell
		if("Flask of Unholy Water")
			pickedtype += /obj/item/reagent_containers/glass/beaker/unholywater
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You kneel before the altar and your faith is rewarded with the [choice]!"))

/obj/structure/destructible/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie."
	icon_state = "forge"
	light_range = 2
	light_color = LIGHT_COLOR_LAVA
	break_message = span_warning("The force breaks apart into shards with a howling scream!")

/obj/structure/destructible/cult/forge/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, span_warning("The heat radiating from [src] pushes you back."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	var/choice
	if(user.mind.has_antag_datum(/datum/antagonist/cult/master))
		choice = alert(user,"You study the schematics etched into the forge...",,"Shielded Robe","Flagellant's Robe","Mirror Shield")
	else
		choice = alert(user,"You study the schematics etched into the forge...",,"Shielded Robe","Flagellant's Robe","Mirror Shield")
	var/list/pickedtype = list()
	switch(choice)
		if("Shielded Robe")
			pickedtype += /obj/item/clothing/suit/hooded/cultrobes/cult_shield
		if("Flagellant's Robe")
			pickedtype += /obj/item/clothing/suit/hooded/cultrobes/berserker
		if("Mirror Shield")
			pickedtype += /obj/item/shield/mirror
	if(src && !QDELETED(src) && anchored && pickedtype && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You work the forge as dark knowledge guides your hands, creating the [choice]!"))



/obj/structure/destructible/cult/pylon
	name = "pylon"
	desc = "A floating crystal that slowly heals those faithful to Nar'Sie."
	icon_state = "pylon"
	light_range = 1.5
	light_color = LIGHT_COLOR_RED
	break_sound = 'sound/effects/glassbr2.ogg'
	break_message = span_warning("The blood-red crystal falls to the floor and shatters!")
	var/heal_delay = 25
	var/last_heal = 0
	var/corrupt_delay = 50
	var/last_corrupt = 0

/obj/structure/destructible/cult/pylon/New()
	START_PROCESSING(SSfastprocess, src)
	..()

/obj/structure/destructible/cult/pylon/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/cult/pylon/process()
	if(!anchored)
		return
	if(last_heal <= world.time)
		last_heal = world.time + heal_delay
		for(var/mob/living/L in range(5, src))
			if(iscultist(L) || isshade(L) || isconstruct(L))
				if(L.health != L.maxHealth)
					new /obj/effect/temp_visual/heal(get_turf(src), "#960000")
					if(ishuman(L))
						L.adjustBruteLoss(-1, 0)
						L.adjustFireLoss(-1, 0)
						L.updatehealth()
					if(isshade(L) || isconstruct(L))
						var/mob/living/simple_animal/M = L
						if(M.health < M.maxHealth)
							M.adjustHealth(-3)
				if(ishuman(L) && L.blood_volume < BLOOD_VOLUME_NORMAL(L))
					L.blood_volume += 1.0
			CHECK_TICK
	if(last_corrupt <= world.time)
		var/list/validturfs = list()
		var/list/cultturfs = list()
		for(var/T in circleviewturfs(src, 5))
			if(istype(T, /turf/open/floor/engine/cult))
				cultturfs |= T
				continue
			var/static/list/blacklisted_pylon_turfs = typecacheof(list(
				/turf/closed,
				/turf/open/floor/engine/cult,
				/turf/open/space,
				/turf/open/lava,
				/turf/open/chasm))
			if(is_type_in_typecache(T, blacklisted_pylon_turfs))
				continue
			else
				validturfs |= T

		last_corrupt = world.time + corrupt_delay

		var/turf/T = safepick(validturfs)
		if(T)
			if(istype(T, /turf/open/floor/plating))
				T.PlaceOnTop(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
			else
				T.ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)
		else
			var/turf/open/floor/engine/cult/F = safepick(cultturfs)
			if(F)
				new /obj/effect/temp_visual/cult/turf/floor(F)
			else
				// Are we in space or something? No cult turfs or
				// convertable turfs?
				last_corrupt = world.time + corrupt_delay*2

/obj/structure/destructible/cult/tome
	name = "archives"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "tomealtar"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE
	break_message = span_warning("The books and tomes of the archives burn into ash as the desk shatters!")

/obj/structure/destructible/cult/tome/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, span_warning("These books won't open and it hurts to even try and read the covers."))
		return
	if(!anchored)
		to_chat(user, span_cultitalic("You need to anchor [src] to the floor with your dagger first."))
		return
	if(cooldowntime > world.time)
		to_chat(user, "<span class='cult italic'>The magic in [src] is weak, it will be ready to use again in [DisplayTimeText(cooldowntime - world.time)].</span>")
		return
	var/choice = alert(user,"You flip through the black pages of the archives...",,"Zealot's Blindfold","Shuttle Curse","Veil Walker Set")
	var/list/pickedtype = list()
	switch(choice)
		if("Zealot's Blindfold")
			pickedtype += /obj/item/clothing/glasses/hud/health/night/cultblind
		if("Shuttle Curse")
			pickedtype += /obj/item/shuttle_curse
		if("Veil Walker Set")
			pickedtype += /obj/item/cult_shift
			pickedtype += /obj/item/flashlight/flare/culttorch
	if(src && !QDELETED(src) && anchored && pickedtype.len && Adjacent(user) && !user.incapacitated() && iscultist(user) && cooldowntime <= world.time)
		cooldowntime = world.time + 2400
		for(var/N in pickedtype)
			new N(get_turf(src))
			to_chat(user, span_cultitalic("You summon the [choice] from the archives!"))

/////////////////////////////WE'RE IN THE ENDGAME NOW/////////////////////////////
/obj/structure/destructible/cult/pillar
	name = "obsidian pillar"
	icon_state = "pillar-enter"
	icon = 'icons/obj/cult_64x64.dmi'
	pixel_x = -16
	obj_integrity = 200
	max_integrity = 200
	break_sound = 'sound/effects/meteorimpact.ogg'
	break_message = span_warning("The pillar crumbles!")
	layer = MASSIVE_OBJ_LAYER
	var/alt = 0
	is_endgame = TRUE

/obj/structure/destructible/cult/pillar/alt
	icon_state = "pillaralt-enter"
	alt = 1

/obj/structure/destructible/cult/pillar/Initialize()
	..()
	var/turf/T = loc
	if (!T)
		qdel(src)
		return
	for (var/obj/O in loc)
		if(O == src)
			continue
		O.ex_act(EXPLODE_HEAVY)
		if(!QDELETED(O) && (istype(O, /obj/structure) || istype(O, /obj/machinery)))
			qdel(O)
	T.narsie_act()

/obj/structure/destructible/cult/pillar/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	..()
	update_icon()

/obj/structure/destructible/cult/pillar/Destroy()
	new /obj/effect/decal/cleanable/ash(loc)
	..()

/obj/structure/destructible/cult/pillar/update_icon()
	icon_state = "pillar[alt ? "alt": ""]2"
	if (obj_integrity < max_integrity/3)
		icon_state = "pillar[alt ? "alt": ""]0"
	else if (obj_integrity < 2*max_integrity/3)
		icon_state = "pillar[alt ? "alt": ""]1"

/obj/structure/destructible/cult/pillar/conceal()
	return

/obj/structure/destructible/cult/pillar/ex_act(var/severity)
	switch(severity)
		if (EXPLODE_DEVASTATE)
			take_damage(200)
		if (EXPLODE_HEAVY)
			take_damage(100)
		if (EXPLODE_LIGHT)
			take_damage(20)

/obj/structure/destructible/cult/bloodstone
	name = "bloodstone"
	desc = "A large, red stone filling with... something. You get a headache even being near it."
	icon_state = "bloodstone-enter1"
	icon = 'icons/obj/cult_64x64.dmi'
	pixel_x = -16
	obj_integrity = 600
	max_integrity = 600
	break_sound = 'sound/effects/glassbr2.ogg'
	break_message = span_warning("The bloodstone resonates violently before crumbling to the floor!")
	layer = MASSIVE_OBJ_LAYER
	light_color = "#FF0000"
	var/current_fullness = 0
	var/anchor = FALSE //are we the bloodstone used to summon nar-sie? used in the final part of the summoning
	is_endgame = TRUE

/obj/structure/destructible/cult/bloodstone/Initialize()
	..()
	if (!src.loc)
		message_admins("Blood Cult: A blood stone was somehow spawned in nullspace. It has been destroyed.")
		qdel(src)
	SSshuttle.registerHostileEnvironment(src)
	SSticker.mode.bloodstone_list.Add(src)
	for (var/obj/O in loc)
		if (O != src)
			O.ex_act(2)
	safe_space()
	set_light(3)
	for(var/mob/M in GLOB.player_list)
		if (M.z == z && M.client)
			if (get_dist(M,src)<=20)
				M.playsound_local(src, get_sfx("explosion"), 50, 1)
				shake_camera(M, 4, 1)
			else
				M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
				shake_camera(M, 1, 1)

	spawn(10)
		var/list/pillars = list()
		icon_state = "bloodstone-enter2"
		for(var/mob/M in GLOB.player_list)
			if (M.z == z && M.client)
				if (get_dist(M,src)<=20)
					M.playsound_local(src, get_sfx("explosion"), 50, 1)
					shake_camera(M, 4, 1)
				else
					M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
					shake_camera(M, 1, 1)
		var/turf/T1 = locate(x-2,y-2,z)
		pillars += new /obj/structure/destructible/cult/pillar(T1)
		var/turf/T2 = locate(x+2,y-2,z)
		pillars += new /obj/structure/destructible/cult/pillar/alt(T2)
		var/turf/T3 = locate(x-2,y+2,z)
		pillars += new /obj/structure/destructible/cult/pillar(T3)
		var/turf/T4 = locate(x+2,y+2,z)
		pillars += new /obj/structure/destructible/cult/pillar/alt(T4)
		sleep(1 SECONDS)
		icon_state = "bloodstone-enter3"
		for(var/mob/M in GLOB.player_list)
			if (M.z == z && M.client)
				if (get_dist(M,src)<=20)
					M.playsound_local(src, get_sfx("explosion"), 50, 1)
					shake_camera(M, 4, 1)
				else
					M.playsound_local(src, 'sound/effects/explosionfar.ogg', 50, 1)
					shake_camera(M, 1, 1)
		for (var/obj/structure/destructible/cult/pillar/P in pillars)
			P.update_icon()

/obj/structure/destructible/cult/bloodstone/proc/summon()
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF //should stop the stone from being destroyed by damage
	sound_to_playing_players('sound/effects/dimensional_rend.ogg')
	sleep(4 SECONDS)
	new /obj/singularity/narsie/large/cult(loc)

/obj/structure/destructible/cult/bloodstone/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	..()
	update_icon()

/obj/structure/destructible/cult/bloodstone/ex_act(var/severity)
	switch(severity)
		if (EXPLODE_DEVASTATE)
			take_damage(200)
		if (EXPLODE_HEAVY)
			take_damage(100)
		if (EXPLODE_LIGHT)
			take_damage(20)

/obj/structure/destructible/cult/bloodstone/Destroy()
	for(var/mob/M in range(7, loc))
		M.playsound_local(M, 'sound/creatures/legion_death.ogg', 75, FALSE) //make it suitably loud
	SSticker.mode.bloodstone_list.Remove(src)
	SSshuttle.clearHostileEnvironment(src)
	for(var/datum/mind/B in SSticker.mode.cult)
		if(B.current)
			SEND_SOUND(B.current, 'sound/magic/demon_dies.ogg')
			if(SSticker.mode.bloodstone_list.len)
				to_chat(B.current, span_cultlarge("The Bloodstone in [get_area(src)] has been destroyed! There are [SSticker.mode.bloodstone_list.len] Bloodstones remaining!."))
	new /obj/effect/decal/cleanable/ash(loc)
	new /obj/item/ectoplasm(loc)
	new /obj/structure/destructible/dead_bloodstone(loc)

	if(!(locate(/obj/singularity/narsie) in GLOB.poi_list) && (!SSticker.mode.bloodstone_cooldown && SSticker.mode.bloodstone_list.len <= 0 || anchor))
		if(anchor)
			SSticker.mode.anchor_bloodstone = null
			SSticker.mode.cult_loss_anchor()
		else
			SSticker.mode.cult_loss_bloodstones()
	..()

/obj/structure/destructible/cult/bloodstone/mech_melee_attack(obj/mecha/M)
	M.force = round(M.force/6, 1) //damage is reduced since mechs deal triple damage to objects, this sets gygaxes to 15 (5*3) damage and durands to 21 (7*3) damage
	. = ..()
	M.force = initial(M.force)

/obj/structure/destructible/cult/bloodstone/hulk_damage()
	return 15 //no

/obj/structure/destructible/cult/bloodstone/proc/safe_space()
	for(var/turf/T in range(5,src))
		var/dist = get_dist(src, T)
		if (dist <= 2)
			T.ChangeTurf(/turf/open/floor/engine/cult)
			for (var/obj/structure/S in T)
				if(!istype(S,/obj/structure/destructible/cult))
					S.ex_act(EXPLODE_DEVASTATE)
			for (var/obj/machinery/M in T)
				qdel(M)
		else if (dist <= 4)
			if (istype(T,/turf/open/space))
				T.ChangeTurf(/turf/open/floor/engine/cult)
			else
				T.narsie_act(TRUE, TRUE)
		else if (dist <= 5)
			if (istype(T,/turf/open/space))
				T.ChangeTurf(/turf/closed/wall/mineral/cult)
			else
				T.narsie_act(TRUE, TRUE)

/obj/structure/destructible/cult/bloodstone/update_icon()
	icon_state = "bloodstone-[current_fullness]"
	cut_overlays()
	var/image/I_base = image('icons/obj/cult_64x64.dmi',"bloodstone-base")
	I_base.appearance_flags |= RESET_COLOR//we don't want the stone to pulse
	overlays += I_base
	if (obj_integrity <= max_integrity/3)
		add_overlay("bloodstone_damage2")
	else if (obj_integrity <= 2*max_integrity/3)
		add_overlay("bloodstone_damage1")
	set_light(3+current_fullness, 2+current_fullness)

/obj/structure/destructible/cult/bloodstone/proc/set_animate()
	animate(src, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 1 SECONDS, loop = -1)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 0.2 SECONDS)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 0.2 SECONDS)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 0.15 SECONDS)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 0.15 SECONDS)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 0.5 SECONDS)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 0.1 SECONDS)
	set_light(20, 20)
	update_icon()

/obj/structure/destructible/cult/bloodstone/conceal() //lol
	return

/obj/structure/destructible/cult/bloodstone/reveal()
	return

/obj/structure/destructible/dead_bloodstone
	name = "shattered bloodstone"
	desc = "The base of a destroyed bloodstone."
	icon = 'icons/obj/cult_64x64.dmi'
	icon_state = "bloodstone-base"
	pixel_x = -16

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = TRUE
	anchored = TRUE

/obj/effect/gateway/singularity_act()
	return

/obj/effect/gateway/singularity_pull()
	return
