	//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	max_integrity = 300
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 75, FIRE = 50, ACID = 75)
	var/basestate = "hardsuit"
	var/brightness_on = 4 //luminosity when on
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit
	//Determines used sprites: hardsuit[on]-[hardsuit_type]
	var/hardsuit_type = "engineering"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)
	var/rad_count = 0
	var/rad_record = 0
	var/grace_count = 0
	var/datum/looping_sound/geiger/soundloop

/obj/item/clothing/head/helmet/space/hardsuit/Initialize()
	. = ..()
	soundloop = new(list(), FALSE, TRUE)
	soundloop.volume = 5
	START_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	on = !on
	icon_state = "[basestate][on]-[hardsuit_type]"
	user.update_inv_head()	//so our mob-overlays update

	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveHelmet()
		soundloop.stop(user)

/obj/item/clothing/head/helmet/space/hardsuit/item_action_slot_check(slot)
	if(slot == SLOT_HEAD)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/equipped(mob/user, slot)
	..()
	if(slot != SLOT_HEAD)
		if(suit)
			suit.RemoveHelmet()
			soundloop.stop(user)
		else
			qdel(src)
	else
		soundloop.start(user)

/obj/item/clothing/head/helmet/space/hardsuit/proc/display_visor_message(var/msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message("[icon2html(src, wearer)]<b>[span_robot("[msg]")]</b>", MSG_VISUAL)

/obj/item/clothing/head/helmet/space/hardsuit/rad_act(severity)
	. = ..()
	rad_count += severity

/obj/item/clothing/head/helmet/space/hardsuit/process()
	if(!rad_count)
		grace_count++
		if(grace_count == 2)
			soundloop.last_radiation = 0
		return

	grace_count = 0
	rad_record -= rad_record/5
	rad_record += rad_count/5
	rad_count = 0

	soundloop.last_radiation = rad_record

/obj/item/clothing/head/helmet/space/hardsuit/emp_act(severity)
	. = ..()
	display_visor_message("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!")


/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	max_integrity = 300
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 75, FIRE = 50, ACID = 75, WOUND = 10)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(/datum/action/item_action/toggle_helmet)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/tank/jetpack/suit/jetpack = null
	var/hardsuit_type

/obj/item/clothing/suit/space/hardsuit/Initialize()
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)
	. = ..()

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, span_warning("[src] already has a jetpack installed."))
			return
		if(src == user.get_item_by_slot(SLOT_WEAR_SUIT)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, span_warning("You cannot install the upgrade to [src] while wearing it."))
			return

		if(user.transferItemToLoc(I, src))
			jetpack = I
			to_chat(user, span_notice("You successfully install the jetpack into [src]."))
			return
	else if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!jetpack)
			to_chat(user, span_warning("[src] has no jetpack installed."))
			return
		if(src == user.get_item_by_slot(SLOT_WEAR_SUIT))
			to_chat(user, span_warning("You cannot remove the jetpack from [src] while wearing it."))
			return

		jetpack.turn_off(user)
		jetpack.forceMove(drop_location())
		jetpack = null
		to_chat(user, span_notice("You successfully remove the jetpack from [src]."))
		return
	return ..()


/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(jetpack)
		if(slot == SLOT_WEAR_SUIT)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == SLOT_WEAR_SUIT) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return 1

	//Engineering
/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	hardsuit_type = "engineering"
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 75, FIRE = 100, ACID = 75, WOUND = 10)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 75, FIRE = 100, ACID = 75, WOUND = 10)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	resistance_flags = FIRE_PROOF

	//Atmospherics
/obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	icon_state = "hardsuit0-atmospherics"
	item_state = "atmo_helm"
	hardsuit_type = "atmospherics"
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 25, FIRE = 100, ACID = 75, WOUND = 10)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding."
	icon_state = "hardsuit-atmospherics"
	item_state = "atmo_hardsuit"
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 25, FIRE = 100, ACID = 75, WOUND = 10)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/atmos

	//Elder_Atmosian's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/elder_atmosian
	name = "Elder Atmosian Hardsuit Helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding. This one is made with the toughest and rarest materials available to man."
	icon_state = "hardsuit0-flight"
	item_state = "flighthelmet"
	hardsuit_type = "flight"
	armor = list(MELEE = 40, BULLET = 35, LASER = 25, ENERGY = 30, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, WOUND = 20)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_1 = RAD_PROTECT_CONTENTS_1

