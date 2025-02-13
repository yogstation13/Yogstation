/obj/item/clothing/glasses/pathology
	name = "viral analyzer goggles"
	desc = "A pair of goggles fitted with an analyzer for viral particles and reagents. Comes with a handy toggle for avoiding visual overload."

	icon = 'monkestation/icons/obj/clothing/glasses.dmi'
	worn_icon = 'monkestation/icons/obj/clothing/eyes.dmi'
	icon_state = "pathology_on"
	worn_icon_state = "pathology_on"

	clothing_traits = list(TRAIT_REAGENT_SCANNER)

/obj/item/clothing/glasses/pathology/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pathology_glasses, icon_state_on = "pathology_on", icon_state_off = "pathology_off", use_glass_color = TRUE)

/obj/item/clothing/glasses/sunglasses/pathology
	name = "viral analyzer glasses"
	desc = "A pair of sunglasses fitted with an analyzer for viral particles and reagents. Comes with a handy toggle for avoiding visual overload."

	icon = 'monkestation/icons/obj/clothing/glasses.dmi'
	worn_icon = 'monkestation/icons/obj/clothing/eyes.dmi'
	icon_state = "sunhudpatho_on"
	worn_icon_state = "sunhudpatho_on"

/obj/item/clothing/glasses/sunglasses/pathology/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pathology_glasses, icon_state_on = "sunhudpatho_on", icon_state_off = "sunhudpatho_off")

/obj/item/clothing/glasses/night/pathology
	name = "night vision viral analyzer goggles"
	desc = "A pair of night vision goggles fitted with an analyzer for viral particles and reagents. Comes with a handy toggle for avoiding visual overload."

	icon = 'monkestation/icons/obj/clothing/glasses.dmi'
	worn_icon = 'monkestation/icons/obj/clothing/eyes.dmi'
	icon_state = "pathohudnight_on"
	worn_icon_state = "pathohudnight_on"

/obj/item/clothing/glasses/night/pathology/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/pathology_glasses, \
		icon_state_on = "pathohudnight_on", \
		icon_state_off = "pathohudnight_off", \
		use_glass_color = TRUE, \
		color_cutoffs_on = list(20, 30, 20), \
		color_cutoffs_off = list(30, 20, 30), \
		use_color_cutoffs = TRUE, \
	)
