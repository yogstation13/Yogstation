/obj/item/clothing/suit/space/hardsuit/engine
  jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/security
  jetpack = /obj/item/tank/jetpack/suit

//POWERARMORS
//Currently are no different from normal hardsuits, except maybe for the higher armor ratings.
/obj/item/clothing/head/helmet/space/hardsuit/powerarmor
	alternate_worn_icon = 'yogstation/icons/mob/head.dmi'
	icon = 'yogstation/icons/obj/clothing/hats.dmi'	
/obj/item/clothing/suit/space/hardsuit/powerarmor
	alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor/t45b
	name = "Salvaged T-45b helmet"
	desc = "It's a pre-War power armor helmet, recovered and maintained by NCR engineers."
	icon_state = "t45bhelmet"
	item_state = "t45bhelmet"
	armor = list("melee" = 50, "bullet" = 48, "laser" = 25, "energy" = 25, "bomb" = 48, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 0) 
/obj/item/clothing/suit/space/hardsuit/powerarmor/t45b
	name = "Salvaged T-45b power armor"
	desc = "It's a set of T-45b power armor recovered by the NCR during the NCR-Brotherhood War."
	icon_state = "t45bpowerarmor"
	item_state = "t45bpowerarmor"
	armor = list("melee" = 50, "bullet" = 48, "laser" = 25, "energy" = 25, "bomb" = 48, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/powerarmor/t45b

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor/advanced
	name = "Advanced power helmet"
	desc = "It's an advanced power armor Mk I helmet, typically used by the Enclave. It looks somewhat threatening."
	icon_state = "advhelmet1"
	item_state = "advhelmet1"
	armor = list("melee" = 50, "bullet" = 48, "laser" = 25, "energy" = 25, "bomb" = 48, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
/obj/item/clothing/suit/space/hardsuit/powerarmor/advanced
	name = "Advanced power armor"
	desc = "An advanced suit of armor typically used by the Enclave.<br>It is composed of lightweight metal alloys, reinforced with ceramic castings at key stress points.<br>Additionally, like the T-51b power armor, it includes a recycling system that can convert human waste into drinkable water, and an air conditioning system for it's user's comfort."
	icon_state = "advpowerarmor1"
	item_state = "advpowerarmor1"
	armor = list("melee" = 50, "bullet" = 48, "laser" = 25, "energy" = 25, "bomb" = 48, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/powerarmor/advanced

