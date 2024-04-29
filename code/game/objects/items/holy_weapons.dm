// CHAPLAIN NULLROD AND CUSTOM WEAPONS //
#define MENU_ALL "all"
#define MENU_WEAPON "weapons" //standard weapons
#define MENU_ARM "arms" //things that replace the arm
#define MENU_CLOTHING "clothing" //things that can be worn
#define MENU_MISC "misc" //anything that doesn't quite fit into the other categories

/obj/item/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian; its very presence disrupts and dampens the powers of Nar'sie and Ratvar's followers."
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
	obj_flags = UNIQUE_RENAME | UNIQUE_REDESC
	wound_bonus = -10
	cryo_preserve = TRUE
	var/reskinned = FALSE
	var/menutab = MENU_MISC //that way if someone forgets, it gets put in the tab that isn't specialized
	var/chaplain_spawnable = TRUE
	var/chaplain_bypass = FALSE //if people other than chaplain can select the rod

	var/selected_category = MENU_ALL
	var/list/show_categories = list(MENU_ALL, MENU_WEAPON, MENU_ARM, MENU_CLOTHING, MENU_MISC)
	/// this text will show on the tgui menu when picking the nullrod form they want. should give a better idea of the nullrod's gimmick or quirks without giving away numbers
	var/additional_desc = "How are you seeing this? This is the default Nullrod bonus description. I makey a mistakey."

/obj/item/nullrod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)

/obj/item/nullrod/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is killing [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to get closer to god!"))
	playsound(user, 'sound/effects/pray.ogg', 50)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.SetImmobilized(10 SECONDS)
	animate(user, pixel_y = (32*8), time = 10 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(suicide), user), 10 SECONDS)
	return MANUAL_SUICIDE

/obj/item/nullrod/proc/suicide(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.dropItemToGround(src, TRUE, TRUE)
	qdel(user, TRUE)

/obj/item/nullrod/proc/check_menu(mob/user)//check if the person is able to access the menu
	if(!istype(user))
		return FALSE
	if(QDELETED(src) || reskinned)
		return FALSE
	if(user.incapacitated() || !user.is_holding(src))
		return FALSE
	if(chaplain_bypass || user?.mind?.holy_role)
		return TRUE

/obj/item/nullrod/ui_interact(mob/user, datum/tgui/ui)
	if(check_menu(user))
		ui = SStgui.try_update_ui(user, src, ui)
		if(!ui)
			ui = new(user, src, "NullRodMenu", name)
			ui.open()

/obj/item/nullrod/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	data["nullrods"] = list()
	for(var/category in show_categories)
		var/list/category_data = list()
		category_data["name"] = category

		var/list/nullrods = list()

		for(var/shaft in subtypesof(/obj/item/nullrod))
			var/obj/item/nullrod/rod = new shaft
			if(!rod?.chaplain_spawnable)
				continue
			var/list/details = list()
			details["name"] = rod.name
			details["description"] = rod.desc
			details["menu_tab"] = rod.menutab
			details["type_path"] = rod.type
			details["additional_description"] = rod.additional_desc

			var/icon/rod_pic = getFlatIcon(rod)
			var/md5 = md5(fcopy_rsc(rod_pic))
			if(!SSassets.cache["photo_[md5]_[rod.name]_icon.png"])
				SSassets.transport.register_asset("photo_[md5]_[rod.name]_icon.png", rod_pic)
			SSassets.transport.send_assets(user, list("photo_[md5]_[rod.name]_icon.png" = rod_pic))
			details["rod_pic"] = SSassets.transport.get_asset_url("photo_[md5]_[rod.name]_icon.png")

			if(category == MENU_ALL || category == rod.menutab)
				nullrods += list(details)

			qdel(rod)

		category_data["nullrods"] = nullrods
		data["categories"] += list(category_data)

	return data

/obj/item/nullrod/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("confirm")
			var/rodPath = text2path(params["rodPath"])
			if(!ispath(rodPath, /obj/item/nullrod))
				return FALSE
			var/obj/item/nullrod/holy_weapon = new rodPath
			GLOB.holy_weapon_type = holy_weapon.type
			SSblackbox.record_feedback("tally", "chaplain_weapon", 1, "[params["rodPath"]]")
			if(holy_weapon)
				holy_weapon.reskinned = TRUE
				qdel(src)
				user.put_in_active_hand(holy_weapon)

/*---------------------------------------------------------------------------
|
|		WEAPON null rods
|
----------------------------------------------------------------------------*/

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
	menutab = MENU_WEAPON
	additional_desc = "An exceptionally large sword, capable of occasionally deflecting blows."

/obj/item/nullrod/claymore/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleave_attack)

/obj/item/nullrod/claymore/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/nullrod/claymore/darkblade
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	icon_state = "cultblade"
	item_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	hitsound = 'sound/hallucinations/growl1.ogg'

