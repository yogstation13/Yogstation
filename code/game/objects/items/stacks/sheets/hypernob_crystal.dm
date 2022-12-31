/obj/item/stack/hypernoblium_crystal
	name = "Hypernoblium Crystal"
	desc = "Crystalized bz, oxygen and hypernoblium stored in a bottle to environmental proof your clothes."
	icon_state = "hypernoblium_crystal"
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF | UNACIDABLE
	merge_type = /obj/item/stack/hypernoblium_crystal

/obj/item/stack/hypernoblium_crystal/afterattack(obj/target_object, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	var/obj/item/clothing/worn_item = target_object
	if(!istype(worn_item))
		to_chat(user, span_warning("The crystal can only be used on clothing!"))
		return
	if(istype(worn_item))
		if(!(worn_item.clothing_flags & STOPSPRESSUREDAMAGE))
			worn_item.clothing_flags |= STOPSPRESSUREDAMAGE
		if(!(worn_item.clothing_flags & THICKMATERIAL))
			worn_item.clothing_flags |= THICKMATERIAL
		if(istype(worn_item, /obj/item/clothing/under))
			to_chat(user, span_notice("Cannot apply \the [src] to this type of clothing!"))
			return
		to_chat(user, span_notice("You see how the [worn_item] changes color, it's now environmental proof."))
		worn_item.name = "environmental-proof [worn_item.name]"
		worn_item.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		worn_item.add_atom_colour("#00fff7", FIXED_COLOUR_PRIORITY)
		worn_item.cold_protection |= CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
		worn_item.heat_protection |= CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
		worn_item.body_parts_covered |= CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
		worn_item.flags_prot |= HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
		worn_item.max_heat_protection_temperature = 1e31
		worn_item.min_cold_protection_temperature = -1e31
		worn_item.resistance_flags |= FIRE_PROOF|ACID_PROOF|FREEZE_PROOF
	amount--
	if(amount<1)
		qdel(src)
