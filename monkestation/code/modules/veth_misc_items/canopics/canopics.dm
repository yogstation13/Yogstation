//canopic box sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_box
	name = "Canopic Box"
	desc = "An ornate stone box inscribed with ancient hieroglyphs."
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic_box.dmi'
	icon_state = "canopic_box"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
	illustration = FALSE

/datum/crafting_recipe/canopic_box
	name = "Canopic box"
	result = /obj/item/storage/box/canopic_box
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 5,
		/obj/item/stack/sheet/mineral/wood = 10,
		/obj/item/stack/sheet/leather = 2,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS

//jackal canopic sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_jackal/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.set_holdable(list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
		))
	atom_storage.exception_hold = list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
		)
	atom_storage.can_hold = typecacheof(/obj/item/organ/internal)
	atom_storage.can_hold_description = "This jar can hold organs!"
	atom_storage.max_total_storage = WEIGHT_CLASS_TINY*10
	update_appearance()

/obj/item/storage/box/canopic_jackal
	name = "Jackal Canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	w_class = WEIGHT_CLASS_TINY
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic.dmi'
	icon_state = "canopic_jackal"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
	illustration = FALSE

/datum/crafting_recipe/canopic_jackal
	name = "Jackal Canopic jar"
	result = /obj/item/storage/box/canopic_jackal
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS
//human canopic sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_human
	name = "Human Canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	w_class = WEIGHT_CLASS_TINY
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic.dmi'
	icon_state = "canopic_human"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
	illustration = FALSE
/obj/item/storage/box/canopic_human/Initialize(mapload)
	. = ..()

	atom_storage.max_slots = 1
	atom_storage.set_holdable(list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
		))
	atom_storage.exception_hold = list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
		)
	atom_storage.can_hold = typecacheof(/obj/item/organ/internal)
	atom_storage.can_hold_description = "This jar can hold organs!"
	atom_storage.max_total_storage = WEIGHT_CLASS_TINY*10
	update_appearance()

/datum/crafting_recipe/canopic_human
	name = "Human Canopic jar"
	result = /obj/item/storage/box/canopic_human
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS
//monke canopic sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_monke/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.set_holdable(list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
		))
	atom_storage.exception_hold = list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
		)
	atom_storage.can_hold = typecacheof(/obj/item/organ/internal)
	atom_storage.can_hold_description = "This jar can hold organs!"
	atom_storage.max_total_storage = WEIGHT_CLASS_TINY*10
	update_appearance()

/obj/item/storage/box/canopic_monke //creates the object
	name = "Monke canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	w_class = WEIGHT_CLASS_TINY
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic.dmi'
	icon_state = "canopic_monke"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
	illustration = FALSE

/datum/crafting_recipe/canopic_monke //creates the crafting recipe
	name = "Monke Canopic jar"
	result = /obj/item/storage/box/canopic_monke
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS



//hawk canopic sprited by twiggy, coded by veth
/obj/item/storage/box/canopic_hawk/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 1
	atom_storage.set_holdable(list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
		))
	atom_storage.exception_hold = list(
		/obj/item/organ/internal/heart,
		/obj/item/organ/internal/lungs,
		/obj/item/organ/internal/liver,
		/obj/item/organ/internal/appendix,
		/obj/item/organ/internal/tongue,
		/obj/item/organ/internal/eyes,
		/obj/item/organ/internal/stomach,
		/obj/item/organ/internal/ears,
		)
	atom_storage.can_hold = typecacheof(/obj/item/organ/internal)
	atom_storage.can_hold_description = "This jar can hold organs!"
	atom_storage.max_total_storage = WEIGHT_CLASS_TINY*10
	update_appearance()

/obj/item/storage/box/canopic_hawk //creates the object
	name = "Hawk Canopic jar"
	desc = "An ornate stone canopic, inscribed with ancient hieroglyphs. These used to be used to store organs."
	w_class = WEIGHT_CLASS_TINY
	icon = 'monkestation/code/modules/veth_misc_items/canopics/icons/canopic.dmi'
	icon_state = "canopic_hawk"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FIRE_PROOF
	drop_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_drop.ogg'
	pickup_sound = 'monkestation/code/modules/veth_misc_items/canopics/sounds/canopic_pickup.ogg'
	foldable_result = FALSE
	illustration = FALSE
/datum/crafting_recipe/canopic_hawk //creates the crafting recipe
	name = "hawk canopic jar"
	result = /obj/item/storage/box/canopic_hawk
	time = 2 SECONDS
	tool_paths = FALSE
	reqs = list(
		/obj/item/stack/sheet/sandblock = 1,
		/obj/item/stack/sheet/mineral/wood = 1,
		/obj/item/stack/sheet/leather = 1,
		/obj/item/stack/sheet/mineral/gold = 1,
		/obj/item/stack/sheet/mineral/silver = 1)
	category = CAT_CONTAINERS

/obj/item/storage/box/canopic_box/stocked

/obj/item/storage/box/canopic_box/stocked/PopulateContents()
	var/static/items_inside = list(
		/obj/item/storage/box/canopic_hawk = 1,
		/obj/item/storage/box/canopic_human = 1,
		/obj/item/storage/box/canopic_monke = 1,
		/obj/item/storage/box/canopic_jackal = 1)
	generate_items_inside(items_inside,src)
