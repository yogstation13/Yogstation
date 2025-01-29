/obj/item/organ/internal/ears/cat/super
	name = "Super Kitty Ears"
	desc = "A pair of kitty ears that harvest the true energy of cats. Mrow!"
	icon_state = "superkitty"
	decay_factor = 0 // Space ruin item
	damage_multiplier = 0.5 // SUPER

/datum/action/cooldown/spell/shapeshift/kitty
	name = "KITTY POWER!!"
	desc = "Take on the shape of a kitty cat! Gain their powers at a loss of vitality."

	cooldown_time = 20 SECONDS
	invocation = "MRR MRRRW!!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	possible_shapes = list(
		/mob/living/simple_animal/pet/cat/super,
		/mob/living/simple_animal/pet/cat/super,
		/mob/living/simple_animal/pet/cat/super,
	)

	// Stole this from demon heart hard, but hey it works
/obj/item/organ/internal/ears/cat/super/attack(mob/target_mob, mob/living/carbon/user, obj/target)
	if(target_mob != user)
		return ..()

	user.visible_message(
		span_warning("[user] raises the [src] to [user.p_their()] head and genetly places it on [user.p_their()] head!"),
		span_danger("A strange feline comes over you. You place the [src] on your head!"),
	)
	playsound(user, 'sound/effects/meow1.ogg', 50, TRUE)

	user.visible_message(
		span_warning("The [src] melt into [user]'s head!"),
		span_userdanger("Everything is so much louder!"),
	)

	user.temporarilyRemoveItemFromInventory(src, TRUE)
	src.Insert(user)

/obj/item/organ/internal/ears/cat/super/on_insert(mob/living/carbon/heart_owner)
	. = ..()
	var/datum/action/cooldown/spell/shapeshift/kitty/heart = new(heart_owner)
	heart.Grant(heart_owner)

/obj/item/organ/internal/ears/cat/super/on_remove(mob/living/carbon/heart_owner, special = FALSE)
	. = ..()
	var/datum/action/cooldown/spell/shapeshift/kitty/heart = locate() in heart_owner.actions
	qdel(heart)

/mob/living/simple_animal/pet/cat/super
	health = 50

/mob/living/simple_animal/pet/cat/breadcat/super
	health = 50

/mob/living/simple_animal/pet/cat/original/super
	health = 50
