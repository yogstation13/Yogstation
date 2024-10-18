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
	weather_immunities = WEATHER_STORM
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



/datum/action/cooldown/spell/aoe/shriek //Stuns anyone in view range.
	name = "Screech"
	desc = "Releases a terrifying screech, freezing those who hear."
	panel = "Abomination"

	sound = 'yogstation/sound/effects/creepyshriek.ogg'
	cooldown_time = 10 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/shriek/cast_on_thing_in_aoe(atom/victim, atom/user)
	if(!istype(user, /mob/living/simple_animal/hostile/abomination))
		return
	user.visible_message(span_warning("<b>[usr] unhinges their jaw and releases a horrifying shriek!"))
	if(!isturf(victim))
		return
	var/turf/T = victim
	for(var/mob/living/carbon/M in T.contents)
		if(M == user) //No message for the user, of course
			continue
		var/mob/living/carbon/human/H = M
		var/distance = max(1,get_dist(usr,H))
		if(istype(H.ears, /obj/item/clothing/ears/earmuffs))//only the true power of earmuffs may block the power of the screech
			continue
		to_chat(M, span_userdanger("You freeze in terror, your blood turning cold from the sound of the scream!"))
		M.Stun(max(7/distance, 1))
	for(var/mob/living/silicon/M in T.contents)
		M.Paralyze(1 SECONDS)
	for(var/obj/machinery/light/L in range(7, user))
		L.set_light(0)

	return ..()
 