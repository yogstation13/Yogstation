////////////////////////////////////////////////////////////////////////////////////
//------------------------------Darkspawn organs----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
 * special eyes that innately have night vision without having a toggle that adds action clutter
 */
/obj/item/organ/eyes/darkspawn
	name = "darkspawn eyes"
	desc = "It turned out they had them after all!"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	healing_factor = 2 * STANDARD_ORGAN_HEALING
	lighting_cutoff = LIGHTING_CUTOFF_HIGH
	color_cutoffs = list(12, 0, 50)
	sight_flags = SEE_MOBS

/**
 * special ears that are a bit tankier and have innate sound protection
 */
/obj/item/organ/ears/darkspawn
	name = "darkspawn ears"
	desc = "It turned out they had them after all!"
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	healing_factor = 2 * STANDARD_ORGAN_HEALING
	bang_protect = 1

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Nightmare organs----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/**
 * Once an nightmare, always a nightmare
 */
/obj/item/organ/brain/nightmare
	name = "tumorous mass"
	desc = "A fleshy growth that was dug out of the skull of a Nightmare."
	icon_state = "tumor"
	color = "#1C1C1C"
	decay_factor = 0
	var/respawn_progress = 0
	var/datum/action/cooldown/spell/jaunt/shadow_walk/jaunt

/obj/item/organ/brain/nightmare/Insert(mob/living/carbon/host, special = FALSE)
	. = ..()
	if(!isshadowperson(host))
		host.set_species(/datum/species/shadow/nightmare)
		visible_message(span_warning("[host] thrashes as [src] takes root in [host.p_their()] body!"))
	
	if(!jaunt)
		jaunt = new(host.mind ? host.mind : host)
	jaunt.Grant(host)

/obj/item/organ/heart/nightmare/Remove(mob/living/carbon/M, special = 0)
	if(jaunt)
		jaunt.Remove(M)
		QDEL_NULL(jaunt)
	return ..()

/**
 * Provides the nightmare with a revive when they die
 */
/// How long for the heart to revive.
#define HEART_RESPAWN_THRESHHOLD 40

/obj/item/organ/heart/nightmare
	name = "heart of darkness"
	desc = "An alien organ that twists and writhes when exposed to light."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart-on"
	color = "#1C1C1C"
	decay_factor = 0
	visual = TRUE

/obj/item/organ/heart/nightmare/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	return ..()

/obj/item/organ/heart/nightmare/attack(mob/M, mob/living/carbon/user, obj/target)
	if(M != user)
		return ..()
	user.visible_message(span_warning("[user] raises [src] to [user.p_their()] mouth and tears into it with [user.p_their()] teeth!"), span_danger("[src] feels unnaturally cold in your hands. You raise [src] your mouth and devour it!"))
	playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)

	user.temporarilyRemoveItemFromInventory(src, TRUE)
	Insert(user)

/obj/item/organ/heart/nightmare/Insert(mob/living/carbon/M, special = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/heart/nightmare/Remove(mob/living/carbon/M, special = 0)
	STOP_PROCESSING(SSobj, src)
	respawn_progress = 0
	return ..()

/obj/item/organ/heart/nightmare/Stop()
	return 0

/obj/item/organ/heart/nightmare/process(delta_time)
	if(QDELETED(owner) || owner.stat != DEAD || !owner)
		respawn_progress += delta_time
		return
	var/turf/T = get_turf(owner)

	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			respawn_progress++
			playsound(owner, 'sound/effects/singlebeat.ogg', 40, 1)
			
	if(respawn_progress >= HEART_RESPAWN_THRESHHOLD)
		owner.revive(full_heal = TRUE)
		owner.visible_message(span_warning("[owner] staggers to [owner.p_their()] feet!"))
		playsound(owner, 'sound/hallucinations/far_noise.ogg', 50, 1)
		respawn_progress = 0
		if(!(isshadowperson(owner)))
			owner.set_species(/datum/species/shadow)
			to_chat(owner, span_userdanger("You feel the shadows invade your skin, leaping into the center of your chest! You're alive!"))
			SEND_SOUND(owner, sound('sound/effects/ghost.ogg'))

#undef HEART_RESPAWN_THRESHHOLD