/obj/item/clothing/suit/space/hardsuit/elder_atmosian
	name = "Elder Atmosian Hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding. This one is made with the toughest and rarest materials available to man."
	icon_state = "flightsuit"
	item_state = "flightsuit"
	armor = list(MELEE = 40, BULLET = 35, LASER = 25, ENERGY = 30, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, WOUND = 20)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/elder_atmosian
	jetpack = /obj/item/tank/jetpack/suit
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_1 = RAD_PROTECT_CONTENTS_1
	slowdown = 0.6

	//Chief Engineer's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	item_state = "ce_helm"
	hardsuit_type = "white"
	armor = list(MELEE = 40, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 90, WOUND = 10)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/elite
	icon_state = "hardsuit-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	armor = list(MELEE = 40, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 90, WOUND = 10)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	jetpack = /obj/item/tank/jetpack/suit

	//Mining hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating for wildlife encounters and dual floodlights."
	icon_state = "hardsuit0-mining"
	item_state = "mining_helm"
	hardsuit_type = "mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	heat_protection = HEAD
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 75, WOUND = 15)
	brightness_on = 7
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator)

/obj/item/clothing/head/helmet/space/hardsuit/mining/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/suit/space/hardsuit/mining
	icon_state = "hardsuit-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating for wildlife encounters."
	item_state = "mining_hardsuit"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 75, WOUND = 15)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/suit/space/hardsuit/mining/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate)

	//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 90, WOUND = 25)
	on = TRUE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	visor_flags_inv = HIDEMASK|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	visor_flags = STOPSPRESSUREDAMAGE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon()
	icon_state = "hardsuit[on]-[hardsuit_type]"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/Initialize()
	. = ..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/syndi))
		linkedsuit = loc

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, span_warning("You cannot toggle your helmet while in this [user.loc]!") )
		return
	on = !on
	if(on || force)
		to_chat(user, span_notice("You switch your hardsuit to EVA mode, sacrificing speed for space protection."))
		name = initial(name)
		desc = initial(desc)
		set_light(brightness_on)
		clothing_flags |= visor_flags
		flags_cover |= HEADCOVERSEYES | HEADCOVERSMOUTH
		flags_inv |= visor_flags_inv
		cold_protection |= HEAD
	else
		to_chat(user, span_notice("You switch your hardsuit to combat mode and can now run at full speed."))
		name += " (combat)"
		desc = alt_desc
		set_light(0)
		clothing_flags &= ~visor_flags
		flags_cover &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
		flags_inv &= ~visor_flags_inv
		cold_protection &= ~HEAD
	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	toggle_hardsuit_mode(user)
	user.update_inv_head()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/toggle_hardsuit_mode(mob/user) //Helmet Toggles Suit Mode
	if(linkedsuit)
		if(on)
			linkedsuit.name = initial(linkedsuit.name)
			linkedsuit.desc = initial(linkedsuit.desc)
			linkedsuit.slowdown = 1
			linkedsuit.clothing_flags |= STOPSPRESSUREDAMAGE
			linkedsuit.cold_protection |= CHEST | GROIN | LEGS | FEET | ARMS | HANDS
		else
			linkedsuit.name += " (combat)"
			linkedsuit.desc = linkedsuit.alt_desc
			linkedsuit.slowdown = 0
			linkedsuit.clothing_flags &= ~STOPSPRESSUREDAMAGE
			linkedsuit.cold_protection &= ~(CHEST | GROIN | LEGS | FEET | ARMS | HANDS)

		linkedsuit.icon_state = "hardsuit[on]-[hardsuit_type]"
		linkedsuit.update_icon()
		user.update_inv_wear_suit()
		user.update_inv_w_uniform()


/obj/item/clothing/suit/space/hardsuit/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 50, BIO = 100, RAD = 50, FIRE = 50, ACID = 90, WOUND = 25)
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit

