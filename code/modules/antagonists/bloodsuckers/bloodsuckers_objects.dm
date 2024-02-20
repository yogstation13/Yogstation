//////////////////////
//       TRAP       //
//////////////////////

/obj/item/restraints/legcuffs/beartrap/bloodsucker
	name = "stake trap"
	desc = "Turn the stakes against the staker! Or something like that..."
	icon = 'icons/obj/vamp_obj.dmi'
	icon_state = "staketrap"
	slowdown = 10
	var/area/lair_area
	var/mob/lair_owner

/obj/item/restraints/legcuffs/beartrap/bloodsucker/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/restraints/legcuffs/beartrap/bloodsucker/attack_self(mob/user)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	lair_area = bloodsuckerdatum?.bloodsucker_lair_area
	START_PROCESSING(SSobj, src)
	if(!bloodsuckerdatum)
		to_chat(user, span_notice("Although it seems simple you have no idea how to reactivate [src]."))
		return
	if(armed)
		STOP_PROCESSING(SSobj,src)
		return ..() //disarm it, otherwise continue to try and place
	if(!bloodsuckerdatum.bloodsucker_lair_area)
		to_chat(user, span_danger("You don't have a lair. Claim a coffin to make that location your lair."))
		return
	if(lair_area != get_area(src))
		to_chat(user, span_danger("You may only activate this trap in your lair: [lair_area]."))
		return
	lair_area = bloodsuckerdatum.bloodsucker_lair_area
	lair_owner = user
	START_PROCESSING(SSobj, src)
	return ..()

/obj/item/restraints/legcuffs/beartrap/bloodsucker/Crossed(AM as mob|obj)
	var/mob/living/carbon/human/user = AM
	if(armed && (IS_BLOODSUCKER(user) || IS_VASSAL(user)))
		to_chat(user, span_notice("You gracefully step over the blood puddle and avoid triggering the trap"))
		return
	return ..()

/obj/item/restraints/legcuffs/beartrap/bloodsucker/close_trap()
	STOP_PROCESSING(SSobj, src)
	lair_area = null
	lair_owner = null
	return ..()
	
/obj/item/restraints/legcuffs/beartrap/bloodsucker/process()
	if(!armed)
		STOP_PROCESSING(SSobj,src)
		return
	if(get_area(src) != lair_area)
		close_trap()

//////////////////////
//      STAKES      //
//////////////////////

/// Do I have a stake in my heart?
/mob/living/proc/am_staked()
	var/obj/item/bodypart/chosen_bodypart = get_bodypart(BODY_ZONE_CHEST)
	if(!chosen_bodypart)
		return FALSE
	for(var/obj/item/embedded_stake in chosen_bodypart.embedded_objects)
		if(istype(embedded_stake, /obj/item/stake))
			return TRUE
	return FALSE

/// You can't go to sleep in a coffin with a stake in you.
/mob/living/proc/StakeCanKillMe()
	if(IsSleeping())
		return TRUE
	if(stat >= UNCONSCIOUS)
		return TRUE
	if(blood_volume <= 0)
		return TRUE
	if(HAS_TRAIT(src, TRAIT_NODEATH))
		return TRUE
	return FALSE

/// Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/mob/living/proc/can_be_staked()
	return FALSE

/mob/living/carbon/can_be_staked()
	if(!(mobility_flags & MOBILITY_MOVE))
		return TRUE
	return FALSE

/obj/item/stake
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
	icon = 'icons/obj/stakes.dmi'
	icon_state = "wood"
	lefthand_file = 'icons/mob/inhands/antag/bs_leftinhand.dmi'
	righthand_file = 'icons/mob/inhands/antag/bs_rightinhand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("staked", "stabbed", "tore into")
	/// Embedding
	sharpness = SHARP_EDGED
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 20, "embedded_fall_chance" = 10)
	force = 6
	throwforce = 10
	max_integrity = 30
	/// Time it takes to embed the stake into someone's chest.
	var/staketime = 12 SECONDS

/obj/item/stake/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if(.)
		return TRUE
	// Invalid Target, or not targetting the chest?
	if(check_zone(user.zone_selected) != BODY_ZONE_CHEST)
		return TRUE
	if(target == user)
		return TRUE
	if(!target.can_be_staked()) // Oops! Can't.
		to_chat(user, span_danger("You can't stake [target] when they are moving about! They have to be laying down or grabbed by the neck!"))
		return TRUE
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		to_chat(user, span_danger("[target]'s chest resists the stake. It won't go in."))
		return TRUE

	to_chat(user, span_notice("You put all your weight into embedding the stake into [target]'s chest..."))
	playsound(user, 'sound/magic/Demon_consume.ogg', 50, 1)
	if(!do_after(user, staketime, target, extra_checks = CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon, can_be_staked)))) // user / target / time / uninterruptable / show progress bar / extra checks
		return
	// Drop & Embed Stake
	user.visible_message(
		span_danger("[user.name] drives the [src] into [target]'s chest!"),
		span_danger("You drive the [src] into [target]'s chest!"),
	)
	playsound(get_turf(target), 'sound/effects/splat.ogg', 40, 1)
