//The chests dropped by mob spawner tendrils. Also contains associated loot.
GLOBAL_LIST_EMPTY(bloodmen_list)
#define HIEROPHANT_CLUB_CARDINAL_DAMAGE 30


/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/PopulateContents()
	var/loot = rand(1,26)
	switch(loot)
		if(1)
			new /obj/item/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/suit/space/hardsuit/cult(src)
		if(3)
			new /obj/item/soulstone/anybody(src)
		if(4)
			new /obj/item/reagent_containers/glass/bottle/potion/flight(src)
		if(5)
			new /obj/item/stack/sheet/mineral/mythril(src)
		if(6)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disc/resonator_blast(src)
			else
				new /obj/item/disk/design_disk/modkit_disc/rapid_repeater(src)
		if(7)
			new /obj/item/rod_of_asclepius(src)
		if(8)
			new /obj/item/organ/heart/cursed/wizard(src)
		if(9)
			new /obj/item/ship_in_a_bottle(src)
		if(10)
			new /obj/item/reagent_containers/glass/bottle/necropolis_seed(src)
		if(11)
			new /obj/item/jacobs_ladder(src)
		if(12)
			new /obj/item/nullrod/scythe/talking(src)
		if(13)
			new /obj/item/nullrod/armblade(src)
		if(14)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe(src)
			else
				new /obj/item/disk/design_disk/modkit_disc/bounty(src)
		if(15)
			new /obj/item/warp_cube/red(src)
		if(16)
			new /obj/item/organ/heart/gland/heals(src)
		if(17)
			new /obj/item/eflowers(src)
		if(18)
			new /obj/item/voodoo(src)
		if(19)
			new /obj/item/clothing/suit/space/hardsuit/powerarmor_advanced(src)
		if(20)
			new /obj/item/book_of_babel(src)
		if(21)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)
		if(22)
			new /obj/item/clothing/neck/necklace/memento_mori(src)
		if(23)
			new /obj/item/rune_scimmy(src)
		if(24)
			new /obj/item/dnainjector/dwarf(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
		if(25)
			new /obj/item/clothing/gloves/gauntlets(src)
		if(26)
			new /obj/item/clothing/under/drip(src)
			new /obj/item/clothing/shoes/drip(src)

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disc
	name = "KA Mod Disk"
	desc = "A design disc containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design = /datum/design/unique_modkit

/obj/item/disk/design_disk/modkit_disc/Initialize()
	. = ..()
	blueprints[1] = new modkit_design

/obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe
	name = "Offensive Mining Explosion Mod Disk"
	modkit_design = /datum/design/unique_modkit/offensive_turf_aoe

/obj/item/disk/design_disk/modkit_disc/rapid_repeater
	name = "Rapid Repeater Mod Disk"
	modkit_design = /datum/design/unique_modkit/rapid_repeater

/obj/item/disk/design_disk/modkit_disc/resonator_blast
	name = "Resonator Blast Mod Disk"
	modkit_design = /datum/design/unique_modkit/resonator_blast

/obj/item/disk/design_disk/modkit_disc/bounty
	name = "Death Syphon Mod Disk"
	modkit_design = /datum/design/unique_modkit/bounty

/datum/design/unique_modkit
	category = list("Mining Designs", "Cyborg Upgrade Modules") //can't be normally obtained
	build_type = PROTOLATHE | MECHFAB
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(/datum/material/iron = 7000, /datum/material/glass = 3000, /datum/material/silver = 3000, /datum/material/gold = 3000, /datum/material/diamond = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/uranium = 8000, /datum/material/bluespace = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/silver = 5000, /datum/material/uranium = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts

/datum/design/unique_modkit/bounty
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(/datum/material/iron = 4000, /datum/material/silver = 4000, /datum/material/gold = 4000, /datum/material/bluespace = 4000)
	reagents_list = list(/datum/reagent/blood = 40)
	build_path = /obj/item/borg/upgrade/modkit/bounty

//Spooky special loot

//Rod of Asclepius
/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "asclepius_dormant"
	var/activated = FALSE
	var/usedHand

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, span_warning("The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath."))
		return
	var/mob/living/carbon/itemUser = user
	usedHand = itemUser.get_held_index_of_item(src)
	if(itemUser.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		to_chat(user, span_warning("You can't possibly handle the responsibility of more than one rod!"))
		return
	var/failText = span_warning("The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!")
	to_chat(itemUser, span_notice("The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong..."))
	if(do_after(itemUser, 4 SECONDS, itemUser))
		itemUser.say("I swear to fulfill, to the best of my ability and judgment, this covenant:", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 2 SECONDS, itemUser))
		itemUser.say("I will apply, for the benefit of the sick, all measures that are required, avoiding those twin traps of overtreatment and therapeutic nihilism.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 3 SECONDS, itemUser))
		itemUser.say("I will remember that I remain a member of society, with special obligations to all my fellow human beings, those sound of mind and body as well as the infirm.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 3 SECONDS, itemUser))
		itemUser.say("If I do not violate this oath, may I enjoy life and art, respected while I live and remembered with affection thereafter. May I always act so as to preserve the finest traditions of my calling and may I long experience the joy of healing those who seek my help.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, span_notice("The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory..."))
	var/datum/status_effect/hippocraticOath/effect = itemUser.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	effect.hand = usedHand
	activated()

/obj/item/rod_of_asclepius/proc/activated()
	item_flags = DROPDEL
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	desc = "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you. "
	icon_state = "asclepius_active"
	activated = TRUE

//Memento Mori
/obj/item/clothing/neck/necklace/memento_mori
	name = "Memento Mori"
	desc = "A mysterious pendant. An inscription on it says: \"Certain death tomorrow means certain life today.\""
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "memento_mori"
	actions_types = list(/datum/action/item_action/hands_free/memento_mori)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/human/active_owner

/obj/item/clothing/neck/necklace/memento_mori/item_action_slot_check(slot)
	return slot == SLOT_NECK

/obj/item/clothing/neck/necklace/memento_mori/dropped(mob/user)
	..()
	if(active_owner)
		mori()

//Just in case
/obj/item/clothing/neck/necklace/memento_mori/Destroy()
	if(active_owner)
		mori()
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/proc/memento(mob/living/carbon/human/user)
	var/list/hasholos = user.hasparasites()
	if(hasholos.len)
		to_chat(user, span_warning("The pendant refuses to work with a guardian spirit..."))
		return
	if(IS_BLOODSUCKER(user))
		to_chat(user, span_warning("The Memento notices your undead soul, and refuses to react.."))
		return
	to_chat(user, span_warning("You feel your life being drained by the pendant..."))
	if(do_after(user, 4 SECONDS, user))
		to_chat(user, span_notice("Your lifeforce is now linked to the pendant! You feel like removing it would kill you, and yet you instinctively know that until then, you won't die."))
		ADD_TRAIT(user, TRAIT_NODEATH, "memento_mori")
		ADD_TRAIT(user, TRAIT_NOHARDCRIT, "memento_mori")
		ADD_TRAIT(user, TRAIT_NOCRITDAMAGE, "memento_mori")
		icon_state = "memento_mori_active"
		active_owner = user

/obj/item/clothing/neck/necklace/memento_mori/proc/mori()
	icon_state = "memento_mori"
	if(!active_owner)
		return
	var/mob/living/carbon/human/H = active_owner //to avoid infinite looping when dust unequips the pendant
	active_owner = null
	to_chat(H, span_userdanger("You feel your life rapidly slipping away from you!"))
	H.dust(TRUE, TRUE)

/datum/action/item_action/hands_free/memento_mori
	check_flags = NONE
	name = "Memento Mori"
	desc = "Bind your life to the pendant."

/datum/action/item_action/hands_free/memento_mori/Trigger()
	var/obj/item/clothing/neck/necklace/memento_mori/MM = target
	if(!MM.active_owner)
		if(ishuman(owner))
			MM.memento(owner)
	else
		to_chat(owner, span_warning("You try to free your lifeforce from the pendant..."))
		if(do_after(owner, 4 SECONDS, owner))
			MM.mori()

//Wisp Lantern
/obj/item/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue"
	item_state = "lantern"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	var/obj/effect/wisp/wisp

/obj/item/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		to_chat(user, span_warning("The wisp has gone missing!"))
		icon_state = "lantern"
		return

	if(wisp.loc == src)
		to_chat(user, span_notice("You release the wisp. It begins to bob around your head."))
		icon_state = "lantern"
		wisp.orbit(user, 20)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Freed")

	else
		to_chat(user, span_notice("You return the wisp to the lantern."))
		icon_state = "lantern-blue"
		wisp.forceMove(src)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Returned")

/obj/item/wisp_lantern/Initialize()
	. = ..()
	wisp = new(src)

/obj/item/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			qdel(wisp)
		else
			wisp.visible_message(span_notice("[wisp] has a sad feeling for a moment, then it passes."))
	return ..()

/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	light_range = 7
	layer = ABOVE_ALL_MOB_LAYER
	var/sight_flags = SEE_MOBS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/effect/wisp/orbit(atom/thing, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)
	. = ..()
	if(ismob(thing))
		RegisterSignal(thing, COMSIG_MOB_UPDATE_SIGHT, .proc/update_user_sight)
		var/mob/being = thing
		being.update_sight()
		to_chat(thing, span_notice("The wisp enhances your vision."))

/obj/effect/wisp/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	if(ismob(orbits.parent))
		UnregisterSignal(orbits.parent, COMSIG_MOB_UPDATE_SIGHT)
		to_chat(orbits.parent, span_notice("Your vision returns to normal."))

/obj/effect/wisp/proc/update_user_sight(mob/user)
	user.sight |= sight_flags
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)

//Red/Blue Cubes
/obj/item/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blue_cube"
	var/teleport_color = "#3FBAFD"
	var/obj/item/warp_cube/linked
	var/teleporting = FALSE

/obj/item/warp_cube/attack_self(mob/user)
	var/turf/current_location = get_turf(user)//yogs added a current location check that was totally ripped from the hand tele code honk
	var/area/current_area = current_location.loc //yogs more location check stuff
	if(!linked || current_area.noteleport) //yogs added noteleport
		to_chat(user, "[src] fizzles uselessly.")
		return
	if(teleporting)
		return
	teleporting = TRUE
	linked.teleporting = TRUE
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/warp_cube(T, user, teleport_color, TRUE)
	SSblackbox.record_feedback("tally", "warp_cube", 1, type)
	new /obj/effect/temp_visual/warp_cube(get_turf(linked), user, linked.teleport_color, FALSE)
	var/obj/effect/warp_cube/link_holder = new /obj/effect/warp_cube(T)
	user.forceMove(link_holder) //mess around with loc so the user can't wander around
	sleep(0.25 SECONDS)
	if(QDELETED(user))
		qdel(link_holder)
		return
	if(QDELETED(linked))
		user.forceMove(get_turf(link_holder))
		qdel(link_holder)
		return
	link_holder.forceMove(get_turf(linked))
	sleep(0.25 SECONDS)
	if(QDELETED(user))
		qdel(link_holder)
		return
	teleporting = FALSE
	if(!QDELETED(linked))
		linked.teleporting = FALSE
	user.forceMove(get_turf(link_holder))
	qdel(link_holder)

/obj/item/warp_cube/red
	name = "red cube"
	desc = "A mysterious red cube."
	icon_state = "red_cube"
	teleport_color = "#FD3F48"

/obj/item/warp_cube/red/Initialize()
	. = ..()
	if(!linked)
		var/obj/item/warp_cube/blue = new(src.loc)
		linked = blue
		blue.linked = src

/obj/effect/warp_cube
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

/obj/effect/warp_cube/ex_act(severity, target)
	return

//Meat Hook
/obj/item/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	item_flags = NEEDS_PERMIT | NOBLUDGEON
	force = 18

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/item/projectile/hook
	caliber = "hook"
	icon_state = "hook"

/obj/item/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 25
	armour_penetration = 100
	damage_type = BRUTE
	hitsound = 'sound/effects/splat.ogg'
	knockdown = 30
	var/chain

/obj/item/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain", time = INFINITY, maxdistance = INFINITY)
	..()
	//TODO: root the firer until the chain returns

/obj/item/projectile/hook/on_hit(atom/target)
	. = ..()
	if(ismovable(target))
		var/atom/movable/A = target
		if(A.anchored)
			return
		A.visible_message(span_danger("[A] is snagged by [firer]'s hook!"))
		new /datum/forced_movement(A, get_turf(firer), 5, TRUE)
		//TODO: keep the chain beamed to A
		//TODO: needs a callback to delete the chain

/obj/item/projectile/hook/Destroy()
	qdel(chain)
	return ..()


//Immortality Talisman
/obj/item/immortality_talisman
	name = "\improper Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0

/obj/item/immortality_talisman/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, TRUE)

/datum/action/item_action/immortality
	name = "Immortality"

/obj/item/immortality_talisman/attack_self(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(cooldown < world.time)
			SSblackbox.record_feedback("amount", "immortality_talisman_uses", 1)
			cooldown = world.time + 600
			L.apply_status_effect(STATUS_EFFECT_VOIDED)

		else
			to_chat(L, span_warning("[src] is not ready yet!"))
	else
		to_chat(user, span_warning("Only the living can attain this power!"))

/obj/effect/immortality_talisman
	name = "hole in reality"
	desc = "It's shaped an awful lot like a person."
	icon_state = "blank"
	icon = 'icons/effects/effects.dmi'
	var/vanish_description = "vanishes from reality"
	var/can_destroy = TRUE

/obj/effect/immortality_talisman/Initialize(mapload, mob/new_user)
	. = ..()

/obj/effect/immortality_talisman/proc/vanish(mob/user)
	user.visible_message(span_danger("[user] [vanish_description], leaving a hole in [user.p_their()] place!"))

	desc = "It's shaped an awful lot like [user.name]."
	setDir(user.dir)

	user.forceMove(src)
	user.notransform = TRUE
	user.status_flags |= GODMODE

	can_destroy = FALSE

/obj/effect/immortality_talisman/proc/unvanish(mob/user)
	user.status_flags &= ~GODMODE
	user.notransform = FALSE
	user.forceMove(get_turf(user))

	user.visible_message(span_danger("[user] pops back into reality!"))
	can_destroy = TRUE
	qdel(src)

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/ex_act()
	return

/obj/effect/immortality_talisman/singularity_pull()
	return

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()

/obj/effect/immortality_talisman/void
	vanish_description = "is dragged into the void"

//Shared Bag

/obj/item/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/storage.dmi'
	icon_state = "cultpack"
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = INDESTRUCTIBLE

/obj/item/shared_storage/red
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."

/obj/item/shared_storage/red/Initialize()
	. = ..()
	var/datum/component/storage/STR = AddComponent(/datum/component/storage/concrete)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60
	STR.max_items = 21
	new /obj/item/shared_storage/blue(drop_location(), STR)

/obj/item/shared_storage/blue/Initialize(mapload, datum/component/storage/concrete/master)
	. = ..()
	if(!istype(master))
		return INITIALIZE_HINT_QDEL
	var/datum/component/storage/STR = AddComponent(/datum/component/storage, master)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60
	STR.max_items = 21

//Book of Babel

/obj/item/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues."
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2

/obj/item/book_of_babel/attack_self(mob/user)
	if(!user.can_read(src))
		return FALSE
	to_chat(user, span_notice("You flip through the pages of the book, quickly and conveniently learning every language in existence. Somewhat less conveniently, the aging book crumbles to dust in the process. Whoops."))
	user.grant_all_languages()
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)


//Runite Scimitar
/obj/item/rune_scimmy
	name = "rune scimitar"
	desc = "A curved sword smelted from an unknown metal. Looking at it gives you the otherworldly urge to pawn it off for '30k', whatever that means."
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/scimmy_lefthand.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/scimmy_righthand.dmi'
	icon = 'yogstation/icons/obj/lavaland/artefacts.dmi'
	icon_state = "rune_scimmy"
	force = 20
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	damtype = BRUTE
	sharpness = SHARP_EDGED
	hitsound = 'yogstation/sound/weapons/rs_slash.ogg'
	attack_verb = list("slashed","pk'd","atk'd")
	var/mobs_grinded = 0
	var/max_grind = 20

/obj/item/rune_scimmy/examine(mob/living/user)
	. = ..()
	. += span_notice("This blade fills you with a need to 'grind'. Slay hostile fauna to increase the Scimmy's power and earn loot.")
	. += span_notice("The blade has grinded [mobs_grinded] out of [max_grind] fauna to reach maximum power, and will deal [mobs_grinded * 5] bonus damage to fauna.")

/obj/item/rune_scimmy/afterattack(atom/target, mob/user, proximity, click_parameters)
	. = ..()
	if(!proximity)
		return
	if(isliving(target))
		var/mob/living/L = target
		if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid)) //no loot allowed from the little skulls
			if(!istype(L, /mob/living/simple_animal/hostile/asteroid/hivelordbrood))
				RegisterSignal(target,COMSIG_MOB_DEATH,.proc/roll_loot, TRUE)
			//after quite a bit of grinding, you'll be doing a total of 120 damage to fauna per hit. A lot, but i feel like the grind justifies the payoff. also this doesn't effect crew. so. go nuts.
			L.apply_damage(mobs_grinded*5,BRUTE)

