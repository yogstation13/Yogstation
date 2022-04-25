/obj/item/clothing/head/helmet/space/hardsuit/infiltration
	name = "engineering hardsuit helmet"
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	item_color = "engineering"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30,"energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	syndicate = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/infiltration/Initialize()
	. = ..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/infiltration))
		var/obj/item/clothing/suit/space/hardsuit/infiltration/I = loc
		I.head_piece = src

/obj/item/clothing/suit/space/hardsuit/infiltration
	name = "engineering hardsuit"
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 15, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/infiltration
	jetpack = /obj/item/tank/jetpack/suit
	syndicate = TRUE
	var/datum/action/item_action/chameleon/change/chameleon_action
	var/obj/item/clothing/head/helmet/space/hardsuit/infiltration/head_piece

/obj/item/clothing/suit/space/hardsuit/infiltration/examine(mob/user)
	. = ..()
	if (is_syndicate(user))
		. += span_notice("There appears to be a hidden panel on it, showing various customization options.")

/obj/item/clothing/suit/space/hardsuit/infiltration/Initialize()
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit/space/hardsuit
	chameleon_action.chameleon_name = "Hardsuit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/suit/space/hardsuit/shielded/swat, /obj/item/clothing/suit/space/hardsuit), only_root_path = TRUE)
	chameleon_action.initialize_disguises()

/obj/item/clothing/suit/space/hardsuit/infiltration/emp_act(severity)
	chameleon_action.emp_randomise()
