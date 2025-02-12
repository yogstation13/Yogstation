/obj/item/mod/control/pre_equipped/waffles
	theme = /datum/mod_theme/waffles
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/dna_lock/reinforced,
	)
	default_pins = list(
		/obj/item/mod/module/stealth/ninja,
		/obj/item/mod/module/jetpack/advanced,
	)

/obj/item/mod/control/pre_equipped/enchanted/no_antimagic
	theme = /datum/mod_theme/enchanted/no_antimagic
	applied_core = /obj/item/mod/core/infinite
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/energy_shield/wizard,
		/obj/item/mod/module/emp_shield/advanced,
	)

/obj/item/mod/control/pre_equipped/blueshield
	worn_icon = 'monkestation/icons/mob/clothing/worn_modsuit.dmi'
	icon = 'monkestation/icons/obj/clothing/modsuits/modsuit.dmi'
	icon_state = "praetorian-control"
	theme = /datum/mod_theme/blueshield
	applied_cell = /obj/item/stock_parts/cell/super
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/flashlight,
		/obj/item/mod/module/projectile_dampener,
		/obj/item/mod/module/quick_carry,
		/obj/item/mod/module/holster,
	)
	default_pins = list(

		/obj/item/mod/module/holster,
		/obj/item/mod/module/projectile_dampener,
	)

/obj/item/mod/control/pre_equipped/rescue
	default_pins = list(

		/obj/item/mod/module/health_analyzer,
		/obj/item/mod/module/injector,
	)

/obj/item/mod/control/pre_equipped/security
	default_pins = list(

		/obj/item/mod/module/pepper_shoulders,
		/obj/item/mod/module/criminalcapture,
		/obj/item/mod/module/dispenser/mirage,
	)

