/obj/item/reagent_containers/hypospray/mixi
	name = "QMC Bicaridine Injector"
	desc = "A quick-mix capital combat injector loaded with bicaridine."
	amount_per_transfer_from_this = 5
	icon_state = "combat_hypo"
	volume = 50
	list_reagents = list("bicaridine" = 50)

/obj/item/reagent_containers/hypospray/derm
	name = "QMC Kelotane Injector"
	desc = "A quick-mix capital combat injector loaded with kelotane."
	amount_per_transfer_from_this = 5
	icon_state = "combat_hypo"
	volume = 50
	list_reagents = list("kelotane" = 50)

/obj/item/reagent_containers/hypospray/combat/metro/brute
	name = "makeshift medical injector"
	desc = "A modified air-needle autoinjector. Used in the metro as a quick way to heal blunt trauma. Contains 2 doses."
	amount_per_transfer_from_this = 10
	icon_state = "combat_hypo"
	volume = 20
	ignore_flags = 1
	list_reagents = list("bicaridine" = 20)

/obj/item/reagent_containers/hypospray/combat/metro/toxin
	name = "green stuff injector"
	desc = "A modified air-needle autoinjector. Used by the military to reduce any damage taken from radiation. The only way to heal toxin damage sustained from breathing without a mask. Contains 1 dose"
	amount_per_transfer_from_this = 15
	icon_state = "combat_hypo"
	volume = 15
	ignore_flags = 1
	list_reagents = list("antitoxin" = 15)