//Elite Syndie suit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fireproofing. It is in EVA mode. Property of Gorlex Marauders."
	alt_desc = "An elite version of the syndicate helmet, with improved armour and fireproofing. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 25, BOMB = 90, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in travel mode."
	alt_desc = "An elite version of the syndicate hardsuit, with improved armour and fireproofing. It is in combat mode."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor = list(MELEE = 60, BULLET = 60, LASER = 50, ENERGY = 25, BOMB = 90, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

//The Owl Hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/owl
	name = "owl hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced helmet designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	item_state = "s_helmet"
	hardsuit_type = "owl"
	visor_flags_inv = 0
	visor_flags = 0
	on = FALSE

/obj/item/clothing/suit/space/hardsuit/syndi/owl
	name = "owl hardsuit"
	desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in travel mode."
	alt_desc = "A dual-mode advanced hardsuit designed for any crime-fighting situation. It is in combat mode."
	icon_state = "hardsuit1-owl"
	item_state = "s_suit"
	hardsuit_type = "owl"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/owl

//Carp hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/carp
	name = "carp helmet"
	desc = "Spaceworthy and it looks like a space carp's head, smells like one too."
	icon_state = "carp_helm"
	item_state = "syndicate"
	armor = list(MELEE = -20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 75, FIRE = 60, ACID = 75)	//As whimpy as a space carp
	brightness_on = 0 //luminosity when on
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/carp/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/suit/space/hardsuit/carp
	name = "carp space suit"
	desc = "A slimming piece of dubious space carp technology, you suspect it won't stand up to hand-to-hand blows."
	icon_state = "carp_suit"
	item_state = "space_suit_syndicate"
	slowdown = 0	//Space carp magic, never stop believing
	armor = list(MELEE = -20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 75, FIRE = 60, ACID = 75) //As whimpy whimpy whoo
	allowed = list(/obj/item/tank/internals, /obj/item/pneumatic_cannon/speargun)	//I'm giving you a hint here
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/carp

/obj/item/clothing/head/helmet/space/hardsuit/carp/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == SLOT_HEAD)
		user.faction |= "carp"

/obj/item/clothing/head/helmet/space/hardsuit/carp/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		user.faction -= "carp"

// space dragon hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/carp/dragon
	name = "dragon helmet"
	desc = "A scaley heat resistant helm sporting a fearsome carp dragon look and smell."
	icon_state = "carpdragon_helm"
	item_state = "carpdragon_helm"
	armor = list(MELEE = 50, BULLET = 30, LASER = 50, ENERGY = 30, BOMB = 50, BIO = 100, RAD = 90, FIRE = 100, ACID = 100) //not so whimpy now
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/carp/dragon
	name = "dragon space suit"
	desc = "A tough, space and heat resistant suit patched together with space dragon scales."
	icon_state = "carpdragon"
	item_state = "carpdragon"
	armor = list(MELEE = 50, BULLET = 30, LASER = 50, ENERGY = 30, BOMB = 50, BIO = 100, RAD = 90, FIRE = 100, ACID = 100)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/carp/dragon
	resistance_flags = FIRE_PROOF | ACID_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT


	//Wizard hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "hardsuit0-wiz"
	item_state = "wiz_helm"
	hardsuit_type = "wiz"
	resistance_flags = FIRE_PROOF | ACID_PROOF //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 25, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, WOUND = 30)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/wizard
	icon_state = "hardsuit-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 20, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 25, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, WOUND = 30)
	allowed = list(/obj/item/teleportation_scroll, /obj/item/tank/internals)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/wizard
	slowdown = 0

/obj/item/clothing/suit/space/hardsuit/wizard/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, FALSE, FALSE, ITEM_SLOT_OCLOTHING, INFINITY, FALSE)


	//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	item_state = "medical_helm"
	hardsuit_type = "medical"
	flash_protect = 0
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 60, FIRE = 60, ACID = 75, WOUND = 10)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SCAN_REAGENTS

