/obj/effect/proc_holder/spell/targeted/shapeshift/demon //emergency get out of jail card.
	name = "Lesser Demon Form"
	desc = "Take on your true demon form. This form is strong but very obvious, and especially weak to holy influence. \
	Also, note that damage taken in this form can transform into your normal body. Heal by attacking living creatures before transforming back if gravely wounded!"
	invocation = "COWER, MORTALS!!"
	shapeshift_type = /mob/living/simple_animal/lesserdemon
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "daemontransform"
	action_background_icon_state = "bg_demon"

/mob/living/simple_animal/lesserdemon
	name = "demon"
	real_name = "demon"
	desc = "A large, menacing creature covered in armored red scales."
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "lesserdaemon"
	icon_living = "lesserdaemon"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	speed = 0.33
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	deathmessage = "wails in anger and fear as it collapses in defeat!"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("hell")
	attacktext = "wildly tears into"
	maxHealth = 200
	health = 200
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage_lower = 24
	melee_damage_upper = 24
	wound_bonus = -15
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	loot = (/obj/effect/decal/cleanable/blood)
	del_on_death = TRUE

/mob/living/simple_animal/lesserdemon/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(istype(W, /obj/item/nullrod))
		visible_message(span_warning("[src] screams in unholy pain from the blow!"), \
						span_cult("As \the [W] hits you, you feel holy power blast through your form, tearing it apart!"))
		adjustBruteLoss(22) //22 extra damage from the nullrod while in your true form. On average this means 40 damage is taken now.

/mob/living/simple_animal/lesserdemon/UnarmedAttack(mob/living/L, proximity)//10 hp healed from landing a hit.
	if(isliving(L))
		if(L.stat != DEAD && !L.anti_magic_check(TRUE, TRUE)) //demons do not gain succor from the dead or holy 
			adjustHealth(-maxHealth * 0.05)
	return ..()

/mob/living/simple_animal/lesserdemon/Life()
	. = ..()
	if(!src)
		return
	if(istype(get_area(src.loc), /area/chapel)) //being a non-carbon will not save you!
		if(src.stat != DEAD) //being dead, however, will save you
			src.visible_message(span_warning("[src] begins to melt apart!"), span_danger("Your very soul melts from the holy room!"), "You hear sizzling.")
			adjustHealth(20) //20 damage every ~2 seconds. About 20 seconds for a full HP demon to melt apart in the chapel.
