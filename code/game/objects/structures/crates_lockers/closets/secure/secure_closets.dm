/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = TRUE
	icon_state = "secure"
	max_integrity = 250
	armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 80, ACID = 80)
	secure = TRUE
	var/obj/item/electronics/airlock/electronics

/obj/structure/closet/secure_closet/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE && damage_amount < 20)
		return 0
	. = ..()

/obj/structure/closet/secure_closet/CheckParts(list/parts_list)
	. = ..()
	electronics = locate(/obj/item/electronics/airlock) in parts_list
	if(electronics)
		req_access = electronics.accesses
		qdel(electronics)