//	user.dropItemToGround(src, TRUE)
	if(QDELETED(src)) // in case trying to embed it caused its deletion (say, if it's DROPDEL)
		return
	if(!target.mind)
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = target.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum)
		// If DEAD or TORPID... Kill Bloodsucker!
		if(target.StakeCanKillMe())
			bloodsuckerdatum.FinalDeath()
		else
			to_chat(target, span_userdanger("You have been staked! Your powers are useless while it remains in place, and death would be permanent!"))
			to_chat(target, span_userdanger("You have been staked!"))

/// Created by welding and acid-treating a simple stake.
/obj/item/stake/hardened
	name = "hardened stake"
	desc = "A hardened wooden stake carved to a sharp point and scorched at the end."
	icon_state = "hardened"
	force = 8
	throwforce = 12
	armour_penetration = 10
	embedding = list("embed_chance" = 35)
	staketime = 80

/obj/item/stake/hardened/silver
	name = "silver stake"
	desc = "Polished and sharp at the end. For when some mofo is always trying to iceskate uphill."
	icon_state = "silver"
	force = 9
	armour_penetration = 25
	embedding = list("embed_chance" = 65)
	staketime = 60

/obj/item/stake/ducky
	name = "wooden ducky"
	desc = "Remember to not drench your wooden ducky in bath water to prevent it from stinking."
	icon_state = "ducky"
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = SHARP_POINTY //torture ducky

/obj/item/stake/ducky/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)

//////////////////////
//      TOOLS       //
//////////////////////

/obj/item/bloodsucker
	icon = 'icons/obj/vamp_obj.dmi'
	lefthand_file = 'icons/mob/inhands/antag/bs_leftinhand.dmi'
	righthand_file = 'icons/mob/inhands/antag/bs_rightinhand.dmi'

/obj/item/bloodsucker/chisel
	name = "chisel"
	desc = "Despite not being the most precise or faster tool, it feels the best to work with nonetheless."
	icon_state = "chisel"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("chiseled", "stabbed", "poked")
	sharpness = SHARP_POINTY
	force = 6
	throwforce = 4

/* #define PAINTING_TYPE_MESMERIZE "Mesmerizing Painting"
#define PAINTING_TYPE_CHARM "Charming Painting"
#define PAINTING_TYPE_CREEPY "Creepy Painting"

/obj/item/bloodsucker/bloodybrush
	name = "paintbrush"
	desc = "Draws from a source that should never run dry, an artist's dream."
	icon_state = "brush"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/bloodsucker/bloodybrush/proc/paint(mob/living/painter, obj/item/canvas/raw_piece)
	var/list/possible_effects = list()
	var/painting_type = tgui_input_list(painter, "You paint a...", "Conscience Flux", possible_effects)
	var/base_x = painter.pixel_x
	var/base_y = painter.pixel_y
	animate(painter, pixel_x = base_x, pixel_y = base_y, time = 0.1 SECONDS, loop = -1)
	balloon_alert(painter, "a little bit here...")
	var/message = TRUE
	for(var/i in 1 to 25)
		var/x_offset = base_x + rand(-3, 3)
		var/y_offset = base_y + rand(-3, 3)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 0.1 SECONDS)
		if(message)
			balloon_alert(painter, "..fill that up there...")
			message = FALSE
	if(!do_after(painter, 10 SECONDS, raw_piece))
		animate(painter, pixel_x = base_x, pixel_y = base_y, time = 0.1 SECONDS)
		balloon_alert(painter, "..ah... dammit.")
		return FALSE
	animate(painter, pixel_x = base_x, pixel_y = base_y, time = 0.1 SECONDS)
	balloon_alert(painter, "..and it's done.")
	qdel(raw_piece)
	var/obj/structure/sign/painting/sign_to_crop = new /obj/structure/sign/painting(get_turf(painter))
	var/obj/item/wirecutters/cutters = new /obj/item/wirecutters(get_turf(painter))
	sign_to_crop.load_persistent()
	sign_to_crop.C.special_effect = painting_type
	sign_to_crop.wirecutter_act(painter, cutters)
	qdel(sign_to_crop)
	qdel(cutters)

/obj/item/canvas/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/bloodsucker/bloodybrush))
		return ..()
	if(!IS_BLOODSUCKER(user))
		return
	var/obj/item/bloodsucker/bloodybrush/brush = I
	var/turf/current_turf = get_turf(src)
	if(!LAZYFIND(current_turf.contents, /obj/structure/easel))
		to_chat(user, span_warning("You need a easel to support your canvas while you paint!"))
		return
	brush.paint(user, src)

#undef PAINTING_TYPE_MESMERIZE
#undef PAINTING_TYPE_CHARM
#undef PAINTING_TYPE_CREEPY */

//////////////////////
//       MISC       //
//////////////////////

