/obj/machinery/vending/rationvendor
	name = "\improper Ration Vendor"
	desc = "High grade, deliciously flavored rations are sold here at an affordable price."
	icon_state = "ration_dispenser"
	panel_type = "panel2"
	product_ads = "Stay nutritionally satisfied.;A hungry citizen is a inefficient citizen.;Consume delicious rations.;The most flavorful food around."
	products = list(/obj/item/storage/box/halflife/ration = 10)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/ration
	default_price = 40
	extra_price = 1
	payment_department = NO_FREEBIES

/obj/item/vending_refill/ration
	machine_name = "Ration Vendor"
	icon_state = "refill_cola"