///This proc handles rolling the loot on the loot table and "drops" the loot where the hostile fauna died
/obj/item/rune_scimmy/proc/roll_loot(mob/living/target)
	UnregisterSignal(target, COMSIG_MOB_DEATH)
	if(mobs_grinded<max_grind)
		mobs_grinded++
	var/spot = get_turf(target)
	var/loot = rand(1,100)
	switch(loot)
		if(1 to 20)//20% chance at 3 gold coins, the most basic rs drop
			for(var/i in 1 to 3) 
				new /obj/item/coin/gold(spot)
		if(21 to 30)//10% chance for 5 gold coins
			for(var/i in 1 to 5)
				new /obj/item/coin/gold(spot)
		if(31 to 40)//10% chance for 2 GOLD (banana) DOUBLOONS 
			for(var/i in 1 to 2)
				new /obj/item/coin/bananium(spot)
		if(41 to 50) //10% chance to spawn 10 gold, diamond, or bluespace crystal ores, because runescape ore drops and gem drops
			for(var/i in 1 to 5)
				switch(rand(1,5))
					if(1 to 2)
						new /obj/item/stack/ore/gold(spot)
					if(3 to 4)
						new /obj/item/stack/ore/diamond(spot)
					if(5)
						new /obj/item/stack/sheet/bluespace_crystal(spot)
		if(51 to 60)//10% for bow and bronze tipped arrows, bronze are supposed to be the worst in runescape but they kinda slap in here, hopefully limited by the 5 arrows
			new /obj/item/gun/ballistic/bow(spot)
			for(var/i in 1 to 5)
				new /obj/item/ammo_casing/caseless/arrow/bronze(spot)
		if(61 to 70)//10% chance at a seed drop, runescape drops seeds somewhat frequently for players to plant and harvest later
			switch(rand(1,5))
				if(1)
					new /obj/item/seeds/lavaland/cactus(spot)
				if(2)
					new /obj/item/seeds/lavaland/ember(spot)
				if(3)
					new /obj/item/seeds/lavaland/inocybe(spot) 
				if(4)
					new /obj/item/seeds/lavaland/polypore(spot) 
				if(5)
					new /obj/item/seeds/lavaland/porcini(spot) 
			if(prob(25)) //25% chance to get strange seeds, should they feel like cooperating with botanists. this would also be interesting to see ash walkers get lmao
				new /obj/item/seeds/random(spot)
		if(71 to 80) //magmite is cool and somewhat rare i think?
			new /obj/item/magmite(spot)
		if(81 to 90) //i could make it drop foods for healing items like rs dropping fish, but i think the rewards should be a bit more immediate
			new /obj/item/reagent_containers/autoinjector/medipen/survival(spot)
		if(91 to 95) //5% PET DROP LET'S GO
			new /mob/living/simple_animal/hostile/mining_drone(spot)
		if(96 to 99) //4% DHIDE ARMOR
			new /obj/item/stack/sheet/animalhide/ashdrake(spot)
		if(100)
			new /obj/structure/closet/crate/necropolis/tendril(spot)

