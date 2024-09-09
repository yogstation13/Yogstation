/datum/mod_theme/blueshield
	name = "praetorian"
	desc = "A prototype of the Magnate-class suit issued to station Blueshields, still boasting exceptional protection worthy of an honor guard."
	extended_desc = "A prototype of the Magnate-class suit issued for use with the station Blueshields, \
		it boasts the exceptional protection of its successor, while sacrificing some of the module capacity.\
		All of the protection of the Magnate, with none of the comfort! The visor uses blue-light to obscure \
		the face of its wearer, adding to its imposing figure. Compared to the sleek and luxurious design \
		that came after it, this suit does nothing to hide its purpose, the reinforced plating layered \
		over the insulated inner armor granting it protection against corrosive liquids, explosive blasts, \
		fires, electrical shocks, and contempt from the rest of the crew."

	default_skin = "praetorian"
	armor_type = /datum/armor/mod_theme_security
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	slowdown_inactive = 1
	slowdown_active = 0.5
	allowed_suit_storage = list(
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
	)
	skins = list(
		"praetorian" = list(
			MOD_ICON_OVERRIDE = 'monkestation/code/modules/blueshield/icons/praetorian.dmi',
			MOD_WORN_ICON_OVERRIDE = 'monkestation/code/modules/blueshield/icons/worn_praetorian.dmi',
			HELMET_FLAGS = list(
				UNSEALED_LAYER = null,
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEEARS|HIDEHAIR,
				SEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEYES|HIDEFACE|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		),
	)