/obj/item/nullrod/claymore/chainsaw_sword
	name = "sacred chainsaw sword"
	desc = "Suffer not a heretic to live."
	icon_state = "chainswordon"
	item_state = "chainswordon"
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'

/obj/item/nullrod/claymore/katana
	name = "\improper Hanzo steel"
	desc = "Capable of cutting clean through a holy claymore."
	icon_state = "katana"
	item_state = "katana"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK

/obj/item/nullrod/claymore/saber
	name = "light energy sword"
	desc = "If you strike me down, I shall become more robust than you can possibly imagine."
	hitsound = 'sound/weapons/blade1.ogg'
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "swordblue"
	item_state = "swordblue"
	slot_flags = ITEM_SLOT_BELT

/obj/item/nullrod/claymore/saber/red
	name = "dark energy sword"
	desc = "Woefully ineffective when used on steep terrain."
	icon_state = "swordred"
	item_state = "swordred"

//VIBRO
/obj/item/nullrod/vibro
	name = "high frequency blade"
	desc = "Bad references are the DNA of the soul."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "vibroblade"//ignore that the sec vibro sword uses the high frequency sprite
	item_state = "vibroblade"//and this this uses vibroblade sprites
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 35
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_EDGED
	attack_verb = list("chopped", "sliced", "cut", "zandatsu'd")
	hitsound = 'sound/weapons/rapierhit.ogg'
	menutab = MENU_WEAPON
	additional_desc = "The cutting edge vibrates rapidly enabling it to cut cleanly through the unrighteous, no matter what armor or form they hide behind."

/obj/item/nullrod/vibro/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 70, 110) //the harvest gives a high bonus chance

/obj/item/nullrod/vibro/spellblade
	name = "dormant spellblade"
	desc = "The blade grants the wielder nearly limitless power...if they can figure out how to turn it on, that is."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "spellblade"
	item_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon = 'icons/obj/guns/magic.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/nullrod/spear
	name = "bronze spear"
	desc = "Purge untruths and honor... rats?"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	force = 16
	throwforce = 16 //16 is not a weird number, it's a perfect square
	armour_penetration = 35
	sharpness = SHARP_POINTY
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("stabbed", "poked", "slashed", "enlightened")
	menutab = MENU_WEAPON
	additional_desc = "Well balanced, good for throwing."

//other non-reskin nullrods
/obj/item/nullrod/corvo
	name = "folding blade"
	desc = "A relic of a fallen empire. Touch of the outsider not included."
	icon = 'icons/obj/weapons/swords.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	icon_state = "corvo_0"
	item_state = "corvo_0"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/on = TRUE
	var/on_sound = 'sound/weapons/batonextend.ogg'
	menutab = MENU_WEAPON
	additional_desc = "A collapsible blade, more than enough for stealthily dispatching foes."

/obj/item/nullrod/corvo/attack_self(mob/user)
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

/obj/item/nullrod/glowing
	name = "force weapon"
	desc = "The blade glows with the power of faith. Or possibly a battery."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "swordon"
	item_state = "swordon"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	sharpness = SHARP_EDGED
	light_system = MOVABLE_LIGHT
	light_range = 7
	light_power = 2
	light_on = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	menutab = MENU_WEAPON
	additional_desc = "An exceptionally large sword, glows brightly from an unknown power within."

/obj/item/nullrod/glowing/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))

/obj/item/nullrod/glowing/proc/on_light_eater(atom/source, datum/light_eater)
	SIGNAL_HANDLER 
	visible_message("The undying glow of \the [src] refuses to fade.")
	return COMPONENT_BLOCK_LIGHT_EATER

/obj/item/nullrod/Hypertool
	name = "hypertool"
	desc = "A tool so powerful even you cannot perfectly use it."
	icon = 'icons/obj/device.dmi'
	icon_state = "hypertool"
	item_state = "hypertool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	armour_penetration = 35
	damtype = BRAIN
	attack_verb = list("pulsed", "mended", "cut")
	hitsound = 'sound/effects/sparks4.ogg'
	menutab = MENU_WEAPON
	additional_desc = "A most valid tool, hurts the brain just looking at it."

/obj/item/nullrod/whip
	name = "holy whip"
	desc = "What a terrible night to be on Space Station 13."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "chain"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 16 //it's basically ranged
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed")
	hitsound = 'sound/weapons/chainhit.ogg'
	menutab = MENU_WEAPON
	additional_desc = "A holy weapon, capable at meting out righteousness from a distance."

/obj/item/nullrod/whip/Initialize(mapload)
	. = ..()
	weapon_stats[REACH] = 4 //closest to a ranged weapon chaplain should ever get (that or maybe a throwing weapon)

