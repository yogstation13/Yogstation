/mob/living/simple_animal/hostile/wizard/trey
	name = "Trey of The Shattered Voice"
	desc = "The Wizard Federations first and only lizard wizard. It seems to have a stuttering problem"
	icon = 'yogstation/icons/mob/simple_human.dmi'
	icon_state = "wizardtrey"
	icon_living = "wizardtrey"
	icon_dead = "wizardtrey_dead"
	speak_emote = list("stutters")
	speak = list("o-oh god", "p-please d-ie", "ei n-nath?")
	speak_chance = 1

/mob/living/simple_animal/hostile/wizard/cloaked
	name = "Malarky The Mad"
	desc = "Malarky The Mad, former space wizard who was recently disbanded from the wizards federation. He uses unholy magic to preserve his body trapped up in his bubble made of magic slowly decaying. Now he spends his days hallucinating in his old abandoned wizard den plotting his revenge."
	stat_attack = 1
	robust_searching = 1
	speed = 1 // they are slow
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	var/image/shieldoverlay

/mob/living/simple_animal/hostile/wizard/cloaked/New()
	..()
	shieldoverlay = image('icons/effects/effects.dmi', "shield-old")
	overlays += shieldoverlay


/mob/living/simple_animal/hostile/wizard/cloaked/()
	..()
	overlays -= shieldoverlay
	shieldoverlay = null
