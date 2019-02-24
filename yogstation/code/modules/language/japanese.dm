/datum/language/japanese
	name = "Japanese"
	desc = "The common language of Japanese citizens. In space, only ninjas speak japanese."
	speech_verb = "To iu"
	ask_verb = "Tazuneru"
	exclaim_verb = "Sakebu"
	key = "j"
	flags = TONGUELESS_SPEECH
	space_chance = 40
	syllables = list(
		"a", "i", "u", "e", "o",
		"ka", "ki", "ku", "ke", "ko",
		"ga", "gi", "gu", "ge", "go",
		"sa", "shi", "su", "se", "so",
		"za", "ji", "zu", "ze", "zo",
		"ta", "chi", "tsu", "te", "to",
		"da", "ji", "zu", "de", "do",
		"na", "ni", "nu", "ne", "no",
		"ha", "hi", "fu", "he", "ho",
		"ba", "bi", "bu", "be", "bo",
		"pa", "pi", "pu", "pe", "po",
		"ma", "mi", "mu", "me", "mo",
		"ya", "yu", "yo",
		"ra", "ri", "ru", "re", "ro",
		"wa", "wo"
	)
	icon = 'yogstation/icons/misc/language.dmi'
	icon_state = "japan"
	default_priority = 90