/obj/item/nullrod/bostaff
	name = "monk's staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts, it is now used to harass the clown."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "bostaff0"
	item_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	hitsound = "swing_hit"
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	w_class = WEIGHT_CLASS_BULKY
	damtype = STAMINA
	force = 18
	block_chance = 40
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_NONE
	menutab = MENU_WEAPON
	additional_desc = "The weapon of choice for a devout monk. Block incoming blows while striking weak points until your opponent is too exhausted to continue."

/obj/item/nullrod/bostaff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleave_attack, arc_size=180)

/obj/item/nullrod/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a stick to a gunfight
	return ..()

/obj/item/nullrod/tribal_knife
	name = "arrhythmic knife"
	desc = "They say fear is the true mind killer, but stabbing them in the head works too. Honour compels you to not sheathe it once drawn."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "crysknife"
	item_state = "crysknife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	slot_flags = null
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	item_flags = SLOWS_WHILE_IN_HAND
	menutab = MENU_WEAPON
	additional_desc = "A knife imbued with erratic tribal magic. While holding it your weight seems to fluctuate between light as a feather on your feet, to impossibly heavy and sluggish."

/obj/item/nullrod/tribal_knife/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/butchering, 50, 100)

/obj/item/nullrod/tribal_knife/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/nullrod/tribal_knife/process()
	slowdown = rand(-2, 2)

/obj/item/nullrod/hammer
	name = "relic war hammer"
	desc = "This war hammer cost the chaplain forty thousand space dollars."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "hammer"
	item_state = "hammer"
	base_icon_state = "hammer"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("smashed", "bashed", "hammered", "crunched")
	sharpness = SHARP_NONE
	menutab = MENU_WEAPON
	additional_desc = "Bonk the sinners."

/obj/item/nullrod/hammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		require_twohands = TRUE, \
	)

/obj/item/nullrod/hammer/attack(mob/living/M, mob/living/user)//functions like a throw, but without the wallsplat
	. = ..()
	if(M == user)
		return
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return
	var/atom/throw_target = get_edge_target_turf(M, user.dir)
	ADD_TRAIT(M, TRAIT_IMPACTIMMUNE, "Nullrod Hammer")
	var/distance = rand(1,5)
	if(prob(1))
		distance = 50 //hehe funny hallway launch
	M.throw_at(throw_target, distance, 3, user, TRUE, TRUE, callback = CALLBACK(src, PROC_REF(afterimpact), M))

/obj/item/nullrod/hammer/proc/afterimpact(mob/living/M)
	REMOVE_TRAIT(M, TRAIT_IMPACTIMMUNE, "Nullrod Hammer")

/obj/item/nullrod/dualsword
	name = "blades of the apostate"
	desc = "You can't seem to make out the writing on the side."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "fulldual"
	item_state = "fulldual"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_HUGE
	force = 12
	block_chance = 10
	wound_bonus = -20
	attack_verb = list("thwacked")
	menutab = MENU_WEAPON
	additional_desc = "Strap the sheathe to your waist, and these blades will never fail you."
	var/swords = TRUE
	var/obj/item/nullrod/handedsword/swordright
	var/obj/item/nullrod/handedsword/other/swordleft

/obj/item/nullrod/dualsword/AltClick(mob/user)
	. = ..()
	if(loc != user)
		user.balloon_alert(user, span_notice("you struggle to pull the blades out of the sheathe..."))
		return
	if(swords)
		if(LAZYLEN(user.get_empty_held_indexes()) < 2)
			user.balloon_alert(user, span_warning("you need both hands free to unsheathe \the [src]!"))
			return

		user.drop_all_held_items() //in case they have some sneaky 3rd hand shit

		if(!swordright)
			swordright = new(src) //copies stats from the sheathe to the weapons to allow for varedit shenanigans
			swordright.sheath = src
			swordright.force = force
			swordright.armour_penetration = armour_penetration
			swordright.block_chance = block_chance
			swordright.wound_bonus = wound_bonus
			swordright.bare_wound_bonus = bare_wound_bonus
			swordright.reskinned = TRUE
		user.put_in_r_hand(swordright)

		if(!swordleft)
			swordleft = new(src)
			swordleft.sheath = src
			swordleft.force = force
			swordleft.armour_penetration = armour_penetration
			swordleft.block_chance = block_chance
			swordleft.wound_bonus = wound_bonus
			swordleft.bare_wound_bonus = bare_wound_bonus
			swordleft.reskinned = TRUE
		user.put_in_l_hand(swordleft)

		user.balloon_alert(user, "you unsheathe \the [src].")
		playsound(user, 'sound/items/unsheath.ogg', 25, TRUE)
		swords = FALSE
		update_appearance(UPDATE_ICON)

/obj/item/nullrod/dualsword/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/nullrod/handedsword))
		swords = TRUE

		var/obj/item/otherhand = user.get_inactive_held_item()
		if(istype(otherhand, /obj/item/nullrod/handedsword))
			otherhand.forceMove(src)
		I.forceMove(src)

		user.balloon_alert(user, "You sheathe \the [src].")
		playsound(user, 'sound/items/sheath.ogg', 25, TRUE)
		update_appearance(UPDATE_ICON)

