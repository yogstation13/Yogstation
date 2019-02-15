// Script -> BYOND code procs
#define SCRIPT_MAX_REPLACEMENTS_ALLOWED 200


// --- List operations (lists known as vectors in n_script) ---

// Creates a list out of all the arguments
/datum/n_function/default/vector
	name = "vector"
/datum/n_function/default/vector/execute(this_obj, list/params)
	var/list/returnlist = list()
	for(var/e in params)
		returnlist.Add(e)
	return returnlist

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

// Gets/Sets a value at a key in the list
/datum/n_function/default/at
	name = "at"
/datum/n_function/default/at/execute(this_obj, list/params)
	var/list/L = LAZYACCESS(params,1)
	var/pos = LAZYACCESS(params,2)
	var/value = LAZYACCESS(params,3)
	if(!istype(L, /list)) return
	if(isnum(pos))
		if(!value)
			if(L.len >= pos)
				return L[pos]
		else
			if(L.len >= pos)
				L[pos] = value
	else if(istext(pos))
		if(!value)
			return L[pos]
		else
			L[pos] = value

// Copies the list into a new one
/datum/n_function/default/copy
	name = "copy"
/datum/n_function/default/copy/execute(this_obj, list/params)
	list/L = params.len >= 1 ? params[1] : null
	start = params.len >= 2 ? params[2] : null
	end = params.len >= 3 ? params[3] : null
	if(!istype(L, /list)) return
	return L.Copy(start, end)

// Adds arg 2,3,4,5... to the end of list at arg 1
/datum/n_function/default/push_back
	name = "push_back"
/datum/n_function/default/push_back/execute(this_obj, list/params)
	var/list/chosenlist
	var/i = 1
	for(var/e in params)
		if(i == 1)
			if(isobject(e))
				if(istype(e, /list))
					chosenlist = e
			i = 2
		else
			if(chosenlist)
				chosenlist.Add(e)

// Removes arg 2,3,4,5... from list at arg 1
/proc/remove()
	var/list/chosenlist
	var/i = 1
	for(var/e in params)
		if(i == 1)
			if(isobject(e))
				if(istype(e, /list))
					chosenlist = e
			i = 2
		else
			if(chosenlist)
				chosenlist.Remove(e)

// Cuts out a copy of a list
/datum/n_function/default/cut
	name = "cut"
/datum/n_function/default/cut/execute(this_obj, list/params)
	list/L = params.len >= 1 ? params[1] : null
	start = params.len >= 2 ? params[2] : null
	end = params.len >= 3 ? params[3] : null
	if(!istype(L, /list)) return
	return L.Cut(start, end)

// Swaps two values in the list
/datum/n_function/default/swap
	name = "swap"
/datum/n_function/default/swap/execute(this_obj, list/params)
	list/L = params.len >= 1 ? params[1] : null
	firstindex = params.len >= 2 ? params[2] : null
	secondindex = params.len >= 3 ? params[3] : null
	if(!istype(L, /list)) return
	if(L.len >= secondindex && L.len >= firstindex)
		return L.Swap(firstindex, secondindex)

// Inserts a value into the list
/datum/n_function/default/insert
	name = "insert"
/datum/n_function/default/insert/execute(this_obj, list/params)
	list/L = params.len >= 1 ? params[1] : null
	index = params.len >= 2 ? params[2] : null
	element = params.len >= 3 ? params[3] : null
	if(!istype(L, /list)) return
	return L.Insert(index, element)

// --- String methods ---

//If list, finds a value in it, if text, finds a substring in it
/datum/n_function/default/find
	name = "find"
/datum/n_function/default/find/execute(this_obj, list/params)
	haystack = params.len >= 1 ? params[1] : null
	needle = params.len >= 2 ? params[2] : null
	start  = params.len >= 3 ? params[3] :  1
	end  = params.len >= 4 ? params[4] :  0
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
	string = params.len >= 1 ? params[1] : null
	start  = params.len >= 2 ? params[2] :  1
	end  = params.len >= 3 ? params[3] :  0
	if(istext(string) && isnum(start) && isnum(end))
		if(start > 0)
			return copytext(string, start, end)

//Returns the length of the string or list
/datum/n_function/default/length
	name = "length"
/datum/n_function/default/length/execute(this_obj, list/params)
	container = params.len >= 1 ? params[1] : null
	if(container)
		if(istype(container, /list) || istext(container))
			return length(container)
	return 0

//Lowercase all characters
/datum/n_function/default/lower
	name = "lower"
