// CHAPLAIN CUSTOM ARMORS //

/obj/item/choice_beacon/holy
	name = "armaments beacon"
	desc = "Contains a set of armaments for the chaplain."

/obj/item/choice_beacon/holy/canUseBeacon(mob/living/user)
	if(user.mind && user.mind.holy_role)
		return ..()
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
		return FALSE

/obj/item/choice_beacon/holy/generate_display_names()
	var/static/list/holy_item_list
	if(!holy_item_list)
		holy_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/holy)
		for(var/V in templist)
			var/atom/A = V
			holy_item_list[initial(A.name)] = A
	return holy_item_list

/obj/item/choice_beacon/holy/spawn_option(obj/choice,mob/living/M)
	if(!GLOB.holy_armor_type)
		..()
		playsound(src, 'sound/effects/pray_chaplain.ogg', 40, 1)
		SSblackbox.record_feedback("tally", "chaplain_armor", 1, "[choice]")
		GLOB.holy_armor_type = choice
	else
		to_chat(M, span_warning("A selection has already been made. Self-Destructing..."))
		return

/obj/item/storage/box/holy
	name = "Templar Kit"

/obj/item/storage/box/holy/PopulateContents()
	new /obj/item/clothing/head/helmet/chaplain(src)
	new /obj/item/clothing/suit/armor/riot/chaplain(src)

/obj/item/clothing/suit/armor/riot/chaplain
	name = "crusader armour"
	desc = "A maintained, full set of plate armor, complete with a tabard. Heavy, but robust."
	icon_state = "knight_templar"
	item_state = "knight_templar"
	armor = list(MELEE = 60, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 40, BIO = 2, RAD = 0, FIRE = 0, ACID = 50) //Medieval armor was exceptional against melee weaponry and shrapnel, as highlighted by breastplate usage during the Napoleonic Wars, but suffered against ballistics
	slowdown = 0.3 //Have you ever worn full plate armor before
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/box/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	blocks_shove_knockdown = FALSE

/obj/item/clothing/head/helmet/chaplain
	name = "crusader helmet"
	desc = "A steel helmet that was often worn by religious knights of ages past. Deus Vult!"
	icon_state = "knight_templar"
	item_state = "knight_templar"
	armor = list(MELEE = 45, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 30, BIO = 2, RAD = 0, FIRE = 0, ACID = 50)
	slowdown = 0.05 //See above
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	strip_delay = 80
	dog_fashion = null

/obj/item/storage/box/holy/student
	name = "Profane Scholar Kit"

/obj/item/storage/box/holy/student/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/studentuni(src)
	new /obj/item/clothing/head/helmet/chaplain/cage(src)

/obj/item/clothing/suit/armor/riot/chaplain/studentuni
	name = "student robe"
	desc = "The uniform of a bygone institute of learning. These robes whip the user into a speedy fervour at the cost of making them more vulnerable to damage."
	icon_state = "studentuni"
	item_state = "studentuni"
	armor = list(MELEE = -25, BULLET = -15, LASER = -15, ENERGY = -10, BOMB = -10, BIO = -2, RAD = 0, FIRE = 0, ACID = 0) //Speed-inspiring robes
	slowdown = -0.2
	body_parts_covered = ARMS|CHEST

/obj/item/clothing/head/helmet/chaplain/cage
	name = "insightful cage"
	desc = "A cage that restrains the will of the self, allowing one to see the profane world for what it is. The user will be more vulnerable but move slightly faster."
	mob_overlay_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	icon_state = "cage"
	item_state = "cage"
	armor = list(MELEE = -15, BULLET = -10, LASER = -10, ENERGY = -5, BOMB = -5, BIO = -2, RAD = 0, FIRE = 0, ACID = 0)
	slowdown = -0.1 //very statistically significant
	worn_x_dimension = 64
	worn_y_dimension = 64
	dynamic_hair_suffix = ""

/obj/item/storage/box/holy/sentinel
	name = "Stone Sentinel Kit"

/obj/item/storage/box/holy/sentinel/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/ancient(src)
	new /obj/item/clothing/head/helmet/chaplain/ancient(src)

