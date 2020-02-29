//Chaplain's Null Rod Holopara
/mob/living/simple_animal/hostile/guardian/chaplain
	a_intent = INTENT_HARM
	friendly = "heals"
	speed = 0
	damage_coeff = list(BRUTE = 0.9, BURN = 0.9, TOX = 0.9, CLONE = 0.9, STAMINA = 0, OXY = 0.9)
	obj_damage = 10
	melee_damage_lower = 10
	melee_damage_upper = 10
	playstyle_string = "<span class='holoparasite'>As the Chaplain's <b>support</b> holyparasite, you may toggle your basic attacks to a healing mode.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the Sun, XIX. Upon closer inspection, all of the cards are the same. What a rip-off.</span>"
	toggle_button_type = /obj/screen/guardian/ToggleMode
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/chaplain/Initialize()
	. = ..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)
	ADD_TRAIT(src, TRAIT_HOLY, SPECIES_TRAIT)

/mob/living/simple_animal/hostile/guardian/chaplain/AttackingTarget()
	. = ..()
	if(is_deployed() && toggle && iscarbon(target))
		var/mob/living/carbon/C = target
		if(C == summoner)
			return
		else
			C.adjustBruteLoss(-2.5)
			C.adjustFireLoss(-2.5)
			C.adjustOxyLoss(-2.5)
			C.adjustToxLoss(-2.5)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(C))
			if(namedatum)
				H.color = namedatum.colour

/mob/living/simple_animal/hostile/guardian/chaplain/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			a_intent = INTENT_HARM
			speed = 0
			damage_coeff = list(BRUTE = 0.9, BURN = 0.9, TOX = 0.9, CLONE = 0.9, STAMINA = 0, OXY = 0.9)
			obj_damage = 10
			melee_damage_lower = 10
			melee_damage_upper = 10
			to_chat(src, "<span class='danger'><B>You switch to combat mode.</span></B>")
			toggle = FALSE
		else
			a_intent = INTENT_HELP
			speed = 1
			damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			obj_damage = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			to_chat(src, "<span class='danger'><B>You switch to healing mode.</span></B>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")
