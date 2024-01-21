/datum/crafting_recipe/skin_twister_cloak
	name = "Skin-twister cloak"
	result = /obj/item/clothing/neck/yogs/skin_twister
	reqs = list(/obj/item/stack/sheet/skin_twister = 6, /obj/item/stack/sheet/meduracha = 2)
	time = 10 SECONDS
	category = CAT_PRIMAL

/datum/crafting_recipe/stinger_sword
	name = "Stinger Sword"
	result = /obj/item/melee/stinger_sword
	reqs = list(/obj/item/stinger = 1, /obj/item/stack/rods =  2, /obj/item/stack/sheet/slime = 4)
	time = 6 SECONDS
	category = CAT_PRIMAL

/datum/crafting_recipe/slime_sling
	name = "Slime sling"
	result = /obj/item/slime_sling
	reqs = list(/obj/item/stack/sheet/slime = 16, /obj/item/stack/sheet/meduracha = 2)
	time = 6 SECONDS
	category = CAT_PRIMAL

/datum/crafting_recipe/tar_crystal
	name = "Ominous Crystal"
	result = /obj/item/full_tar_crystal
	reqs = list(/obj/item/tar_crystal = 3)
	time = 20 SECONDS
	category = CAT_PRIMAL

/datum/crafting_recipe/stinger_trident
	name = "Stinger Trident"
	result = /obj/item/stinger_trident
	reqs = list(/obj/item/stack/sheet/meduracha = 2,
				/obj/item/stinger  = 3,
				/obj/item/stack/rods = 4)
	parts = list(/obj/item/shard = 1)
	time = 6 SECONDS
	category = CAT_PRIMAL