/obj/item/nullrod/dualsword/update_icon_state()
	. = ..()
	item_state = swords ? "fulldual" : "emptydual"
	icon_state = item_state
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_belt()

/obj/item/nullrod/handedsword
	name = "Justice"
	desc = "Ashes to ashes... Rust to rust..."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "dualright"
	item_state = "dualright"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "ripped", "diced", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_HUGE
	chaplain_spawnable = FALSE
	var/obj/item/nullrod/dualsword/sheath //so the sheathe is refilled when the swords are dropped

/obj/item/nullrod/handedsword/other
	name = "Splendor"
	desc = "\"I'm going to ultrakill you!\" -Righteous Judge"
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "dualleft"
	item_state = "dualleft"

/obj/item/nullrod/handedsword/attack(mob/living/M, mob/living/user, secondattack = FALSE)
	. = ..()
	var/obj/item/nullrod/handedsword/secondsword = user.get_inactive_held_item()
	if(istype(secondsword, /obj/item/nullrod/handedsword) && !secondattack)
		addtimer(CALLBACK(src, PROC_REF(secondattack), M, user, secondsword), 2, TIMER_UNIQUE | TIMER_OVERRIDE)
	return

/obj/item/nullrod/handedsword/proc/secondattack(mob/living/M, mob/living/user, obj/item/nullrod/handedsword/secondsword)
	if(QDELETED(secondsword) || QDELETED(src))
		return
	user.swap_hand()
	secondsword.attack(M, user, TRUE)
	user.changeNext_move(CLICK_CD_MELEE * 1.4)

/obj/item/nullrod/handedsword/dropped(mob/user, silent = TRUE)
	. = ..()
	if(sheath)
		if(sheath.swordright)
			sheath.swordright.forceMove(sheath)
		if(sheath.swordleft)
			sheath.swordleft.forceMove(sheath)
		if(!sheath.swords)
			user.balloon_alert(user, "you sheathe \the [sheath].")
			sheath.update_appearance(UPDATE_ICON)
			playsound(user, 'sound/items/sheath.ogg', 25, TRUE)
		sheath.swords = TRUE


/*---------------------------------------------------------------------------
|
|		ARM null rods
|
----------------------------------------------------------------------------*/
/obj/item/nullrod/godhand
	name = "god hand"
	desc = "This hand of yours glows with an awesome power!"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = null
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb = list("punched", "cross countered", "pummeled")
	menutab = MENU_ARM
	additional_desc = "Give up your hand to God and let it be the instrument of his will."

/obj/item/nullrod/godhand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/nullrod/godhand/ignition_effect(atom/A, mob/user)
	. = span_notice("[user] grasps [A] with [user.p_their()] flaming hand, igniting it in a burst of holy flame. Holy hot damn, that is badass. ")

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
	menutab = MENU_ARM
	additional_desc = "Do you really need TWO arms? Consider one arm and a chainsaw arm."

/obj/item/nullrod/chainsaw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 30, 100, 0, hitsound)
	AddComponent(/datum/component/cleave_attack)

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
	menutab = MENU_ARM
	additional_desc = "Channel all your sins into one arm and watch it twist and contort into an instrument of pure violence. Use it to protect the innocent as your penance."

/obj/item/nullrod/armblade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)
	AddComponent(/datum/component/cleave_attack)

/obj/item/nullrod/armblade/tentacle
	name = "unholy blessing"
	icon_state = "tentacle"
	item_state = "tentacle"
	additional_desc = "No one wants to know what sins you were harboring to turn your arm into THAT, but you better use it to protect the innocent and do nothing else."

/*---------------------------------------------------------------------------
|
|		CLOTHING null rods
|
----------------------------------------------------------------------------*/

/obj/item/nullrod/fedora
	name = "atheist's fedora"
	desc = "The brim of the hat is as sharp as your wit. The edge would hurt almost as much as disproving the existence of God."
	icon_state = "fedora"
	item_state = "fedora"
	slot_flags = ITEM_SLOT_HEAD
	icon = 'icons/obj/clothing/hats/hats.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 30
	sharpness = SHARP_EDGED
	embedding = list("embed_chance" = 0)
	attack_verb = list("enlightened", "redpilled", "m'lady'ed")
	menutab = MENU_CLOTHING
	additional_desc = "This gaudy hat has surprisingly good weight distribution, you could probably throw it very effectively."

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
	name = "unholy pitchfork"
	desc = "Holding this makes you look absolutely devilish."
	icon = 'icons/obj/weapons/spears.dmi'
	icon_state = "pitchfork0"
	item_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
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
	if(hud_type && slot == ITEM_SLOT_EYES)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.show_to(user)