/obj/item/clothing/suit/armor/riot/chaplain/ancient
	name = "ancient armour"
	desc = "Armor worn by ancient ethereal protectors, covered head to toe in the stone of Borealia's cavernous walls. Tiny holes in the armor permit the light of their skin to peer through."
	icon_state = "knight_ancient"
	item_state = "knight_ancient"
	armor = list(MELEE = 65, BULLET = 20, LASER = 15, ENERGY = 15, BOMB = 20, BIO = 4, RAD = 0, FIRE = 40, ACID = 60) //LITERALLY made of stone; this is BASICALLY miner armor with HARD slowdown
	slowdown = 0.4 //ROCK; full set is slowdown equal to firesuit

/obj/item/clothing/head/helmet/chaplain/ancient
	name = "ancient helmet"
	desc = "A helmet worn by a relict ethereal knight."
	icon_state = "knight_ancient"
	item_state = "knight_ancient"
	armor = list(MELEE = 50, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 15, BIO = 4, RAD = 0, FIRE = 40, ACID = 60)
	slowdown = 0.1 //Pretty sure riot is just strictly better because lmao

/obj/item/storage/box/holy/witchhunter
	name = "Witchhunter Kit"

/obj/item/storage/box/holy/witchhunter/PopulateContents()
	new /obj/item/clothing/suit/armor/riot/chaplain/witchhunter(src)
	new /obj/item/clothing/head/helmet/chaplain/witchunter_hat(src)

/obj/item/clothing/suit/armor/riot/chaplain/witchhunter
	name = "witch hunter garb"
	desc = "An armored coat sported by the Inquisition, a holy organization that arose in response to humanity's contact with the otherworldly supernatural."
	icon_state = "witchhunter"
	item_state = "witchhunter"
	armor = list(MELEE = 40, BULLET = 10, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 0, RAD = 0, FIRE = 0, ACID = 40) //Basically faster Dark Templar but you lose out on a lot of the non-melee armor
	slowdown = 0.1
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/head/helmet/chaplain/witchunter_hat
	name = "witch hunter hat"
	desc = "The hat of a respected inquisitor, layered with protective plating."
	icon_state = "witchhunterhat"
	item_state = "witchhunterhat"
	armor = list(MELEE = 30, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 5, BIO = 0, RAD = 0, FIRE = 0, ACID = 40)
	slowdown = 0
	flags_cover = HEADCOVERSEYES

/obj/item/storage/box/holy/follower
	name = "Followers of the Chaplain Kit"

/obj/item/storage/box/holy/follower/PopulateContents()
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/leader(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)

/obj/item/clothing/suit/hooded/chaplain_hoodie
	name = "follower hoodie"
	desc = "Hoodie made for acolytes of the chaplain."
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/box/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/tank/internals/ipc_coolant)
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood

