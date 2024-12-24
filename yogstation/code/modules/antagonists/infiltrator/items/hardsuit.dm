/obj/item/clothing/head/helmet/space/hardsuit/infiltration
	name = "engineering hardsuit helmet"
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list(MELEE = 35, BULLET = 15, LASER = 30,ENERGY = 10, BOMB = 10, BIO = 100, RAD = 50, FIRE = 75, ACID = 75)
	syndicate = TRUE
	var/current_disguise = /obj/item/clothing/suit/space/hardsuit/infiltration
	var/new_type = "engineering"
	var/static/list/bad_hardsuits = list(
		/obj/item/clothing/suit/space/hardsuit/darktemplar, 
		/obj/item/clothing/suit/space/hardsuit/darktemplar/chap, 
		/obj/item/clothing/suit/space/hardsuit/cult, 
		/obj/item/clothing/suit/space/hardsuit/syndi, 
		/obj/item/clothing/suit/space/hardsuit/syndi/elite, 
		/obj/item/clothing/suit/space/hardsuit/syndi/owl, 
		/obj/item/clothing/suit/space/hardsuit/syndi/debug, 
		/obj/item/clothing/suit/space/hardsuit/carp, 
		/obj/item/clothing/suit/space/hardsuit/carp/dragon, 
		/obj/item/clothing/suit/space/hardsuit/swat, 
		/obj/item/clothing/suit/space/hardsuit/swat/captain, 
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal, 
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor, 
		/obj/item/clothing/suit/space/hardsuit/ert/paranormal/beserker, 
		/obj/item/clothing/suit/space/hardsuit/shielded/swat, 
		/obj/item/clothing/suit/space/hardsuit/shielded/swat/honk, 
		/obj/item/clothing/suit/space/hardsuit/deathsquad
	)

/obj/item/clothing/head/helmet/space/hardsuit/infiltration/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/infiltration))
		var/obj/item/clothing/suit/space/hardsuit/infiltration/I = loc
		I.head_piece = src

/obj/item/clothing/head/helmet/space/hardsuit/infiltration/attack_self(mob/user)
	if(bad_hardsuits.Find(current_disguise))
		to_chat(user, span_warning("You can't use the hardsuit's helmet light with this current disguise, change to another one!"))
	else //Copied from original hardsuit attack_self and modified slightly
		on = !on
		icon_state = "[basestate][on]-[new_type]"
		user.update_inv_head()	//so our mob-overlays update

		set_light_on(on)

		for(var/X in actions)
			var/datum/action/A = X
			A.build_all_button_icons()

/obj/item/clothing/suit/space/hardsuit/infiltration
	name = "engineering hardsuit"
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 35, BIO = 100, RAD = 50, FIRE = 50, ACID = 90)
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

/obj/item/clothing/suit/space/hardsuit/infiltration/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit/space/hardsuit
	chameleon_action.chameleon_name = "Hardsuit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/suit/space/hardsuit/shielded/swat, /obj/item/clothing/suit/space/hardsuit), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/suit/space/hardsuit/infiltration/emp_act(severity)
	chameleon_action.emp_randomise()