/obj/item/nullrod/servoskull/dropped(mob/living/carbon/human/user)
	..()
	if(hud_type && istype(user) && user.glasses == src)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.hide_from(user)

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
	menutab = MENU_CLOTHING
	additional_desc = "This mysterious floating skull can communicate diagnostic reports to you regarding both mechanical and organic disciples around you."

/obj/item/nullrod/servoskull/equipped(mob/living/carbon/human/user, slot)
	..()
	if(hud_type && slot == ITEM_SLOT_NECK)
		to_chat(user, "Sensory augmentation initiated")
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.show_to(user)
		var/datum/atom_hud/H2 = GLOB.huds[hud_type2]
		H2.show_to(user)

/obj/item/nullrod/servoskull/dropped(mob/living/carbon/human/user)
	..()
	if(hud_type && istype(user) && user.wear_neck == src)
		var/datum/atom_hud/H = GLOB.huds[hud_type]
		H.hide_from(user)
		var/datum/atom_hud/H2 = GLOB.huds[hud_type2]
		H2.hide_from(user)

/obj/item/nullrod/hermes
	name = "fairy boots"
	desc = "Boots blessed by the god Hermes. Some say that they were discarded after being tainted by fae magic."
	gender = PLURAL //Carn: for grammarically correct text-parsing, but over here too
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "fairyboots"
	item_state = "fairyboots"
	slot_flags = ITEM_SLOT_FEET
	body_parts_covered = FEET
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	throwforce = 0
	slowdown = 0.3 //slower until speed is built up
	menutab = MENU_CLOTHING
	additional_desc = "The blessing of Hermes imbues the wearer with incredible speed."
	var/steps = 0 //how many steps currently at
	var/speedperstep = -0.05 //how much speed increases per step
	var/maxspeed = -0.4 //what is the max amount of speed someone can get
	var/stilltimer = 8 //how long (in deciseconds) someone can standstill without losing stacks
	COOLDOWN_DECLARE(standstill)

/obj/item/nullrod/hermes/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_FEET)
		RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(move_react))

/obj/item/nullrod/hermes/dropped(mob/user, silent)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_PRE_MOVE)

/obj/item/nullrod/hermes/proc/move_react()
	if(COOLDOWN_FINISHED(src, standstill))
		steps = 0
	COOLDOWN_START(src, standstill, stilltimer)
	slowdown = max(initial(slowdown) + (steps * speedperstep), maxspeed)
	steps ++
	if(slowdown < 0)//only see the effect if you're getting extra speed
		playsound(src, 'sound/effects/fairyboots.ogg', 45, FALSE)
		new /obj/effect/temp_visual/flowers(get_turf(src))

/obj/effect/temp_visual/flowers
	layer = BELOW_MOB_LAYER
	icon_state = "quantum_sparks"
	duration = 6

/obj/effect/temp_visual/flowers/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration - 1)

/*---------------------------------------------------------------------------
|
|		MISC null rods
|
----------------------------------------------------------------------------*/
/obj/item/nullrod/staff
	icon = 'icons/obj/wizard.dmi'
	name = "holy staff"
	icon_state = "staff-blue"
	item_state = "godstaff-blue"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	desc = "It has a mysterious, protective aura."
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	slot_flags = ITEM_SLOT_BACK
	menutab = MENU_MISC
	additional_desc = "A magical staff that conjures a shield around the holder, protecting from blows."
	var/current_charges = 2
	var/max_charges = 2 //How many charges total the shielding has
	var/recharge_delay = 20 SECONDS //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 2 //How quickly the shield recharges once it starts charging
	var/shield_icon = "shield-old"
	var/shield_on = "shield-old"

/obj/item/nullrod/staff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	recharge_cooldown = world.time + recharge_delay
	if(current_charges > 0)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(2, 1, src)
		s.start()
		owner.visible_message(span_danger("[owner]'s shield deflects [attack_text] in a shower of sparks!"))
		current_charges--
		if(recharge_rate)
			START_PROCESSING(SSobj, src)
		if(current_charges <= 0)
			owner.visible_message("[owner]'s shield overloads!")
			shield_icon = "broken"
			owner.regenerate_icons()
		return 1
	return 0

/obj/item/nullrod/staff/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/nullrod/staff/process(delta_time)
	if(world.time > recharge_cooldown && current_charges < max_charges)
		current_charges = clamp((current_charges + recharge_rate), 0, max_charges)
		if(current_charges == max_charges)
			playsound(loc, 'sound/magic/charge.ogg', 50, 1)
			STOP_PROCESSING(SSobj, src)
		shield_icon = "[shield_on]"
		if(ishuman(loc))
			var/mob/living/carbon/human/C = loc
			C.regenerate_icons()

/obj/item/nullrod/staff/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', shield_icon, MOB_LAYER + 0.01)

