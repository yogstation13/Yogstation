/obj/item/projectile/beam/anoxia
	name = "anoxia ray"
	icon_state = "flayerlaser"
	damage = 8
	damage_type = OXY //stop oxygen from being correctly processed by your cells.
	flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_LAVENDER
	eyeblur = 0

/obj/item/projectile/beam/anoxia/mindflayer
	name = "flayer ray"
	damage = 8

/obj/item/projectile/beam/anoxia/mindflayer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		var/current_oxygen_damage = M.getOxyLoss()
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, current_oxygen_damage) //the more oxygen damage you have the more brain damage you get
		M.hallucination = max(50, M.hallucination) //50 hallucination (5 seconds) when the target get hit but you can't stack it to make someone hallucinate for 5 hours because door shock hallucination exist

/obj/item/projectile/beam/anoxia/bounce
	name = "bouncing anoxia ball"
	icon_state = "flayerbouncer"
	damage = 6
	ricochets_max = 5
	ricochet_chance = 100

/obj/item/projectile/beam/anoxia/bounce/check_ricochet_flag(atom/A)
	return TRUE //whatever it is, we bounce on it