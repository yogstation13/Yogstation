/obj/item/clothing/under/dress
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	icon = 'icons/obj/clothing/under/dress.dmi'
	worn_icon = 'icons/mob/clothing/under/dress.dmi'

/obj/item/clothing/under/dress/striped
	name = "striped dress"
	desc = "Fashion in space."
	icon_state = "striped_dress"
	inhand_icon_state = null
	female_sprite_flags = FEMALE_UNIFORM_FULL

/obj/item/clothing/under/dress/sailor
	name = "sailor dress"
	desc = "Formal wear for a leading lady."
	icon_state = "sailor_dress"
	inhand_icon_state = null

/obj/item/clothing/under/dress/wedding_dress
	name = "wedding dress"
	desc = "A luxurious gown for once-in-a-lifetime occasions."
	icon_state = "wedding_dress"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS
	flags_inv = HIDESHOES

/obj/item/clothing/under/dress/redeveninggown
	name = "red evening gown"
	desc = "Fancy dress for space bar singers."
	icon_state = "red_evening_gown"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS
	flags_inv = HIDESHOES

/obj/item/clothing/under/dress/skirt
	name = "black skirt"
	desc = "A black skirt, very fancy!"
	icon_state = "blackskirt"
	inhand_icon_state = "blackskirt"

/obj/item/clothing/under/dress/skirt/plaid
	name = "plaid skirt"
	desc = "A preppy plaid skirt with a white blouse."
	icon_state = "plaidskirt"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#CC2102"
	greyscale_config = /datum/greyscale_config/plaidskirt
	greyscale_config_worn = /datum/greyscale_config/plaidskirt_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/skirt/turtleskirt
	name = "turtleneck skirt"
	desc = "A casual turtleneck skirt."
	icon_state = "turtleskirt"
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#cc0000#5f5f5f"
	greyscale_config = /datum/greyscale_config/turtleskirt
	greyscale_config_worn = /datum/greyscale_config/turtleskirt_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/tango
	name = "tango dress"
	desc = "Filled with Latin fire."
	icon_state = "tango"
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#ff0000#1c1c1c"
	greyscale_config = /datum/greyscale_config/tango
	greyscale_config_worn = /datum/greyscale_config/tango_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/sundress
	name = "sundress"
	desc = "Makes you want to frolic in a field of daisies."
	icon_state = "sundress"
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#FFE60F#9194A5#1F243C"
	greyscale_config = /datum/greyscale_config/sundress
	greyscale_config_worn = /datum/greyscale_config/sundress_worn
	flags_1 = IS_PLAYER_COLORABLE_1

//MONKESTATION ADDITIONS
/obj/item/clothing/under/dress/ballgown
	name = "ballgown"
	desc = "A luxurious ballgown best worn before midnight. A signature of the letters 'VA` is stitched on the hem."
	icon_state = "ballgown"
	custom_price = PAYCHECK_COMMAND
	body_parts_covered = CHEST|GROIN|LEGS
	greyscale_config = /datum/greyscale_config/ballgown
	greyscale_config_worn = /datum/greyscale_config/ballgown_worn
	greyscale_colors = "#FFFFFF#CCECFF#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1
	flags_inv = HIDESHOES

/obj/item/clothing/under/dress/wlpinafore
	name = "wonderland pinafore"
	desc = "An adorable pinafore, just don't chase any white rabbits down any holes this time. It has the initials 'VA' embroidered on the skirt hem."
	icon_state = "wlpinafore"
	custom_price = PAYCHECK_COMMAND
	greyscale_config = /datum/greyscale_config/wlpinafore
	greyscale_config_worn = /datum/greyscale_config/wlpinafore_worn
	greyscale_colors = "#5190c8#FFFFFF"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/ribbondress
	name = "ribboned gown"
	desc = "A classy and elegant gown with ribbon sleeves. It has the initials 'VA' stitched on the back hem."
	icon_state = "ribbondress"
	custom_price = PAYCHECK_COMMAND
	greyscale_config = /datum/greyscale_config/ribbondress
	greyscale_config_worn = /datum/greyscale_config/ribbondress_worn
	greyscale_colors = "#845FAA#D5A6F4"
	flags_1 = IS_PLAYER_COLORABLE_1
	flags_inv = HIDESHOES

/obj/item/clothing/under/dress/sparkle
	name = "sparkly ribbon dress"
	desc = "A fancy dress that sparkles gently in the light, and it comes with removeable sleeves!"
	icon_state = "sparkledress"
	inhand_icon_state = "sparkledress"
	can_adjust = TRUE

/obj/item/clothing/under/dress/white
	name = "gaudy white dress"
	desc = "A simple easy to wear dress for when you're in a rush but still want to look good."
	icon_state = "whitedress"
	inhand_icon_state = "whitedress"
	can_adjust = FALSE

/obj/item/clothing/under/dress/angel
	name = "lace angel dress"
	desc = "I can be your angle or your debil."
	icon_state = "angeldress"
	inhand_icon_state = "angeldress"
	can_adjust = FALSE

/obj/item/clothing/under/dress/angel/alt
	name = "lace devil dress"
	desc = "I can be your angle or your debil."
	icon_state = "devildress"
	inhand_icon_state = "devildress"
	can_adjust = FALSE

/obj/item/clothing/under/dress/flowery
	name = "perfumed light dress"
	desc = "A delicate dress that's vastly worth more than it's weight in fabric. On top of that it smells great!"
	icon_state = "flowerydress"
	inhand_icon_state = "flowerydress"
	can_adjust = FALSE
	flags_inv = HIDESHOES

/obj/item/clothing/under/dress/starry
	name = "starry dress"
	desc = "A modest dress "
	icon_state = "stardress"
	inhand_icon_state = "stardress"
	can_adjust = FALSE

/obj/item/clothing/under/dress/gown //Miss me with subtypes I dont wanna fuck with it
	name = "regal ball gown"
	desc = "A delicate dress that's vastly worth more than it's weight in fabric. On top of that it smells great!"
	icon_state = "rballgown"
	inhand_icon_state = null
	can_adjust = TRUE
	flags_inv = HIDESHOES

/obj/item/clothing/under/dress/moonlit
	name = "moonlit gown"
	desc = "A luxurious gown for VERY special occasions, this gown glitters with silver sewn into the very fabric itself."
	icon_state = "stargown"
	inhand_icon_state = null
