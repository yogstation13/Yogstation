/mob/living/simple_animal/hunter
	name = "hunter demon"
	real_name = "hunter demon"
	desc = "A large, armored creature emmitting unholy energies."
	speak_emote = list("declares")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "hunter_daemon"
	icon_living = "hunter_daemon"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	damage_coeff = list(BRUTE = 1, BURN = 0.75, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	speed = 0
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	deathsound = 'sound/magic/demon_dies.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	faction = list("slaughter")
	attacktext = "rips and tears"
	maxHealth = 125
	health = 125
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage_lower = 25
	melee_damage_upper = 25
	see_in_dark = 4
	bloodcrawl = BLOODCRAWL_EAT
	var/playstyle_string = "<span class='big bold'>You are a hunter demon,</span><B> a terrible creature from another realm.  \
							You may use the \"Jaunt\" ability to dissapear from reality and allow you to move to almost any place. \
							You can return to the mortal plane only near the bloody orb that summonned you or near your target. \
							Your target is chosen in the bloody orb by a human, and if it isn't protected with a blood ritual you can also pick a target for yourself! \
             	 			Your orb has two blood counters: one that stands for blood, obtained through the blood ritual(while your or has such you can't choose a target yourelf),\
              				and a summary blood counter, that is obtained by attacking humans AND by the blood ritual. It is used to heal you.\
              				While not near the orb or your target you are slower, and loose health. If you will kill 8 targets, you will ascend, making you no more bound to the orb!</B>"
	del_on_death = 1
	deathmessage = "collapses, as it's bound with the mortal reality plain weakens!"
	var/obj/structure/bloody_orb/orb
	var/mob/living/carbon/human/prey
	var/mob/living/last_target
	var/attack_streak

/mob/living/simple_animal/hunter/AttackingTarget()
	if(isliving(target))
		if(last_target != target)
			attack_streak = 0
	if(prey==target)
		var/mob/living/carbon/human/dude = target
		if(dude.stat != UNCONSCIOUS && dude.stat != DEAD)
			if(HAS_TRAIT(dude, TRAIT_NODISMEMBER))
				return ..()
			if(prob(20) + attack_streak*10)
				var/list/parts = list()
				var/undismembermerable_limbs = 0
				for(var/X in dude.bodyparts)
					var/obj/item/bodypart/BP = X
					if(BP.body_part != HEAD && BP.body_part != CHEST)
						if(BP.dismemberable)
							parts += BP
						else
							undismembermerable_limbs++

				if(!LAZYLEN(parts))
					if(undismembermerable_limbs)
						return ..()
					dude.Paralyze(100)
					visible_message(span_danger("[src] knocks [dude] down!"))
					return FALSE
				do_attack_animation(dude)
				var/obj/item/bodypart/BP = pick(parts)
				BP.dismember()
				return FALSE

	.=..()
	if((isliving(target)))
			heal_bodypart_damage(5)
	




