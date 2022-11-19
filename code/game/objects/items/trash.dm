//Added by Jack Rost
/obj/item/trash
	icon = 'yogstation/icons/obj/janitor.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	desc = "This is rubbish."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	fryable = TRUE

/obj/item/trash/raisins
	name = "\improper 4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "syndi-cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/energybar
	name = "energybar wrapper"
	icon_state = "energybar"

/obj/item/trash/waffles
	name = "waffles tray"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "plate"
	desc = "a relic from a forgotten time...  I miss eating off of plates..."
	icon_state = "plate"
	resistance_flags = NONE

/obj/item/trash/pistachios
	name = "pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "tray"
	icon_state = "tray"
	resistance_flags = NONE

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/candle/resin
	name = "resin candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "resincandle4"

/obj/item/trash/can
	name = "crushed can"
	icon_state = "cola"
	resistance_flags = NONE
	grind_results = list(/datum/reagent/aluminium = 10)

/obj/item/trash/attack(mob/M, mob/living/user)
	return

/obj/item/trash/floursack
	name = "torn flour sack"
	icon = 'yogstation/icons/obj/food/containers.dmi'
	icon_state = "floursad"
	desc = "Perhaps it shouldn't have been filled with water."

/obj/item/trash/toritose
	name = "toritose"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "toritoseded"

/obj/item/trash/topkakes
	name = "top kakes"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "topkakesded"
