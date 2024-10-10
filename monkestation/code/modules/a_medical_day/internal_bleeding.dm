/datum/wound_pregen_data/internal_bleeding
	abstract = FALSE
	wound_path_to_generate = /datum/wound/bleed_internal
	ignore_cannot_bleed = FALSE
	required_limb_biostate = BIO_BLOODED
	required_wounding_types = list(WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE)
	threshold_minimum = 45

/datum/wound/bleed_internal
	name = "Internal Bleeding"
	desc = "The patient is bleeding internally, causing severe pain and difficulty breathing."
	treat_text = "Surgical repair of the affected vein is necessary."
	treat_text_short = "Surgical repair required."
	examine_desc = ""
	scar_keyword = ""
	severity = WOUND_SEVERITY_MODERATE
	simple_treat_text = "Surgery."
	homemade_treat_text = "Taking a <b>blood clotting pill</b> may help slow the bleeding, \
		or an <b>iron supplement</b> to help your body recover."
	processes = TRUE
	wound_flags = NONE
	regen_ticks_needed = 120 //around 4 minutes
	/// How much blood lost per life tick, gets modified by severity.
	var/bleed_amount = 0.25
	/// Cooldown between when the wound can be allowed to worsen
	COOLDOWN_DECLARE(worsen_cd)

/datum/wound/bleed_internal/get_self_check_description(mob/user)
	return span_warning("You can see dark bruising.") // same as rib fracture!

/datum/wound/bleed_internal/handle_process(seconds_per_tick, times_fired)
	. = ..()
	regen_ticks_current++
	if(!victim || victim.stat == DEAD || HAS_TRAIT(victim, TRAIT_STASIS) || !victim.needs_heart())
		return
	victim.bleed(min(bleed_amount * severity * seconds_per_tick, 3))

/datum/wound/bleed_internal/wound_injury(datum/wound/old_wound, attack_direction)
	COOLDOWN_START(src, worsen_cd, 5 SECONDS)

/datum/wound/bleed_internal/receive_damage(wounding_type, wounding_dmg, wound_bonus, attack_direction, damage_source)
	if(wounding_type == WOUND_BURN || wound_bonus == CANT_WOUND)
		return
	if(!COOLDOWN_FINISHED(src, worsen_cd))
		return
	if(wounding_dmg + wound_bonus + rand(-10, 30) - victim.getarmor(limb, WOUND) < 45)
		return
	severity = min(severity + 1, WOUND_SEVERITY_CRITICAL)
	COOLDOWN_START(src, worsen_cd, 6 SECONDS)
