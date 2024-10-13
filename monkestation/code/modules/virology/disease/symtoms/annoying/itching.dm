/datum/symptom/itching
	name = "Itching"
	desc = "Makes you Itch!"
	stage = 1
	badness = EFFECT_DANGER_ANNOYING
	var/scratch = FALSE
	///emote cooldowns
	COOLDOWN_DECLARE(itching_cooldown)
	///if FALSE, there is a percentage chance that the mob will emote scratching while itching_cooldown is on cooldown. If TRUE, won't emote again until after the off cooldown scratch occurs.
	var/off_cooldown_scratched = FALSE

/datum/symptom/itching/activate(mob/living/mob)
	if(!iscarbon(mob))
		return
	var/mob/living/carbon/affected_mob = mob
	var/obj/item/bodypart/bodypart = affected_mob.get_bodypart(affected_mob.get_random_valid_zone(even_weights = TRUE))
	if(bodypart && IS_ORGANIC_LIMB(bodypart) && !(bodypart.bodypart_flags & BODYPART_PSEUDOPART))  //robotic limbs will mean less scratching overall (why are golems able to damage themselves with self-scratching, but not androids? the world may never know)
		var/can_scratch = scratch && !affected_mob.incapacitated()
		if(can_scratch)
			bodypart.receive_damage(0.5)
		//below handles emotes, limiting the emote of emotes passed to chat
		if(COOLDOWN_FINISHED(src, itching_cooldown) || !COOLDOWN_FINISHED(src, itching_cooldown) && prob(60) && !off_cooldown_scratched)
			affected_mob.visible_message("[can_scratch ? span_warning("[affected_mob] scratches [affected_mob.p_their()] [bodypart.plaintext_zone].") : ""]", span_warning("Your [bodypart.plaintext_zone] itches. [can_scratch ? " You scratch it." : ""]"))
			COOLDOWN_START(src, itching_cooldown, 5 SECONDS)
			if(!off_cooldown_scratched && !COOLDOWN_FINISHED(src, itching_cooldown))
				off_cooldown_scratched = TRUE
			else
				off_cooldown_scratched = FALSE
