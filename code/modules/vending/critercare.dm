/obj/item/vending_refill/crittercare
	machine_name = "CritterCare"
	icon_state = "refill_pet"

/obj/machinery/vending/crittercare
	name = "\improper CritterCare"
	desc = "A vending machine for pet supplies."
	product_slogans = list("Stop by for all your animal's needs!","Cuddly pets deserve a stylish collar!","Pets in space, what could be more adorable?","Freshest fish eggs in the system!","Rocks are the perfect pet, buy one today!")
	product_ads = "House-training costs extra!; Now with 1000% more cat hair!; Allergies are a sign of weakness!"
	icon_state = "crittercare"
	products = list(/obj/item/clothing/neck/petcollar = 5, /obj/item/storage/firstaid/aquatic_kit/full =5, /obj/item/fish_eggs/goldfish = 5,
					/obj/item/fish_eggs/clownfish = 5, /obj/item/fish_eggs/shark = 5, /obj/item/fish_eggs/feederfish = 10,
					/obj/item/fish_eggs/salmon = 5, /obj/item/fish_eggs/catfish = 5, /obj/item/fish_eggs/glofish = 5,
					/obj/item/fish_eggs/electric_eel = 5, /obj/item/fish_eggs/shrimp = 10,)

	contraband = list(/obj/item/fish_eggs/babycarp = 5)
	refill_canister = /obj/item/vending_refill/crittercare
	default_price = 10
	extra_price = 50
