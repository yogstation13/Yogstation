/mob/living/simple_animal/snail
	name = "Snail"
	desc = "Somehow this snail is here, cute"
	icon = 'icons/mob/pets.dmi'
	icon_state = "snail"
	icon_dead = "snail_dead"
	health = 5
	maxHealth = 6
	turns_per_move = 10
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	response_help  = "pokes"
	response_disarm = "shoos"
	response_harm   = "splats"
	speak_emote = list("chitters")
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	verb_say = "chitters"
	verb_ask = "chitters inquisitively"
	verb_exclaim = "chitters loudly"
	verb_yell = "chitters loudly"

