/obj/item/stack/tape
	name = "tape"
	singular_name = "tape"
	desc = "Used for sticking things together."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape_w"
	item_flags = NOBLUDGEON
	amount = 1
	max_amount = 5
	resistance_flags = FLAMMABLE
	grind_results = list(/datum/reagent/cellulose = 5)

/obj/item/stack/tape/attack(mob/living/M, mob/user)
	. = ..()
	if(user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		var/obj/item/clothing/mask/muzzle/tape/tape_muzzle = new()
		if(!tape_muzzle.mob_can_equip(M, null, SLOT_WEAR_MASK, TRUE, TRUE))
			to_chat(user, span_warning("You can't tape [M]'s mouth shut!"))
			return
		playsound(user, 'sound/effects/tape.ogg', 25)
		if(!do_after(user, 20, target = M))
			return
		if(!M.equip_to_slot_or_del(tape_muzzle, SLOT_WEAR_MASK, user))
			to_chat(user, span_warning("You fail tape [M]'s mouth shut!"))
			return
		use(1)

/obj/item/stack/tape/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !istype(target, /obj/item))
		return
	var/obj/item/I = target
	if(I.is_sharp())
		to_chat(user, span_warning("[I] would cut the tape if you tried to wrap it!"))
		return
	to_chat(user, span_info("You wrap [I] with [src]."))
	use(1)
	I.embedding = I.embedding.setRating(100, 10, 0, 0, 0, 0, 0, 0, TRUE)
	I.taped = TRUE
