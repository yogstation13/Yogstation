// Clothing //

/datum/crafting_recipe/durathread_vest
	name = "Durathread Vest"
	result = /obj/item/clothing/suit/armor/vest/durathread
	reqs = list(/obj/item/stack/sheet/cloth/durathread = 5,
				/obj/item/stack/sheet/leather = 4)
	time = 5 SECONDS
	category = CAT_ARMOR
	
/datum/crafting_recipe/durathread_jumpsuit
	name = "Durathread Jumpsuit"
	result = /obj/item/clothing/under/rank/civilian/hydroponics/durathread
	reqs = list(/obj/item/stack/sheet/cloth/durathread = 4)
	time = 4 SECONDS
	category = CAT_CLOTHING // Can be technically considered armor since it gives protection (similar-ish to security jumpsuit).

//armor up a citizen uniform and remove the scanners
/datum/crafting_recipe/rebel_uniform
	name = "Rebel Jumpsuit"
	result = /obj/item/clothing/under/citizen/rebel
	reqs = list(/obj/item/clothing/under/citizen = 1,
				/obj/item/clothing/under/combine/civilprotection = 1)
	time = 10 SECONDS
	category = CAT_CLOTHING
