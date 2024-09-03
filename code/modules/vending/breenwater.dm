/obj/machinery/vending/breenwater
	name = "\improper Breen's Private Reserve"
	desc = "The finest, most pure water around."
	icon_state = "breen_machine"
	panel_type = "panel2"
	product_ads = "Stay hydrated.;A thirsty citizen is a inefficient citizen.;Drink Breen's private reserve!;The purest water around."
	products = list(/obj/item/reagent_containers/food/drinks/soda_cans/breenwater = 30)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/breen
	default_price = 5
	extra_price = 1
	payment_department = NO_FREEBIES

/obj/item/vending_refill/breen
	machine_name = "Breen's Private Reserve"
	icon_state = "refill_cola"