/datum/n_function/default/lower/execute(this_obj, list/params)
	string = params.len >= 1 ? params[1] : null
	if(istext(string))
		return lowertext(string)

//Uppercase all characters
/datum/n_function/default/upper
	name = "upper"
/datum/n_function/default/upper/execute(this_obj, list/params)
	string = params.len >= 1 ? params[1] : null
	if(istext(string))
		return uppertext(string)

//Converts a string to a list
/datum/n_function/default/explode
	name = "explode"
/datum/n_function/default/explode/execute(this_obj, list/params)
	string = params.len >= 1 ? params[1] : null
	separator  = params.len >= 2 ? params[2] :  ""
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
	string = params.len >= 1 ? params[1] : null
	amount = params.len >= 2 ? params[2] : null
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
	string = params.len >= 1 ? params[1] : null
	if(istext(string))
		var/newstring = ""
		var/i
		for(i=lentext(string), i>0, i--)
			if(i>=1000)
				break
			newstring = newstring + copytext(string, i, i+1)

		return newstring

// String -> Number
/datum/n_function/default/tonum
	name = "tonum"
/datum/n_function/default/tonum/execute(this_obj, list/params)
	string = params.len >= 1 ? params[1] : null
	if(istext(string))
		return text2num(string)

/datum/n_function/default/proper
	name = "proper"
/datum/n_function/default/proper/execute(this_obj, list/params)
	string = params.len >= 1 ? params[1] : null
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
	chance = params.len >= 1 ? params[1] : null
	return prob(chance)

/datum/n_function/default/randseed
	name = "randseed"
/datum/n_function/default/randseed/execute(this_obj, list/params)
	seed = params.len >= 1 ? params[1] : null
	rand_seed(seed)

/datum/n_function/default/n_rand
	name = "n_rand"
/datum/n_function/default/n_rand/execute(this_obj, list/params)
	low = params.len >= 1 ? params[1] : null
	high = params.len >= 2 ? params[2] : null
	if(isnull(low) && isnull(high))
		return rand()

	return rand(low, high)

// Number -> String
/datum/n_function/default/tostring
	name = "tostring"
/datum/n_function/default/tostring/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return num2text(num)

// Squareroot
/datum/n_function/default/sqrt
	name = "sqrt"
/datum/n_function/default/sqrt/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return sqrt(num)

// Magnitude of num
/datum/n_function/default/abs
	name = "abs"
/datum/n_function/default/abs/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return abs(num)

// Round down
/datum/n_function/default/floor
	name = "floor"
/datum/n_function/default/floor/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return round(num)

// Round up
/datum/n_function/default/ceil
	name = "ceil"
/datum/n_function/default/ceil/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return round(num)+1

// Round to nearest integer
/datum/n_function/default/round
	name = "round"
/datum/n_function/default/round/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		if(num-round(num)<0.5)
			return round(num)
		return n_ceil(num)

// Clamps N between min and max
/datum/n_function/default/clamp
	name = "clamp"
/datum/n_function/default/clamp/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	min = params.len >= 2 ? params[2] : -1
	max = params.len >= 3 ? params[3] : 1
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
	num = params.len >= 1 ? params[1] : null
	min = params.len >= 2 ? params[2] : -1
	max = params.len >= 3 ? params[3] : 1
	if(isnum(num)&&isnum(min)&&isnum(max))
		return ((min <= num) && (num <= max))

// Returns the sine of num
/datum/n_function/default/sin
	name = "sin"
/datum/n_function/default/sin/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return sin(num)

// Returns the cosine of num
/datum/n_function/default/cos
	name = "cos"
/datum/n_function/default/cos/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num))
		return cos(num)

// Returns the arcsine of num
/datum/n_function/default/asin
	name = "asin"
/datum/n_function/default/asin/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num)&&-1<=num&&num<=1)
		return arcsin(num)

// Returns the arccosine of num
/datum/n_function/default/acos
	name = "acos"
/datum/n_function/default/acos/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num)&&-1<=num&&num<=1)
		return arccos(num)

// Returns the natural log of num
/datum/n_function/default/log
	name = "log"
/datum/n_function/default/log/execute(this_obj, list/params)
	num = params.len >= 1 ? params[1] : null
	if(isnum(num)&&0<num)
		return log(num)

// Replace text
/datum/n_function/default/replace
	name = "replace"
/datum/n_function/default/replace/execute(this_obj, list/params)
	text = params.len >= 1 ? params[1] : null
	find = params.len >= 2 ? params[2] : null
	replacement = params.len >= 3 ? params[3] : null
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
	time = params.len >= 1 ? params[1] : null
	sleep(time)
