/obj/item/clothing/mask/breath/vox
	name = "vox breath mask"
	desc = "A weirdly-shaped breath mask."
	icon_state = "voxmask"
	species_restricted = list(SPECIES_VOX)
	flags_cover = NONE
	visor_flags_cover = NONE
	actions_types = list()

/obj/item/clothing/mask/breath/vox/attack_self(mob/user)
	return

/obj/item/clothing/mask/breath/vox/AltClick(mob/user)
	return

/obj/item/clothing/mask/breath/vox/respirator
	name = "vox respirator"
	desc = "A weirdly-shaped breath mask, this one seems to be designed for a vox beak."
	icon_state = "voxmask2"
	item_state = "voxmask2"
