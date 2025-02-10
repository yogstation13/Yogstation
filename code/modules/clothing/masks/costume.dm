/obj/item/clothing/mask/joy
	name = "emotion mask"
	desc = "Express your happiness or hide your sorrows with this cultured cutout."
	icon_state = "joy"
	clothing_flags = MASKINTERNALS
	flags_inv = HIDESNOUT
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION
	unique_reskin = list(
			"Joy" = "joy",
			"Flushed" = "flushed",
			"Pensive" = "pensive",
			"Angry" = "angry",
			"Pleading" = "pleading"
	)

/obj/item/clothing/mask/joy/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/clothing/mask/joy/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Change Emotion"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/clothing/mask/joy/reskin_obj(mob/user)
	. = ..()
	user.update_worn_mask()
	current_skin = null//so we can infinitely reskin

/obj/item/clothing/mask/mummy
	name = "mummy mask"
	desc = "Ancient bandages."
	icon_state = "mummy_mask"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/scarecrow
	name = "sack mask"
	desc = "A burlap sack with eyeholes."
	icon_state = "scarecrow_sack"
	inhand_icon_state = null
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/mask/kitsune
	name = "kitsune mask"
	desc = "Porcelain mask made in the style of the Sol-3 region. It is painted to look like a kitsune."
	icon_state = "kitsune"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	adjusted_flags = ITEM_SLOT_HEAD
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#EEEEEE#AA0000"
	greyscale_config = /datum/greyscale_config/kitsune
	greyscale_config_worn = /datum/greyscale_config/kitsune/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/mask/kitsune/examine(mob/user)
	. = ..()
	if(up)
		. += "Use in-hand to wear as a mask!"
		return
	else
		. += "Use in-hand to tie it up to wear as a hat!"

/obj/item/clothing/mask/kitsune/attack_self(mob/user)
	weldingvisortoggle(user)
	alternate_worn_layer = up ? ABOVE_BODY_FRONT_HEAD_LAYER : null

/obj/item/clothing/mask/joy/manhunt
	name = "smiley mask"
	desc = "A happy mask! Doesn't seem like there is anything wrong with it...right?"
	icon_state = "happy"
	unique_reskin = list(
			"Happy" = "happy",
			"Bloodied" = "bloodied",
			"Stop me" = "stop_me",
			"Cracked" = "cracked",
	)
