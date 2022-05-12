/obj/item/money_printer
	name = "money printer"
	desc = "Highly illegal money counterfeiting device."
	w_class = WEIGHT_CLASS_GIGANTIC
	var/money_stacks_per_cycle = 5
	var/money_typepath_to_print = /obj/item/stack/spacecash/c1000
	var/cooldown_per_cycle = 120 SECONDS

	icon = 'yogstation/icons/obj/items.dmi'
	icon_state = "money_printer"

/obj/item/money_printer/Initialize()
	. = ..()
	name = pick("ruby", "diamond", "gold", "sapphire", "emerald", "VIP", "admin") + " " + name
	addtimer(CALLBACK(src, .proc/print), cooldown_per_cycle)

/obj/item/money_printer/proc/print()
	addtimer(CALLBACK(src, .proc/print), cooldown_per_cycle)

	if(isturf(loc))
		visible_message(span_warning("\The [src] spits out money!"))
	else
		visible_message(span_warning("\The [src] violently whirrs and rumbles as it tries to spit out money, but can't!"))
		return
	var/obj/item/stack/spacecash/printed_cash = new money_typepath_to_print(loc)
	if(istype(printed_cash))
		printed_cash.amount = money_stacks_per_cycle
		printed_cash.name = "counterfeit " + printed_cash.name
		printed_cash.throw_at(get_edge_target_turf(printed_cash, SOUTH), 100, 10)
