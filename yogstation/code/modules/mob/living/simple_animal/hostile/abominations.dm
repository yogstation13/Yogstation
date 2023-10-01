/mob/living/simple_animal/hostile/abomination
	name = "abomination"
	desc = "A groveling, hulking beast. Another failed experiment from those terror ship abductors. What exactly were they trying to make?"
	speak_emote = list("haunts")
	icon = 'yogstation/icons/mob/horrors.dmi'
	icon_state = "horror1"
	icon_living = "horror1"
	icon_dead = "horror_dead"
	health = 300
	maxHealth = 300
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("abomination")
	speak_emote = list("screams")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	weather_immunities = list("ash")
	stat_attack = UNCONSCIOUS

/mob/living/simple_animal/hostile/abomination/super
	desc = "A groveling, terrifying beast. This one seems agile."
	icon = 'yogstation/icons/mob/horrors.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	health = 250
	maxHealth = 250
	var/datum/action/cooldown/spell/aoe/shriek/scream = null
	var/screamCD

/mob/living/simple_animal/hostile/abomination/super/New()
	..()
	scream = new /datum/action/cooldown/spell/aoe/shriek()
	scream.Grant(src)

/mob/living/simple_animal/hostile/abomination/super/handle_automated_action()
	. = ..()
	if(target)
		if(screamCD < world.time)
			visible_message("[src.name] grows a wicked smile before dropping their jaw and inhaling.")
			scream.get_things_to_cast_on(src)
			screamCD = world.time + 2 MINUTES

/mob/living/simple_animal/hostile/abomination/altform1
	icon = 'yogstation/icons/mob/horrors.dmi'
	icon_state = "horror2"
	icon_living = "horror2"
	icon_dead = "horror_dead"

/mob/living/simple_animal/hostile/abomination/altform2
	icon = 'yogstation/icons/mob/horrors.dmi'
	icon_state = "horror3"
	icon_living = "horror3"
	icon_dead = "horror_dead"

/mob/living/simple_animal/hostile/abomination/altform3
	icon = 'yogstation/icons/mob/horrors.dmi'
	icon_state = "horror4"
	icon_living = "horror4"
	icon_dead = "horror_dead"

/mob/living/simple_animal/hostile/abomination/altform4
	icon = 'yogstation/icons/mob/horrors.dmi'
	icon_state = "horror5"
	icon_living = "horror5"
	icon_dead = "horror_dead"
