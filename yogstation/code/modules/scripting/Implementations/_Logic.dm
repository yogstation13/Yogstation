// Script -> BYOND code procs
#define SCRIPT_MAX_REPLACEMENTS_ALLOWED 200


// --- List operations (lists known as vectors in n_script) ---

// Picks one random item from the list
/datum/n_function/default/pick
	name = "pick"
/datum/n_function/default/pick/execute(this_obj, list/params)
	var/list/finalpick = list()
	for(var/e in params)
		if(isobject(e))
			if(istype(e, /list))
				var/list/sublist = e
				for(var/sube in sublist)
					finalpick.Add(sube)
				continue
		finalpick.Add(e)

	return pick(finalpick)

// --- String methods ---

//If list, finds a value in it, if text, finds a substring in it
/datum/n_function/default/find
	name = "find"
/datum/n_function/default/find/execute(this_obj, list/params)
	var/haystack = params.len >= 1 ? params[1] : null
	var/needle = params.len >= 2 ? params[2] : null
	var/start  = params.len >= 3 ? params[3] :  1
	var/end  = params.len >= 4 ? params[4] :  0
	if(haystack && needle)
		if(isobject(haystack))
			if(istype(haystack, /list))
				if(length(haystack) >= end && start > 0)
					var/list/listhaystack = haystack
					return listhaystack.Find(needle, start, end)

		else
			if(istext(haystack))
				if(length(haystack) >= end && start > 0)
					return findtext(haystack, needle, start, end)

//Returns a substring of the string
/datum/n_function/default/substr
	name = "substr"
/datum/n_function/default/substr/execute(this_obj, list/params)
	var/string = params.len >= 1 ? params[1] : null
	var/start  = params.len >= 2 ? params[2] :  1
	var/end  = params.len >= 3 ? params[3] :  0
	if(istext(string) && isnum(start) && isnum(end))
		if(start > 0)
			return copytext(string, start, end)

//Returns the length of the string or list
/datum/n_function/default/length
	name = "length"
/datum/n_function/default/length/execute(this_obj, list/params)
	var/container = params.len >= 1 ? params[1] : null
	if(container)
		if(istype(container, /list) || istext(container))
			return length(container)
	return 0

//Lowercase all characters
/datum/n_function/default/lower
	name = "lower"
/datum/n_function/default/lower/execute(this_obj, list/params)
	var/string = params.len >= 1 ? params[1] : null
	if(istext(string))
		return lowertext(string)

//Uppercase all characters
/datum/n_function/default/upper
	name = "upper"
/datum/n_function/default/upper/execute(this_obj, list/params)
	var/string = params.len >= 1 ? params[1] : null
	if(istext(string))
		return uppertext(string)

//Converts a string to a list
/datum/n_function/default/explode
	name = "explode"
/datum/n_function/default/explode/execute(this_obj, list/params)
	var/string = params.len >= 1 ? params[1] : null
	var/separator  = params.len >= 2 ? params[2] :  ""
	if(istext(string) && (istext(separator) || isnull(separator)))
		return splittext(string, separator)

//Converts a list to a string
/datum/n_function/default/implode
	name = "implode"
/datum/n_function/default/implode/execute(this_obj, list/params)
	var/list/li = LAZYACCESS(params, 1)
	var/separator = LAZYACCESS(params, 2)
	if(istype(li) && (istext(separator) || isnull(separator)))
		return jointext(li, separator)

//Repeats the string x times
/datum/n_function/default/repeat
	name = "repeat"
/datum/n_function/default/repeat/execute(this_obj, list/params)
	var/string = params.len >= 1 ? params[1] : null
	var/amount = params.len >= 2 ? params[2] : null
	if(istext(string) && isnum(amount))
		var/i
		var/newstring = ""
		if(length(newstring)*amount >=1000)
			return
		for(i=0, i<=amount, i++)
			if(i>=1000)
				break
			newstring = newstring + string

		return newstring

//Reverses the order of the string. "Clown" becomes "nwolC"
/datum/n_function/default/reverse
	name = "reverse"
/datum/n_function/default/reverse/execute(this_obj, list/params)
	var/string = params.len >= 1 ? params[1] : null
	if(istext(string))
		var/newstring = ""
		var/i
		for(i=length(string), i>0, i--)
			if(i>=1000)
				break
			newstring = newstring + copytext(string, i, i+1)

		return newstring

// String -> Number
/datum/n_function/default/tonum
	name = "tonum"
/datum/n_function/default/tonum/execute(this_obj, list/params)
	var/string = params.len >= 1 ? params[1] : null
	if(istext(string))
		return text2num(string)

/datum/n_function/default/proper
	name = "proper"
/datum/n_function/default/proper/execute(this_obj, list/params)
	var/string = params.len >= 1 ? params[1] : null
	if(!istext(string))
		return ""

	return text("[][]", uppertext(copytext(string, 1, 2)), lowertext(copytext(string, 2)))

// --- Number methods ---

//Returns the highest value of the arguments
//Need custom functions here cause byond's min and max runtimes if you give them a string or list.
/datum/n_function/default/max
	name = "max"
