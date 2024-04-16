/*
	In this file:
		various vampire interactions and items
*/


/obj/item/clothing/suit/draculacoat
	name = "Vampire Coat"
	desc = "What is a man? A miserable little pile of secrets."
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'icons/obj/clothing/suits/suits.dmi'
	icon_state = "draculacoat"
	item_state = "draculacoat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	slowdown = -0.2 //very minor speedboost
	allowed = null
	var/blood_regen_delay = 10 SECONDS
	COOLDOWN_DECLARE(regen_cooldown)
	var/dodge_delay = 10 SECONDS
	COOLDOWN_DECLARE(dodge_cooldown)

/obj/item/clothing/suit/draculacoat/Initialize(mapload)
	if(!allowed)
		allowed = GLOB.security_vest_allowed
	START_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/draculacoat/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/draculacoat/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING)
		RegisterSignal(user, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_projectile_hit))

/obj/item/clothing/suit/draculacoat/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_ATOM_BULLET_ACT)

/obj/item/clothing/suit/draculacoat/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!isprojectile(hitby) && dodge(owner, hitby, attack_text))
		return TRUE
	return ..()
	
/obj/item/clothing/suit/draculacoat/proc/on_projectile_hit(mob/living/carbon/human/user, obj/projectile/P, def_zone)
	SIGNAL_HANDLER
	if(dodge(user, P, "[P]"))
		return BULLET_ACT_FORCE_PIERCE
		
/obj/item/clothing/suit/draculacoat/proc/dodge(mob/living/carbon/human/user, atom/movable/hitby, attack_text)
	if(user.incapacitated() || !COOLDOWN_FINISHED(src, dodge_cooldown) || !is_vampire(user))
		return FALSE
	COOLDOWN_START(src, dodge_cooldown, dodge_delay)

	user.balloon_alert_to_viewers("dodged!", "dodged!", COMBAT_MESSAGE_RANGE)
	user.visible_message(span_danger("With inhuman speed [user] dodges [attack_text]!"), span_userdanger("You dodge [attack_text]"), null, COMBAT_MESSAGE_RANGE)
	playsound(user, 'sound/effects/space_wind_big.ogg', 50, 1)
	return TRUE

/obj/item/clothing/suit/draculacoat/process()
	var/mob/living/carbon/human/user = src.loc
	if(user && ishuman(user) && is_vampire(user) && (user.wear_suit == src))
		if(COOLDOWN_FINISHED(src, regen_cooldown))
			COOLDOWN_START(src, regen_cooldown, blood_regen_delay)
			var/datum/antagonist/vampire/vampire = is_vampire(user)
			if (vampire.total_blood >= 5 && vampire.usable_blood < vampire.total_blood)
				vampire.usable_blood = min(vampire.usable_blood + 5, vampire.total_blood) // 5 units every 10 seconds

/obj/item/storage/book/bible/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)
	. = ..()
	if(!(user.mind && user.mind.holy_role) && is_vampire(user))
		to_chat(user, span_danger("[deity_name] channels through \the [src] and sets you ablaze for your blasphemy!"))
		user.adjust_fire_stacks(5)
		user.ignite_mob()
		user.emote("scream", 1)