/obj/item/clothing/suit/space/hardsuit/medical
	icon_state = "hardsuit-medical"
	name = "medical hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Built with lightweight materials for easier movement."
	item_state = "medical_hardsuit"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/firstaid, /obj/item/healthanalyzer, /obj/item/stack/medical)
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 60, FIRE = 60, ACID = 75, WOUND = 10)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical
	slowdown = 0.5

	//Research Director hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/rd
	name = "prototype hardsuit helmet"
	desc = "A prototype helmet designed for research in a hazardous, low pressure environment. Scientific data flashes across the visor."
	icon_state = "hardsuit0-rd"
	hardsuit_type = "rd"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 100, BIO = 100, RAD = 60, FIRE = 60, ACID = 80, WOUND = 15)
	var/explosion_detection_dist = 21
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SCAN_REAGENTS
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_research_scanner)

/obj/item/clothing/head/helmet/space/hardsuit/rd/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, .proc/sense_explosion)

/obj/item/clothing/head/helmet/space/hardsuit/rd/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == SLOT_HEAD)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.add_hud_to(user)

/obj/item/clothing/head/helmet/space/hardsuit/rd/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
		DHUD.remove_hud_from(user)

/obj/item/clothing/head/helmet/space/hardsuit/rd/proc/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range,
		light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	var/turf/T = get_turf(src)
	if(T.z != epicenter.z)
		return
	if(get_dist(epicenter, T) > explosion_detection_dist)
		return
	display_visor_message("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]")

/obj/item/clothing/suit/space/hardsuit/rd
	icon_state = "hardsuit-rd"
	name = "prototype hardsuit"
	desc = "A prototype suit that protects against hazardous, low pressure environments. Fitted with extensive plating for handling explosives and dangerous research materials."
	item_state = "hardsuit-rd"
	resistance_flags = ACID_PROOF | FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/energy/wormhole_projector,
	/obj/item/hand_tele, /obj/item/aicard)
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 100, BIO = 100, RAD = 60, FIRE = 60, ACID = 80, WOUND = 15)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/rd



	//Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	hardsuit_type = "sec"
	armor = list(MELEE = 35, BULLET = 25, LASER = 30,ENERGY = 10, BOMB = 10, BIO = 100, RAD = 50, FIRE = 75, ACID = 75, WOUND = 20)


/obj/item/clothing/suit/space/hardsuit/security
	icon_state = "hardsuit-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	armor = list(MELEE = 35, BULLET = 25, LASER = 30, ENERGY = 10, BOMB = 10, BIO = 100, RAD = 50, FIRE = 75, ACID = 75, WOUND = 20)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security

/obj/item/clothing/suit/space/hardsuit/security/Initialize()
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

	//Head of Security hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "head of security's hardsuit helmet"
	desc = "A special bulky helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-hos"
	hardsuit_type = "hos"
	armor = list(MELEE = 45, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 100, RAD = 50, FIRE = 95, ACID = 95, WOUND = 25)


/obj/item/clothing/suit/space/hardsuit/security/hos
	icon_state = "hardsuit-hos"
	name = "head of security's hardsuit"
	desc = "A special bulky suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	armor = list(MELEE = 45, BULLET = 30, LASER = 30, ENERGY = 10, BOMB = 25, BIO = 100, RAD = 50, FIRE = 95, ACID = 95, WOUND = 25)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/tank/jetpack/suit

	//SWAT MKII
/obj/item/clothing/head/helmet/space/hardsuit/swat
	name = "\improper MK.II SWAT Helmet"
	icon_state = "swat2helm"
	item_state = "swat2helm"
	desc = "A tactical SWAT helmet MK.II."
	armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, WOUND = 15)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR //we want to see the mask
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/swat/attack_self()

/obj/item/clothing/suit/space/hardsuit/swat
	name = "\improper MK.II SWAT Suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available."
	icon_state = "swat2"
	item_state = "swat2"
	armor = list(MELEE = 40, BULLET = 50, LASER = 50, ENERGY = 25, BOMB = 50, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, WOUND = 15)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this needed to be added a long fucking time ago
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat

/obj/item/clothing/suit/space/hardsuit/swat/Initialize()
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

	//Captain
