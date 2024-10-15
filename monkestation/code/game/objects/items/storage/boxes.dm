/obj/item/storage/box/disks_nanite
	name = "nanite program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/nanite_program(src)

/obj/item/storage/fancy/popsiclestick_pack
	name = "popsicle stick pack"
	desc = "A pack of ethically-sourced popsicle sticks, great for medical examinations or iced treats! Comes in a modest pack of 6, for wood is quite a scarcity on space stations."
	icon = 'monkestation/icons/obj/popsiclestick_pack.dmi'
	icon_state = "popsiclepack6"
	base_icon_state = "popsiclepack"
	inhand_icon_state = null
	worn_icon_state = null
	spawn_type = /obj/item/popsicle_stick
	slot_flags = ITEM_SLOT_POCKETS
	spawn_count = 6
	open_status = FANCY_CONTAINER_ALWAYS_OPEN
	contents_tag = "popsicle stick"
	custom_price = PAYCHECK_COMMAND //Makes price 100, 20 for the chef - Only the most premium popsicle sticks

/obj/item/storage/fancy/popsiclestick_pack/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/popsicle_stick))

/obj/item/storage/box/pillbottles/psych_pills
	name = "Box of psychiatric pills bottles"
	desc = "A box full of pills bottles for various psychiartic uses"

/obj/item/storage/box/pillbottles/psych_pills/PopulateContents()
	var/static/items_inside = list(
		/obj/item/storage/pill_bottle/happinesspsych = 1,
		/obj/item/storage/pill_bottle/lsdpsych = 1,
		/obj/item/storage/pill_bottle/mannitol = 1,
		/obj/item/storage/pill_bottle/paxpsych = 1,
		/obj/item/storage/pill_bottle/psicodine = 1,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/nanitecontrol
	name = "Nanite Controller Box"
	illustration = "disk_kit"

/obj/item/storage/box/nanitecontrol/PopulateContents()
	new /obj/item/nanite_remote(src)
	new /obj/item/nanite_remote(src)
	new /obj/item/nanite_remote(src)
	new /obj/item/nanite_scanner(src)
	new /obj/item/nanite_scanner(src)
	new /obj/item/nanite_scanner(src)
	///obj/item/nanite_injector(src)
	//coded out as its been on blueshift and noones had issues with it but there probably should be a discussion before added everywhere.