/obj/item/clothing/head/hooded/chaplain_hood
	name = "follower hood"
	desc = "Hood made for acolytes of the chaplain."
	icon_state = "chaplain_hood"
	armor = list(MELEE = 5, BULLET = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HEAD //Is this redundant?
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS

/obj/item/clothing/suit/hooded/chaplain_hoodie/leader
	name = "leader hoodie"
	desc = "Hoodie worn by apocalyptic cult leaders. Bling water not included."
	icon_state = "chaplain_hoodie_leader"
	item_state = "chaplain_hoodie_leader"
	armor = list(MELEE = 25, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 5, BIO = 0, RAD = 0, FIRE = 0, ACID = 25) //I don't know specially layered clothing?
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood/leader

/obj/item/clothing/head/hooded/chaplain_hood/leader
	name = "leader hood"
	desc = "The cowl of a fanatical prodigy."
	icon_state = "chaplain_hood_leader"
	armor = list(MELEE = 15, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 25)

/obj/item/storage/box/holy/darktemplar
	name = "Founder Kit of the Black Templars"

/obj/item/storage/box/holy/darktemplar/PopulateContents()
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar(src)
	new /obj/item/clothing/suit/space/hardsuit/darktemplar/chap(src)

/obj/item/clothing/suit/space/hardsuit/darktemplar
	name = "Black Templar armor"
	desc = "Apprentice-rated power armor developed by the Black Templars, a Confederate militant group that cuts out corruption and treachery without mercy."
	icon_state = "darktemplar-follower0"
	item_state = "darktemplar-follower0"
	cold_protection = null
	min_cold_protection_temperature = null
	heat_protection = null
	max_heat_protection_temperature = null
	clothing_flags = null
	armor = list(MELEE = 25, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 15, BIO = 30, RAD = 30, FIRE = 70, ACID = 50) //Crappier version of the standard armor
	slowdown = 0.25 //No sir you are NOT a space marine you are in CHUNKY power armor
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/box/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/darktemplar

/obj/item/clothing/suit/space/hardsuit/darktemplar/chap
	name = "Black Templar chaplain battle armor"
	desc = "A suit of power armor worn by the zealous Black Templars. A fear-inspiring sight for heretics and dissenters."
	icon_state = "darktemplar-chaplain0"
	item_state = "darktemplar-chaplain0"
	armor = list(MELEE = 40, BULLET = 15, LASER = 25, ENERGY = 15, BOMB = 25, BIO = 60, RAD = 40, FIRE = 90, ACID = 80) //Hilariously similar to the goliath cloak but with slowdown because lmao; ultimately made of more advanced, sci-fi materials
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/darktemplar

/obj/item/clothing/head/helmet/space/hardsuit/darktemplar
	name = "Black Templar helmet"
	desc = "A custom-made Black Templar helmet. The words 'Contempt is Armour' and 'Purge Heresy' are written on the side."
	icon_state = "darktemplar-follower1"
	item_state = "darktemplar-follower1"
	armor = list(MELEE = 20, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, BIO = 30, RAD = 30, FIRE = 70, ACID = 50)
	cold_protection = null
	min_cold_protection_temperature = null
	heat_protection = null
	max_heat_protection_temperature = null
	flash_protect = 0 //We are not giving four mfers free flash protection
	clothing_flags = null
	strip_delay = 50
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/darktemplar/chap
	name = "Black Templar chaplain battle helmet"
	desc = "A custom-made Black Templar chaplain battle helmet. The words 'Excise Corruption' and 'The Razebringer Protects' are written on the side."
	icon_state = "darktemplar-chaplain1"
	item_state = "darktemplar-chaplain1"
	armor = list(MELEE = 30, BULLET = 10, LASER = 15, ENERGY = 10, BOMB = 20, BIO = 60, RAD = 40, FIRE = 90, ACID = 80)

// CHAPLAIN NULLROD AND CUSTOM WEAPONS //

/obj/item/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian; its very presence disrupts and dampens the powers of Nar-Sie and Ratvar's followers."
	icon_state = "nullrod"
	item_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 18
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	obj_flags = UNIQUE_RENAME
	wound_bonus = -10
	cryo_preserve = TRUE
	var/reskinned = FALSE
	var/chaplain_spawnable = TRUE

/obj/item/nullrod/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, FALSE, null, null, FALSE)

