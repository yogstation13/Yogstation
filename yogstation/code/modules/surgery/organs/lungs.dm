/obj/item/organ/lungs/ashwalker
	name = "grey lungs"
	desc = "The grey-ish lungs of an ashwalker."
	icon = 'yogstation/icons/obj/surgery.dmi'
	icon_state = "lungs-ash"

	safe_oxygen_min = 0
	safe_nitro_min = 16
	safe_toxins_max = 0.05
	safe_co2_max = 20
	SA_para_min = 1
	SA_sleep_min = 5
	BZ_trip_balls_min = 1
	gas_stimulation_min = 0.002

/obj/item/organ/lungs/plant
	name = "mesophyll"
	desc = "A lung-shaped organ playing a key role in phytosian's photosynthesis." //phytosians don't need that for their light healing so that's just flavor, I might try to tie their light powers to it later(tm)
	icon = 'yogstation/icons/obj/surgery.dmi'
	icon_state = "lungs-plant"

	safe_co2_max = 0 //make them not choke on CO2 so they can actually breathe it
	oxygen_substitutes = list(/datum/gas/pluoxium = 8, /datum/gas/carbon_dioxide = 1) //able of using CO2 AND oxygen to breathe

/obj/item/organ/lungs/plant/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H) //Directly taken from the xenos lungs
	. = ..()
	if(breath)
		var/breath_amt = breath.get_moles(/datum/gas/carbon_dioxide)
		breath.adjust_moles(/datum/gas/carbon_dioxide, -breath_amt)
		breath.adjust_moles(/datum/gas/oxygen, breath_amt)

/obj/item/organ/lungs/plant/prepare_eat()
	var/obj/item/reagent_containers/food/snacks/organ/plant_lung/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.w_class = w_class

	return S

/obj/item/reagent_containers/food/snacks/organ/plant_lung
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)
	foodtype = VEGETABLES | FRUIT
