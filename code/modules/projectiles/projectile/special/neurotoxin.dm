/obj/item/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	paralyze = 100

/obj/item/projectile/bullet/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		paralyze = 0
		nodamage = TRUE
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/I = C.get_item_by_slot(ITEM_SLOT_OCLOTHING)
			if(istype(I, /obj/item/clothing/suit/space/hardsuit))  ///If you are wearing a hardsuit you don't give a fuck about it!
				paralyze = 0
				nodamage = TRUE				
	return ..()