//Potion of Flight
/obj/item/reagent_containers/glass/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"


/obj/item/reagent_containers/glass/bottle/potion/flight/syndicate
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/reagent_containers/glass/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list(/datum/reagent/flightpotion = 5)

/obj/item/reagent_containers/glass/bottle/potion/update_icon()
	if(reagents.total_volume)
		icon_state = "potionflask"
	else
		icon_state = "potionflask_empty"

/datum/reagent/flightpotion
	name = "Flight Potion"
	description = "Strange mutagenic compound of unknown origins."
	reagent_state = LIQUID
	color = "#FFEBEB"

/datum/reagent/flightpotion/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		var/mob/living/carbon/C = M
		var/holycheck = ishumanbasic(C)
		if(!(holycheck || islizard(C) || ismoth(C) || isskeleton(C) || ispreternis(C)) || (reac_volume < 5)) //humans (which are holy?), lizards, skeletons, and preterni(ises?) can get wings
			if(method == INGEST && show_message)
				to_chat(C, span_notice("<i>You feel nothing but a terrible aftertaste.</i>"))
			return ..()

		to_chat(C, span_userdanger("A terrible pain travels down your back as wings burst out!"))
		C.dna.species.GiveSpeciesFlight(C)
		if(holycheck)
			to_chat(C, span_notice("You feel blessed!"))
			ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
		if(islizard(C))
			to_chat(C, span_notice("You feel blessed... by... something?"))
			ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
		if(ismoth(C))
			to_chat(C, span_notice("Your wings feel.... stronger?"))
			ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
		if(isskeleton(C))
			to_chat(C, span_notice("Your ribcage feels... bigger?"))
			ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
		if(ispreternis(C))
			to_chat(C, span_notice("The servos in your back feel... different?"))
			ADD_TRAIT(C, TRAIT_HOLY, SPECIES_TRAIT)
		playsound(C.loc, 'sound/items/poster_ripped.ogg', 50, TRUE, -1)
		C.adjustBruteLoss(20)
		C.emote("scream")
	..()