/obj/item/clothing/head/helmet/space/hardsuit/swat/captain
	name = "captain's hardsuit helmet"
	icon_state = "capspace"
	item_state = "capspacehelmet"
	desc = "A tactical MK.II SWAT helmet boasting better protection and a horrible fashion sense."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR	//Full helmet

/obj/item/clothing/suit/space/hardsuit/swat/captain
	name = "captain's SWAT suit"
	desc = "A MK.II SWAT suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available. Usually reserved for heavy hitter corporate security, this one has a regal finish in Nanotrasen company colors. Better not let the assistants get a hold of it."
	icon_state = "caparmor"
	item_state = "capspacesuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat/captain

	//Clown
/obj/item/clothing/head/helmet/space/hardsuit/clown
	name = "cosmohonk hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-humor environment. Has radiation shielding."
	icon_state = "hardsuit0-clown"
	item_state = "hardsuit0-clown"
	hardsuit_type = "clown"
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 75, FIRE = 60, ACID = 30)

/obj/item/clothing/suit/space/hardsuit/clown
	name = "cosmohonk hardsuit"
	desc = "A special suit that protects against hazardous, low humor environments. Has radiation shielding. Only a true clown can wear it."
	icon_state = "hardsuit-clown"
	item_state = "clown_hardsuit"
	armor = list(MELEE = 30, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 100, RAD = 75, FIRE = 60, ACID = 30)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/clown

/obj/item/clothing/suit/space/hardsuit/clown/mob_can_equip(mob/M, slot)
	if(!..() || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/H = M
	if(H.mind.assigned_role == "Clown")
		return TRUE
	else
		return FALSE


	//Emergency Response Team suits
/obj/item/clothing/head/helmet/space/hardsuit/ert
	name = "emergency response team commander helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has blue highlights."
	icon_state = "hardsuit0-ert_commander"
	item_state = "hardsuit0-ert_commander"
	hardsuit_type = "ert_commander"
	armor = list(MELEE = 65, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80)
	strip_delay = 130
	brightness_on = 7
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/hardsuit/ert/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/suit/space/hardsuit/ert
	name = "emergency response team commander hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has blue highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_command"
	item_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 65, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80)
	slowdown = 0
	strip_delay = 130
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

	//ERT Security
/obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	name = "emergency response team security helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has red highlights."
	icon_state = "hardsuit0-ert_security"
	item_state = "hardsuit0-ert_security"
	hardsuit_type = "ert_security"

/obj/item/clothing/suit/space/hardsuit/ert/sec
	name = "emergency response team security hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has red highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_security"
	item_state = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/sec

	//ERT Engineering
/obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	name = "emergency response team engineering helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has orange highlights."
	icon_state = "hardsuit0-ert_engineer"
	item_state = "hardsuit0-ert_engineer"
	hardsuit_type = "ert_engineer"

/obj/item/clothing/suit/space/hardsuit/ert/engi
	name = "emergency response team engineering hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has orange highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_engineer"
	item_state = "ert_engineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engi

	//ERT Medical
/obj/item/clothing/head/helmet/space/hardsuit/ert/med
	name = "emergency response team medical helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has white highlights."
	icon_state = "hardsuit0-ert_medical"
	item_state = "hardsuit0-ert_medical"
	hardsuit_type = "ert_medical"

/obj/item/clothing/suit/space/hardsuit/ert/med
	name = "emergency response team medical hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has white highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_medical"
	item_state = "ert_medical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/med

	//ERT Janitor
/obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	name = "emergency response team janitorial helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has purple highlights."
	icon_state = "hardsuit0-ert_janitor"
	item_state = "hardsuit0-ert_janitor"
	hardsuit_type = "ert_janitor"

/obj/item/clothing/suit/space/hardsuit/ert/jani
	name = "emergency response team janitorial hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has purple highlights. Offers superb protection against environmental hazards. This one has extra clips for holding various janitorial tools."
	icon_state = "ert_janitor"
	item_state = "ert_janitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	allowed = list(/obj/item/storage/bag/trash, /obj/item/melee/flyswatter, /obj/item/mop, /obj/item/holosign_creator/janibarrier, /obj/item/reagent_containers/glass/bucket, /obj/item/reagent_containers/spray/chemsprayer/janitor)

	//Paranormal ERT
