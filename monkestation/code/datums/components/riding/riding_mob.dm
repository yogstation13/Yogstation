// Carps move 4x faster when ridden in space
/datum/component/riding/creature/carp/move_delay()
	. = ..()
	var/mob/living/living_parent = parent
	if(!living_parent.has_gravity())
		. *= 0.25

/datum/component/riding/creature/human/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = NONE, potion_boost = FALSE)
	. = ..()
	var/mob/living/carbon/human/human_parent = parent
	if (HAS_TRAIT(human_parent, TRAIT_FEEBLE))
		human_parent.Paralyze(1 SECONDS)
		human_parent.Knockdown(4 SECONDS)
		human_parent.emote("scream", intentional=FALSE)
		human_parent.adjustBruteLoss(15)
		human_parent.visible_message(span_danger("The weight of [riding_mob] is too much for [human_parent]!"), \
				span_userdanger("The weight of [riding_mob] is too much. You are crushed beneath [riding_mob.p_them()]!"))
		playsound(human_parent.loc, 'sound/weapons/punch1.ogg', 35, TRUE, -1)
		Unbuckle(riding_mob)
