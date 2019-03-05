/obj/item/clothing/suit/space/hardsuit/engine
  jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/security
  jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/swat/metro
	name = "\improper Heavy Armor"
	desc = "An advanced suit of armor, compared to Metro standards atleast. Gives protection against ballistics."
	icon_state = "swat2"
	item_state = "swat2"
	armor = list("melee" = 45, "bullet" = 45, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this needed to be added a long fucking time ago
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat/metro

/obj/item/clothing/head/helmet/space/hardsuit/swat/metro
	name = "\improper Heavy Armor Helmet"
	icon_state = "swat2helm"
	item_state = "swat2helm"
	desc = "An integral part of the Heavy Armor suit, protects your head from projectiles and blunt trauma."
	armor = list("melee" = 45, "bullet" = 45, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR //we want to see the mask
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/swat/attack_self()