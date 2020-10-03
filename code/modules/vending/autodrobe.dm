/obj/machinery/vending/autodrobe
	name = "\improper Paperdrobe"
	desc = "A vending machine for removing fun."
	icon_state = "theater"
	icon_deny = "theater-deny"
	req_access = list(ACCESS_THEATRE)
	product_slogans = "Get back to work, slave!;Paperwork is love. Paperwork is life.;I love roleplay.;THIS IS GOOD FOR MRP BECAUSE"
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/camera_film = 3,
					/obj/item/hand_labeler = 2,
					/obj/item/hand_labeler_refill = 2,
					/obj/item/paper_bin = 3,
					/obj/item/pen/fourcolor = 3,					
					/obj/item/pen = 6,
					/obj/item/pen/fountain = 3,
					/obj/item/pen/blue = 2,
					/obj/item/pen/red = 2,
					/obj/item/folder/blue = 1,
					/obj/item/folder/red = 1,
					/obj/item/folder/yellow = 1,
					/obj/item/clipboard = 4,
					/obj/item/stamp = 2,
					/obj/item/stamp/denied = 2,
					/obj/item/laser_pointer/purple = 1)
	refill_canister = /obj/item/vending_refill/autodrobe
	default_price = 50
	extra_price = 75
	payment_department = ACCOUNT_SRV

/obj/machinery/vending/autodrobe/canLoadItem(obj/item/I,mob/user)
	return (I.type in products)

/obj/machinery/vending/autodrobe/all_access
	desc = "A vending machine for costumes. This model appears to have no access restrictions."
	req_access = null

/obj/item/vending_refill/autodrobe
	machine_name = "AutoDrobe"
	icon_state = "refill_costume"

/obj/machinery/vending/autodrobe/capdrobe
	name = "\improper CapDrobe"
	desc = "A vending machine for captain outfits."
	icon_state = "capdrobe"
	icon_deny = "capdrobe-deny"
	req_access = list(ACCESS_CAPTAIN)
	product_slogans = "Dress for success!;Suited and booted!;It's show time!;Why leave style up to fate? Use the Captain's Autodrobe!"
	vend_reply = "Thank you for using the Captain's Autodrobe!"
	products = list(/obj/item/clothing/suit/hooded/wintercoat/captain = 1,
					/obj/item/storage/backpack/captain = 1,
					/obj/item/storage/backpack/satchel/cap = 1,
					/obj/item/storage/backpack/duffelbag/captain = 1,
					/obj/item/clothing/neck/cloak/cap = 1,
					/obj/item/clothing/shoes/sneakers/brown = 1,
					/obj/item/clothing/under/rank/captain = 1,
					/obj/item/clothing/under/rank/captain/skirt = 1,
					/obj/item/clothing/suit/armor/vest/capcarapace = 1,
					/obj/item/clothing/head/caphat = 1,
					/obj/item/clothing/under/captainparade = 1,
					/obj/item/clothing/suit/armor/vest/capcarapace/alt = 1,
					/obj/item/clothing/head/caphat/parade = 1,
					/obj/item/clothing/suit/captunic = 1,
					/obj/item/clothing/glasses/sunglasses/gar/supergar = 1,
					/obj/item/clothing/gloves/color/captain = 1,
					/obj/item/clothing/under/yogs/captainartillery = 1,
					/obj/item/clothing/under/yogs/casualcaptain = 1,
					/obj/item/clothing/under/yogs/whitecaptainsuit = 1,
					/obj/item/clothing/head/yogs/whitecaptaincap = 1,
					/obj/item/clothing/under/yogs/victoriouscaptainuniform = 1,
					/obj/item/clothing/head/beret/captain = 1)
	premium = list(/obj/item/clothing/head/crown/fancy = 1)

	default_price = 50
	extra_price = 75
	payment_department = ACCOUNT_SEC
