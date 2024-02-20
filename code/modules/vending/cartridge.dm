//This one's from bay12
/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDAs."
	product_slogans = "Carts to go!"
	icon_state = "cart"
	icon_deny = "cart-deny"
	products = list(/obj/item/modular_computer/tablet/pda/preset = 10)//honestly, this feels dumb, but okay
	refill_canister = /obj/item/vending_refill/cart
	default_price = 50
	extra_price = 100
	payment_department = ACCOUNT_SRV

/obj/item/vending_refill/cart
	machine_name = "PTech"
	icon_state = "refill_smoke"

