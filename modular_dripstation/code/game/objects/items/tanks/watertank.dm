/obj/item/reagent_containers/spray/mister/janitor
	possible_transfer_amounts = list(5, 10)

/obj/item/reagent_containers/spray/mister/janitor/attack_self(var/mob/user)
	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, span_notice("You [amount_per_transfer_from_this == 10 ? "remove" : "affix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray."))