/obj/item/nullrod/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is killing [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to get closer to god!"))
	playsound(user, 'sound/effects/pray.ogg', 50)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.SetImmobilized(10 SECONDS)
	animate(user, pixel_y = (32*8), time = 10 SECONDS)
	addtimer(CALLBACK(src, .proc/suicide, user), 10 SECONDS)
	return MANUAL_SUICIDE

/obj/item/nullrod/proc/suicide(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.dropItemToGround(src, TRUE, TRUE)
	qdel(user, TRUE)
	

/obj/item/nullrod/attack_self(mob/user)
	if(user.mind && (user.mind.holy_role) && !reskinned)
		reskin_holy_weapon(user)

  /*
  reskin_holy_weapon: Shows a user a list of all available nullrod reskins and based on his choice replaces the nullrod with the reskinned version

  Arguments:
  M : The mob choosing a nullrod reskin
  */
/obj/item/nullrod/proc/reskin_holy_weapon(mob/M)
	var/list/display_names = list()
	var/list/nullrod_icons = list()
	for(var/V in typesof(/obj/item/nullrod))
		var/obj/item/nullrod/rodtype = V
		if(initial(rodtype.chaplain_spawnable))
			display_names[initial(rodtype.name)] = rodtype
			nullrod_icons += list(initial(rodtype.name) = image(icon = initial(rodtype.icon), icon_state = initial(rodtype.icon_state)))

	nullrod_icons = sortList(nullrod_icons)
	var/choice = show_radial_menu(M, src , nullrod_icons, custom_check = CALLBACK(src, .proc/check_menu, M), radius = 42, require_near = TRUE, tooltips = TRUE)
	if(!choice || !check_menu(M))
		return

	var/A = display_names[choice] // This needs to be on a separate var as list member access is not allowed for new
	var/obj/item/nullrod/holy_weapon = new A

	GLOB.holy_weapon_type = holy_weapon.type

	SSblackbox.record_feedback("tally", "chaplain_weapon", 1, "[choice]")

	if(holy_weapon)
		holy_weapon.reskinned = TRUE
		qdel(src)
		M.put_in_active_hand(holy_weapon)

  /*
  check_menu : Checks if we are allowed to interact with a radial menu

  Arguments:
  user : The mob interacting with a menu
  */
/obj/item/nullrod/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(QDELETED(src) || reskinned)
		return FALSE
	if(user.incapacitated() || !user.is_holding(src))
		return FALSE
	return TRUE

/obj/item/nullrod/godhand
	icon = 'icons/obj/wizard.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	name = "god hand"
	desc = "This hand of yours glows with an awesome power!"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = null
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb = list("punched", "cross countered", "pummeled")

/obj/item/nullrod/godhand/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/nullrod/godhand/ignition_effect(atom/A, mob/user)
	. = span_notice("[user] grasps [A] with [user.p_their()] flaming hand, igniting it in a burst of holy flame. Holy hot damn, that is badass. ")

/obj/item/nullrod/staff
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff-red"
	item_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	name = "red holy staff"
	desc = "It has a mysterious, protective aura."
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	slot_flags = ITEM_SLOT_BACK
	block_chance = 50
	var/shield_icon = "shield-red"

/obj/item/nullrod/staff/worn_overlays(isinhands)
	. = list()
	if(isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', shield_icon, MOB_LAYER + 0.01)

/obj/item/nullrod/staff/blue
	icon = 'icons/obj/wizard.dmi'
	name = "blue holy staff"
	icon_state = "staff-blue"
	item_state = "godstaff-blue"
	shield_icon = "shield-old"

/obj/item/nullrod/claymore
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "holyblade"
	item_state = "holyblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "holy claymore"
	desc = "A weapon fit for a crusade!"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	block_chance = 30
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/nullrod/claymore/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/nullrod/claymore/darkblade
	icon_state = "cultblade"
	item_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	hitsound = 'sound/hallucinations/growl1.ogg'

/obj/item/nullrod/claymore/chainsaw_sword
	icon_state = "chainswordon"
	item_state = "chainswordon"
	name = "sacred chainsaw sword"
	desc = "Suffer not a heretic to live."
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'

/obj/item/nullrod/claymore/glowing
	icon_state = "swordon"
	item_state = "swordon"
	name = "force weapon"
	desc = "The blade glows with the power of faith. Or possibly a battery."
	slot_flags = ITEM_SLOT_BELT

/obj/item/nullrod/claymore/katana
	name = "\improper Hanzo steel"
	desc = "Capable of cutting clean through a holy claymore."
	icon_state = "katana"
	item_state = "katana"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK

/obj/item/nullrod/claymore/multiverse
	name = "extradimensional blade"
	desc = "Once the harbinger of an interdimensional war, its sharpness fluctuates wildly."
	icon_state = "multiverse"
	item_state = "multiverse"
	slot_flags = ITEM_SLOT_BELT

/obj/item/nullrod/claymore/multiverse/attack(mob/living/carbon/M, mob/living/carbon/user)
	force = rand(1, 30)
	..()

/obj/item/nullrod/claymore/saber
	name = "light energy sword"
	hitsound = 'sound/weapons/blade1.ogg'
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "swordblue"
	item_state = "swordblue"
	desc = "If you strike me down, I shall become more robust than you can possibly imagine."
	slot_flags = ITEM_SLOT_BELT

/obj/item/nullrod/claymore/saber/red
	name = "dark energy sword"
	icon_state = "swordred"
	item_state = "swordred"
	desc = "Woefully ineffective when used on steep terrain."

/obj/item/nullrod/claymore/saber/pirate
	name = "nautical energy sword"
	icon_state = "cutlass1"
	item_state = "cutlass1"
	desc = "Convincing HR that your religion involved piracy was no mean feat."

/obj/item/nullrod/claymore/corvo
	name = "folding blade"
	desc = "A relic of a fallen empire. Touch of the outsider not included."
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	icon_state = "corvo_0"
	item_state = "corvo_0"
	slot_flags = ITEM_SLOT_BELT
	var/on = FALSE
	var/on_sound = 'sound/weapons/batonextend.ogg'

/obj/item/nullrod/claymore/corvo/attack_self(mob/user)
	on = !on

	if(on)
		to_chat(user, "<span class ='warning'>You unfold the sword.</span>")
		icon_state = "corvo_1"
		item_state = "nullrod"
		w_class = WEIGHT_CLASS_NORMAL
		force = 18
		attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	else
		to_chat(user, "<span class ='notice'>You fold the sword.</span>")
		icon_state = "corvo_0"
		item_state = "corvo_0"
		item_state = null //no sprite for concealment even when in hand
		w_class = WEIGHT_CLASS_SMALL
		force = 0
		attack_verb = list("hit", "poked")

	playsound(src.loc, on_sound, 50, 1)
	add_fingerprint(user)


/obj/item/nullrod/sord
	name = "\improper UNREAL SORD"
	desc = "This thing is so unspeakably HOLY you are having a hard time even holding it."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "sord"
	item_state = "sord"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 4.13
	throwforce = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/nullrod/scythe
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "scythe1"
	item_state = "scythe1"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "reaper scythe"
	desc = "Ask not for whom the bell tolls..."
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 35
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_EDGED
	attack_verb = list("chopped", "sliced", "cut", "reaped")

/obj/item/nullrod/scythe/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 70, 110) //the harvest gives a high bonus chance

/obj/item/nullrod/scythe/vibro
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "hfrequency0_ext"
	item_state = "hfrequency1"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "high frequency blade"
	desc = "Bad references are the DNA of the soul."
	attack_verb = list("chopped", "sliced", "cut", "zandatsu'd")
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/nullrod/Hypertool
	icon = 'icons/obj/device.dmi'
	icon_state = "hypertool"
	item_state = "hypertool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	name = "hypertool"
	desc = "A tool so powerful even you cannot perfectly use it."
	armour_penetration = 35
	damtype = BRAIN
	attack_verb = list("pulsed", "mended", "cut")
	hitsound = 'sound/effects/sparks4.ogg'

/obj/item/nullrod/scythe/spellblade
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "spellblade"
	item_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon = 'icons/obj/guns/magic.dmi'
	name = "dormant spellblade"
	desc = "The blade grants the wielder nearly limitless power...if they can figure out how to turn it on, that is."
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/nullrod/scythe/talking
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "talking_sword"
	item_state = "talking_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "possessed blade"
	desc = "When the station falls into chaos, it's nice to have a friend by your side."
	attack_verb = list("chopped", "sliced", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	var/possessed = FALSE

/obj/item/nullrod/scythe/talking/relaymove(mob/user)
	return //stops buckled message spam for the ghost.

/obj/item/nullrod/scythe/talking/attack_self(mob/living/user)
	if(possessed)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		to_chat(user, span_notice("Anomalous otherworldly energies block you from awakening the blade!"))
		return

	to_chat(user, "You attempt to wake the spirit of the blade...")

	possessed = TRUE

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the spirit of [user.real_name]'s blade?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)

	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/shade/S = new(src)
		S.ckey = C.ckey
		S.fully_replace_character_name(null, "The spirit of [name]")
		S.status_flags |= GODMODE
		S.copy_languages(user, LANGUAGE_MASTER)	//Make sure the sword can understand and communicate with the user.
		S.update_atom_languages()
		grant_all_languages(FALSE, FALSE, TRUE)	//Grants omnitongue
		var/input = stripped_input(S,"What are you named?", ,"", MAX_NAME_LEN)

		if(src && input)
			name = input
			S.fully_replace_character_name(null, "The spirit of [input]")
	else
		to_chat(user, "The blade is dormant. Maybe you can try again later.")
		possessed = FALSE

/obj/item/nullrod/scythe/talking/Destroy()
	for(var/mob/living/simple_animal/shade/S in contents)
		to_chat(S, "You were destroyed!")
		qdel(S)
	return ..()

/obj/item/nullrod/scythe/talking/chainsword
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "chainswordon"
	item_state = "chainswordon"
	name = "possessed chainsaw sword"
	desc = "Suffer not a heretic to live."
	chaplain_spawnable = FALSE
	force = 30
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'


/obj/item/nullrod/hammmer
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "hammeron"
	item_state = "hammeron"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	name = "relic war hammer"
	desc = "This war hammer cost the chaplain forty thousand space dollars."
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("smashed", "bashed", "hammered", "crunched")

/obj/item/nullrod/chainsaw
	name = "chainsaw hand"
	desc = "Good? Bad? You're the guy with the chainsaw hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "chainsaw_on"
	item_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT
	sharpness = SHARP_EDGED
	slot_flags = null
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'

/obj/item/nullrod/chainsaw/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 30, 100, 0, hitsound)

/obj/item/nullrod/clown
	icon = 'icons/obj/wizard.dmi'
	icon_state = "clownrender"
	item_state = "render"
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrifices."
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = SHARP_EDGED
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/nullrod/pride_hammer
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "pride"
	name = "Pride-struck Hammer"
	desc = "It resonates an aura of Pride."
	force = 16
	throwforce = 15
	w_class = 4
	slot_flags = ITEM_SLOT_BACK
	attack_verb = list("attacked", "smashed", "crushed", "splattered", "cracked")
	hitsound = 'sound/weapons/blade1.ogg'

/obj/item/nullrod/pride_hammer/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(prob(30) && ishuman(A))
		var/mob/living/carbon/human/H = A
		user.reagents.trans_to(H, user.reagents.total_volume, 1, 1, 0, transfered_by = user)
		to_chat(user, span_notice("Your pride reflects on [H]."))
		to_chat(H, span_userdanger("You feel insecure, taking on [user]'s burden."))

/obj/item/nullrod/whip
	name = "holy whip"
	desc = "What a terrible night to be on Space Station 13."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "chain"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("whipped", "lashed")
	hitsound = 'sound/weapons/chainhit.ogg'
	
/obj/item/nullrod/whip/Initialize()
	. = ..()
	weapon_stats[REACH] = 3

/obj/item/nullrod/fedora
	name = "atheist's fedora"
	desc = "The brim of the hat is as sharp as your wit. The edge would hurt almost as much as disproving the existence of God."
	icon_state = "fedora"
	item_state = "fedora"
	slot_flags = ITEM_SLOT_HEAD
	icon = 'icons/obj/clothing/hats.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 30
	sharpness = SHARP_EDGED
	attack_verb = list("enlightened", "redpilled")

/obj/item/nullrod/armblade
	name = "dark blessing"
	desc = "Particularly twisted deities grant gifts of dubious value."
	icon = 'icons/obj/changeling.dmi'
	icon_state = "arm_blade"
	item_state = "arm_blade"
	tool_behaviour = TOOL_MINING
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	slot_flags = null
	item_flags = ABSTRACT
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	wound_bonus = -20
	bare_wound_bonus = 25

/obj/item/nullrod/armblade/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)

/obj/item/nullrod/armblade/tentacle
	name = "unholy blessing"
	icon_state = "tentacle"
	item_state = "tentacle"

/obj/item/nullrod/carp
	name = "carp-sie plushie"
	desc = "An adorable stuffed toy that resembles the god of all carp. The teeth look pretty sharp. Activate it to receive the blessing of Carp-Sie."
	icon = 'icons/obj/plushes.dmi'
	icon_state = "carpplush"
	item_state = "carp_plushie"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 15
	attack_verb = list("bitten", "eaten", "fin slapped")
	hitsound = 'sound/weapons/bite.ogg'
	var/used_blessing = FALSE

/obj/item/nullrod/carp/attack_self(mob/living/user)
	if(used_blessing)
	else if(user.mind && (user.mind.holy_role))
		to_chat(user, "You are blessed by Carp-Sie. Wild space carp will no longer attack you.")
		user.faction |= "carp"
		used_blessing = TRUE

/obj/item/nullrod/claymore/bostaff //May as well make it a "claymore" and inherit the blocking
	icon = 'icons/obj/weapons/misc.dmi'
	name = "monk's staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts, it is now used to harass the clown."
	w_class = WEIGHT_CLASS_BULKY
	damtype = STAMINA
	force = 15
	block_chance = 40
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_NONE
	hitsound = "swing_hit"
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "bostaff0"
	item_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'

/obj/item/nullrod/tribal_knife
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "crysknife"
	item_state = "crysknife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	name = "arrhythmic knife"
	w_class = WEIGHT_CLASS_HUGE
	desc = "They say fear is the true mind killer, but stabbing them in the head works too. Honour compels you to not sheathe it once drawn."
	sharpness = SHARP_EDGED
	slot_flags = null
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	item_flags = SLOWS_WHILE_IN_HAND

/obj/item/nullrod/tribal_knife/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/butchering, 50, 100)