/obj/item/jacobs_ladder
	name = "jacob's ladder"
	desc = "A celestial ladder that violates the laws of physics."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder00"

/obj/item/jacobs_ladder/attack_self(mob/user)
	var/turf/T = get_turf(src)
	var/ladder_x = T.x
	var/ladder_y = T.y
	to_chat(user, span_notice("You unfold the ladder. It extends much farther than you were expecting."))
	var/last_ladder = null
	for(var/i in 1 to world.maxz)
		if(is_centcom_level(i) || is_reserved_level(i) || is_reebe(i) || is_away_level(i))
			continue
		var/turf/T2 = locate(ladder_x, ladder_y, i)
		last_ladder = new /obj/structure/ladder/unbreakable/jacob(T2, null, last_ladder)
	qdel(src)

// Inherit from unbreakable but don't set ID, to suppress the default Z linkage
/obj/structure/ladder/unbreakable/jacob
	name = "jacob's ladder"
	desc = "An indestructible celestial ladder that violates the laws of physics."

#define COOLDOWN_SUMMON 1 MINUTES
/obj/item/eflowers
	name ="enchanted flowers"
	desc ="A charming bunch of flowers, most animals seem to find the bearer amicable after momentary contact with it. Squeeze the bouqet to summon tamed creatures. Megafauna cannot be summoned.<b>Megafauna need to be exposed 35 times to become friendly.</b>"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "eflower"
	var/next_summon = 0
	var/list/summons = list()
	attack_verb = list("thumped", "brushed", "bumped")

/obj/item/eflowers/attack_self(mob/user)
	var/turf/T = get_turf(user)
	var/area/A = get_area(user)
	if(next_summon > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	if(is_station_level(T.z) && !A.outdoors)
		to_chat(user, span_warning("You feel like calling a bunch of animals indoors is a bad idea."))
		return
	user.visible_message(span_warning("[user] holds the bouqet out, summoning their allies!"))
	for(var/mob/m in summons)
		m.forceMove(T)
	playsound(T, 'sound/effects/splat.ogg', 80, 5, -1)
	next_summon = world.time + COOLDOWN_SUMMON

/obj/item/eflowers/afterattack(mob/living/simple_animal/M, mob/user, proximity)
	var/datum/status_effect/taming/G = M.has_status_effect(STATUS_EFFECT_TAMING)
	. = ..()
	if(!proximity)
		return
	if(M.client)
		to_chat(user, span_warning("[M] is too intelligent to tame!"))
		return
	if(M.stat)
		to_chat(user, span_warning("[M] is dead!"))
		return
	if(M.faction == user.faction)
		to_chat(user, span_warning("[M] is already on your side!"))
		return
	if(M.sentience_type == SENTIENCE_BOSS)
		if(!G)
			M.apply_status_effect(STATUS_EFFECT_TAMING, user)
		else
			G.add_tame(G.tame_buildup)
			if(ISMULTIPLE(G.tame_crit-G.tame_amount, 5))
				to_chat(user, span_notice("[M] has to be exposed [G.tame_crit-G.tame_amount] more times to accept your gift!"))
		return
	if(M.sentience_type != SENTIENCE_ORGANIC)
		to_chat(user, span_warning("[M] cannot be tamed!"))
		return
	if(!do_after(user, 1.5 SECONDS, M))
		return
	M.visible_message(span_notice("[M] seems happy with you after exposure to the bouqet!"))
	M.add_atom_colour("#11c42f", FIXED_COLOUR_PRIORITY)
	M.drop_loot()
	M.faction = user.faction
	summons |= M
	
///Bosses

//Miniboss Miner

/obj/item/melee/transforming/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	force = 12
	force_on = 20 //force when active
	throwforce = 20
	throwforce_on = 20
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	icon_state = "cleaving_saw"
	icon_state_on = "cleaving_saw_open"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_off = list("attacked", "sawed", "sliced", "torn", "ripped", "diced", "cut")
	attack_verb_on = list("cleaved", "swiped", "slashed", "chopped")
	hitsound = 'sound/weapons/bladeslice.ogg'
	hitsound_on = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	w_class_on = WEIGHT_CLASS_BULKY
	sharpness = SHARP_EDGED
	faction_bonus_force = 30
	nemesis_factions = list("mining", "boss")
	var/transform_cooldown
	var/swiping = FALSE

/obj/item/melee/transforming/cleaving_saw/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [active ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].\n"+\
	"Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.\n"+\
	"Transforming it immediately after an attack causes the next attack to come out faster.</span>"

/obj/item/melee/transforming/cleaving_saw/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is [active ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!"))
	transform_cooldown = 0
	transform_weapon(user, TRUE)
	return BRUTELOSS

/obj/item/melee/transforming/cleaving_saw/transform_weapon(mob/living/user, supress_message_text)
	if(transform_cooldown > world.time)
		return FALSE
	. = ..()
	if(.)
		transform_cooldown = world.time + (CLICK_CD_MELEE * 0.5)
		user.changeNext_move(CLICK_CD_MELEE * 0.25)

/obj/item/melee/transforming/cleaving_saw/transform_messages(mob/living/user, supress_message_text)
	if(!supress_message_text)
		if(active)
			to_chat(user, span_notice("You open [src]. It will now cleave enemies in a wide arc and deal additional damage to fauna."))
		else
			to_chat(user, span_notice("You close [src]. It will now attack rapidly and cause fauna to bleed."))
	playsound(user, 'sound/magic/clockwork/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (active * 30000))

/obj/item/melee/transforming/cleaving_saw/clumsy_transform_effect(mob/living/user)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("You accidentally cut yourself with [src], like a doofus!"))
		user.take_bodypart_damage(10)

/obj/item/melee/transforming/cleaving_saw/melee_attack_chain(mob/user, atom/target, params)
	..()
	if(!active)
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/transforming/cleaving_saw/nemesis_effects(mob/living/user, mob/living/target)
	var/datum/status_effect/saw_bleed/B = target.has_status_effect(STATUS_EFFECT_SAWBLEED)
	if(!B)
		if(!active) //This isn't in the above if-check so that the else doesn't care about active
			target.apply_status_effect(STATUS_EFFECT_SAWBLEED)
	else
		B.add_bleed(B.bleed_buildup)

/obj/item/melee/transforming/cleaving_saw/attack(mob/living/target, mob/living/carbon/human/user)
	if(!active || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!active)
			faction_bonus_force = 0
		..()
		if(!active)
			faction_bonus_force = initial(faction_bonus_force)
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(target))
		swiping = TRUE
		var/static/list/cleaving_saw_cleave_angles = list(0, -45, 45) //so that the animation animates towards the target clicked and not towards a side target
		for(var/i in cleaving_saw_cleave_angles)
			var/turf/T = get_step(user_turf, turn(dir_to_target, i))
			for(var/mob/living/L in T)
				if(user.Adjacent(L) && L.density)
					melee_attack_chain(user, L)
		swiping = FALSE

//Dragon

/obj/structure/closet/crate/necropolis/dragon
	name = "dragon chest"

/obj/structure/closet/crate/necropolis/dragon/PopulateContents()
	new /obj/item/gem/bloodstone(src)
	var/loot = rand(1,4)
	switch(loot)
		if(1)
			new /obj/item/melee/ghost_sword(src)
		if(2)
			new /obj/item/lava_staff(src)
			new /obj/item/book/granter/spell/sacredflame(src)
		if(3)
			new /obj/item/dragon_egg(src)
		if(4)
			new /obj/item/dragons_blood(src)

/obj/structure/closet/crate/necropolis/dragon/crusher
	name = "firey dragon chest"

/obj/structure/closet/crate/necropolis/dragon/crusher/PopulateContents()
	..()
	new /obj/item/crusher_trophy/tail_spike(src)
	new /obj/item/gem/bloodstone(src)

/obj/item/melee/ghost_sword
	name = "\improper spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon = 'icons/obj/weapons/swords.dmi'
	icon_state = "spectral"
	item_state = "spectral"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/Initialize()
	. = ..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src
	AddComponent(/datum/component/butchering, 150, 90)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = GLOB.observer_default_invisibility
		G.mouse_opacity = initial(G.mouse_opacity)
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list -= src
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "You just recently called out for aid. You don't want to annoy the spirits.")
		return
	to_chat(user, "You call out for aid, attempting to summon spirits to your side.")

	notify_ghosts("[user] is raising [user.p_their()] [src], calling for your help!",
		enter_link="<a href=?src=[REF(src)];orbit=1>(Click to help)</a>",
		source = user, action=NOTIFY_ORBIT, ignore_key = POLL_IGNORE_SPECTRAL_BLADE)

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/recursive_orbit_collect(atom/A, list/L)
	for(var/i in A.orbiters?.orbiters)
		if(!isobserver(i) || (i in L))
			continue
		L |= i
		recursive_orbit_collect(i, L)

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/list/mob/dead/observer/current_spirits = list()

	recursive_orbit_collect(src, current_spirits)
	recursive_orbit_collect(loc, current_spirits)		//anything holding us

	for(var/i in spirits - current_spirits)
		var/mob/dead/observer/G = i
		G.invisibility = GLOB.observer_default_invisibility
		G.mouse_opacity = initial(G.mouse_opacity)

	for(var/i in current_spirits)
		var/mob/dead/observer/G = i
		G.invisibility = 0
		G.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	spirits = current_spirits
	return length(spirits)

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()

	force = clamp((ghost_counter * 4), 0, 75)
	user.visible_message(span_danger("[user] strikes with the force of [ghost_counter] vengeful spirits!"))
	..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/ghost_counter = ghost_check()
	final_block_chance += clamp((ghost_counter * 5), 0, 75)
	owner.visible_message(span_danger("[owner] is protected by a ring of [ghost_counter] ghosts!"))
	return ..()

