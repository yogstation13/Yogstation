GLOBAL_LIST_INIT(voice_types, generate_voice_types()) //we have a list of all voice types that players reference to, rather than creating a new one for each character

/proc/generate_voice_types()
	. = list()
	for(var/path in subtypesof(/datum/voice))
		var/datum/voice/new_type = new path()
		.[new_type.name] = new_type

/// Returns a voice datum that is valid for the input species
/proc/get_random_valid_voice(species)
	var/list/valid = list()
	for(var/i in GLOB.voice_types)
		var/datum/voice/test = GLOB.voice_types[i]
		if(test.can_use(species))
			valid |= i
			
	var/voice = GLOB.voice_types[pick(GLOB.voice_types)]
	if(length(valid))
		voice = GLOB.voice_types[pick(valid)]
	return voice

/datum/voice
	var/name = "debug"

	/// list of sounds used any time it isn't a question or exclamation
	var/list/normal
	/// list of sounds used for when adding ! at the end
	var/list/exclamation
	/// list of sounds used for when adding ? at the end
	var/list/question

	/// set this to false if you don't want people to be able to select it
	var/selectable = TRUE

	///if this is initialized, a species needs to be on this list to pick it (unused)
	var/list/species_whitelist
	///needs to not be on this list to pick it (unused)
	var/list/species_blacklist

/datum/voice/proc/get_sound(mob/living/speaker, message, list/spans)
	if(HAS_TRAIT(speaker, TRAIT_SIGN_LANG))
		return

	if(SPAN_HELIUM in spans) //lol, squeeky
		return 'sound/effects/mousesqueek.ogg'

	var/ending = copytext_char(message, -1)

	if(ending == "?" && length(question))
		return pick(question)

	if(ending == "!" && length(exclamation))
		return pick(exclamation)

	if(!length(normal))
		return

	//otherwise, just pick one of the regular ones
	return pick(normal)

/datum/voice/proc/can_use(species)
	if(!selectable)
		return FALSE
	if(species_blacklist && (species in species_blacklist))
		return FALSE
	if(species_whitelist && !(species in species_whitelist))
		return FALSE
	return TRUE

/datum/voice/high
	name = "High pitched"

	normal = list('goon/sound/speak_2.ogg')
	exclamation = list('goon/sound/speak_2_exclaim.ogg')
	question = list('goon/sound/speak_2_ask.ogg')

/datum/voice/middle
	name = "Medium pitched"

	normal = list('goon/sound/speak_1.ogg')
	exclamation = list('goon/sound/speak_1_exclaim.ogg')
	question = list('goon/sound/speak_1_ask.ogg')

/datum/voice/low
	name = "Low pitched"

	normal = list('goon/sound/speak_4.ogg')
	exclamation = list('goon/sound/speak_4_exclaim.ogg')
	question = list('goon/sound/speak_4_ask.ogg')

/datum/voice/wonky
	name = "Wonky"

	normal = list('goon/sound/speak_3.ogg')
	exclamation = list('goon/sound/speak_3_exclaim.ogg')
	question = list('goon/sound/speak_3_ask.ogg')