/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	name = "paranormal response team helmet"
	desc = "A helmet worn by those who deal with paranormal threats for a living."
	icon_state = "hardsuit0-prt"
	item_state = "hardsuit0-prt"
	hardsuit_type = "knight_grey"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, FALSE, FALSE, TRUE, ITEM_SLOT_OCLOTHING)

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	name = "paranormal response team hardsuit"
	desc = "Powerful wards are built into this hardsuit, protecting the user from all manner of paranormal threats."
	icon_state = "knight_grey"
	item_state = "knight_grey"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, TRUE, ITEM_SLOT_OCLOTHING)

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's hardsuit"
	icon_state = "hardsuit-inq"
	item_state = "hardsuit-inq"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's helmet"
	icon_state = "hardsuit0-inq"
	item_state = "hardsuit0-inq"

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/beserker
	name = "champion's hardsuit"
	desc = "Voices echo from the hardsuit, driving the user insane."
	icon_state = "hardsuit-beserker"
	item_state = "hardsuit-beserker"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/beserker

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/beserker
	name = "champion's helmet"
	desc = "Peering into the eyes of the helmet is enough to seal damnation."
	icon_state = "hardsuit0-beserker"
	item_state = "hardsuit0-beserker"


	//Old Prototype
/obj/item/clothing/head/helmet/space/hardsuit/ancient
	name = "prototype RIG hardsuit helmet"
	desc = "Early prototype RIG hardsuit helmet, designed to quickly shift over a user's head. Design constraints of the helmet mean it has no inbuilt cameras, thus it restricts the users visability."
	icon_state = "hardsuit0-ancient"
	item_state = "anc_helm"
	hardsuit_type = "ancient"
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 75)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ancient
	name = "prototype RIG hardsuit"
	desc = "Prototype powered RIG hardsuit. Provides excellent protection from the elements of space while being comfortable to move around in, thanks to the powered locomotives. Remains very bulky however."
	icon_state = "hardsuit-ancient"
	item_state = "anc_hardsuit"
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 50, BIO = 100, RAD = 100, FIRE = 100, ACID = 75)
	slowdown = 3
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ancient
	resistance_flags = FIRE_PROOF
	var/footstep = 1
	var/mob/listeningTo

/obj/item/clothing/suit/space/hardsuit/ancient/proc/on_mob_move()
	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(footstep > 1)
		playsound(src, 'sound/effects/servostep.ogg', 100, 1)
		footstep = 0
	else
		footstep++

/obj/item/clothing/suit/space/hardsuit/ancient/equipped(mob/user, slot)
	. = ..()
	if(slot != SLOT_WEAR_SUIT)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		return
	if(listeningTo == user)
		return
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_mob_move)
	listeningTo = user

/obj/item/clothing/suit/space/hardsuit/ancient/dropped()
	. = ..()
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)

/obj/item/clothing/suit/space/hardsuit/ancient/Destroy()
	listeningTo = null
	return ..()

