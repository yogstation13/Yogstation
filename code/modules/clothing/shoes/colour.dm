/obj/item/clothing/shoes/sneakers
	dying_key = DYE_REGISTRY_SNEAKERS
	icon_state = "sneakers"
	item_state = "sneakers_back"
	lefthand_file = 'icons/mob/inhands/clothing/shoes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/shoes_righthand.dmi'
	greyscale_colors = "#2d2d33#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn
	greyscale_config_inhand_left = /datum/greyscale_config/sneakers_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/sneakers_inhand_right
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/sneakers/black
	name = "black shoes"
	desc = "A pair of black shoes."
	custom_price = 20

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/sneakers/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	greyscale_colors = "#472c21#ffffff"

/obj/item/clothing/shoes/sneakers/blue
	name = "blue shoes"
	greyscale_colors = "#4f88df#ffffff"

/obj/item/clothing/shoes/sneakers/green
	name = "green shoes"
	greyscale_colors = "#3bca5a#ffffff"

/obj/item/clothing/shoes/sneakers/yellow
	name = "yellow shoes"
	greyscale_colors = "#deb63d#ffffff"

/obj/item/clothing/shoes/sneakers/purple
	name = "purple shoes"
	greyscale_colors = "#7e1980#ffffff"

/obj/item/clothing/shoes/sneakers/red
	name = "red shoes"
	desc = "Stylish red shoes."
	greyscale_colors = "#a52f29#ffffff"	

/obj/item/clothing/shoes/sneakers/white
	name = "white shoes"
	greyscale_colors = "#ffffff#ffffff"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/shoes/sneakers/rainbow
	name = "rainbow shoes"
	desc = "Very colorful shoes."
	icon_state = "rain_bow"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	flags_1 = NONE

/obj/item/clothing/shoes/sneakers/orange
	name = "orange shoes"
	greyscale_colors = "#d15b1b#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_orange
	greyscale_config_worn = /datum/greyscale_config/sneakers_orange_worn
	greyscale_config_inhand_left = /datum/greyscale_config/sneakers_orange_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/sneakers_orange_inhand_right
	flags_1 = NONE	

/obj/item/clothing/shoes/sneakers/orange/attack_self(mob/user)
	if (chained)
		chained = FALSE
		slowdown = SHOES_SLOWDOWN
		new /obj/item/restraints/handcuffs( user.loc )
		update_icon()
	return

/obj/item/clothing/shoes/sneakers/orange/attackby(obj/H, loc, params)
	..()
	// Note: not using istype here because we want to ignore all subtypes
	if (H.type == /obj/item/restraints/handcuffs && !chained)
		qdel(H)
		chained = TRUE
		slowdown = 15
		update_appearance(UPDATE_ICON)
	return

/obj/item/clothing/shoes/sneakers/orange/allow_attack_hand_drop(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/C = user
		if(C.shoes == src && chained)
			to_chat(user, span_warning("You need help taking these off!"))
			return FALSE
	return ..()

/obj/item/clothing/shoes/sneakers/orange/MouseDrop(atom/over)
	var/mob/m = usr
	if(ishuman(m))
		var/mob/living/carbon/human/c = m
		if(c.shoes == src && chained)
			to_chat(c, span_warning("You need help taking these off!"))
			return
	return ..()

/obj/item/clothing/shoes/sneakers/orange/update_icon_state()
	. = ..()
	if(chained)
		icon_state = item_state = "sneakers_chained"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	update_greyscale()

/obj/item/clothing/shoes/sneakers/mime
	name = "mime shoes"
	greyscale_colors = "#ffffff#ffffff"

/obj/item/clothing/shoes/sneakers/marisa
	desc = "A pair of magic black shoes."
	name = "magic shoes"
	greyscale_colors = "#2d2d33#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_marisa
	greyscale_config_worn = /datum/greyscale_config/sneakers_marisa/worn
	strip_delay = 5
	equip_delay_other = 50
//	can_be_tied = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/sneakers/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	greyscale_colors = "#4e4e4e#4e4e4e"
