/obj/item/artifact_item
	//This is literally just an artifact, but item sized for item generation of traits that require it.

	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	icon = 'icons/obj/artifacts.dmi'
	inhand_icon_state = "plasmashiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	obj_flags = CAN_BE_HIT
	var/datum/component/artifact/assoc_comp = /datum/component/artifact

ARTIFACT_SETUP(/obj/item/artifact_item, SSobj, null, null, ARTIFACT_SIZE_SMALL)

/obj/item/artifact_item/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user,span_notice("You squeeze the [src] tightly."))
	on_artifact_touched(src,user,modifiers)


/obj/item/artifact_item_tiny
	//This is literally just an artifact, but s m o l for item generation of traits that require it.

	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	icon = 'icons/obj/artifacts.dmi'
	var/datum/component/artifact/assoc_comp = /datum/component/artifact
	obj_flags = CAN_BE_HIT

ARTIFACT_SETUP(/obj/item/artifact_item_tiny, SSobj, null, null, ARTIFACT_SIZE_TINY)

/obj/item/artifact_item_tiny/attack_self(mob/user, modifiers)
	. = ..()
	to_chat(user,span_notice("You squeeze the [src] tightly."))
	on_artifact_touched(src,user,modifiers)