//Blood

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	var/random = rand(1,4)

	switch(random)
		if(1)
			to_chat(user, span_danger("Your appearance morphs to that of a very small humanoid ash dragon! You feel a little tougher, and fire now seems oddly comforting."))
			H.dna.features = list("mcolor" = "A02720", "tail_lizard" = "Dark Tiger", "tail_human" = "None", "snout" = "Sharp", "horns" = "Drake", "ears" = "None", "wings" = "None", "frills" = "None", "spines" = "Long", "body_markings" = "Dark Tiger Body", "legs" = "Digitigrade Legs")
			H.set_species(/datum/species/lizard/draconid)
			H.eye_color = "fee5a3"
			H.dna.update_ui_block(DNA_EYE_COLOR_BLOCK)
			H.updateappearance()
		if(2)
			to_chat(user, span_danger("Your flesh begins to melt! Miraculously, you seem fine otherwise."))
			H.set_species(/datum/species/skeleton)
		if(3)
			to_chat(user, span_danger("Power courses through you! You can now shift your form at will."))
			if(user.mind)
				var/obj/effect/proc_holder/spell/targeted/shapeshift/dragon/D = new
				user.mind.AddSpell(D)
		if(4)
			to_chat(user, span_danger("You feel like you could walk straight through lava now."))
			H.weather_immunities |= "lava"

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)

/datum/disease/transformation/dragon
	name = "dragon transformation"
	cure_text = "nothing"
	cures = list(/datum/reagent/medicine/adminordrazine)
	agent = "dragon's blood"
	desc = "What do dragons have to do with Space Station 13?"
	stage_prob = 20
	severity = DISEASE_SEVERITY_BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your bones ache.")
	stage2	= list("Your skin feels scaly.")
	stage3	= list(span_danger("You have an overwhelming urge to terrorize some peasants."), span_danger("Your teeth feel sharper."))
	stage4	= list(span_danger("Your blood burns."))
	stage5	= list(span_danger("You're a fucking dragon. However, any previous allegiances you held still apply. It'd be incredibly rude to eat your still human friends for no reason."))
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser


//Lava Staff

/obj/item/lava_staff
	name = "staff of lava"
	desc = "The ability to fill the emergency shuttle with lava. What more could you want out of life?"
	icon_state = "staffofstorms"
	item_state = "staffofstorms"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hitsound = 'sound/weapons/sear.ogg'
	var/turf_type = /turf/open/lava/smooth
	var/transform_string = "lava"
	var/reset_turf_type = /turf/open/floor/plating/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 10 SECONDS
	var/create_delay = 3 SECONDS
	var/reset_cooldown = 5 SECONDS
	var/timer = 0
	var/static/list/banned_turfs = typecacheof(list(/turf/open/space/transit, /turf/closed))

/obj/item/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(timer > world.time)
		return

	if(is_type_in_typecache(target, banned_turfs))
		return

	if(target in view(user.client.view, get_turf(user)))

		var/turf/open/T = get_turf(target)
		if(!istype(T))
			return
		if(!istype(T, turf_type))
			var/obj/effect/temp_visual/lavastaff/L = new /obj/effect/temp_visual/lavastaff(T)
			L.alpha = 0
			animate(L, alpha = 255, time = create_delay)
			user.visible_message(span_danger("[user] points [src] at [T]!"))
			timer = world.time + create_delay + 1
			if(do_after(user, create_delay, T))
				var/old_name = T.name
				if(T.TerraformTurf(turf_type, flags = CHANGETURF_INHERIT_AIR))
					user.visible_message(span_danger("[user] turns \the [old_name] into [transform_string]!"))
					message_admins("[ADMIN_LOOKUPFLW(user)] fired the lava staff at [ADMIN_VERBOSEJMP(T)]")
					log_game("[key_name(user)] fired the lava staff at [AREACOORD(T)].")
					timer = world.time + create_cooldown
					playsound(T,'sound/magic/fireball.ogg', 200, 1)
			else
				timer = world.time
			qdel(L)
		else
			var/old_name = T.name
			if(T.TerraformTurf(reset_turf_type, flags = CHANGETURF_INHERIT_AIR))
				user.visible_message(span_danger("[user] turns \the [old_name] into [reset_string]!"))
				timer = world.time + reset_cooldown
				playsound(T,'sound/magic/fireball.ogg', 200, 1)

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50

//Dragon Egg

/obj/item/dragon_egg
	name = "dragon's egg"
	desc = "A large egg-shaped rock. It's cold to the touch..."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	color = "#2C2C2C"

/obj/item/dragon_egg/burn()
	visible_message(span_boldwarning("[src] suddenly begins to glow red and starts violently shaking!"))
	name = "heated dragon's egg"
	desc = "A large egg seemingly made out of rock. It's red-hot and seems to be shaking!"
	color = "#990000"
	extinguish()
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	addtimer(CALLBACK(src, .proc/hatch), 20 SECONDS)

/obj/item/dragon_egg/proc/hatch()
	visible_message(span_boldwarning("[src] suddenly cracks apart, revealing a tiny ash drake!"))
	new /mob/living/simple_animal/hostile/drakeling(get_turf(src))
	qdel(src)