/obj/item/nullrod/tribal_knife/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/nullrod/tribal_knife/process()
	slowdown = rand(-2, 2)


/obj/item/nullrod/pitchfork
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "unholy pitchfork"
	w_class = WEIGHT_CLASS_NORMAL
	desc = "Holding this makes you look absolutely devilish."
	attack_verb = list("poked", "impaled", "pierced", "jabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_POINTY

/obj/item/nullrod/egyptian
	name = "egyptian staff"
	desc = "A tutorial in mummification is carved into the staff. You could probably craft the wraps if you had some cloth."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "pharoah_sceptre"
	item_state = "pharoah_sceptre"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashes", "smacks", "whacks")

/obj/item/nullrod/servoskull/equipped(mob/living/carbon/human/user, slot)
	..()
	if(hud_type && slot == SLOT_GLASSES)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.add_hud_to(user)

/obj/item/nullrod/servoskull/dropped(mob/living/carbon/human/user)
	..()
	if(hud_type && istype(user) && user.glasses == src)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.remove_hud_from(user)
/obj/item/nullrod/servoskull
	name = "servitor skull"
	desc = "Even in death, I still serve"
	icon = 'icons/obj/clothing/neck.dmi'
	slot_flags = ITEM_SLOT_NECK
	icon_state = "servoskull"
	item_state = "servoskull"
	w_class = WEIGHT_CLASS_SMALL
	force = 7
	throwforce = 15
	alternate_worn_layer = ABOVE_BODY_FRONT_LAYER
	var/hud_type = DATA_HUD_DIAGNOSTIC_ADVANCED
	var/hud_type2 = DATA_HUD_MEDICAL_ADVANCED
	
/obj/item/nullrod/servoskull/equipped(mob/living/carbon/human/user, slot)
	..()
	if(hud_type && slot == SLOT_NECK)
		to_chat(user, "Sensory augmentation initiated")
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.add_hud_to(user)
		var/datum/atom_hud/H2 = GLOB.huds[hud_type2]
		H2.add_hud_to(user)

/obj/item/nullrod/servoskull/dropped(mob/living/carbon/human/user)
	..()
	if(hud_type && istype(user) && user.wear_neck == src)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.remove_hud_from(user)
		var/datum/atom_hud/H2 = GLOB.huds[hud_type2]
		H2.remove_hud_from(user)

/obj/item/nullrod/cross
	name = "golden crucifix"
	desc = "Resist the devil, and he will flee from you."
	icon_state = "cross"
	item_state = "cross"
	force = 0 // How often we forget
	throwforce = 0 // Faith without works is...
	attack_verb = list("blessed")
	var/held_up = FALSE
	var/mutable_appearance/holy_glow_fx
	var/obj/effect/dummy/lighting_obj/moblight/holy_glow_light
	COOLDOWN_DECLARE(holy_notification)

/obj/item/nullrod/cross/attack_self(mob/living/user)
	. = ..()
	if(!istype(user))
		return // sanity
	if(held_up)
		unwield(user)
		return
	user.visible_message(span_notice("[user] raises \the [src]."), span_notice("You raise \the [src]."))
	held_up = TRUE
	w_class = WEIGHT_CLASS_GIGANTIC // Heavy, huh?
	slot_flags = 0
	holy_glow_fx = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
	user.add_overlay(holy_glow_fx)
	holy_glow_light = user.mob_light(_color = LIGHT_COLOR_HOLY_MAGIC, _range = 2)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/unwield)
	RegisterSignal(src, COMSIG_ITEM_PREDROPPED, .proc/drop_unwield)
	START_PROCESSING(SSfastprocess, src)