/obj/item/nullrod/cross
	name = "golden crucifix"
	desc = "Resist the devil, and he will flee from you."
	icon_state = "cross"
	item_state = "cross"
	force = 0 // How often we forget
	throwforce = 0 // Faith without works is...
	attack_verb = list("blessed")
	menutab = MENU_MISC
	additional_desc = "A holy icon, praying to it will allow it to weaken and burn those that draw your god's ire."

	var/held_up = FALSE
	var/mutable_appearance/holy_glow_fx
	COOLDOWN_DECLARE(holy_notification)
	var/obj/effect/dummy/lighting_obj/moblight/holy_glow_light

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
	holy_glow_light = user.mob_light(range = 2, color = LIGHT_COLOR_HOLY_MAGIC)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(unwield))
	RegisterSignal(src, COMSIG_ITEM_PREDROPPED, PROC_REF(drop_unwield))
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

	var/mob/user = loc
	var/damage = TRUE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))//no hurting as a pacifist
		damage = FALSE

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
			if(iscultist(L) || is_clockcult(L) || iswizard(L) || isvampire(L) || IS_BLOODSUCKER(L) || IS_VASSAL(L) || IS_HERETIC(L) || IS_HERETIC_MONSTER(L) || isshadowperson(L))
				if(damage)
					L.adjustFireLoss(rand(3,5) * 0.5) // 1.5-2.5 AVG 2.0
				if(L.getStaminaLoss() < 65)
					L.adjustStaminaLoss(2)
			else
				if(damage)
					L.adjustFireLoss(rand(1,3) * 0.5) // 0.5-1.5 AVG 1.0
				if(L.getStaminaLoss() < 65)
					L.adjustStaminaLoss(3)

/obj/item/nullrod/cross/examine(mob/user)
	. = ..()
	. += "[span_notice("Use in-hand while facing evil to ")][span_danger("purge it.")]"

/obj/item/nullrod/clown
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrifices."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "clownrender"
	item_state = "render"
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = SHARP_EDGED
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	menutab = MENU_MISC
	additional_desc = "This banana is comedically sharp."

/obj/item/nullrod/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 40)

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
	menutab = MENU_MISC //a downgrade from proper weapons entirely for the gimmick of carp blessing
	additional_desc = "Hugging this plush proves your love and devotion to all fishkind. Even space carps will respect this reverence."

/obj/item/nullrod/carp/attack_self(mob/living/user)
	if(used_blessing)
	else if(user.mind && (user.mind.holy_role))
		to_chat(user, "You are blessed by Carp-Sie. Wild space carp will no longer attack you.")
		user.faction |= "carp"
		used_blessing = TRUE

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
	additional_desc = "A stick, but it's a VERY regal stick."
	menutab = MENU_MISC //eventually give it an effect comparable to a staff

/*probably overly complicated, but should be very cool

general idea for anyone trying to modify this
has two states:
	-item
	-flying mob

it can be thrown to change it into flying mode
if it dies, it swaps back into a weapon
it also swaps back if it gets thrown into the chaplain, but the chaplain catches it
*/
/obj/item/nullrod/talking
	name = "possessed blade"
	desc = "When the station falls into chaos, it's nice to have a friend by your side."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "talking_sword"
	item_state = "talking_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	attack_verb = list("chopped", "sliced", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	sharpness = SHARP_EDGED
	throw_speed = 2 //make it slow so it has time to look cool
	throwforce = 0 //it doesn't actually use this because we override throw impact, it's just for letting pacifists throw it
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	var/possessed = FALSE
	var/mob/living/simple_animal/shade/soul //when they're just a blade (stored inside the blade at all times)
	var/mob/living/simple_animal/nullrod/blade //when they're flying around (blade stored inside them (soul is inside that blade))
	var/mob/living/owner //the person with the recall spell
	var/datum/action/cooldown/spell/recall_nullrod/summon //the recall spell in question
	menutab = MENU_MISC
	additional_desc = "You feel an unwoken presence in this one."

/obj/item/nullrod/talking/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleave_attack)

/obj/item/nullrod/talking/relaymove(mob/user)
	return //stops buckled message spam for the ghost.

/obj/item/nullrod/talking/attack_self(mob/living/user)
	if(possessed)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		to_chat(user, span_notice("Anomalous otherworldly energies block you from awakening the blade!"))
		return

	to_chat(user, "You attempt to wake the spirit of the blade...")
	possessed = TRUE
	owner = user
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the spirit of [user.real_name]'s blade?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		soul = new(src)
		soul.ckey = C.ckey
		soul.fully_replace_character_name(null, "The spirit of alastor")
		soul.status_flags |= GODMODE
		soul.copy_languages(user, LANGUAGE_MASTER)	//Make sure the sword can understand and communicate with the user.
		soul.update_atom_languages()
		grant_all_languages(FALSE, FALSE, TRUE)	//Grants omnitongue
		var/input = stripped_input(soul,"What are you named?", ,"", MAX_NAME_LEN)

		if(src && input)
			name = input
			soul.fully_replace_character_name(null, "The spirit of [input]")

		to_chat(owner, "You feel the spirit within the blade stir and waken.")
		summon = new(owner)
		summon.sword = src
		summon.Grant(owner)
	else
		to_chat(user, "The blade is dormant. Maybe you can try again later.")
		possessed = FALSE
		owner = null

