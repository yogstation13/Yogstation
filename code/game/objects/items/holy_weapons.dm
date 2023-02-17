// CHAPLAIN NULLROD AND CUSTOM WEAPONS //
#define MENU_WEAPON "nullrod weapon"
#define MENU_ARM "nullrod arm"
#define MENU_CLOTHING "nullrod clothing"
#define MENU_MISC "nullrod misc"

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
	var/menutab = MENU_MISC //that way if someone forgets, it gets put in the tab that isn't specialized
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
		ui_interact(user)

  /*
  reskin_holy_weapon: Shows a user a list of all available nullrod reskins and based on his choice replaces the nullrod with the reskinned version

  Arguments:
  M : The mob choosing a nullrod reskin
  */
/obj/item/nullrod/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NullRod", name)
		ui.open()
	
/obj/item/nullrod/ui_data(mob/user)
	var/list/data = list()
	for(var/V in typesof(/obj/item/nullrod))
		var/obj/item/nullrod/rodtype = V
		if(initial(rodtype.chaplain_spawnable))
			data["names"] += rodtype
			data["desc"] += rodtype.desc
			data["icons"] += rodtype.icon_state

	return data

/*
/obj/item/nullrod/ui_act(action, params)
	if(..())
		return

	nullrod_icons = sortList(nullrod_icons)
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
*/

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

/*---------------------------------------------------------------------------
|
|		WEAPON null rods
|
----------------------------------------------------------------------------*/
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
	menutab = MENU_WEAPON

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
	menutab = MENU_WEAPON

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

/obj/item/nullrod/claymore/glowing//reminder, make it actually glow
	name = "force weapon"
	desc = "The blade glows with the power of faith. Or possibly a battery."
	icon_state = "swordon"
	item_state = "swordon"
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

/obj/item/nullrod/claymore/saber/pirate
	name = "nautical energy sword"
	desc = "Convincing HR that your religion involved piracy was no mean feat."
	icon_state = "cutlass1"
	item_state = "cutlass1"

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

//SCYTHES
/obj/item/nullrod/scythe
	name = "reaper scythe"
	desc = "Ask not for whom the bell tolls..."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "scythe1"
	item_state = "scythe1"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 35
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_EDGED
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	menutab = MENU_WEAPON

/obj/item/nullrod/scythe/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 70, 110) //the harvest gives a high bonus chance

/obj/item/nullrod/scythe/vibro
	name = "high frequency blade"
	desc = "Bad references are the DNA of the soul."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "hfrequency0"
	item_state = "hfrequency1"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	attack_verb = list("chopped", "sliced", "cut", "zandatsu'd")
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/nullrod/scythe/spellblade
	name = "dormant spellblade"
	desc = "The blade grants the wielder nearly limitless power...if they can figure out how to turn it on, that is."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "spellblade"
	item_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	icon = 'icons/obj/guns/magic.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/nullrod/scythe/talking
	name = "possessed blade"
	desc = "When the station falls into chaos, it's nice to have a friend by your side."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "talking_sword"
	item_state = "talking_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
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

/obj/item/nullrod/hammmer
	name = "relic war hammer"
	desc = "This war hammer cost the chaplain forty thousand space dollars."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "hammeron"
	item_state = "hammeron"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_HUGE
	attack_verb = list("smashed", "bashed", "hammered", "crunched")
	menutab = MENU_WEAPON


/obj/item/nullrod/clown
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrifices."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "clownrender"
	item_state = "render"
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = SHARP_EDGED
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	menutab = MENU_WEAPON

/obj/item/nullrod/pride_hammer
	name = "Pride-struck Hammer"
	desc = "It resonates an aura of Pride."
	icon = 'icons/obj/weapons/misc.dmi'
	icon_state = "pride"
	force = 16
	throwforce = 15
	w_class = 4
	slot_flags = ITEM_SLOT_BACK
	attack_verb = list("attacked", "smashed", "crushed", "splattered", "cracked")
	hitsound = 'sound/weapons/blade1.ogg'
	menutab = MENU_WEAPON

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
	menutab = MENU_WEAPON
	
/obj/item/nullrod/whip/Initialize()
	. = ..()
	weapon_stats[REACH] = 3


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
	force = 15
	block_chance = 40
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_NONE
	menutab = MENU_WEAPON

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

/obj/item/nullrod/godhand/Initialize()
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

/obj/item/nullrod/chainsaw/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 30, 100, 0, hitsound)

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

/obj/item/nullrod/armblade/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 80, 70)

/obj/item/nullrod/armblade/tentacle
	name = "unholy blessing"
	icon_state = "tentacle"
	item_state = "tentacle"

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
	icon = 'icons/obj/clothing/hats.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 30
	sharpness = SHARP_EDGED
	attack_verb = list("enlightened", "redpilled")

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

/*---------------------------------------------------------------------------
|
|		MISC null rods
|
----------------------------------------------------------------------------*/
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

/obj/item/nullrod/carp/attack_self(mob/living/user)
	if(used_blessing)
	else if(user.mind && (user.mind.holy_role))
		to_chat(user, "You are blessed by Carp-Sie. Wild space carp will no longer attack you.")
		user.faction |= "carp"
		used_blessing = TRUE

//NOT CHAPLAIN SPAWNABLE
/obj/item/nullrod/scythe/talking/chainsword
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

#undef MENU_WEAPON
#undef MENU_ARM
#undef MENU_CLOTHING
#undef MENU_MISC
