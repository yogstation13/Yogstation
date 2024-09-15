#define PROJECTILE_HIT_EFFECT_CHANCE 80
#define NORMAL_BLOCK_CHANCE 30
#define REACTION_MODE_ABSORB 0
#define REACTION_MODE_REFLECT 1

//a "shield" that can absorb projectiles and then shoot them back at attackers
/obj/item/gun/magic/mirror_shield
	name = "mirror shield"
	desc = "A strange mirror adorned with various gemstones. If you look close enough it almost seems as if the surface is... rippling?"
	icon = 'monkestation/icons/obj/weapons/shields.dmi'
	icon_state = "wizard_mirror_shield"
	inhand_icon_state = "wizard_mirror_shield"
	lefthand_file = 'monkestation/icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/equipment/shields_righthand.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/back.dmi'
	worn_icon_state = "wizard_mirror_shield"
	force = 16
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bumps", "prods")
	attack_verb_simple = list("bump", "prod")
	hitsound = 'sound/weapons/smash.ogg'
	fire_sound = 'sound/magic/cosmic_expansion.ogg'
	ammo_type = /obj/item/ammo_casing/mirror_shield_dummy
	can_charge = TRUE
	///Up to how many projectiles can we "have stored"
	var/max_stored_projectiles = 10
	///Do we absorb or reflect projectiles when hit
	var/reaction_mode = REACTION_MODE_ABSORB
	///The list of projectiles we have stored ready to fire
	var/list/stored_projectiles = list()
	///Cannot absorb projectile types in here
	var/static/list/blacklisted_projectile_types = list()

/obj/item/gun/magic/mirror_shield/Initialize(mapload)
	. = ..()
	STOP_PROCESSING(SSobj, src) //we want can_charge set to TRUE but dont actually use the processing it gives so just disable it

/obj/item/gun/magic/mirror_shield/Destroy()
	for(var/projectile in stored_projectiles)
		qdel(projectile) //could also have them shoot off in random directions
		stored_projectiles -= projectile
	return ..()

/obj/item/gun/magic/mirror_shield/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(ismob(old_loc))
		UnregisterSignal(old_loc, COMSIG_PROJECTILE_PREHIT)

	if(ismob(loc))
		RegisterSignal(loc, COMSIG_PROJECTILE_PREHIT, PROC_REF(handle_hit))

/obj/item/gun/magic/mirror_shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(attack_type != PROJECTILE_ATTACK && prob(NORMAL_BLOCK_CHANCE))
		return TRUE

/obj/item/gun/magic/mirror_shield/attack_self(mob/user, modifiers)
	. = ..()
	reaction_mode = !reaction_mode
	balloon_alert(user, "you hold \the [src] in such a way as to [reaction_mode == REACTION_MODE_ABSORB ? "absorb" : "reflect"] projectiles.")

/obj/item/gun/magic/mirror_shield/examine(mob/user)
	. = ..()
	if(HAS_MIND_TRAIT(user, TRAIT_MAGICALLY_GIFTED))
		. += "<br>It currently contains: [english_list(stored_projectiles, comma_text = ", <br>")]."

/obj/item/gun/magic/mirror_shield/recharge_newshot()
	if(!chambered.loaded_projectile && length(stored_projectiles))
		var/obj/projectile/loaded = stored_projectiles[1]
		loaded.forceMove(chambered)
		chambered.loaded_projectile = loaded
		stored_projectiles -= loaded

/obj/item/gun/magic/mirror_shield/can_shoot()
	return chambered.loaded_projectile

/obj/item/gun/magic/mirror_shield/handle_chamber(mob/living/user, empty_chamber, from_firing, chamber_next_round)
	recharge_newshot()

/obj/item/gun/magic/mirror_shield/proc/absorb_projectile(obj/projectile/absorbed)
	STOP_PROCESSING(SSprojectiles, absorbed)
	absorbed.fired = FALSE
	QDEL_NULL(absorbed.trajectory)
	if(!chambered.loaded_projectile)
		absorbed.forceMove(chambered)
		chambered.loaded_projectile = absorbed
	else
		absorbed.forceMove(src)
		stored_projectiles += absorbed
	absorbed.update_appearance()
	visible_message(span_notice("\The [src] absorbs [absorbed]!"))

/obj/item/gun/magic/mirror_shield/proc/handle_hit(mob/held_by, list/projectile_args, obj/projectile/hit_by)
	SIGNAL_HANDLER
	if(!prob((src in held_by.held_items) ? PROJECTILE_HIT_EFFECT_CHANCE : NORMAL_BLOCK_CHANCE)) //turns out its harder to block with something when your not holding it
		return

	hit_by.impacted = list()
	var/turf/firer_turf = get_turf(hit_by.firer)
	if(hit_by.firer && get_dist(firer_turf, get_turf(src)) <= 1) //this is due to some jank I cant figure out, if you want to go ahead
		hit_by.process_hit(firer_turf, hit_by.firer)
	else if(reaction_mode == REACTION_MODE_ABSORB && length(stored_projectiles) <= max_stored_projectiles && !(hit_by.type in blacklisted_projectile_types))
		absorb_projectile(hit_by)
	else
		hit_by.set_angle_centered(get_angle(held_by, hit_by.firer))
		hit_by.firer = held_by
		hit_by.speed *= 0.8
		hit_by.damage *= 1.15

	playsound(src, 'sound/magic/cosmic_expansion.ogg', vol = 120, channel = CHANNEL_SOUND_EFFECTS)
	return PROJECTILE_INTERRUPT_HIT | PROJECTILE_INTERRUPT_BLOCK_QDEL

//a dummy casing type to get filled with absorbed projectiles
/obj/item/ammo_casing/mirror_shield_dummy
	loaded_projectile = null
	firing_effect_type = null

/obj/item/ammo_casing/mirror_shield_dummy/newshot()
	return

#undef PROJECTILE_HIT_EFFECT_CHANCE
#undef NORMAL_BLOCK_CHANCE
#undef REACTION_MODE_ABSORB
#undef REACTION_MODE_REFLECT