/obj/item/nullrod/talking/Destroy()
	if(soul)
		if(owner && summon)
			to_chat(owner, "You feel weakened as your blade fades from this world.")
			summon.Remove(owner)
		to_chat(soul, "You were destroyed!")
		qdel(soul)
	return ..()

/obj/item/nullrod/talking/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(isliving(hit_atom))//only transform if it doesn't hit a person
		var/mob/living/target = hit_atom
		if(owner && target == owner)
			var/caught = owner.put_in_hands(src)
			if(caught)
				visible_message("[owner] catches the flying [src] out of the air!")
			else
				playsound(target, 'sound/weapons/rapierhit.ogg', 30, 1, -1)
				owner.take_overall_damage(5)
				visible_message("[src] smacks [owner] in the face as [owner.p_they()] try to catch it with [owner.p_their()] hands full!")
	else if(possessed && soul)
		transform = initial(transform)//to reset rotation for when it drops to the ground
		if(!blade)
			blade = new(get_turf(src))
			blade.sword = src
			blade.fully_replace_character_name(null, soul.name)
		forceMove(blade)//just hide it in here for now
		if(soul?.mind)
			soul.mind.transfer_to(blade)
	else
		. = ..()

/datum/action/cooldown/spell/recall_nullrod
	name = "Sword Recall"
	desc = "Pulls your possessed sword back to you."
	panel = "Chaplain"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "swordrecall"

	school = SCHOOL_CONJURATION
	invocation = "COME"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 10 SECONDS
	spell_requirements = NONE
	var/obj/item/nullrod/talking/sword

/datum/action/cooldown/spell/recall_nullrod/before_cast(atom/cast_on)
	if(sword.loc == cast_on)
		to_chat(cast_on, span_notice("[sword] is already in your hand"))
		return FALSE
	return ..()

/datum/action/cooldown/spell/recall_nullrod/cast(mob/living/carbon/user)
	. = ..()
	if(!sword)
		return

	if(sword.blade)
		sword.blade.throw_at(user, 20, 3) //remember, sword is the item, blade is the mob
		return

	if(ismob(sword.loc))
		var/mob/holder = sword.loc //rip it out of the thief's hands first
		if(holder != user)
			to_chat(holder, "you feel [sword] ripped out of your hands by an unseen force.")
			holder.dropItemToGround(sword)
	sword.throw_at(user, 20, 3)

//the mob
/mob/living/simple_animal/nullrod
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit."
	gender = PLURAL
	icon = 'icons/mob/nonhuman-player/holy.dmi'
	icon_state = "talking_sword"
	icon_living = "talking_sword"
	mob_biotypes = MOB_INORGANIC|MOB_SPIRIT
	maxHealth = 20
	health = 20
	speed = 0
	spacewalk = TRUE
	healable = 0
	speak_emote = list("hisses")
	emote_hear = list("wails.","screeches.")
	response_help = "pokes"
	response_disarm = "pushes"
	response_harm = "whacks"
	speak_chance = 1
	melee_damage_lower = 0 //don't let it be a powergame mob
	melee_damage_upper = 0
	attacktext = "prods"
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	stop_automated_movement = 1
	status_flags = 0
	status_flags = CANPUSH
	movement_type = FLYING
	initial_language_holder = /datum/language_holder/universal
	var/obj/item/nullrod/talking/sword //the sword they're part of
	var/datum/action/cooldown/spell/nullrod_drop/button //suicide button so they can return to being an item if need be

/mob/living/simple_animal/nullrod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	button = new(src)
	button.Grant(src)

/mob/living/simple_animal/nullrod/death()
	if(sword)
		visible_message("[src] lowers to the ground as it's power wanes!")
		if(mind)
			mind.transfer_to(sword.soul)
		sword.forceMove(get_turf(src))
	qdel(src)

/mob/living/simple_animal/nullrod/canSuicide()
	return FALSE //you're a sword, you can't suicide

/mob/living/simple_animal/nullrod/attack_hand(mob/living/carbon/human/M)
	if(!sword.owner || M != sword.owner)//let the chaplain pick it up in one hit
		return ..()
	sword.owner.put_in_active_hand(sword)
	if(mind)
		mind.transfer_to(sword.soul)
	visible_message("[sword.owner] grabs [src] by the hilt.")
	qdel(src)

