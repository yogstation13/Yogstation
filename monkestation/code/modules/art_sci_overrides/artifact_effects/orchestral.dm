/datum/artifact_effect/orchestral
	weight = ARTIFACT_VERYUNCOMMON
	type_name = "Audible Jazzy Effect"
	activation_message = "starts playing unanticipated jazz!"
	deactivation_message = "falls silent, its jazzy aura dissipating!"
	valid_activators = list(
		/datum/artifact_activator/touch,
		/datum/artifact_activator/range
	)

	research_value = 400

	examine_discovered = span_warning("It appears to play smooth jazz, but suddenly.")
	var/sound_hit_list = list(
		'monkestation/sound/effects/artifacts/orchestral/hit01.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit02.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit03.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit04.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit05.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit06.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit07.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit08.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit09.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit10.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit11.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit12.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit13.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit14.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit15.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit16.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit17.ogg',
		'monkestation/sound/effects/artifacts/orchestral/hit18.ogg'
	)

	var/reactions = list(
		"The sudden jazz makes you feel jazzy.",
		"Smooth jazz has been deployed to your eardrums.",
		"Your soul feels... jazzified.",
		"Your auditory senses are being serenaded by jazz.",
		"A gentle jazz washes over you.",
		"Your mind drifts away on a cloud of jazz.",
		"The world slows down to a jazzy rhythm.",
		"Jazz attack!",
	)

	var/reaction_radius = 9

	COOLDOWN_DECLARE(jazz_cooldown)

/datum/artifact_effect/orchestral/setup()
	return

/datum/artifact_effect/orchestral/effect_touched(mob/living/user)
	if(!COOLDOWN_FINISHED(src, jazz_cooldown))
		return

	playsound(our_artifact.holder, pick(sound_hit_list), channel = CHANNEL_MACHINERY, vol = 80)

	var/turf/our_turf = get_turf(our_artifact.holder)
	for(var/turf/open/floor in range(reaction_radius,our_artifact.holder))
		if(floor == our_turf)
			continue
		for(var/mob/living/living in floor)
			to_chat(living, span_notice(pick(reactions)))
			living.add_mood_event("orchestral_artifact", /datum/mood_event/jazzy)
	COOLDOWN_START(src, jazz_cooldown, 3 SECONDS)
