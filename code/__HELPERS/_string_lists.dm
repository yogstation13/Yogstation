#define pick_list(FILE, KEY) (pick(strings(FILE, KEY)))
#define pick_list_weighted(FILE, KEY) (pickweight(strings(FILE, KEY)))
#define pick_list_replacements(FILE, KEY) (strings_replacement(FILE, KEY))
#define json_load(FILE) (json_decode(file2text(FILE)))

GLOBAL_LIST(string_cache)
GLOBAL_VAR(string_filename_current_key)


/proc/strings_replacement(filename, key, directory = "strings")
	load_strings_file(filename, directory)

	if((filename in GLOB.string_cache) && (key in GLOB.string_cache[filename]))
		var/response = pick(GLOB.string_cache[filename][key])
		var/regex/r = regex("@pick\\((\\D+?)\\)", "g")
		response = r.Replace(response, GLOBAL_PROC_REF(strings_subkey_lookup))
		return response
	else
		CRASH("strings list not found: [directory]/[filename], index=[key]")

/proc/strings(filename as text, key as text, directory = "strings")
	load_strings_file(filename, directory)
	if((filename in GLOB.string_cache) && (key in GLOB.string_cache[filename]))
		return GLOB.string_cache[filename][key]
	else
		CRASH("strings list not found: [directory]/[filename], index=[key]")

/proc/strings_subkey_lookup(match, group1)
	return pick_list(GLOB.string_filename_current_key, group1)

/proc/load_strings_file(filename, directory = "strings")
	GLOB.string_filename_current_key = filename
	if(filename in GLOB.string_cache)
		return //no work to do

	if(!GLOB.string_cache)
		GLOB.string_cache = new

	if(fexists("[directory]/[filename]"))
		GLOB.string_cache[filename] = json_load("[directory]/[filename]")
	else
		CRASH("file not found: [directory]/[filename]")

GLOBAL_LIST_EMPTY(string_lists)

/**
 * Caches lists with non-numeric stringify-able values (text or typepath).
 */
/proc/string_list(list/values)
	var/string_id = values.Join("-")

	. = GLOB.string_lists[string_id]

	if(.)
		return .

	return GLOB.string_lists[string_id] = values

///A wrapper for baseturf string lists, to offer support of non list values, and a stack_trace if we have major issues
/proc/baseturfs_string_list(list/values, turf/baseturf_holder)
	if(!islist(values))
		return values //baseturf things
	// return values
	if(length(values) > 10)
		stack_trace("The baseturfs list of [baseturf_holder] at [baseturf_holder.x], [baseturf_holder.y], [baseturf_holder.x] is [length(values)], it should never be this long, investigate. I've set baseturfs to a flashing wall as a visual queue")
		baseturf_holder.ChangeTurf(/turf/closed/indestructible/baseturfs_ded, list(/turf/closed/indestructible/baseturfs_ded), flags = CHANGETURF_FORCEOP)
		return string_list(list(/turf/closed/indestructible/baseturfs_ded)) //I want this reported god damn it
	return string_list(values)

/turf/closed/indestructible/baseturfs_ded
	name = "Report this"
	desc = "It looks like base turfs went to the fucking moon, TELL YOUR LOCAL CODER TODAY"
	icon = 'icons/turf/debug.dmi'
	icon_state = "fucked_baseturfs"