/obj/item/nullrod/cross/Destroy()
	if(held_up && isliving(loc))
		unwield(loc)
	. = ..()

/obj/item/nullrod/cross/proc/drop_unwield(obj/item, mob/user)
	unwield(user)

/obj/item/nullrod/cross/proc/unwield(mob/user)
	if(!held_up)
		return
	user.visible_message(span_notice("[user] lowers \the [src]."), span_notice("You lower \the [src]."))
	held_up = FALSE
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	if(holy_glow_fx)
		user.cut_overlay(holy_glow_fx)
		holy_glow_fx = null
	if(holy_glow_light)
		QDEL_NULL(holy_glow_light)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	STOP_PROCESSING(SSfastprocess, src)

/obj/item/nullrod/cross/process()
	if(!held_up)
		return PROCESS_KILL // something has gone terribly wrong
	if(!isliving(loc))
		return PROCESS_KILL // something has gone terribly wrong
	
	var/notify = FALSE
	if(COOLDOWN_FINISHED(src, holy_notification))
		COOLDOWN_START(src, holy_notification, 0.8 SECONDS)
		notify = TRUE

	var/list/chapview = view(4, get_turf(loc))
	for(var/mob/living/L in range(2, get_teleport_loc(get_turf(loc), loc, 2)))
		if(!L.mind?.holy_role && (L in chapview)) // Priests are unaffected, trying to use it as a non-priest will harm you
			if(notify)
				to_chat(L, span_userdanger("The holy light burns you!"))
				new /obj/effect/temp_visual/cult/sparks(get_turf(L))
			// Unholy creatures take more damage
			// Everyone else still takes damage but less real damage
			// Average DPS is 5|15 or 10|10 if unholy (burn|stam)
			// Should be incredibly difficult to metacheck with this due to RNG and fast processing
			if(iscultist(L) || is_clockcult(L) || iswizard(L) || isvampire(L) || IS_BLOODSUCKER(L) || IS_VASSAL(L) || IS_HERETIC(L) || IS_HERETIC_MONSTER(L))
				L.adjustFireLoss(rand(3,5) * 0.5) // 1.5-2.5 AVG 2.0
				L.adjustStaminaLoss(2)
			else
				L.adjustFireLoss(rand(1,3) * 0.5) // 0.5-1.5 AVG 1.0
				L.adjustStaminaLoss(3)

/obj/item/nullrod/cross/examine(mob/user)
	. = ..()
	. += "[span_notice("Use in-hand while facing evil to ")][span_danger("purge it.")]"
