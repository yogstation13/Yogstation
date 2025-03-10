//Clockwork armor: High melee protection but weak to lasers
/obj/item/clothing/head/helmet/clockwork
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS | HIDEHAIR | HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor = list(MELEE = 50, BULLET = 40, LASER = 20, ENERGY = 10, BOMB = 60, BIO = 15, RAD = 0, FIRE = 100, ACID = 100)

/obj/item/clothing/head/helmet/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clothing/head/helmet/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clothing/head/helmet/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		armor.setRating(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100, electric = 100)
		clothing_flags |= STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else if(GLOB.ratvar_approaches)
		armor.setRating(melee = 60, bullet = 50, laser = 25, energy = 25, bomb = 70, bio = 90, rad = 0, fire = 100, acid = 100)
		clothing_flags |= STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else
		armor.setRating(melee = 50, bullet = 40, laser = 20, energy = 10, bomb = 60, bio = 15, rad = 0, fire = 100, acid = 100)
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = initial(max_heat_protection_temperature)
		min_cold_protection_temperature = initial(min_cold_protection_temperature)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == ITEM_SLOT_HEAD && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			to_chat(user, "[span_heavy_brass("\"Now now, this is for my servants, not you.\"")]")
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off [user.p_their()] head!"), span_warning("The helmet flickers off your head, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
		else
			to_chat(user, "[span_heavy_brass("\"Do you have a hole in your head? You're about to.\"")]")
			to_chat(user, span_userdanger("The helmet tries to drive a spike through your head as you scramble to remove it!"))
			user.emote("scream")
			user.apply_damage(30, BRUTE, BODY_ZONE_HEAD)
			user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, dropItemToGround), src, TRUE), 1) //equipped happens before putting stuff on(but not before picking items up), 1). thus, we need to wait for it to be on before forcing it off.

/obj/item/clothing/head/helmet/clockwork/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS
	cold_protection = CHEST|GROIN|LEGS
	heat_protection = CHEST|GROIN|LEGS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 50, BULLET = 40, LASER = 20, ENERGY = 10, BOMB = 60, BIO = 15, RAD = 0, FIRE = 100, ACID = 100)
	allowed = list(/obj/item/clockwork, /obj/item/clothing/glasses/wraith_spectacles, /obj/item/clothing/glasses/judicial_visor, /obj/item/mmi/posibrain/soul_vessel)

/obj/item/clothing/suit/armor/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clothing/suit/armor/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clothing/suit/armor/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		armor.setRating(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100)
		clothing_flags |= STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else if(GLOB.ratvar_approaches)
		armor.setRating(melee = 60, bullet = 50, laser = 25, energy = 25, bomb = 70, bio = 90, rad = 0, fire = 100, acid = 100)
		clothing_flags |= STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else
		armor.setRating(melee = 50, bullet = 40, laser = 20, energy = 10, bomb = 60, bio = 15, rad = 0, fire = 100, acid = 100)
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = initial(max_heat_protection_temperature)
		min_cold_protection_temperature = initial(min_cold_protection_temperature)

/obj/item/clothing/suit/armor/clockwork/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == ITEM_SLOT_OCLOTHING && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			to_chat(user, "[span_heavy_brass("\"Now now, this is for my servants, not you.\"")]")
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off [user.p_their()] body!"), span_warning("The cuirass flickers off your body, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20)
		else
			to_chat(user, "[span_heavy_brass("\"I think this armor is too hot for you to handle.\"")]")
			to_chat(user, span_userdanger("The cuirass emits a burst of flame as you scramble to get it off!"))
			user.emote("scream")
			user.apply_damage(15, BURN, BODY_ZONE_CHEST)
			user.adjust_fire_stacks(2)
			user.ignite_mob()
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, dropItemToGround), src, TRUE), 1)

/obj/item/clothing/gloves/clockwork
	name = "clockwork gauntlets"
	desc = "Heavy, shock-resistant gauntlets with brass reinforcement."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	strip_delay = 50
	equip_delay_other = 30
	body_parts_covered = ARMS
	cold_protection = ARMS
	heat_protection = ARMS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 50, BULLET = 40, LASER = 20, ENERGY = 10, BOMB = 60, BIO = 60, RAD = 0, FIRE = 100, ACID = 100, ELECTRIC = 100)

/obj/item/clothing/gloves/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clothing/gloves/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clothing/gloves/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		armor.setRating(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100, electric = 100)
		clothing_flags |= STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else if(GLOB.ratvar_approaches)
		armor.setRating(melee = 60, bullet = 50, laser = 25, energy = 25, bomb = 60, bio = 90, rad = 0, fire = 100, acid = 100, electric = 100)
		clothing_flags |= STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else
		armor.setRating(melee = 50, bullet = 40, laser = 20, energy = 10, bomb = 60, bio = 60, rad = 0, fire = 100, acid = 100, electric = 100)
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = initial(max_heat_protection_temperature)
		min_cold_protection_temperature = initial(min_cold_protection_temperature)

/obj/item/clothing/gloves/clockwork/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == ITEM_SLOT_GLOVES && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			to_chat(user, "[span_heavy_brass("\"Now now, this is for my servants, not you.\"")]")
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off [user.p_their()] arms!"), span_warning("The gauntlets flicker off your arms, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
		else
			to_chat(user, "[span_heavy_brass("\"Did you like having arms?\"")]")
			to_chat(user, span_userdanger("The gauntlets suddenly squeeze tight, crushing your arms before you manage to get them off!"))
			user.emote("scream")
			user.apply_damage(7, BRUTE, BODY_ZONE_L_ARM)
			user.apply_damage(7, BRUTE, BODY_ZONE_R_ARM)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, dropItemToGround), src, TRUE), 1)

/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"
	w_class = WEIGHT_CLASS_NORMAL
	strip_delay = 50
	equip_delay_other = 30
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clothing/shoes/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clothing/shoes/clockwork/negates_gravity()
	return TRUE

/obj/item/clothing/shoes/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		clothing_flags |= NOSLIP
	else
		clothing_flags &= ~NOSLIP

/obj/item/clothing/shoes/clockwork/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == ITEM_SLOT_FEET && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			to_chat(user, "[span_heavy_brass("\"Now now, this is for my servants, not you.\"")]")
			user.visible_message(span_warning("As [user] puts [src] on, it flickers off [user.p_their()] feet!"), span_warning("The treads flicker off your feet, leaving only nausea!"))
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit()
		else
			to_chat(user, "[span_heavy_brass("\"Let's see if you can dance with these.\"")]")
			to_chat(user, span_userdanger("The treads turn searing hot as you scramble to get them off!"))
			user.emote("scream")
			user.apply_damage(7, BURN, BODY_ZONE_L_LEG)
			user.apply_damage(7, BURN, BODY_ZONE_R_LEG)
		addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, dropItemToGround), src, TRUE), 1)
