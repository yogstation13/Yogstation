/datum/memory/key/codewords
	memory_flags = parent_type::memory_flags | MEMORY_NO_STORY

/datum/memory/key/codewords/get_names()
	return list("The code phrases used by the Syndicate: [jointext(GLOB.syndicate_code_phrase, ", ")].")

/datum/memory/key/codewords/responses/get_names()
	return list("The code responses used by the Syndicate: [jointext(GLOB.syndicate_code_response, ", ")].")
