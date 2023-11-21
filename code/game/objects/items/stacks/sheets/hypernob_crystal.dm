/obj/item/stack/hypernoblium_crystal
	name = "hypernoblium crystal"
	desc = "Crystalized bz, oxygen and hypernoblium stored in a bottle to environmental proof your clothes."
	icon_state = "hypernoblium_crystal"
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF | UNACIDABLE
	grind_results = list(/datum/reagent/hypernoblium = 20)
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
		to_chat(user, span_notice("You crush [src] against [worn_item], making it resistant to nearly all hazardous environmnents."))
		worn_item.name = "environmental-proof [worn_item.name]"
		worn_item.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		worn_item.add_atom_colour("#00fff7", FIXED_COLOUR_PRIORITY)
		worn_item.cold_protection |= CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
		worn_item.heat_protection |= CHEST|GROIN|LEGS|FEET|ARMS|HANDS|HEAD
		worn_item.max_heat_protection_temperature = INFINITY
		worn_item.min_cold_protection_temperature = -INFINITY
		worn_item.resistance_flags |= FIRE_PROOF|ACID_PROOF|FREEZE_PROOF
	amount--
	if(amount<1)
		qdel(src)

/obj/item/stack/antinoblium_crystal
	name = "Antinoblium Crystal"
	desc = "Crystalized antinoblium, bz, and plasma. An incredibly volatile material."
	icon_state = "antinoblium_crystal"
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF | UNACIDABLE
	grind_results = list(/datum/reagent/antinoblium = 20)
	merge_type = /obj/item/stack/antinoblium_crystal
