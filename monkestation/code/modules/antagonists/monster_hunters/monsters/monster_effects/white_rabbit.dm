/obj/effect/bnnuy
	name = "white rabbit"
	desc = span_big(span_hypnophrase("FEED YOUR HEAD."))
	icon = 'monkestation/icons/effects/512x512.dmi'
	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND | INTERACT_ATOM_NO_FINGERPRINT_INTERACT
	resistance_flags = parent_type::resistance_flags | SHUTTLE_CRUSH_PROOF
	invisibility = INVISIBILITY_OBSERVER
	appearance_flags = PIXEL_SCALE | KEEP_TOGETHER
	pixel_x = -240
	pixel_y = -240
	/// The icon state applied to the image created for this rabbit.
	var/real_icon_state = "bnnuy"
	/// The antag datum of the monster hunter that can see us.
	var/datum/antagonist/monsterhunter/hunter_antag
	/// The mind of the monster hunter that can see us.
	var/datum/mind/hunter_mind
	/// The image shown to the hunter.
	var/image/hunter_image
	/// Has the rabbit already whispered?
	var/being_used = FALSE
	/// Is this rabbit selected to drop the gun?
	var/drop_gun = FALSE

/obj/effect/bnnuy/Initialize(mapload, datum/antagonist/monsterhunter/hunter)
	. = ..()
	if(!istype(hunter) || QDELING(hunter) || QDELETED(hunter.owner) || !isopenturf(loc) || QDELING(loc))
		return INITIALIZE_HINT_QDEL
	hunter_image = create_bnnuy_image()
	hunter_antag = hunter
	hunter_mind = hunter.owner
	update_mouse_opacity(hunter_mind.current)
	hunter_mind.current?.client?.images |= hunter_image
	AddComponent(/datum/component/redirect_attack_hand_from_turf, interact_check = CALLBACK(src, PROC_REF(verify_user_can_see)))

/obj/effect/bnnuy/Destroy(force)
	hunter_antag?.rabbits -= src
	hunter_antag = null
	hunter_mind?.current?.client?.images -= hunter_image
	hunter_mind = null
	hunter_image = null
	return ..()

/obj/effect/bnnuy/examine(mob/user)
	. = ..()
	if(hunter_antag)
		. += span_info("You have found [hunter_antag.rabbits_spotted] out of 5 rabbits.")

/obj/effect/bnnuy/attack_hand(mob/living/user, list/modifiers)
	if(user?.mind != hunter_mind)
		return SECONDARY_ATTACK_CALL_NORMAL
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(being_used)
		return
	being_used = TRUE
	spotted(user)
	SEND_SIGNAL(hunter_antag, COMSIG_GAIN_INSIGHT)
	icon = 'monkestation/icons/mob/rabbit.dmi'
	real_icon_state = "rabbit_hole"
	pixel_x = 0
	pixel_y = 0
	update_bnnuy_image()
	QDEL_IN(src, 8 SECONDS)

/obj/effect/bnnuy/proc/create_bnnuy_image() as /image
	RETURN_TYPE(/image)
	var/image/new_image = image(icon, src, real_icon_state, BELOW_MOB_LAYER)
	SET_PLANE_EXPLICIT(new_image, ABOVE_LIGHTING_PLANE, src)
	return new_image

/obj/effect/bnnuy/proc/update_bnnuy_image()
	hunter_mind?.current?.client?.images -= hunter_image
	hunter_image = create_bnnuy_image()
	hunter_mind?.current?.client?.images |= hunter_image

/obj/effect/bnnuy/proc/verify_user_can_see(mob/user)
	return (user?.mind == hunter_mind)

/obj/effect/bnnuy/proc/spotted(mob/living/user)
	if(hunter_antag?.rabbits_spotted == 0) //our first bunny
		user.put_in_hands(new /obj/item/clothing/mask/cursed_rabbit(drop_location()))
	user.put_in_hands(new /obj/item/rabbit_eye(drop_location()))
	if(drop_gun)
		give_gun(user)
	hunter_antag?.rabbits -= src

/obj/effect/bnnuy/proc/give_gun(mob/living/user)
	user.put_in_hands(new /obj/item/gun/ballistic/revolver/hunter_revolver(drop_location()))
	var/datum/action/cooldown/spell/conjure_item/blood_silver/silverblood = new(user)
	silverblood.StartCooldown()
	silverblood.Grant(user)

/// Janky workaround to avoid the 512x512 sprite always occuping the user's right click menu
/obj/effect/bnnuy/proc/update_mouse_opacity(mob/living/user)
	if(in_view_range(user, src, TRUE) && can_see(user, src))
		mouse_opacity = MOUSE_OPACITY_ICON
	else
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
