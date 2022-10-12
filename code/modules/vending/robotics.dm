//This one's from bay12
/obj/machinery/vending/robotics
	name = "\improper Robotech Deluxe"
	desc = "All the tools you need to create your own robot army."
	icon_state = "robotics"
	icon_deny = "robotics-deny"
	req_access = list(ACCESS_ROBOTICS)
	products = list(/obj/item/stack/cable_coil = 4,
					/obj/item/assembly/flash/handheld = 6,
					/obj/item/stock_parts/cell/high = 2,
					/obj/item/assembly/prox_sensor = 6,
					/obj/item/assembly/signaler = 3,
					/obj/item/healthanalyzer = 3,
					/obj/item/storage/firstaid/regular/empty = 3,
					/obj/item/reagent_containers/glass/bucket = 3,
					/obj/item/ipcrevive = 2)
	refill_canister = /obj/item/vending_refill/robotics
	default_price = 50
	extra_price = 75
	payment_department = ACCOUNT_SCI

/obj/item/vending_refill/robotics
	machine_name = "Robotech Deluxe"
	icon_state = "refill_engi"