/////////////SHIELDED//////////////////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded
	name = "shielded hardsuit"
	desc = "A hardsuit with built in energy shielding. Will rapidly recharge when not under fire."
	icon_state = "hardsuit-hos"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	allowed = null
	armor = list(MELEE = 30, BULLET = 15, LASER = 30, ENERGY = 10, BOMB = 10, BIO = 100, RAD = 50, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 200 //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging
	var/shield_state = "shield-old"
	var/shield_on = "shield-old"

/obj/item/clothing/suit/space/hardsuit/shielded/Initialize()
	. = ..()
	if(!allowed)
		allowed = GLOB.advanced_hardsuit_allowed

/obj/item/clothing/suit/space/hardsuit/shielded/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	recharge_cooldown = world.time + recharge_delay
	if(current_charges > 0)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(2, 1, src)
		s.start()
		owner.visible_message(span_danger("[owner]'s shields deflect [attack_text] in a shower of sparks!"))
		current_charges--
		if(recharge_rate)
			START_PROCESSING(SSobj, src)
		if(current_charges <= 0)
			owner.visible_message("[owner]'s shield overloads!")
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return 1
	return 0


/obj/item/clothing/suit/space/hardsuit/shielded/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/space/hardsuit/shielded/process()
	if(world.time > recharge_cooldown && current_charges < max_charges)
		current_charges = clamp((current_charges + recharge_rate), 0, max_charges)
		playsound(loc, 'sound/magic/charge.ogg', 50, 1)
		if(current_charges == max_charges)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			STOP_PROCESSING(SSobj, src)
		shield_state = "[shield_on]"
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			C.update_inv_wear_suit()

/obj/item/clothing/suit/space/hardsuit/shielded/worn_overlays(isinhands)
	. = list()
	if(!isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', shield_state, MOB_LAYER + 0.01)

/obj/item/clothing/head/helmet/space/hardsuit/shielded
	resistance_flags = FIRE_PROOF | ACID_PROOF

///////////////Capture the Flag////////////////////

/obj/item/clothing/suit/space/hardsuit/shielded/ctf
	name = "white team armor"
	desc = "Standard issue hardsuit for playing capture the flag."
	icon_state = "ctf-white"
	item_state = null
	hardsuit_type = "ctf-white"
	// Adding TRAIT_NODROP is done when the CTF spawner equips people
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 100, RAD = 100, FIRE = 95, ACID = 95)
	slowdown = 0
	max_charges = 5

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	name = "red team armor"
	icon_state = "ctf-red"
	item_state =  null
	hardsuit_type = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	shield_state = "shield-red"
	shield_on = "shield-red"

/obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	name = "blue team armor"
	icon_state = "ctf-blue"
	item_state = null
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue



/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	name = "white team helmet"
	desc = "Standard issue hardsuit helmet for playing capture the flag."
	icon_state = "hardsuit0-ctf_white"
	item_state = null
	hardsuit_type = "ert_medical"
	armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 100, RAD = 100, FIRE = 95, ACID = 95)


/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/red
	name = "red team helmet"
	icon_state = "hardsuit0-ctf_red"
	item_state = null
	hardsuit_type = "ert_security"

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf/blue
	name = "blue team helmet"
	desc = "Standard issue hardsuit helmet for playing capture the flag."
	icon_state = "hardsuit0-ctf_blue"
	item_state = null
	hardsuit_type = "ert_commander"





//////Syndicate Version

/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit"
	desc = "An advanced hardsuit with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	hardsuit_type = "syndi"
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 80, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, WOUND = 30)
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/transforming/energy/sword/saber, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	slowdown = 0


/obj/item/clothing/suit/space/hardsuit/shielded/syndi/Initialize()
	jetpack = new /obj/item/tank/jetpack/suit(src)
	. = ..()

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced hardsuit helmet with built in energy shielding."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	hardsuit_type = "syndi"
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 80, BIO = 100, RAD = 50, FIRE = 100, ACID = 100, WOUND = 30)

///Deathsquad version

/obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	name = "MK.III SWAT Helmet"
	desc = "An advanced tactical space helmet."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, WOUND = 30)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/deathsquad/attack_self(mob/user)
	return

/obj/item/clothing/suit/space/hardsuit/deathsquad
	name = "MK.III SWAT Suit"
	desc = "A prototype designed to replace the ageing MK.II SWAT suit. Based on the streamlined MK.II model, the traditional ceramic and graphene plate construction was replaced with plasteel, allowing superior armor against most threats. There's room for some kind of energy projection device on the back."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, WOUND = 30)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	dog_fashion = /datum/dog_fashion/back/deathsquad


