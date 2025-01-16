///hidden dagger
#define DAGGER_COMBO "HH"
///fingergun
#define FINGERGUN_COMBO "HG"

/datum/martial_art/liquidator
	name = "Liquidator"
	id =  MARTIALART_LIQUIDATOR
	help_verb = /mob/living/carbon/human/proc/preternis_martial_help
	/// List of chemicals and how much is injected, will inject in descending order based on if a target has at least half the designated amount
	var/list/injection_chems = list(
		/datum/reagent/toxin/sodium_thiopental = 10,
		/datum/reagent/toxin/cyanide = 5
	)
	/// Chem injected if no other chem is valid
	var/datum/reagent/default_chem = /datum/reagent/toxin/cyanide

/datum/martial_art/liquidator/can_use(mob/living/carbon/human/H)
	if(!H.combat_mode)
		return FALSE
	if(!ispreternis(H))
		return FALSE
	return TRUE

/datum/martial_art/liquidator/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak, FINGERGUN_COMBO)) //prioritize the gun combo because the dagger combo can combo into itself
		fingergun(A,D)
		streak = ""
		return TRUE //don't upgrade the grab

	if(findtext(streak, DAGGER_COMBO))
		hidden_knife(A,D)
		return TRUE

/datum/martial_art/liquidator/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(A == D)
		return FALSE

	add_to_streak("G",D)
	if(check_streak(A,D)) //if a combo is made no grab upgrade is done (QoL rather than stealth)
		return TRUE
	return FALSE

/datum/martial_art/liquidator/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE

	add_to_streak("H",D)
	if(check_streak(A,D)) //stab doesn't seem like anything
		return TRUE
	return FALSE  ///We need it work like a generic, non martial art attack

/datum/martial_art/liquidator/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(can_use(A)))
		return FALSE

	var/datum/reagent/picked_chem = default_chem
	var/amount = injection_chems[picked_chem]

	for(var/i in injection_chems)
		var/has_reagent = D.reagents.get_reagent_amount(i)
		if(has_reagent <= (injection_chems[i]/2))
			picked_chem = i
			amount = injection_chems[i]
			break

	D.reagents.add_reagent(picked_chem, amount)
	to_chat(A, span_warning("You inject [initial(picked_chem.name)] into [D]!"))
	to_chat(D, span_notice("You feel a tiny prick."))

	return FALSE //always looks like a generic push

