/datum/symptom/cult_hallucination
	name = "Visions of the End-Times"
	desc = "UNKNOWN"
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	severity = 2
	max_multiplier = 2.5
	var/list/rune_words_rune = list("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")

/datum/symptom/cult_hallucination/activate(mob/living/mob)
	if(IS_CULTIST(mob))
		return
	if(istype(get_area(mob), /area/station/service/chapel))
		return
	var/client/C = mob.client
	if(!C)
		return
	mob.whisper("...[pick(rune_words_rune)]...")

	var/list/turf_list = list()
	for(var/turf/T in spiral_block(get_turf(mob), 40))
		if(locate(/obj/structure/grille) in T.contents)
			continue
		if(istype(get_area(T), /area/station/service/chapel))
			continue
		if(prob(2*multiplier))
			turf_list += T
	if(turf_list.len)
		for(var/turf/open/T in turf_list)
			var/delay = rand(0, 50) // so the runes don't all appear at once
			spawn(delay)

				var/runenum = rand(1,2)
				var/image/rune_holder = image('monkestation/code/modules/virology/icons/deityrunes.dmi',T,"")
				var/image/rune_render = image('monkestation/code/modules/virology/icons/deityrunes.dmi',T,"fullrune-[runenum]")
				rune_render.color = LIGHT_COLOR_BLOOD_MAGIC

				C.images += rune_holder

		//		anim(target = T, a_icon = 'monkestation/code/modules/virology/icons/deityrunes.dmi', flick_anim = "fullrune-[runenum]-write", col = DEFAULT_BLOOD, sleeptime = 36)

				spawn(30)

					rune_render.icon_state = "fullrune-[runenum]"
					rune_holder.overlays += rune_render
					AnimateFakeRune(rune_holder)

				var/duration = rand(20 SECONDS, 40 SECONDS)
				spawn(duration)
					if(C)
						rune_holder.overlays -= rune_render
		//				anim(target = T, a_icon = 'icons/effects/deityrunes.dmi', flick_anim = "fullrune-[runenum]-erase", col = DEFAULT_BLOOD)
						spawn(12)
							C.images -= rune_holder


/datum/symptom/cult_hallucination/proc/AnimateFakeRune(var/image/rune)
	animate(rune, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)//1
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)//2
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)//3
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)//4
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)//5
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)//9
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)//5
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)//4
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)//3
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)//2

/proc/spiral_block(turf/epicenter, range, draw_red=FALSE)
	if(!epicenter)
		return list()

	if(!range)
		return list(epicenter)

	. = list()

	var/turf/T
	var/y
	var/x
	var/c_dist = 1
	. += epicenter

	while( c_dist <= range )
		y = epicenter.y + c_dist
		x = epicenter.x - c_dist + 1
		//bottom
		for(x in x to epicenter.x+c_dist)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y + c_dist - 1
		x = epicenter.x + c_dist
		for(y in y to epicenter.y-c_dist step -1)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y - c_dist
		x = epicenter.x + c_dist - 1
		for(x in  x to epicenter.x-c_dist step -1)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y - c_dist + 1
		x = epicenter.x - c_dist
		for(y in y to epicenter.y+c_dist)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)
		c_dist++

	if(draw_red)
		sleep(30)
		for(var/turf/Q in .)
			Q.color = null