/obj/item/clothing/suit/space/hardsuit/shielded/swat
	name = "death commando hardsuit"
	desc = "An advanced hardsuit favored by commandos for use in special operations."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	hardsuit_type = "syndi"
	max_charges = 4
	current_charges = 4
	recharge_delay = 15
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	dog_fashion = /datum/dog_fashion/back/deathsquad

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	name = "death commando hardsuit helmet"
	desc = "A tactical helmet with built in energy shielding."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	hardsuit_type = "syndi"
	armor = list(MELEE = 80, BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/suit/space/hardsuit/shielded/swat/honk
	name = "honk squad spacesuit"
	desc = "A hilarious hardsuit favored by HONK squad troopers for use in special pranks."
	icon_state = "hardsuit-clown"
	item_state = "clown_hardsuit"
	hardsuit_type = "clown"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/shielded/swat/honk

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat/honk
	name = "honk squad helmet"
	desc = "A hilarious helmet with built-in anti-mime propaganda shielding."
	icon_state = "hardsuit0-clown"
	item_state = "hardsuit0-clown"
	hardsuit_type = "clown"

//POWERARMORS
//Currently are no different from normal hardsuits, except maybe for the higher armor ratings.

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor_t45b
	name = "Salvaged T-45b helmet"
	desc = "It's some barely-functional power armor helmet from a by-gone age."
	icon_state = "hardsuit0-t45b"
	item_state = "t45b_helm"
	hardsuit_type = "t45b"
	armor = list(MELEE = 50, BULLET = 48, LASER = 25, ENERGY = 25, BOMB = 48, BIO = 100, RAD = 50, FIRE = 50, ACID = 25)

/obj/item/clothing/suit/space/hardsuit/powerarmor_t45b
	name = "Salvaged T-45b power armor"
	desc = "It's some barely-functional power armor, probably hundreds of years old."
	icon_state = "hardsuit-t45b"
	item_state = "t45b_hardsuit"
	armor = list(MELEE = 50, BULLET = 48, LASER = 25, ENERGY = 25, BOMB = 48, BIO = 0, RAD = 0, FIRE = 0, ACID = 25)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/powerarmor_t45b
	hardsuit_type = "t45b"

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor_advanced
	name = "X-01 power helmet"
	desc = "It's an X-01 power armor helmet. It looks pretty impressive and threatening."
	icon_state = "hardsuit0-advpa1"
	item_state = "advpa1_helm"
	hardsuit_type = "advpa1"
	strip_delay = 100
	equip_delay_other = 100
	armor = list(MELEE = 50, BULLET = 10, LASER = 25, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 10, WOUND = 0)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/powerarmor_advanced
	name = "X-01 power armor"
	desc = "A suit of X-01 power armor. It looks pretty impressive and threatening. The suit storage hook looks reinforced, able to hold bulkier items."
	icon_state = "hardsuit-advancedpa1"
	item_state = "advpa1_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/powerarmor_advanced
	hardsuit_type = "advancedpa1"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/twohanded/required/kinetic_crusher, /obj/item/pickaxe, /obj/item/pickaxe/drill/jackhammer, /obj/item/shield/riot/goliath, /obj/item/shield/riot/roman)
	armor = list(MELEE = 50, BULLET = 10, LASER = 25, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 10, WOUND = 0)
	slowdown = 0
	strip_delay = 180
	equip_delay_other = 180
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/powerarmor_advanced/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate,10,/obj/item/stack/sheet/animalhide/weaver_chitin, list(MELEE = 0.5, BULLET = 3, LASER = 0.5, ENERGY = 2.5, BOMB = 5, BIO = 10, RAD = 8, FIRE = 10, ACID = 9, WOUND = 0.1))

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor_advanced/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate,10,/obj/item/stack/sheet/animalhide/weaver_chitin, list(MELEE = 0.5, BULLET = 3, LASER = 0.5, ENERGY = 2.5, BOMB = 5, BIO = 10, RAD = 8, FIRE = 10, ACID = 9, WOUND = 0.1))

/obj/item/clothing/head/helmet/space/hardsuit/syndi/debug // reused code so I dont have to make new procs
	name = "debug hardsuit helmet"
	desc = "A debug hardsuit helmet. It is in EVA mode."
	alt_desc = "A debug hardsuit helmet. It is in combat mode."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/syndi/debug
	name = "debug hardsuit"
	desc = "A debug hardsuit. It is in travel mode."
	alt_desc = "A debug hardsuit. It is in combat mode."
	icon_state = "hardsuit0-syndielite"
	hardsuit_type = "syndielite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/debug
	armor = list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	slowdown = 0
