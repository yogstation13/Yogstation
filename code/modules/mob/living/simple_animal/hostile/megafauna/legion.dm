/*

LEGION

Legion spawns from the necropolis gate in the far north of lavaland. It is the guardian of the Necropolis and emerges from within whenever an intruder tries to enter through its gate.
Whenever Legion emerges, everything in lavaland will receive a notice via color, audio, and text. This is because Legion is powerful enough to slaughter the entirety of lavaland with little effort.

It has two attack modes that it constantly rotates between.

In ranged mode, it will behave like a normal legion - retreating when possible and firing legion skulls at the target.
In charge mode, it will spin and rush its target, attacking with melee whenever possible.

When Legion dies, it drops a staff of storms, which allows its wielder to call and disperse ash storms at will and functions as a powerful melee weapon.

Difficulty: Medium

*/

#define LEGION_LARGE 5
#define LEGION_MEDIUM 3
#define LEGION_SMALL 1

/mob/living/simple_animal/hostile/megafauna/legion
	name = "Legion"
	health = 800
	maxHealth = 800
	icon_state = "mega_legion"
	icon_living = "mega_legion"
	health_doll_icon = "mega_legion"
	desc = "One of many."
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	speak_emote = list("echoes")
	armour_penetration = 50
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_vis_effect = ATTACK_EFFECT_BITE
	speed = 5
	ranged = TRUE
	del_on_death = TRUE
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_time = 20
	var/size = LEGION_LARGE
	var/charging = FALSE
	internal_type = /obj/item/gps/internal/legion
	pixel_y = -32
	pixel_x = -16
	loot = list(/obj/item/stack/sheet/bone = 3)
	vision_range = 13
	wander = FALSE
	elimination = TRUE
	appearance_flags = LONG_GLIDE
	mouse_opacity = MOUSE_OPACITY_ICON
	attack_action_types = list(/datum/action/innate/megafauna_attack/create_skull,
							   /datum/action/innate/megafauna_attack/charge_target)
	small_sprite_type = /datum/action/small_sprite/megafauna/legion

/mob/living/simple_animal/hostile/megafauna/legion/medium
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	pixel_x = -16
	pixel_y = -8
	maxHealth = 350
	size = LEGION_MEDIUM

/mob/living/simple_animal/hostile/megafauna/legion/medium/left
	icon_state = "mega_legion_left"

/mob/living/simple_animal/hostile/megafauna/legion/medium/eye
	icon_state = "mega_legion_eye"

/mob/living/simple_animal/hostile/megafauna/legion/medium/right
	icon_state = "mega_legion_right"

/mob/living/simple_animal/hostile/megafauna/legion/small
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "mega_legion"
	pixel_x = 0
	pixel_y = 0
	maxHealth = 200
	size = LEGION_SMALL

/datum/action/innate/megafauna_attack/create_skull
	name = "Create Legion Skull"
	icon_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	button_icon_state = "legion_head"
	chosen_message = span_colossus("You are now creating legion skulls.")
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/charge_target
	name = "Charge Target"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = span_colossus("You are now charging at your target.")
	chosen_attack_num = 2

/mob/living/simple_animal/hostile/megafauna/legion/OpenFire(the_target)
	if(charging)
		return
	ranged_cooldown = world.time + ranged_cooldown_time

	if(client)
		switch(chosen_attack)
			if(1)
				create_legion_skull()
			if(2)
				charge_target()
		return

	if(prob(75))
		create_legion_skull()
	else
		charge_target()

/mob/living/simple_animal/hostile/megafauna/legion/proc/create_legion_skull()
	var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(loc)
	A.GiveTarget(target)
	A.friends = friends
	A.faction = faction

/mob/living/simple_animal/hostile/megafauna/legion/proc/charge_target()
	visible_message(span_warning("<b>[src] charges!</b>"))
	SpinAnimation(speed = 20, loops = 3, parallel = FALSE)
	ranged = FALSE
	retreat_distance = 0
	minimum_distance = 0
	set_varspeed(0)
	charging = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_charge)), 5 SECONDS)

/mob/living/simple_animal/hostile/megafauna/legion/GiveTarget(new_target)
	. = ..()
	if(target)
		wander = TRUE

/mob/living/simple_animal/hostile/megafauna/legion/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0 && GLOB.necropolis_gate && true_spawn)
		GLOB.necropolis_gate.toggle_the_gate(null, TRUE) //very clever.
	return ..()