//Bubblegum
/obj/structure/closet/crate/necropolis/bubblegum
	name = "bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/PopulateContents()
	new /obj/item/clothing/suit/space/hostile_environment(src)
	new /obj/item/clothing/head/helmet/space/hostile_environment(src)
	new /obj/item/gem/bloodstone(src)
	var/loot = rand(1,2)
	switch(loot)
		if(1)
			new /obj/item/melee/knuckles(src)
		if(2)
			new /obj/item/clothing/gloves/bracer/cuffs(src)

/obj/structure/closet/crate/necropolis/bubblegum/crusher
	name = "bloody bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/crusher/PopulateContents()
	..()
	new /obj/item/crusher_trophy/demon_claws(src)

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/H in range(7,user))
		var/obj/effect/mine/pickup/bloodbath/B = new(H)
		INVOKE_ASYNC(B, /obj/effect/mine/pickup/bloodbath/.proc/mineEffect, H)
	to_chat(user, span_notice("You shatter the bottle!"))
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
	message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(user)] has activated a bottle of mayhem!"))
	log_combat(user, null, "activated a bottle of mayhem", src)
	qdel(src)

/obj/item/blood_contract
	name = "blood contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	color = "#FF0000"
	desc = "Mark your target for death."
	var/used = FALSE

/obj/item/blood_contract/attack_self(mob/user)
	if(used)
		return
	used = TRUE

	var/list/da_list = list()
	for(var/I in GLOB.alive_mob_list & GLOB.player_list)
		var/mob/living/L = I
		da_list[L.real_name] = L

	var/choice = input(user,"Who do you want dead?","Choose Your Victim") as null|anything in da_list

	choice = da_list[choice]

	if(!choice)
		used = FALSE
		return
	if(!(isliving(choice)))
		to_chat(user, "[choice] is already dead!")
		used = FALSE
		return
	if(choice == user)
		to_chat(user, "You feel like writing your own name into a cursed death warrant would be unwise.")
		used = FALSE
		return

	var/mob/living/L = choice

	message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(L)] has been marked for death by [ADMIN_LOOKUPFLW(user)]!"))

	var/datum/antagonist/blood_contract/A = new
	L.mind.add_antag_datum(A)

	log_combat(user, L, "took out a blood contract on", src)
	qdel(src)

#define COOLDOWN 150
#define COOLDOWN_HUMAN 100
#define COOLDOWN_ANIMAL 60
#define COOLDOWN_SPLASH 100
/obj/item/melee/knuckles
	name = "bloody knuckles"
	desc = "Knuckles born of a desire for violence. Made to ensure their victims stay in the fight until there's a winner. Activating these knuckles covers several meters ahead of the user with blood."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "bloodyknuckle"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	item_state = "knuckles"
	w_class = WEIGHT_CLASS_SMALL
	force = 18
	var/next_reach = 0
	var/next_splash = 0
	var/next_knuckle = 0
	var/splash_range = 9
	attack_verb = list("thrashed", "pummeled", "walloped")
	actions_types = list(/datum/action/item_action/reach, /datum/action/item_action/visegrip)

/obj/item/melee/knuckles/afterattack(mob/living/target, mob/living/user, proximity)
	var/mob/living/L = target
	if (proximity)
		if(L.has_status_effect(STATUS_EFFECT_KNUCKLED))
			L.apply_status_effect(/datum/status_effect/roots)
			return
		if(next_knuckle > world.time)
			to_chat(user, span_warning("The knuckles aren't ready to mark yet."))
			return
		else
			L.apply_status_effect(STATUS_EFFECT_KNUCKLED)
			if(ishuman(L))
				next_knuckle = world.time + COOLDOWN_HUMAN
				return
			next_knuckle = world.time + COOLDOWN_ANIMAL

/obj/item/melee/knuckles/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(next_splash > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	user.visible_message(span_warning("[user] splashes blood from the knuckles!"))
	playsound(T, 'sound/effects/splat.ogg', 80, 5, -1)
	for(var/i = 0 to splash_range)
		if(T)
			new /obj/effect/decal/cleanable/blood(T)
		T = get_step(T,user.dir)
	next_splash = world.time + COOLDOWN_SPLASH

/obj/item/melee/knuckles/ui_action_click(mob/living/user, action)
	var/mob/living/U = user
	if(istype(action, /datum/action/item_action/reach))
		if(next_reach > world.time)
			to_chat(U, span_warning("You can't do that yet!"))
			return
		var/valid_reaching = FALSE
		for(var/mob/living/L in view(7, U))
			if(L == U)
				continue
			for(var/obj/effect/decal/cleanable/B in range(0,L))
				if(istype(B, /obj/effect/decal/cleanable/blood )|| istype(B, /obj/effect/decal/cleanable/trail_holder))
					valid_reaching = TRUE
					L.apply_status_effect(STATUS_EFFECT_KNUCKLED)
		if(!valid_reaching)
			to_chat(U, span_warning("There's nobody to use this on!"))
			return
		next_reach = world.time + COOLDOWN
	else if(istype(action, /datum/action/item_action/visegrip))
		var/valid_casting = FALSE
		for(var/mob/living/L in view(8, U))
			if(L.has_status_effect(STATUS_EFFECT_KNUCKLED))
				valid_casting = TRUE
				L.apply_status_effect(/datum/status_effect/roots)
		if(!valid_casting)
			to_chat(U, span_warning("There's nobody to use this on!"))
			return
		#undef COOLDOWN
		#undef COOLDOWN_HUMAN
		#undef COOLDOWN_ANIMAL
//Colossus
/obj/structure/closet/crate/necropolis/colossus
	name = "colossus chest"

/obj/structure/closet/crate/necropolis/colossus/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/colossus))
		return BULLET_ACT_FORCE_PIERCE
	return ..()

/obj/structure/closet/crate/necropolis/colossus/PopulateContents()
	var/list/choices = subtypesof(/obj/machinery/anomalous_crystal)
	var/random_crystal = pick(choices)
	new random_crystal(src)
	new /obj/item/organ/vocal_cords/colossus(src)
	new /obj/item/clothing/glasses/godeye(src)
	new /obj/item/gem/void(src)

/obj/structure/closet/crate/necropolis/colossus/crusher
	name = "angelic colossus chest"

/obj/structure/closet/crate/necropolis/colossus/crusher/PopulateContents()
	..()
	new /obj/item/crusher_trophy/blaster_tubes(src)

//Hierophant
/obj/item/hierophant_club
	name = "hierophant club"
	desc = "The strange technology of this large club allows various nigh-magical feats. It used to beat you, but now you can set the beat."
	icon_state = "hierophant_club_ready_beacon"
	item_state = "hierophant_club_ready_beacon"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	attack_verb = list("clubbed", "beat", "pummeled")
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall, /datum/action/item_action/toggle_unfriendly_fire)
	var/z_level_check = TRUE //Whether or not it checks for mining z level
	var/cooldown_time = 20 //how long the cooldown between non-melee ranged attacks is
	var/chaser_cooldown = 81 //how long the cooldown between firing chasers at mobs is
	var/chaser_timer = 0 //what our current chaser cooldown is
	var/chaser_speed = 0.8 //how fast our chasers are
	var/timer = 0 //what our current cooldown is
	var/blast_range = 13 //how long the cardinal blast's walls are
	var/obj/effect/hierophant/beacon //the associated beacon we teleport to
	var/teleporting = FALSE //if we ARE teleporting
	var/friendly_fire_check = FALSE //if the blasts we make will consider our faction against the faction of hit targets

