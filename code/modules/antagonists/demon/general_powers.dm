/datum/action/cooldown/spell/shapeshift/demon //emergency get out of jail card.
	name = "Lesser Demon Form"
	desc = "Take on your true demon form. This form is strong but very obvious. It's full demonic nature in this realm is taxing on you \
	and you will slowly lose life while in this form, while also being especially weak to holy influences. \
	Be aware low health transfers between forms. If gravely wounded, attack live mortals to siphon life energy from them!"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "daemontransform"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	invocation = "COWER, MORTALS!!"

	possible_shapes = list(/mob/living/simple_animal/lesserdemon)
	spell_requirements = NONE

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
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speed = 0.25
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
	melee_damage_lower = 20
	melee_damage_upper = 20
	wound_bonus = -15
	lighting_cutoff_red = 22
	lighting_cutoff_green = 5
	lighting_cutoff_blue = 5
	loot = (/obj/effect/decal/cleanable/blood)
	del_on_death = TRUE

/mob/living/simple_animal/lesserdemon/attackby(obj/item/W, mob/living/caster, params)
	. = ..()
	if(istype(W, /obj/item/nullrod))
		visible_message(span_warning("[src] screams in unholy pain from the blow!"), \
						span_cult("As \the [W] hits you, you feel holy power blast through your form, tearing it apart!"))
		adjustBruteLoss(22) //22 extra damage from the nullrod while in your true form. On average this means 40 damage is taken now.

/mob/living/simple_animal/lesserdemon/UnarmedAttack(mob/living/L, proximity)//10 hp healed from landing a hit.
	if(isliving(L))
		if(L.stat != DEAD && !L.can_block_magic(MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND)) //demons do not gain succor from the dead or holy 
			adjustHealth(-maxHealth * 0.05)
	return ..()

/mob/living/simple_animal/lesserdemon/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(!src)
		return
	if(istype(get_area(src.loc), /area/chapel)) //being a non-carbon will not save you!
		if(src.stat != DEAD) //being dead, however, will save you
			src.visible_message(span_warning("[src] begins to melt apart!"), span_danger("Your very soul melts from the holy room!"), "You hear sizzling.")
			adjustHealth(20) //20 damage every ~2 seconds. About 20 seconds for a full HP demon to melt apart in the chapel.

/mob/living/simple_animal/lesserdemon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/life_draining, damage_overtime = 2)

//not really a general power, but more than 1 sin has it
/datum/action/cooldown/spell/touch/torment
	name = "Torment"
	desc = "Engulfs your arm in a vindictive might. Striking someone with it will severely debilitate them, though will cause no visible damage."
	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	button_icon_state = "mutate"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	
	school = SCHOOL_EVOCATION
	invocation = "TORMENT"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 20 SECONDS
	spell_requirements = NONE

	hand_path = /obj/item/melee/touch_attack/torment
	

/obj/item/melee/touch_attack/torment
	name = "Vindictive Hand"
	desc = "An utterly scornful mass of hateful energy, ready to strike."
	icon_state = "flagellation"
	item_state = "hivemind"

/datum/action/cooldown/spell/touch/torment/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	if(victim.can_block_magic())
		to_chat(caster, span_warning("[victim] resists your torment!"))
		to_chat(victim, span_warning("A hideous feeling of agony dances around your mind before being suddenly dispelled."))
		..()
		return TRUE
	playsound(caster, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	victim.adjust_eye_blur(15) //huge array of relatively minor effects.
	victim.adjust_jitter(5 SECONDS)
	victim.set_confusion_if_lower(5 SECONDS)
	victim.adjust_disgust(40)
	victim.adjust_hallucinations(20 SECONDS)
	victim.Immobilize(3 SECONDS)
	victim.Stun(1 SECONDS)
	victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)
	victim.visible_message(span_danger("[victim] cringes in pain as they hold their head for a second!"))
	victim.emote("scream")
	to_chat(victim, span_warning("You feel an explosion of pain erupt in your mind!"))
	return TRUE

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/sin
	name = "Demonic Jaunt"
	desc = "Briefly turn to cinder and ash, allowing you to freely pass through objects."
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	sound = 'sound/magic/fireball.ogg'
	spell_requirements = NONE

	cooldown_time = 50 SECONDS

	jaunt_duration = 3 SECONDS
	jaunt_out_time = 0.5 SECONDS
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/ash_shift
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/ash_shift/out