/mob/living/simple_animal/hostile/megafauna/legion/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/L = target
		if(L.stat == UNCONSCIOUS)
			var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(loc)
			A.infest(L)

/mob/living/simple_animal/hostile/megafauna/legion/proc/reset_charge()
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	set_varspeed(2)
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/legion/death()
	if(health)
		return
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(maxHealth * MEGAFAUNA_CASH_SCALE)
	if(size > LEGION_SMALL)
		var/datum/component/music_player/player = GetComponent(/datum/component/music_player)
		size--
		switch(size)
			if(LEGION_SMALL)
				for(var/i in 0 to 2)
					new /mob/living/simple_animal/hostile/megafauna/legion/small(loc)
				qdel(src)
			if(LEGION_MEDIUM)
				new /mob/living/simple_animal/hostile/megafauna/legion/medium/left(loc)
				new /mob/living/simple_animal/hostile/megafauna/legion/medium/right(loc)
				new /mob/living/simple_animal/hostile/megafauna/legion/medium/eye(loc)
				qdel(src)
			else
				adjustHealth(-maxHealth) //heal ourselves to full in prep for next phase
		
		if(player)
			for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_living_list)
				if(other.GetComponent(/datum/component/music_player))
					continue
				other.AddComponent(player.type, player.music_path)
	else
		var/last_legion = TRUE
		for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_living_list)
			if(other != src)
				last_legion = FALSE
				break
		if(last_legion)
			loot = list(/obj/item/staff/storm,
			/obj/item/cane/cursed,
			/obj/item/keycard/necropolis)
			crusher_loot = list(/obj/item/crusher_trophy/malformed_bone,/obj/item/staff/storm,
			/obj/item/cane/cursed,
			/obj/item/keycard/necropolis) //the way it is now you can get this if you just whip out the crusher towards the end but nobody's gonna do that probably
			elimination = FALSE
		else if(prob(10))
			loot = list(/obj/structure/closet/crate/necropolis/tendril)
		if(!true_spawn)
			loot = null
		return ..()

/obj/item/gps/internal/legion
	icon_state = null
	gpstag = "Echoing Signal"
	desc = "The message repeats."
	invisibility = 100


//Loot

/obj/item/staff/storm
	name = "staff of storms"
	desc = "An ancient staff retrieved from the remains of Legion. The wind stirs as you move it."
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	wound_bonus = -40
	bare_wound_bonus = 20
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	var/storm_type = /datum/weather/ash_storm
	var/storm_cooldown = 0
	var/static/list/excluded_areas = list(/area/reebe/city_of_cogs)

/obj/item/staff/storm/attack_self(mob/user)
	if(storm_cooldown > world.time)
		to_chat(user, span_warning("The staff is still recharging!"))
		return

	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_area || !user_turf || (user_area.type in excluded_areas))
		to_chat(user, span_warning("Something is preventing you from using the staff here."))
		return
	var/datum/weather/A = SSweather.get_weather(user_turf.z, user_area)

	if(A)
		if(A.stage != END_STAGE)
			if(A.stage == WIND_DOWN_STAGE)
				to_chat(user, span_warning("The storm is already ending! It would be a waste to use the staff now."))
				return
			user.visible_message(span_warning("[user] holds [src] skywards as an orange beam travels into the sky!"), \
			span_notice("You hold [src] skyward, dispelling the storm!"))
			playsound(user, 'sound/magic/staff_change.ogg', 200, 0)
			A.wind_down()
			log_game("[user] ([key_name(user)]) has dispelled a storm at [AREACOORD(user_turf)]")
			return
	else
		A = new storm_type(list(user_turf.z))
		A.name = "staff storm"
		log_admin("[user] ([key_name(user)]) has summoned [A] at [AREACOORD(user_turf)]")
		message_admins("[A] has been summoned in [ADMIN_VERBOSEJMP(user_turf)] by [ADMIN_LOOKUPFLW(user)]")
		A.area_type = user_area.type
		A.telegraph_duration = 100
		A.end_duration = 100

	user.visible_message(span_warning("[user] holds [src] skywards as red lightning crackles into the sky!"), \
	span_notice("You hold [src] skyward, calling down a terrible storm!"))
	playsound(user, 'sound/magic/staff_change.ogg', 200, 0)
	A.telegraph()
	storm_cooldown = world.time + 200

#undef LEGION_LARGE
#undef LEGION_MEDIUM
#undef LEGION_SMALL