/obj/item/hierophant_club/examine(mob/user)
	. = ..()
	. += "[span_hierophant_warning("The[beacon ? " beacon is not currently":"re is a beacon"] attached.")]"

/obj/item/hierophant_club/suicide_act(mob/living/user)
	say("Xverwpsgexmrk...", forced = "hierophant club suicide")
	user.visible_message(span_suicide("[user] holds [src] into the air! It looks like [user.p_theyre()] trying to commit suicide!"))
	new/obj/effect/temp_visual/hierophant/telegraph(get_turf(user))
	playsound(user,'sound/machines/airlockopen.ogg', 75, TRUE)
	user.visible_message("[span_hierophant_warning("[user] fades out, leaving [user.p_their()] belongings behind!")]")
	for(var/obj/item/I in user)
		if(I != src)
			user.dropItemToGround(I)
	for(var/turf/T in RANGE_TURFS(1, user))
		var/obj/effect/temp_visual/hierophant/blast/B = new(T, user, TRUE)
		B.damage = 0
	user.dropItemToGround(src) //Drop us last, so it goes on top of their stuff
	qdel(user)

/obj/item/hierophant_club/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/turf/T = get_turf(target)
	if(!T || timer > world.time)
		return
	if(!is_mining_level(T.z) && z_level_check)
		to_chat(user, span_warning("The club fizzles weakly, it seem its power doesn't reach this area.") )
		return
	calculate_anger_mod(user)
	timer = world.time + CLICK_CD_MELEE //by default, melee attacks only cause melee blasts, and have an accordingly short cooldown
	if(proximity_flag)
		INVOKE_ASYNC(src, .proc/aoe_burst, T, user)
		log_combat(user, target, "fired 3x3 blast at", src)
	else
		if(ismineralturf(target) && get_dist(user, target) < 6) //target is minerals, we can hit it(even if we can't see it)
			INVOKE_ASYNC(src, .proc/cardinal_blasts, T, user)
			timer = world.time + cooldown_time
		else if(target in view(5, get_turf(user))) //if the target is in view, hit it
			timer = world.time + cooldown_time
			if(isliving(target) && chaser_timer <= world.time) //living and chasers off cooldown? fire one!
				chaser_timer = world.time + chaser_cooldown
				var/obj/effect/temp_visual/hierophant/chaser/C = new(get_turf(user), user, target, chaser_speed, friendly_fire_check)
				C.damage = 30
				C.monster_damage_boost = FALSE
				log_combat(user, target, "fired a chaser at", src)
			else
				INVOKE_ASYNC(src, .proc/cardinal_blasts, T, user) //otherwise, just do cardinal blast
				log_combat(user, target, "fired cardinal blast at", src)
		else
			to_chat(user, span_warning("That target is out of range!") )
			timer = world.time
	INVOKE_ASYNC(src, .proc/prepare_icon_update)

/obj/item/hierophant_club/proc/calculate_anger_mod(mob/user) //we get stronger as the user loses health
	chaser_cooldown = initial(chaser_cooldown)
	cooldown_time = initial(cooldown_time)
	chaser_speed = initial(chaser_speed)
	blast_range = initial(blast_range)
	if(isliving(user))
		var/mob/living/L = user
		var/health_percent = L.health / L.maxHealth
		chaser_cooldown += round(health_percent * 20) //two tenths of a second for each missing 10% of health
		cooldown_time += round(health_percent * 10) //one tenth of a second for each missing 10% of health
		chaser_speed = max(chaser_speed + health_percent, 0.5) //one tenth of a second faster for each missing 10% of health
		blast_range -= round(health_percent * 10) //one additional range for each missing 10% of health

/obj/item/hierophant_club/update_icon()
	icon_state = "hierophant_club[timer <= world.time ? "_ready":""][(beacon && !QDELETED(beacon)) ? "":"_beacon"]"
	item_state = icon_state
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
		M.update_inv_back()

/obj/item/hierophant_club/proc/prepare_icon_update()
	update_icon()
	sleep(timer - world.time)
	update_icon()

/obj/item/hierophant_club/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_unfriendly_fire)) //toggle friendly fire...
		friendly_fire_check = !friendly_fire_check
		to_chat(user, span_warning("You toggle friendly fire [friendly_fire_check ? "off":"on"]!"))
		return
	if(timer > world.time)
		return
	if(!user.is_holding(src)) //you need to hold the staff to teleport
		to_chat(user, span_warning("You need to hold the club in your hands to [beacon ? "teleport with it":"detach the beacon"]!"))
		return
	if(!beacon || QDELETED(beacon))
		if(isturf(user.loc))
			user.visible_message("[span_hierophant_warning("[user] starts fiddling with [src]'s pommel...")]", \
			span_notice("You start detaching the hierophant beacon..."))
			timer = world.time + 5.1 SECONDS
			INVOKE_ASYNC(src, .proc/prepare_icon_update)
			if(do_after(user, 5 SECONDS, user) && !beacon)
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/blind.ogg', 200, 1, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
				beacon = new/obj/effect/hierophant(T)
				user.update_action_buttons_icon()
				user.visible_message("[span_hierophant_warning("[user] places a strange machine beneath [user.p_their()] feet!")]", \
				"[span_hierophant("You detach the hierophant beacon, allowing you to teleport yourself and any allies to it at any time!")]\n\
				[span_notice("You can remove the beacon to place it again by striking it with the club.")]")
			else
				timer = world.time
				INVOKE_ASYNC(src, .proc/prepare_icon_update)
		else
			to_chat(user, span_warning("You need to be on solid ground to detach the beacon!"))
		return
	if(get_dist(user, beacon) <= 2) //beacon too close abort
		to_chat(user, span_warning("You are too close to the beacon to teleport to it!"))
		return
	if(is_blocked_turf(get_turf(beacon), TRUE))
		to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("You don't have enough space to teleport from here!"))
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message("[span_hierophant_warning("[user] starts to glow faintly...")]")
	timer = world.time + 5 SECONDS
	INVOKE_ASYNC(src, .proc/prepare_icon_update)
	beacon.icon_state = "hierophant_tele_on"
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE1 = new /obj/effect/temp_visual/hierophant/telegraph/edge(user.loc)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE2 = new /obj/effect/temp_visual/hierophant/telegraph/edge(beacon.loc)
	if(do_after(user, 4 SECONDS, user) && user && beacon)
		var/turf/T = get_turf(beacon)
		var/turf/source = get_turf(user)
		if(is_blocked_turf(T, TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
			user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, .proc/prepare_icon_update)
			beacon.icon_state = "hierophant_tele_off"
			return
		new /obj/effect/temp_visual/hierophant/telegraph(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph(source, user)
		playsound(T,'sound/magic/wand_teleport.ogg', 200, 1)
		playsound(source,'sound/machines/airlockopen.ogg', 200, 1)
		if(!do_after(user, 0.3 SECONDS, user) || !user || !beacon || QDELETED(beacon)) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, .proc/prepare_icon_update)
			if(beacon)
				beacon.icon_state = "hierophant_tele_off"
			return
		if(is_blocked_turf(T, TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
			user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, .proc/prepare_icon_update)
			beacon.icon_state = "hierophant_tele_off"
			return
		user.log_message("teleported self from [AREACOORD(source)] to [beacon]", LOG_GAME)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, user)
		for(var/t in RANGE_TURFS(1, T))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //blasts produced will not hurt allies
			B.damage = 30
		for(var/t in RANGE_TURFS(1, source))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //but absolutely will hurt enemies
			B.damage = 30
		for(var/mob/living/L in range(1, source))
			INVOKE_ASYNC(src, .proc/teleport_mob, source, L, T, user) //regardless, take all mobs near us along
		sleep(0.6 SECONDS) //at this point the blasts detonate
		if(beacon)
			beacon.icon_state = "hierophant_tele_off"
	else
		qdel(TE1)
		qdel(TE2)
		timer = world.time
		INVOKE_ASYNC(src, .proc/prepare_icon_update)
	if(beacon)
		beacon.icon_state = "hierophant_tele_off"
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/hierophant_club/proc/teleport_mob(turf/source, mob/M, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, M)) //get position relative to caster
	if(!turf_to_teleport_to || is_blocked_turf(turf_to_teleport_to, TRUE))
		return
	animate(M, alpha = 0, time = 0.2 SECONDS, easing = EASE_OUT) //fade out
	sleep(0.1 SECONDS)
	if(!M)
		return
	M.visible_message("[span_hierophant_warning("[M] fades out!")]")
	sleep(0.2 SECONDS)
	if(!M)
		return
	M.forceMove(turf_to_teleport_to)
	sleep(0.1 SECONDS)
	if(!M)
		return
	animate(M, alpha = 255, time = 0.2 SECONDS, easing = EASE_IN) //fade IN
	sleep(0.1 SECONDS)
	if(!M)
		return
	M.visible_message("[span_hierophant_warning("[M] fades in!")]")
	if(user != M)
		log_combat(user, M, "teleported", null, "from [AREACOORD(source)]")