/mob/living/simple_animal/nullrod/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!isliving(hit_atom))
		return ..()
	var/mob/living/target = hit_atom
	if(sword?.owner && target == sword.owner)
		var/caught = sword.owner.put_in_hands(sword)
		if(mind)
			mind.transfer_to(sword.soul)
		qdel(src)
		if(caught)
			visible_message("[sword.owner] catches the flying blade out of the air!")
		else
			playsound(target, 'sound/weapons/rapierhit.ogg', 30, 1, -1)
			sword.owner.take_overall_damage(5)
			visible_message("The flying blade smacks [sword.owner] in the face as [sword.owner.p_they()] try to catch it with [sword.owner.p_their()] hands full!")

/datum/action/cooldown/spell/nullrod_drop
	name = "land"
	desc = "Return to the ground for people to wield you."
	panel = "Chaplain"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "sworddrop"

	school = SCHOOL_TRANSMUTATION
	invocation = "COME"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 10 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/nullrod_drop/cast(mob/living/user)
	user.death()//basically a glorified suicide button PLEASE don't give it to any actual player
	. = ..()

/obj/item/nullrod/aspergillum //lol, lmao even
	name = "aspergillum and aspersorium"
	desc = "A weirdly named bucket and hand sprinkler."
	icon = 'icons/obj/misc.dmi'
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	mob_overlay_icon = 'icons/mob/clothing/belt.dmi'
	icon_state = "aspergillum0"
	item_state = "aspergillum0"
	base_icon_state = "aspergillum"
	force = 0
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/items/trayhit2.ogg'
	menutab = MENU_MISC
	additional_desc = "An everfilling bucket of holy water. A blessed hand held sprinkler."
	var/splash_charges = 5
	var/distance = 10
	COOLDOWN_DECLARE(splashy)
	COOLDOWN_DECLARE(balloon)

/obj/item/nullrod/aspergillum/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	
/obj/item/nullrod/aspergillum/proc/on_wield(atom/source, mob/living/user)
	playsound(src, 'sound/effects/slosh.ogg', 40, 1, -1)

/obj/item/nullrod/aspergillum/proc/on_unwield(atom/source, mob/living/user)
	playsound(src, 'sound/effects/splosh.ogg', 15, 1, -1)
	splash_charges = initial(splash_charges)

/obj/item/nullrod/aspergillum/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(target.loc == user)
			return

		if(splash_charges <= 0)
			if(COOLDOWN_FINISHED(src, balloon))
				user.balloon_alert(user, span_warning("The aspergillum is dry!"))
				COOLDOWN_START(src, balloon, CLICK_CD_MELEE)
			return

		if(!COOLDOWN_FINISHED(src, splashy))
			return
		COOLDOWN_START(src, splashy, CLICK_CD_MELEE)

		splash_charges--

		playsound(src.loc, 'sound/effects/wounds/splatter.ogg', 50, 1, 3)
		playsound(src.loc, get_sfx(SFX_COLLARBELL), 50, 1, 3)

		var/direction = get_dir(src,target)

		user.newtonian_move(turn(direction, 180))

		//Get all the turfs that can be shot at
		var/turf/T = get_turf(target)
		var/turf/T1 = get_ranged_target_turf(target, direction, 1) //aim 1 tile past where you click
		var/turf/T2 = get_step(T,turn(direction, 90))
		var/turf/T3 = get_step(T,turn(direction, -90))
		var/turf/T4 = get_step(get_turf(target),turn(direction, 90))
		var/turf/T5 = get_step(get_turf(target),turn(direction, -90))
		var/list/the_targets = list(T,T1,T2,T3,T4,T5)

		for(var/a=0, a<6, a++)
			var/my_target = pick(the_targets)
			var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(src), my_target, TOUCH|VAPOR)
			W.reagents.add_reagent(/datum/reagent/water/holywater, 1)
			the_targets -= my_target
			W.life = distance

/obj/item/nullrod/aspergillum/update_icon_state()
	. = ..()
	item_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"
	icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]"

//never put anything below this, it deserves to be buried
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
	menutab = MENU_MISC //banish it from being associated with proper weapons
	additional_desc = "Hey, God here. Asking you to pick literally anything else as your implement of justice."

/obj/item/nullrod/sord/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cleave_attack) // i guess???

//NOT CHAPLAIN SPAWNABLE
/obj/item/nullrod/talking/chainsword
	name = "possessed chainsaw sword"
	desc = "Suffer not a heretic to live."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "chainswordon"
	item_state = "chainswordon"
	chaplain_spawnable = FALSE
	force = 30
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("sawed", "torn", "cut", "chopped", "diced")
	hitsound = 'sound/weapons/chainsawhit.ogg'

/obj/item/nullrod/unrestricted //anyone can select the nullrod, not just the chaplain
	chaplain_bypass = TRUE
	chaplain_spawnable = FALSE

#undef MENU_WEAPON
#undef MENU_ARM
#undef MENU_CLOTHING
#undef MENU_MISC
