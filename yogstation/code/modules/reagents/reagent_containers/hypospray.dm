/obj/item/reagent_containers/autoinjector/mixi
	name = "QMC Libital Injector"
	desc = "A quick-mix capital combat injector loaded with libital."
	amount_per_transfer_from_this = 5
	icon_state = "combat_hypo"
	volume = 50
	list_reagents = list(/datum/reagent/medicine/c2/libital = 50)

/obj/item/reagent_containers/autoinjector/derm
	name = "QMC Aiuri Injector"
	desc = "A quick-mix capital combat injector loaded with aiuri."
	amount_per_transfer_from_this = 5
	icon_state = "combat_hypo"
	volume = 50
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 50)

/obj/item/reagent_containers/autoinjector/medipen/stimpack/large
	name = "stimpack injector"
	desc = "Contains three heavy doses of stimulants."
	icon = 'yogstation/icons/obj/syringe.dmi'
	icon_state = "stimpakpen"
	volume = 75
	amount_per_transfer_from_this = 25
	list_reagents = list(/datum/reagent/medicine/stimulants = 75)

/obj/item/reagent_containers/autoinjector/medipen/stimpack/large/update_icon()
	if(reagents.total_volume > 25)
		icon_state = initial(icon_state)
	else if(reagents.total_volume)
		icon_state = "[initial(icon_state)]25"
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/reagent_containers/autoinjector/medipen/stimpack/large/redpill
	name = "Red Pill injector"
	desc = "Contains two heavy doses of Red Pills (Stimulants)."
	icon = 'yogstation/icons/obj/syringe.dmi'
	icon_state = "stimpakpen"
	volume = 50
	amount_per_transfer_from_this = 25
	list_reagents = list(/datum/reagent/medicine/stimulants = 50)

/obj/item/reagent_containers/autoinjector/medipen/stimpack/large/redpill/update_icon()
	if(reagents.total_volume > 25)
		icon_state = initial(icon_state)
	else if(reagents.total_volume)
		icon_state = "[initial(icon_state)]25"
	else
		icon_state = "[initial(icon_state)]0"