/obj/item/hierophant_club/proc/cardinal_blasts(turf/T, mob/living/user) //fire cardinal cross blasts with a delay
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph/cardinal(T, user)
	playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(0.2 SECONDS)
	var/obj/effect/temp_visual/hierophant/blast/B = new(T, user, friendly_fire_check)
	B.damage = HIEROPHANT_CLUB_CARDINAL_DAMAGE
	B.monster_damage_boost = FALSE
	for(var/d in GLOB.cardinals)
		INVOKE_ASYNC(src, .proc/blast_wall, T, d, user)

/obj/item/hierophant_club/proc/blast_wall(turf/T, dir, mob/living/user) //make a wall of blasts blast_range tiles long
	if(!T)
		return
	var/range = blast_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		if(!J)
			return
		var/obj/effect/temp_visual/hierophant/blast/B = new(J, user, friendly_fire_check)
		B.damage = HIEROPHANT_CLUB_CARDINAL_DAMAGE
		B.monster_damage_boost = FALSE
		previousturf = J
		J = get_step(previousturf, dir)

/obj/item/hierophant_club/proc/aoe_burst(turf/T, mob/living/user) //make a 3x3 blast around a target
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph(T, user)
	playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(0.2 SECONDS)
	for(var/t in RANGE_TURFS(1, T))
		var/obj/effect/temp_visual/hierophant/blast/B = new(t, user, friendly_fire_check)
		B.damage = 15 //keeps monster damage boost due to lower damage

/obj/item/hierophant_antenna
	name = "hierophant's antenna"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "hierophant_antenna"
	item_state = "hierophant_antenna"
	desc = "Extends the range of the herald's power."

/obj/item/hierophant_club/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/hierophant_antenna))
		if(z_level_check)
			z_level_check = FALSE
			desc += " It has an ominous antenna attached."
			qdel(I)
		else
			to_chat(user, span_warning("The herald's power already reaches this club!"))
		return TRUE
	else
		return ..()

/obj/item/hierophant_club/station
	z_level_check = FALSE

//Stalwart
/obj/structure/closet/crate/sphere/stalwart
	name = "silvery capsule"
	desc = "It feels cold to the touch..."

/obj/structure/closet/crate/sphere/stalwart/PopulateContents()
	new /obj/item/gun/energy/plasmacutter/adv/robocutter

/obj/item/gun/energy/plasmacutter/adv/robocutter
	name = "energized powercutter"
	desc = "Ripped out of an ancient machine, this self-recharging cutter is unmatched."
	fire_delay = 4
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "robocutter"
	selfcharge = 1
//Just some minor stuff
/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"

/obj/structure/closet/crate/necropolis/puzzle/PopulateContents()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody(src)
		if(2)
			new /obj/item/wisp_lantern(src)
		if(3)
			new /obj/item/prisoncube(src)

//Legion
/obj/item/organ/grandcore
	name = "grand core"
	desc = "The source of the Legion's powers. Though mostly expended, you might be able to get some use out of it."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "grandcore"
	slot = "hivecore"
	w_class = WEIGHT_CLASS_SMALL 
	decay_factor = 0
	actions_types = list(/datum/action/item_action/organ_action/threebloodlings)

/obj/item/organ/grandcore/attack(mob/living/carbon/human/H, mob/living/carbon/human/user, obj/target)
	if(H == user && istype(H))
		playsound(user,'sound/effects/singlebeat.ogg',40,1)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		Insert(user)

/obj/item/organ/grandcore/Insert(mob/living/carbon/H, special = 0)
	..()
	H.faction |= "blooded"
	H.AddSpell (new /obj/effect/proc_holder/spell/targeted/touch/raise)
	H.AddSpell (new /obj/effect/proc_holder/spell/aoe_turf/horde)
	if(NOBLOOD in H.dna.species.species_traits)
		to_chat(owner, "<span class ='userdanger'>Despite lacking blood, you were able to take in the grand core. You will pay for your power in killer headaches!</span>")
	else
		to_chat(owner, "<span class ='userdanger'>You've taken in the grand core, allowing you to control minions at the cost of your blood!</span>")

/obj/item/organ/grandcore/Remove(mob/living/carbon/H, special = 0)
	H.faction -= "blooded"
	H.RemoveSpell (/obj/effect/proc_holder/spell/targeted/touch/raise)
	H.RemoveSpell (/obj/effect/proc_holder/spell/aoe_turf/horde)
	..()

/datum/action/item_action/organ_action/threebloodlings
	name = "Summon bloodlings"
	desc = "Summon a conjure a few bloodlings at the cost of 6% blood or 8 brain damage for races without blood."
	var/next_expulsion = 0
	var/cooldown = 10 
	
/datum/action/item_action/organ_action/threebloodlings/Trigger()
	var/mob/living/carbon/H = owner
	. = ..() 
	if(next_expulsion > world.time)
		to_chat(owner, span_warning("Don't spill your blood so haphazardly!"))
		return
	if(NOBLOOD in H.dna.species.species_traits)
		H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 8) //brain damage wont stop you from running away so opting for that instead of poison or breath damage 
		to_chat(H, "<span class ='userdanger'>Your head pounds as you produce bloodlings!</span>")
	else
		to_chat(H, "<span class ='userdanger'>You spill your blood, and it comes to life as bloodlings!</span>")
		H.blood_volume -= 35
	spawn_atom_to_turf(/mob/living/simple_animal/hostile/asteroid/hivelordbrood/bloodling, owner, 3, TRUE) //think 1 in 4 is a good chance of not being targeted by fauna
	next_expulsion = world.time + cooldown

//demonic-frost miner
/obj/structure/closet/crate/wooden/miner
	name = "frosty chest"

/obj/structure/closet/crate/wooden/miner/PopulateContents()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/clothing/shoes/winterboots/ice_boots/speedy(src)
		if(2)
			new /obj/item/pickaxe/drill/jackhammer/demonic(src)
		if(3)
			new /obj/item/gun/energy/snowball_machine_gun(src)