//////////////////////////////////////////////////////////////////////////////////
//------------------------------Hidden knife------------------------------------//
//////////////////////////////////////////////////////////////////////////////////
/datum/martial_art/liquidator/proc/hidden_knife(mob/living/carbon/human/user, mob/living/carbon/human/target)
	/**
	 * Literally just copy pasted all this from /proc/disarm in _species.dm
	 * we are pretending to be a shove
	 */
	user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
	playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

	var/shove_dir = get_dir(user.loc, target.loc)
	var/turf/target_shove_turf = get_step(target.loc, shove_dir)
	var/mob/living/carbon/human/target_collateral_human
	var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied

	//Thank you based whoneedsspace
	target_collateral_human = locate(/mob/living/carbon/human) in target_shove_turf.contents
	var/bothstanding = target_collateral_human && (target.mobility_flags & MOBILITY_STAND) && (target_collateral_human.mobility_flags & MOBILITY_STAND)
	if(target_collateral_human && bothstanding)
		shove_blocked = TRUE
	else
		target.Move(target_shove_turf, shove_dir)
		if(get_turf(target) != target_shove_turf)
			shove_blocked = TRUE

	if(shove_blocked && !target.is_shove_knockdown_blocked() && !target.buckled)
		var/directional_blocked = FALSE
		if(shove_dir in GLOB.cardinals) //Directional checks to make sure that we're not shoving through a windoor or something like that
			var/target_turf = get_turf(target)
			for(var/obj/O in target_turf)
				if(O.flags_1 & ON_BORDER_1 && O.dir == shove_dir && O.density)
					directional_blocked = TRUE
					break
			if(target_turf != target_shove_turf) //Make sure that we don't run the exact same check twice on the same tile
				for(var/obj/O in target_shove_turf)
					if(O.flags_1 & ON_BORDER_1 && O.dir == turn(shove_dir, 180) && O.density)
						directional_blocked = TRUE
						break
		if(!bothstanding || directional_blocked)
			var/obj/item/I = target.get_active_held_item()
			if(target.dropItemToGround(I))
				user.visible_message(span_danger("[user.name] shoves [target.name], disarming them!"), span_danger("You shove [target.name], disarming them!"), null, COMBAT_MESSAGE_RANGE)
				log_combat(user, target, "liquidator hidden knife shove", "disarming them")
		else if(bothstanding)
			target.Knockdown(SHOVE_KNOCKDOWN_HUMAN)
			if(!target_collateral_human.is_shove_knockdown_blocked())
				target_collateral_human.Knockdown(SHOVE_KNOCKDOWN_HUMAN)
			user.visible_message(span_danger("[user.name] shoves [target.name] into [target_collateral_human.name]!"), span_danger("You shove [target.name] into [target_collateral_human.name]!"), null, COMBAT_MESSAGE_RANGE)
			log_combat(user, target, "liquidator hidden knife shove", "into [target_collateral_human.name]")
	else
		user.visible_message(span_danger("[user.name] shoves [target.name]!"), null, null, COMBAT_MESSAGE_RANGE)
		var/target_held_item = target.get_active_held_item()
		var/knocked_item = FALSE

		if(!is_type_in_typecache(target_held_item, GLOB.shove_disarming_types))
			target_held_item = null

		if(!target.has_movespeed_modifier(MOVESPEED_ID_SHOVE))
			target.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH)
			if(target_held_item)
				target.visible_message(span_danger("[target.name]'s grip on \the [target_held_item] loosens!"), span_danger("Your grip on \the [target_held_item] loosens!"), null, COMBAT_MESSAGE_RANGE)
			addtimer(CALLBACK(target, /mob/living/carbon/human/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH)
		else if(target_held_item)
			target.dropItemToGround(target_held_item)
			knocked_item = TRUE
			target.visible_message(span_danger("[target.name] drops \the [target_held_item]!!"), span_danger("You drop \the [target_held_item]!!"), null, COMBAT_MESSAGE_RANGE)
		var/append_message = ""
		if(target_held_item)
			if(knocked_item)
				append_message = "causing them to drop [target_held_item]"
			else
				append_message = "loosening their grip on [target_held_item]"
		log_combat(user, target, "liquidator hidden knife shove", append_message)



	/**
	 * The actual martial art stuff
	 */

	var/selected_zone = target.get_bodypart(user.zone_selected) ? user.zone_selected : BODY_ZONE_CHEST //check if the zone exists, if not, default to chest

	var/armor_block = target.run_armor_check(selected_zone, MELEE, armour_penetration = 40)
	target.apply_damage(user.get_punchdamagehigh() * 4, BRUTE, selected_zone, armor_block, -100, 100, SHARP_POINTY) 	//28 damage by default  TWENTY EIGHT STAB WOUNDS (not gonna wound, unless the target has no armour)
	if(shove_blocked) //if they're getting pushed into a wall or another person, they're probably down for the count, GET THEM
		user.changeNext_move(CLICK_CD_RANGE) //stab stab stab stab stab stab stab stab

	// Stab sounds only play to you and the target
	user.playsound_local(target, 'sound/weapons/sword2.ogg', 30, FALSE)
	target.playsound_local(target, 'sound/weapons/sword2.ogg', 30, FALSE)

	to_chat(user, span_warning("You stab [target] with a hidden blade!"))
	to_chat(target, span_userdanger("You are suddenly stabbed with a blade!"))

/*---------------------------------------------------------------

	start of fingergun section

---------------------------------------------------------------*/
/datum/martial_art/liquidator/proc/fingergun(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/obj/item/gun/ballistic/automatic/pistol/martial/gun = new /obj/item/gun/ballistic/automatic/pistol/martial (A)   ///I don't check does the user have an item in a hand, because it is a martial art action, and to use it... you need to have a empty hand
	gun.gun_owner = A
	A.put_in_hands(gun)
	to_chat(A, span_notice("You extract a hidden gun from your hand."))	
	D.Stun(1 SECONDS)
	A.changeNext_move(CLICK_CD_RANGE) //it's just pulling out a gun, not actually grabbing them, so have a shorter cooldown

/obj/item/gun/ballistic/automatic/pistol/martial
	desc = "A concelated version of a stechkin APS pistol, that comes with special Preternis upgrade modules."
	can_suppress = TRUE
	fire_sound_volume = 30
	lefthand_file = null  ///We don't want it to be visible inhands
	righthand_file = null
	mag_type = /obj/item/ammo_box/magazine/m10mm/martial
	var/mob/gun_owner

/obj/item/ammo_box/magazine/m10mm/martial
	max_ammo = 1

/obj/item/gun/ballistic/automatic/pistol/martial/pre_attack(atom/target, mob/living/user, params) //prevents using this as a melee weapon, and allows its use in point blank while in combat mode
	afterattack(target, user, FALSE, params) //call afterattack so the gun still shoots
	return TRUE //prevent the regular attack

/obj/item/gun/ballistic/automatic/pistol/martial/eject_magazine(mob/user, display_message = TRUE, obj/item/ammo_box/magazine/tac_load = null)
	return FALSE

/obj/item/gun/ballistic/automatic/pistol/martial/insert_magazine(mob/user, obj/item/ammo_box/magazine/AM, display_message = TRUE)
	return FALSE

/obj/item/gun/ballistic/automatic/pistol/martial/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)
	ADD_TRAIT(src, TRAIT_NODROP, "martial")
	RegisterSignal(src, COMSIG_ITEM_PREDROPPED, PROC_REF(on_drop))

/obj/item/gun/ballistic/automatic/pistol/martial/Destroy()
	UnregisterSignal(src, COMSIG_ITEM_PREDROPPED)
	return ..()

/obj/item/gun/ballistic/automatic/pistol/martial/attack_self(mob/living/user)
	on_drop()

/obj/item/gun/ballistic/automatic/pistol/martial/process_chamber(empty_chamber, from_firing, chamber_next_round)
	. = ..()
	if(!magazine.ammo_count(FALSE))//if it's out of ammo delete it
		to_chat(gun_owner, span_warning("You hide [src]."))	
		qdel(src)	

/obj/item/gun/ballistic/automatic/pistol/martial/proc/on_drop()
	if(QDELETED(src))
		return
	to_chat(gun_owner, span_notice("You decide that it isn't the best time to use [src]"))
	qdel(src)

/*---------------------------------------------------------------

	end of fingergun section

---------------------------------------------------------------*/
/mob/living/carbon/human/proc/preternis_martial_help()
	set name = "Refresh Data"
	set desc = "You try to remember some basic actions from your covert combat module."
	set category = "Remnant Liquidator"
	var/list/combined_msg = list()

	var/datum/martial_art/liquidator/helper = new()

	combined_msg += "<b><i>You try to remember some basic actions from your covert combat module.</i></b>"

	combined_msg += "[span_notice("Hidden Blade")]: Harm Harm. You shove the target while stabbing them with a concealed blade, dealing considerable brute damage. Can infinitely combo with itself."
	combined_msg += "[span_notice("Finger gun")]: Harm Grab. Briefly stun your target and place a stealthy version of a stechkin in your hand."

	combined_msg += "[span_notice("Injection")]: Your disarm intent will inject chemicals in a determined order."
	combined_msg += span_notice("<i>A chemical will only be injected if the target has under half the amount of injected units in them.</i>")
	for(var/datum/reagent/chemical as anything in helper.injection_chems)
		combined_msg += "[initial(chemical.name)]: [helper.injection_chems[chemical]]u."
	combined_msg += span_notice("If none of the above chemicals are injected, you will default to [helper.injection_chems[helper.default_chem]]u of [initial(helper.default_chem.name)].")

	to_chat(usr, examine_block(combined_msg.Join("\n")))
	qdel(helper)

#undef DAGGER_COMBO 
#undef FINGERGUN_COMBO 
