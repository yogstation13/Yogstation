/obj/item/amogus_potion
	name = "strange flask"
	desc = "A strange flask with red liquid inside of it, with the label \"do not drink at 3AM\" on its surface. Drinking this is probably not a good idea."
	icon = 'monkestation/icons/obj/misc.dmi'
	icon_state = "amogus_potion"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/amogus_potion/attack_self(mob/user, modifiers)
	. = ..()
	var/mob/living/carbon/human/impostor = user
	if(!istype(impostor))
		to_chat(impostor, span_userdanger("You know better than to drink it..."))
		return

	if(!ismonkey(impostor) && !isgoblin(impostor))
		impostor.visible_message(span_notice("[impostor] drinks the strange red liquid from [src] as they shrink!"), span_notice("You drink [src]."))
		to_chat(impostor, span_userdanger("You have a strange feeling as the world seems to grow around you!"))
		impostor.apply_displacement_icon(/obj/effect/distortion/large/amogus)
	else
		impostor.visible_message(span_notice("[impostor] drinks the strange red liquid from [src]!"), span_notice("You drink [src]."))
		to_chat(impostor, span_userdanger("You feel strange..."))

	impostor.AddElement(/datum/element/waddling)
	impostor.can_be_held = TRUE
	to_chat(impostor, span_notice("You can now be picked up by other people."))
	qdel(src)
