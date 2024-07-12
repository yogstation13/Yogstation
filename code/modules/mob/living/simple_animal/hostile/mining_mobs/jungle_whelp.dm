/mob/living/simple_animal/hostile/drakeling/jungle
	attack_sound = 'sound/magic/demon_attack1.ogg'
	icon = 'yogstation/icons/mob/jungle.dmi'
	icon_state = "jungle_whelp"
	icon_living = "jungle_whelp"
	icon_dead ="jungle_whelp_dead"
	attacktext = "chomps"
	vision_range = 4
	aggro_vision_range = 7
	melee_damage_lower = 15
	melee_damage_upper = 15
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	speak_chance = 5
	weather_immunities = list(WEATHER_ACID)
	movement_type = FLYING
	emote_see = list("flaps its little wings.", "waves its tail.","hops around a few times.", "wiggles it's vines.", "tilts its head.")
	mounted_abilities = list(
		/datum/action/cooldown/drake_ollie,
		/datum/action/cooldown/spell/pointed/drakeling/wing_flap,
		/datum/action/cooldown/spell/pointed/drakeling/vine_lash
	)

///drakeling vine breath attack: shoots a short line of fire that is very effective against lavaland fauna and not very effective against much else
/datum/action/cooldown/spell/pointed/drakeling/vine_lash
	name = "Vine lash"
	desc = "Use vines to lash targets in a direction. Effective against fauna but worthless off of jungleland."
	button_icon = 'icons/effects/spacevines.dmi'
	button_icon_state = "Light3"
	cooldown_time = 1.6 SECONDS //kinetic gun
	active_msg = span_notice("You prepare the vine lash")
	deactive_msg = span_notice("You decide to refrain from lacerating more peasants for the time.")

/datum/action/cooldown/spell/pointed/drakeling/vine_lash/InterceptClickOn(mob/living/L, params, atom/A)
	. = ..()
	if(!.)
		return FALSE
	playsound(get_turf(drake),'sound/magic/tail_swing.ogg', 100, 1)
	var/turf/T = get_turf(drake)
	var/range = is_mining_level(T.z) ? 4 : 1 //1 tile range means it tends to be incapable of firing diagonally but if it's any longer it's "not a melee weapon"
	var/damage = is_mining_level(T.z) ? 20 : 5
	var/list/turfs = list()
	var/list/protected = list(drake, L)
	turfs = drake.line_target(range, A)
	INVOKE_ASYNC(src, PROC_REF(drakeling_vine_line), drake, turfs, damage, protected)

	return TRUE

///actual bit that shoots fire for the fire breath attack
/datum/action/cooldown/spell/pointed/drakeling/vine_lash/proc/drakeling_vine_line(source, list/turfs, damage, list/protected)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break
		new /obj/effect/temp_visual/vineball(T)
		for(var/mob/living/L in T.contents)
			if((L in hit_list) || (L in protected))
				continue
			hit_list += L
			if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid))
				L.adjustBruteLoss(damage * 3) //60 damage plus the normal damage against fauna, total of 80 should make it mega competitive vs other weapons
			L.adjustBruteLoss(damage)
			to_chat(L, span_userdanger("You're hit by [source]'s vine whip!"))
		sleep(0.1 SECONDS)
