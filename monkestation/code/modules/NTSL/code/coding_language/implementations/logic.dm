// Script -> BYOND code procs
#define SCRIPT_MAX_REPLACEMENTS_ALLOWED 200

/**
 * List operations (lists known as vectors in n_script)
 */
/// Picks one random item from the list
/datum/n_function/default/pick
	name = "pick"

/datum/n_function/default/pick/execute(this_obj, list/params)
	var/list/finalpick = list()
	for(var/e in params)
		if(IS_OBJECT(e))
			if(istype(e, /list))
				var/list/sublist = e
				for(var/sube in sublist)
					finalpick.Add(sube)
				continue
		finalpick.Add(e)

	return pick(finalpick)

/**
 * String methods
 */
///If list, finds a value in it, if text, finds a substring in it
/datum/n_function/default/find
	name = "find"

/datum/n_function/default/find/execute(this_obj, list/params)
	var/haystack = length(params) >= 1 ? params[1] : null
	var/needle = length(params) >= 2 ? params[2] : null
	var/start = length(params) >= 3 ? params[3] : 1
	var/end = length(params) >= 4 ? params[4] : 0
	if(!haystack || !needle)
		return
	if(IS_OBJECT(haystack))
		if(!istype(haystack, /list))
			return
		if(length(haystack) >= end && start > 0)
			var/list/listhaystack = haystack
			return listhaystack.Find(needle, start, end)
	else if(istext(haystack))
		if(length(haystack) >= end && start > 0)
			return findtext(haystack, needle, start, end)

///Returns a substring of the string
/datum/n_function/default/substr
	name = "substr"

/datum/n_function/default/substr/execute(this_obj, list/params)
	var/string = length(params) >= 1 ? params[1] : null
	var/start = length(params) >= 2 ? params[2] : 1
	var/end = length(params) >= 3 ? params[3] : 0
	if(istext(string) && isnum(start) && isnum(end))
		if(start > 0)
			return copytext(string, start, end)

///Returns the length of the string or list
/datum/n_function/default/length
	name = "length"

/datum/n_function/default/length/execute(this_obj, list/params)
	var/container = length(params) >= 1 ? params[1] : null
	if(container)
		if(istype(container, /list) || istext(container))
			return length(container)
	return FALSE

///Lowercase all characters
/datum/n_function/default/lower
	name = "lower"

/datum/n_function/default/lower/execute(this_obj, list/params)
	var/string = length(params) >= 1 ? params[1] : null
	if(istext(string))
		return lowertext(string)

///Uppercase all characters
/datum/n_function/default/upper
	name = "upper"

/datum/n_function/default/upper/execute(this_obj, list/params)
	var/string = length(params) >= 1 ? params[1] : null
	if(istext(string))
		return uppertext(string)

///Converts a string to a list
/datum/n_function/default/explode
	name = "explode"

/datum/n_function/default/explode/execute(this_obj, list/params)
	var/string = length(params) >= 1 ? params[1] : null
	var/separator = length(params) >= 2 ? params[2] : ""
	if(istext(string) && (istext(separator) || isnull(separator)))
		return splittext(string, separator)

///Converts a list to a string
/datum/n_function/default/implode
	name = "implode"

/datum/n_function/default/implode/execute(this_obj, list/params)
	var/list/li = LAZYACCESS(params, 1)
	var/separator = LAZYACCESS(params, 2)
	if(istype(li) && (istext(separator) || isnull(separator)))
		return jointext(li, separator)

///Repeats the string x times
/datum/n_function/default/repeat
	name = "repeat"

/datum/n_function/default/repeat/execute(this_obj, list/params)
	var/string = length(params) >= 1 ? params[1] : null
	var/amount = length(params) >= 2 ? params[2] : null
	if(istext(string) && isnum(amount))
		var/i
		var/newstring = ""
		if(length(newstring) * amount >= 1000)
			return
		for(i = 0, i <= amount, i++)
			if(i >= 1000)
				break
			newstring = newstring + string

		return newstring

///Reverses the order of the string. "Clown" becomes "nwolC"
/datum/n_function/default/reverse
	name = "reverse"

/datum/n_function/default/reverse/execute(this_obj, list/params)
	var/string = length(params) >= 1 ? params[1] : null
	if(istext(string))
		var/newstring = ""
		var/i
		for(i = length(string), i > 0, i--)
			if(i >= 1000)
				break
			newstring = newstring + copytext(string, i, i+1)

		return newstring

//Turns a String into a Number
/datum/n_function/default/tonum
	name = "tonum"

/datum/n_function/default/tonum/execute(this_obj, list/params)
	var/string = length(params) >= 1 ? params[1] : null
	if(istext(string))
		return text2num(string)

/datum/n_function/default/proper
	name = "proper"

/datum/n_function/default/proper/execute(this_obj, list/params)
	var/string = length(params) >= 1 ? params[1] : null
	if(!istext(string))
		return ""

	return text("[][]", uppertext(copytext(string, 1, 2)), lowertext(copytext(string, 2)))

/**
 * Number methods
 */

///Returns the highest value of the arguments
///Need custom functions here cause byond's min and max runtimes if you give them a string or list.
/datum/n_function/default/max
	name = "max"

/datum/n_function/default/max/execute(this_obj, list/params)
	if(!length(params))
		return FALSE

	var/max = params[1]
	for(var/e in params)
		if(isnum(e) && e > max)
			max = e

	return max

