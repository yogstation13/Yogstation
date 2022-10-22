/obj/item/projectile/beam/mindflayer
	name = "flayer ray"
	damage = 10
	damage_type = STAMINA //this is not destroying your body, it's destroying your mind
	flag = ENERGY
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		var/current_stamina_damage = M.getStaminaLoss()
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, current_stamina_damage * 0.5) //the more stamina damage you have the more brain damage you get
		M.hallucination = max(20, M.hallucination) //20 hallucination when the target get hit but you can't stack it to make someone hallucinate for 5 hours because door shock hallucination exist
