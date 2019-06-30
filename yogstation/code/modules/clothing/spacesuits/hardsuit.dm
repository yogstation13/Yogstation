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
	desc = "It's some barely-functional power armor helmet from a by-gone age."
	icon_state = "t45bhelmet"
	item_state = "t45bhelmet"
	armor = list("melee" = 50, "bullet" = 48, "laser" = 25, "energy" = 25, "bomb" = 48, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 25)
/obj/item/clothing/suit/space/hardsuit/powerarmor/t45b
	name = "Salvaged T-45b power armor"
	desc = "It's some barely-functional power armor, probably hundreds of years old."
	icon_state = "t45bpowerarmor"
	item_state = "t45bpowerarmor"
	armor = list("melee" = 50, "bullet" = 48, "laser" = 25, "energy" = 25, "bomb" = 48, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 25)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/powerarmor/t45b

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor/advanced
	name = "Advanced power helmet"
	desc = "It's an advanced power armor Mk I helmet. It looks somewhat threatening."
	icon_state = "advhelmet1"
	item_state = "advhelmet1"
	armor = list("melee" = 50, "bullet" = 48, "laser" = 25, "energy" = 25, "bomb" = 48, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 25)
/obj/item/clothing/suit/space/hardsuit/powerarmor/advanced
	name = "Advanced power armor"
	desc = "An advanced suit of power armor. It looks pretty impressive and threatening."
	icon_state = "advpowerarmor1"
	item_state = "advpowerarmor1"
	armor = list("melee" = 50, "bullet" = 48, "laser" = 25, "energy" = 25, "bomb" = 48, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 25)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/powerarmor/advanced


//Paramedic Hardsuit
//For the yogstation specific paramedic role
//Let the record state that hardsuit code is actual shitcode

obj/item/clothing/head/helmet/space/hardsuit/paramedic
    name = "paramedic hardsuit helmet"
    desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
    alternate_worn_icon = 'yogstation/icons/mob/head.dmi'
    icon = 'yogstation/icons/mob/head.dmi'
    icon_state = "hardsuit0-para"
    item_state = "para"
    item_color = "para"
    armor = list("melee" = 35, "bullet" = 10, "laser" = 15, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 30, "fire" = 30, "acid" = 50)

/obj/item/clothing/suit/space/hardsuit/paramedic
    name = "Paramedic Hardsuit"
    desc = "An advanced response and rescue suit for elite paramedics. Packs some extra padding instead of biological protection for high-risk areas."
    alternate_worn_icon = 'yogstation/icons/mob/suit.dmi'
    icon = 'yogstation/icons/mob/suit.dmi'
    icon_state = "hardsuit-para"
    item_state = "hardsuit-para"
    helmettype = /obj/item/clothing/head/helmet/space/hardsuit/paramedic
    armor = list("melee" = 35, "bullet" = 10, "laser" = 15, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 30, "fire" = 30, "acid" = 50)