/obj/item/bloodsucker/abyssal_essence
	name = "abyssal essence"
	desc = "As you glare at the abyssal essence, you feel it glaring back."
	icon_state = "abyssal_essence"
	item_state = "abyssal_essence"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 10

//////////////////////
//     ARCHIVES     //
//////////////////////

/*
 *	# Archives of the Kindred:
 *
 *	A book that can only be used by Curators.
 *	When used on a player, after a short timer, will reveal if the player is a Bloodsucker, including their real name and Clan.
 *	This book should not work on Bloodsuckers using the Masquerade ability.
 *	If it reveals a Bloodsucker, the Curator will then be able to tell they are a Bloodsucker on examine (Like a Vassal).
 *	Reading it normally will allow Curators to read what each Clan does, with some extra flavor text ones.
 *
 *	Regular Bloodsuckers won't have any negative effects from the book, while everyone else will get burns/eye damage.
 *	It is also Tremere's Clan objective to ensure a Tremere Bloodsucker has stolen this by the end of the round.
 */

/obj/item/book/codex_gigas/Initialize(mapload)
	. = ..()
	var/turf/current_turf = get_turf(src)
	new /obj/item/book/kindred(current_turf)

/obj/item/book/kindred
	name = "\improper Archive of the Kindred"
	title = "the Archive of the Kindred"
	desc = "Cryptic documents explaining hidden truths behind Undead beings. It is said only Curators can decipher what they really mean."
	icon = 'icons/obj/vamp_obj.dmi'
	lefthand_file = 'icons/mob/inhands/antag/bs_leftinhand.dmi'
	righthand_file = 'icons/mob/inhands/antag/bs_rightinhand.dmi'
	icon_state = "kindred_book"
	author = "dozens of generations of Curators"
	unique = TRUE
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/in_use = FALSE

/obj/item/book/kindred/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, TRUE)

// Overwriting attackby to prevent cutting the book out
/obj/item/book/kindred/attackby(obj/item/item, mob/user, params)
	// Copied from '/obj/item/book/attackby(obj/item/item, mob/user, params)'
	if((istype(item, /obj/item/kitchen/knife) || item.tool_behaviour == TOOL_WIRECUTTER) && !(flags_1 & HOLOGRAM_1))
		to_chat(user, span_notice("You feel the gentle whispers of a Librarian telling you not to cut [title]."))
		return
	return ..()

/*
 *	# Attacking someone with the Book
 */
// target is the person being hit here
/obj/item/book/kindred/afterattack(mob/living/target, mob/living/user, flag, params)
	. = ..()
	if(!user.can_read(src) || in_use || (target == user) || !ismob(target))
		return
	// Curator/Tremere using it
	if(!HAS_TRAIT(user.mind, TRAIT_BLOODSUCKER_HUNTER))
		if(IS_BLOODSUCKER(user))
			to_chat(user, span_notice("[src] seems to be too complicated for you. It would be best to leave this for someone else to take."))
			return
		to_chat(user, span_warning("[src] burns your hands as you try to use it!"))
		user.apply_damage(3, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		return
	
	in_use = TRUE
	user.balloon_alert_to_viewers(user, "reading book...", "looks at [target] and [src]")
	if(!do_after(user, 3 SECONDS, target))
		to_chat(user, span_notice("You quickly close [src]."))
		in_use = FALSE
		return
	if(HAS_TRAIT(user.mind, TRAIT_BLOODSUCKER_HUNTER))
		user.visible_message(span_notice("[user] opens [src] and begins reading intently."))
		ui_interact(user)
		return
	in_use = FALSE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(target)
	// Are we a Bloodsucker | Are we on Masquerade. If one is true, they will fail.
	if(IS_BLOODSUCKER(target) && !HAS_TRAIT(target, TRAIT_MASQUERADE))
		if(bloodsuckerdatum.broke_masquerade)
			to_chat(user, span_warning("[target], also known as '[bloodsuckerdatum.return_full_name()]', is indeed a Bloodsucker, but you already knew this."))
			return
		to_chat(user, span_warning("[target], also known as '[bloodsuckerdatum.return_full_name()]', [bloodsuckerdatum.my_clan ? "is part of the [bloodsuckerdatum.my_clan]!" : "is not part of a clan."] You quickly note this information down, memorizing it."))
		bloodsuckerdatum.break_masquerade()
	else
		to_chat(user, span_notice("You fail to draw any conclusions to [target] being a Bloodsucker."))

/obj/item/book/kindred/attack_self(mob/living/user)
	ui_interact(user)

/obj/item/book/kindred/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KindredBook", name)
		ui.open()

/obj/item/book/kindred/ui_static_data(mob/user)
	var/data = list()
	for(var/datum/bloodsucker_clan/clans as anything in subtypesof(/datum/bloodsucker_clan))
		var/clan_data = list()
		clan_data["clan_name"] = initial(clans.name)
		clan_data["clan_desc"] = initial(clans.description)
		data["clans"] += list(clan_data)

	return data