/datum/n_function/default/max/execute(this_obj, list/params)
	if(params.len == 0)
		return 0

	var/max = params[1]
	for(var/e in params)
		if(isnum(e) && e > max)
			max = e

	return max

//Returns the lowest value of the arguments
/datum/n_function/default/min
	name = "min"
/datum/n_function/default/min/execute(this_obj, list/params)
	if(params.len == 0)
		return 0

	var/min = params[1]
	for(var/e in params)
		if(isnum(e) && e < min)
			min = e

	return min

/datum/n_function/default/prob
	name = "prob"
/datum/n_function/default/prob/execute(this_obj, list/params)
	var/chance = params.len >= 1 ? params[1] : null
	return prob(chance)

/datum/n_function/default/randseed
	name = "randseed"
/datum/n_function/default/randseed/execute(this_obj, list/params)
	//var/seed = params.len >= 1 ? params[1] : null
	//rand_seed(seed)

/datum/n_function/default/rand
	name = "rand"
/datum/n_function/default/rand/execute(this_obj, list/params)
	var/low = params.len >= 1 ? params[1] : null
	var/high = params.len >= 2 ? params[2] : null
	if(isnull(low) && isnull(high))
		return rand()

	return rand(low, high)

// Number -> String
/datum/n_function/default/tostring
	name = "tostring"
/datum/n_function/default/tostring/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return num2text(num)

// Squareroot
/datum/n_function/default/sqrt
	name = "sqrt"
/datum/n_function/default/sqrt/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return sqrt(num)

// Magnitude of num
/datum/n_function/default/abs
	name = "abs"
/datum/n_function/default/abs/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return abs(num)

// Round down
/datum/n_function/default/floor
	name = "floor"
/datum/n_function/default/floor/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return round(num)

// Round up
/datum/n_function/default/ceil
	name = "ceil"
/datum/n_function/default/ceil/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return round(num)+1

// Round to nearest integer
/datum/n_function/default/round
	name = "round"
/datum/n_function/default/round/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		if(num-round(num)<0.5)
			return round(num)
		return round(num) + 1

// Clamps N between min and max
/datum/n_function/default/clamp
	name = "clamp"
/datum/n_function/default/clamp/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	var/min = params.len >= 2 ? params[2] : -1
	var/max = params.len >= 3 ? params[3] : 1
	if(isnum(num)&&isnum(min)&&isnum(max))
		if(num<=min)
			return min
		if(num>=max)
			return max
		return num

// Returns 1 if N is inbetween Min and Max
/datum/n_function/default/inrange
	name = "inrange"
/datum/n_function/default/inrange/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	var/min = params.len >= 2 ? params[2] : -1
	var/max = params.len >= 3 ? params[3] : 1
	if(isnum(num)&&isnum(min)&&isnum(max))
		return ((min <= num) && (num <= max))

// Returns the sine of num
/datum/n_function/default/sin
	name = "sin"
/datum/n_function/default/sin/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return sin(num)

// Returns the cosine of num
/datum/n_function/default/cos
	name = "cos"
/datum/n_function/default/cos/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return cos(num)

// Returns the arcsine of num
/datum/n_function/default/asin
	name = "asin"
/datum/n_function/default/asin/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num)&&-1<=num&&num<=1)
		return arcsin(num)

// Returns the arccosine of num
/datum/n_function/default/acos
	name = "acos"
/datum/n_function/default/acos/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num)&&-1<=num&&num<=1)
		return arccos(num)

// Returns the natural log of num
/datum/n_function/default/log
	name = "log"
/datum/n_function/default/log/execute(this_obj, list/params)
	var/num = params.len >= 1 ? params[1] : null
	if(isnum(num)&&0<num)
		return log(num)

// Replace text
/datum/n_function/default/replace
	name = "replace"
/datum/n_function/default/replace/execute(this_obj, list/params)
	var/text = params.len >= 1 ? params[1] : null
	var/find = params.len >= 2 ? params[2] : null
	var/replacement = params.len >= 3 ? params[3] : null
	if(istext(text) && istext(find) && istext(replacement))
		var/find_len = length(find)
		if(find_len < 1)	return text
		. = ""
		var/last_found = 1
		var/count = 0
		while(1)
			count += 1
			if(count >  SCRIPT_MAX_REPLACEMENTS_ALLOWED)
				break
			var/found = findtext(text, find, last_found, 0)
			. += copytext(text, last_found, found)
			if(found)
				. += replacement
				last_found = found + find_len
				continue
			return

#undef SCRIPT_MAX_REPLACEMENTS_ALLOWED

// --- Miscellaneous functions ---

/datum/n_function/default/time
	name = "time"
/datum/n_function/default/time/execute(this_obj, list/params)
	return world.timeofday

// Clone of sleep()
/datum/n_function/default/sleep
	name = "sleep"
/datum/n_function/default/sleep/execute(this_obj, list/params)
	var/time = params.len >= 1 ? params[1] : null
	sleep(time)

/datum/n_function/default/timestamp
	name = "timestamp"
/datum/n_function/default/timestamp/execute(this_obj, list/params)
	return gameTimestamp(arglist(params))
