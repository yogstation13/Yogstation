/// How much health super kitties have by default.
#define SUPER_KITTY_HEALTH 50
/// How much health syndicate super kitties have by default.
#define SYNDIE_SUPER_KITTY_HEALTH 80

/obj/item/organ/internal/ears/cat/super
	name = "Super Kitty Ears"
	desc = "A pair of kitty ears that harvest the true energy of cats. Mrow!"
	icon_state = "superkitty"
	decay_factor = 0 // Space ruin item
	damage_multiplier = 0.5 // SUPER
	organ_flags = ORGAN_HIDDEN
	organ_traits = list(TRAIT_CAT)
	/// The instance of kitty form spell given to the user.
	/// The spell will be initialized using the initial typepath.
	var/datum/action/cooldown/spell/shapeshift/kitty/kitty_spell = /datum/action/cooldown/spell/shapeshift/kitty

/obj/item/organ/internal/ears/cat/super/Initialize(mapload)
	if(ispath(kitty_spell))
		kitty_spell = new kitty_spell(src)
	else
		stack_trace("kitty_spell is invalid typepath ([kitty_spell || "null"])")
	return ..()

/obj/item/organ/internal/ears/cat/super/Destroy()
	QDEL_NULL(kitty_spell)
	return ..()

/obj/item/organ/internal/ears/cat/super/attack(mob/target_mob, mob/living/carbon/user, obj/target)
	if(target_mob != user || !implant_on_use(user))
		return ..()

/obj/item/organ/internal/ears/cat/super/attack_self(mob/user, modifiers)
	implant_on_use(user)
	return ..()

/obj/item/organ/internal/ears/cat/super/on_insert(mob/living/carbon/ear_owner)
	. = ..()
	kitty_spell.Grant(ear_owner)

/obj/item/organ/internal/ears/cat/super/on_remove(mob/living/carbon/ear_owner, special = FALSE)
	. = ..()
	kitty_spell.Remove(ear_owner)

// Stole this from demon heart hard, but hey it works
/obj/item/organ/internal/ears/cat/super/proc/implant_on_use(mob/living/carbon/user)
	if(!iscarbon(user) || !user.is_holding(src))
		return FALSE
	user.visible_message(
		span_warning("[user] raises \the [src] to [user.p_their()] head and gently places it on [user.p_their()] head!"),
		span_danger("A strange feline comes over you. You place \the [src] on your head!"),
	)
	playsound(user, 'sound/effects/meow1.ogg', 50, TRUE)

	user.visible_message(
		span_warning("\The [src] melt into [user]'s head!"),
		span_userdanger("Everything is so much louder!"),
	)

	user.temporarilyRemoveItemFromInventory(src, force = TRUE)
	Insert(user)
	return TRUE

/datum/action/cooldown/spell/shapeshift/kitty
	name = "KITTY POWER!!"
	desc = "Take on the shape of a kitty cat! Gain their powers at a loss of vitality."

	cooldown_time = 20 SECONDS
	invocation = "MRR MRRRW!!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	possible_shapes = list(
		/mob/living/simple_animal/pet/cat/super,
		/mob/living/simple_animal/pet/cat/breadcat/super,
		/mob/living/simple_animal/pet/cat/original/super,
	)
	keep_name = TRUE

/mob/living/simple_animal/pet/cat/super
	maxHealth = SUPER_KITTY_HEALTH
	health = SUPER_KITTY_HEALTH
	speed = 0
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/breadcat/super
	maxHealth = SUPER_KITTY_HEALTH
	health = SUPER_KITTY_HEALTH
	speed = 0
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/original/super
	maxHealth = SUPER_KITTY_HEALTH
	health = SUPER_KITTY_HEALTH
	speed = 0
	gold_core_spawnable = NO_SPAWN

/obj/item/organ/internal/ears/cat/super/syndie
	kitty_spell = /datum/action/cooldown/spell/shapeshift/kitty/syndie

/datum/action/cooldown/spell/shapeshift/kitty/syndie
	name = "SYNDICATE KITTY POWER!!"
	desc = "Take on the shape of an kitty cat, clad in blood-red armor! Gain their powers at a loss of vitality."
	possible_shapes = list(/mob/living/simple_animal/hostile/syndicat/super)

/mob/living/simple_animal/hostile/syndicat/super
	maxHealth = SYNDIE_SUPER_KITTY_HEALTH
	health = SYNDIE_SUPER_KITTY_HEALTH
	speed = 0
	// it's clad in blood-red armor
	damage_coeff = list(BRUTE = 0.8, BURN = 0.9, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	bodytemp_cold_damage_limit = -1
	bodytemp_heat_damage_limit = INFINITY
	unsuitable_atmos_damage = 0

/mob/living/simple_animal/hostile/syndicat/super/Initialize(mapload)
	. = ..()
	// get rid of the microbomb normal syndie cats have
	for(var/obj/item/implant/explosive/implant_to_remove in implants)
		qdel(implant_to_remove)

#undef SYNDIE_SUPER_KITTY_HEALTH
#undef SUPER_KITTY_HEALTH