///Returns the lowest value of the arguments
/datum/n_function/default/min
	name = "min"

/datum/n_function/default/min/execute(this_obj, list/params)
	if(!length(params))
		return FALSE

	var/min = params[1]
	for(var/e in params)
		if(isnum(e) && e < min)
			min = e

	return min

/datum/n_function/default/prob
	name = "prob"

/datum/n_function/default/prob/execute(this_obj, list/params)
	var/chance = length(params) >= 1 ? params[1] : null
	return prob(chance)

/datum/n_function/default/randseed
	name = "randseed"

/datum/n_function/default/randseed/execute(this_obj, list/params)
	//var/seed = length(params) >= 1 ? params[1] : null
	//rand_seed(seed)

/datum/n_function/default/rand
	name = "rand"

/datum/n_function/default/rand/execute(this_obj, list/params)
	var/low = length(params) >= 1 ? params[1] : null
	var/high = length(params) >= 2 ? params[2] : null
	if(isnull(low) && isnull(high))
		return rand()

	return rand(low, high)

///Turns a Number into a String
/datum/n_function/default/tostring
	name = "tostring"

/datum/n_function/default/tostring/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num))
		return num2text(num)

// Squareroot
/datum/n_function/default/sqrt
	name = "sqrt"

/datum/n_function/default/sqrt/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num))
		return sqrt(num)

///Magnitude of a Number
/datum/n_function/default/abs
	name = "abs"

/datum/n_function/default/abs/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num))
		return abs(num)

///Rounds a number down
/datum/n_function/default/floor
	name = "floor"

/datum/n_function/default/floor/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num))
		return round(num)

///Rounds a number up
/datum/n_function/default/ceil
	name = "ceil"

/datum/n_function/default/ceil/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num))
		return round(num)+1

///Rounds a number to its nearest integer
/datum/n_function/default/round
	name = "round"

/datum/n_function/default/round/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num))
		if(num-round(num) < 0.5)
			return round(num)
		return round(num) + 1

/// Clamps a number between min and max
/datum/n_function/default/clamp
	name = "clamp"

/datum/n_function/default/clamp/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	var/min = length(params) >= 2 ? params[2] : -1
	var/max = length(params) >= 3 ? params[3] : 1
	if(isnum(num) && isnum(min) && isnum(max))
		if(num <= min)
			return min
		if(num >= max)
			return max
		return num

///Returns TRUE if a number is inbetween Min and Max
/datum/n_function/default/inrange
	name = "inrange"

/datum/n_function/default/inrange/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	var/min = length(params) >= 2 ? params[2] : -1
	var/max = length(params) >= 3 ? params[3] : 1
	if(isnum(num)&&isnum(min)&&isnum(max))
		return ((min <= num) && (num <= max))

///Returns the sine of a number
/datum/n_function/default/sin
	name = "sin"

/datum/n_function/default/sin/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num))
		return sin(num)

///Returns the cosine of a number
/datum/n_function/default/cos
	name = "cos"

/datum/n_function/default/cos/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num))
		return cos(num)

///Returns the arcsine of a number
/datum/n_function/default/asin
	name = "asin"

/datum/n_function/default/asin/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num) && -1 <= num && num <= 1)
		return arcsin(num)

///Returns the arccosine of a number
/datum/n_function/default/acos
	name = "acos"

/datum/n_function/default/acos/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num) && -1 <= num && num <= 1)
		return arccos(num)

///Returns the natural log of a number
/datum/n_function/default/log
	name = "log"

/datum/n_function/default/log/execute(this_obj, list/params)
	var/num = length(params) >= 1 ? params[1] : null
	if(isnum(num) && 0 < num)
		return log(num)

///Replaces text
/datum/n_function/default/replace
	name = "replace"

/datum/n_function/default/replace/execute(this_obj, list/params)
	var/text = length(params) >= 1 ? params[1] : null
	var/find = length(params) >= 2 ? params[2] : null
	var/replacement = length(params) >= 3 ? params[3] : null
	if(!istext(text) || !istext(find) || !istext(replacement))
		return
	var/find_len = length(find)
	if(!find_len)
		return text

	var/max_count
	if(length(params) >= 4 && isnum(params[4]))
		max_count = min(params[4], SCRIPT_MAX_REPLACEMENTS_ALLOWED)
	else
		max_count = SCRIPT_MAX_REPLACEMENTS_ALLOWED

	. = ""
	var/last_found = 1
	for(var/count = 0; count < max_count; ++count)
		var/found = findtext(text, find, last_found, 0)
		if(!found)
			break
		. += copytext(text, last_found, found)
		. += replacement
		last_found = found + find_len
	return . + copytext(text, last_found)

/**
 * Miscellaneous functions
 */

/datum/n_function/default/time
	name = "time"

/datum/n_function/default/time/execute(this_obj, list/params)
	return world.timeofday

///Clone of BYOND's sleep()
/datum/n_function/default/sleeps
	name = "sleep"

/datum/n_function/default/sleeps/execute(this_obj, list/params)
	var/time = length(params) >= 1 ? params[1] : null
	sleep(time)

/datum/n_function/default/timestamp
	name = "timestamp"

/datum/n_function/default/timestamp/execute(this_obj, list/params)
	return gameTimestamp(arglist(params))

#undef SCRIPT_MAX_REPLACEMENTS_ALLOWED
