/obj/item/clothing/mask/gas/metro
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Blocks radioactive particles. Useful in the Metro." //More accurate
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	resistance_flags = NONE
	var/obj/item/filter/filter


/obj/item/clothing/mask/gas/metro/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/filter))
		filter = W
		W.forceMove(src)

/obj/item/clothing/mask/gas/metro/proc/EmptyFilter()
	src.visible_message("Filter depleted, insert new filter.", "<span class='danger'>Your gas mask notifies you that its <b>filter has run out!</b></span>")
	qdel(filter)

/obj/item/clothing/mask/gas/metro/proc/CanBreathe()
	if(filter)
		if(filter.time_remaining > 0)
			return TRUE
		else
			return FALSE
	else
		return FALSE

/obj/item/clothing/mask/gas/metro/proc/Breathe()
	filter.time_remaining--
	if(filter.time_remaining <= 0)
		EmptyFilter()

/obj/item/filter
	name = "filter"
	desc = "A filter for the metro gas mask. Needed to prevent radioactive particles from entering your lungs. This one looks old."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "film"

	var/time_remaining = 6000