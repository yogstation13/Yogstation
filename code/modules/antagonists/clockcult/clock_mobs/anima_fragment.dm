/mob/living/simple_animal/hostile/clockwork/anima_fragment
	name = "anima fragment"
	desc = "An ominous humanoid shell with a spinning cogwheel as its head, lifted by a jet of blazing red flame."
	icon_state = "anime_fragment" //Oh fuck
	mob_biotypes = list(MOB_INORGANIC, MOB_HUMANOID)
	health = 75 //Glass cannon
	maxHealth = 75
	attacktext = "slashes"
	attack_vis_effect = ATTACK_EFFECT_CLAW
	attack_sound = 'sound/magic/clockwork/anima_fragment_attack.ogg'
	melee_damage_lower = 20
	melee_damage_upper = 20
	deathsound = 'sound/magic/clockwork/anima_fragment_death.ogg'
	playstyle_string = "<span class='heavy_brass'>You are an anima fragment</span><b>, a clockwork creation of Ratvar. As a fragment, you are weak but possess powerful melee capabilities \
	in addition to being immune to extreme temperatures and pressures. Your goal is to serve the Justiciar and his servants in any way you can.</b>"
	empower_string = null

/mob/living/simple_animal/hostile/clockwork/anima_fragment/death(gibbed)
	visible_message(span_warning("[src]'s flame jets cut out as it falls to the floor with a tremendous crash. A cube of metal tumbles out, whirring and sputtering."), \
	span_userdanger("Your gears seize up. Your flame jets flicker. Your soul vessel belches smoke as you helplessly crash down."))
	new/obj/item/mmi/posibrain/soul_vessel(get_turf(src)) //An empty soul vessel
	return ..()