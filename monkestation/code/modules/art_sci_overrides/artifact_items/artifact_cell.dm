/obj/item/stock_parts/cell/artifact
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	ratingdesc = FALSE
	charge_light_type = null
	obj_flags = CAN_BE_HIT
	var/datum/component/artifact/assoc_comp = /datum/component/artifact

ARTIFACT_SETUP(/obj/item/stock_parts/cell/artifact, SSobj, null, /datum/artifact_effect/cell, ARTIFACT_SIZE_TINY)

/obj/item/stock_parts/cell/artifact/use(amount, force) //dont use power unless active
	. = FALSE
	if(assoc_comp.active)
		return ..()

/obj/item/stock_parts/cell/artifact/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user,span_notice("You squeeze the [src] tightly."))
	on_artifact_touched(src,user,modifiers)
