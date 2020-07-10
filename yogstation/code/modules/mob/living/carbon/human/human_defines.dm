/mob/living/carbon/human
	var/gender_ambiguous = FALSE //if something goes wrong during gender reassignment this generates a line in examine
	var/mood_enabled = FALSE // Marks whether this player had moods enabled in preferences at the time of spawning (helps prevent exploitation)