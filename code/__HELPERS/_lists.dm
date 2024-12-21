/*
 * Holds procs to help with list operations
 * Contains groups:
 *			Misc
 *			Sorting
 */

/*
 * Misc
 */

/*
 * ## Lazylists
 *
 * * What is a lazylist?
 *
 * True to its name a lazylist is a lazy instantiated list.
 * It is a list that is only created when necessary (when it has elements) and is null when empty.
 *
 * * Why use a lazylist?
 *
 * Lazylists save memory - an empty list that is never used takes up more memory than just `null`.
 *
 * * When to use a lazylist?
 *
 * Lazylists are best used on hot types when making lists that are not always used.
 *
 * For example, if you were adding a list to all atoms that tracks the names of people who touched it,
 * you would want to use a lazylist because most atoms will never be touched by anyone.
 *
 * * How do I use a lazylist?
 *
 * A lazylist is just a list you defined as `null` rather than `list()`.
 * Then, you use the LAZY* macros to interact with it, which are essentially null-safe ways to interact with a list.
 *
 * Note that you probably should not be using these macros if your list is not a lazylist.
 * This will obfuscate the code and make it a bit harder to read and debug.
 *
 * Generally speaking you shouldn't be checking if your lazylist is `null` yourself, the macros will do that for you.
 * Remember that LAZYLEN (and by extension, length) will return 0 if the list is null.
 */

// Generic listoflist safe add and removal macros:
///If value is a list, wrap it in a list so it can be used with list add/remove operations
#define LIST_VALUE_WRAP_LISTS(value) (islist(value) ? list(value) : value)
///Add an untyped item to a list, taking care to handle list items by wrapping them in a list to remove the footgun
#define UNTYPED_LIST_ADD(list, item) (list += LIST_VALUE_WRAP_LISTS(item))
///Remove an untyped item to a list, taking care to handle list items by wrapping them in a list to remove the footgun
#define UNTYPED_LIST_REMOVE(list, item) (list -= LIST_VALUE_WRAP_LISTS(item))

///Initialize the lazylist
#define LAZYINITLIST(L) if (!L) { L = list(); }
///If the provided list is empty, set it to null
#define UNSETEMPTY(L) if (L && !length(L)) L = null
///If the provided key -> list is empty, remove it from the list
#define ASSOC_UNSETEMPTY(L, K) if (!length(L[K])) L -= K;
///Like LAZYCOPY - copies an input list if the list has entries, If it doesn't the assigned list is nulled
#define LAZYLISTDUPLICATE(L) (L ? L.Copy() : null )
///Remove an item from the list, set the list to null if empty
#define LAZYREMOVE(L, I) if(L) { L -= I; if(!length(L)) { L = null; } }
///Add an item to the list, if the list is null it will initialize it
#define LAZYADD(L, I) if(!L) { L = list(); } L += I;
///Add an item to the list if not already present, if the list is null it will initialize it
#define LAZYOR(L, I) if(!L) { L = list(); } L |= I;
///Returns the key of the submitted item in the list
#define LAZYFIND(L, V) (L ? L.Find(V) : 0)
///returns L[I] if L exists and I is a valid index of L, runtimes if L is not a list
#define LAZYACCESS(L, I) (L ? (isnum(I) ? (I > 0 && I <= length(L) ? L[I] : null) : L[I]) : null)
///Sets the item K to the value V, if the list is null it will initialize it
#define LAZYSET(L, K, V) if(!L) { L = list(); } L[K] = V;
///Sets the length of a lazylist
#define LAZYSETLEN(L, V) if (!L) { L = list(); } L.len = V;
///Returns the length of the list
#define LAZYLEN(L) length(L)
///Sets a list to null
#define LAZYNULL(L) L = null
///Accesses an associative list, returns null if nothing is found
#define LAZYACCESSASSOC(L, I, K) L ? L[I] ? L[I][K] ? L[I][K] : null : null : null
///This is used to add onto lazy assoc list when the value you're adding is a /list/. This one has extra safety over lazyaddassoc because the value could be null (and thus cant be used to += objects)
#define LAZYADDASSOCLIST(L, K, V) if(!L) { L = list(); } L[K] += list(V);
///Qdel every item in the list before setting the list to null
#define QDEL_LAZYLIST(L) for(var/I in L) qdel(I); L = null;
//These methods don't null the list
///Use LAZYLISTDUPLICATE instead if you want it to null with no entries
#define LAZYCOPY(L) (L ? L.Copy() : list() )
/// Consider LAZYNULL instead
#define LAZYCLEARLIST(L) if(L) L.Cut()
///Returns the list if it's actually a valid list, otherwise will initialize it
#define SANITIZE_LIST(L) ( islist(L) ? L : list() )
#define reverseList(L) reverseRange(L.Copy())
/// Performs an insertion on the given lazy list with the given key and value. If the value already exists, a new one will not be made.
#define LAZYORASSOCLIST(lazy_list, key, value) \
	LAZYINITLIST(lazy_list); \
	LAZYINITLIST(lazy_list[key]); \
	lazy_list[key] |= value;
///Adds to the item K the value V, if the list is null it will initialize it
#define LAZYADDASSOC(L, K, V) if(!L) { L = list(); } L[K] += V;
///Removes the value V from the item K, if the item K is empty will remove it from the list, if the list is empty will set the list to null
#define LAZYREMOVEASSOC(L, K, V) if(L) { if(L[K]) { L[K] -= V; if(!length(L[K])) L -= K; } if(!length(L)) L = null; }

///Ensures the length of a list is at least I, prefilling it with V if needed. if V is a proc call, it is repeated for each new index so that list() can just make a new list for each item.
#define LISTASSERTLEN(L, I, V...) \
	if (length(L) < I) { \
		var/_OLD_LENGTH = length(L); \
		L.len = I; \
		/* Convert the optional argument to a if check */ \
		for (var/_USELESS_VAR in list(V)) { \
			for (var/_INDEX_TO_ASSIGN_TO in _OLD_LENGTH+1 to I) { \
				L[_INDEX_TO_ASSIGN_TO] = V; \
			} \
		} \
	}

/// Passed into BINARY_INSERT to compare keys
#define COMPARE_KEY __BIN_LIST[__BIN_MID]
/// Passed into BINARY_INSERT to compare values
#define COMPARE_VALUE __BIN_LIST[__BIN_LIST[__BIN_MID]]

/****
	* Binary search sorted insert
	* INPUT: Object to be inserted
	* LIST: List to insert object into
	* TYPECONT: The typepath of the contents of the list
	* COMPARE: The object to compare against, usualy the same as INPUT
	* COMPARISON: The variable on the objects to compare
	* COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
	*/
#define BINARY_INSERT(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON <= COMPARE.##COMPARISON) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON > COMPARE.##COMPARISON ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

/**
 * Custom binary search sorted insert utilising comparison procs instead of vars.
 * INPUT: Object to be inserted
 * LIST: List to insert object into
 * TYPECONT: The typepath of the contents of the list
 * COMPARE: The object to compare against, usualy the same as INPUT
 * COMPARISON: The plaintext name of a proc on INPUT that takes a single argument to accept a single element from LIST and returns a positive, negative or zero number to perform a comparison.
 * COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
 */
#define BINARY_INSERT_PROC_COMPARE(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON(COMPARE) <= 0) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON(COMPARE) > 0 ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

#define SORT_FIRST_INDEX(list) (list[1])
#define SORT_COMPARE_DIRECTLY(thing) (thing)
#define SORT_VAR_NO_TYPE(varname) var/varname
/****
	* Even more custom binary search sorted insert, using defines instead of vars
	* INPUT: Item to be inserted
	* LIST: List to insert INPUT into
	* TYPECONT: A define setting the var to the typepath of the contents of the list
	* COMPARE: The item to compare against, usualy the same as INPUT
	* COMPARISON: A define that takes an item to compare as input, and returns their comparable value
	* COMPTYPE: How should the list be compared? Either COMPARE_KEY or COMPARE_VALUE.
	*/
#define BINARY_INSERT_DEFINE(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			##TYPECONT(__BIN_ITEM);\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(##COMPARISON(__BIN_ITEM) <= ##COMPARISON(COMPARE)) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = ##COMPARISON(__BIN_ITEM) > ##COMPARISON(COMPARE) ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

/// Returns a list in plain english as a string
/proc/english_list(list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = input.len
	if (!total)
		return "[nothing_text]"
	else if (total == 1)
		return "[input[1]]"
	else if (total == 2)
		return "[input[1]][and_text][input[2]]"
	else
		var/output = ""
		var/index = 1
		while (index < total)
			if (index == total - 1)
				comma_text = final_comma_text

			output += "[input[index]][comma_text]"
			index++

		return "[output][and_text][input[index]]"

/// Returns list element or null. Should prevent "index out of bounds" error.
/proc/listgetindex(list/L, index)
	if(LAZYLEN(L))
		if(isnum(index) && ISINTEGER(index))
			if(ISINRANGE(index,1,L.len))
				return L[index]
		else if(index in L)
			return L[index]
	return

/// Return either pick(list) or null if list is not of type /list or is empty
/proc/safepick(list/L)
	if(LAZYLEN(L))
		return pick(L)

/// Checks if the list is empty
/proc/isemptylist(list/L)
	if(!L.len)
		return TRUE
	return FALSE

/// Checks for specific types in a list
/proc/is_type_in_list(atom/A, list/L)
	if(!LAZYLEN(L) || !A)
		return FALSE
	for(var/type in L)
		if(istype(A, type))
			return TRUE
	return FALSE

/// Checks for specific types in specifically structured (Assoc "type" = TRUE) lists ('typecaches')
#define is_type_in_typecache(A, L) (A && length(L) && L[(ispath(A) ? A : A:type)])

/// Checks for a string in a list
/proc/is_string_in_list(string, list/L)
	if(!LAZYLEN(L) || !string)
		return
	for(var/V in L)
		if(string == V)
			return TRUE
	return

/// Removes a string from a list
/proc/remove_strings_from_list(string, list/L)
	if(!LAZYLEN(L) || !string)
		return
	for(var/V in L)
		if(V == string)
			L -= V //No return here so that it removes all strings of that type
	return

/// returns a new list with only atoms that are in typecache L
/proc/typecache_filter_list(list/atoms, list/typecache)
	RETURN_TYPE(/list)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if (typecache[A.type])
			. += A

/// returns a new list with only atoms that are not in typecache L
/proc/typecache_filter_list_reverse(list/atoms, list/typecache)
	RETURN_TYPE(/list)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if(!typecache[A.type])
			. += A

/proc/typecache_filter_multi_list_exclusion(list/atoms, list/typecache_include, list/typecache_exclude)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if(typecache_include[A.type] && !typecache_exclude[A.type])
			. += A

/// Like typesof() or subtypesof(), but returns a typecache instead of a list
/proc/typecacheof(path, ignore_root_path, only_root_path = FALSE)
	if(ispath(path))
		var/list/types = list()
		if(only_root_path)
			types = list(path)
		else
			types = ignore_root_path ? subtypesof(path) : typesof(path)
		var/list/L = list()
		for(var/T in types)
			L[T] = TRUE
		return L
	else if(islist(path))
		var/list/pathlist = path
		var/list/L = list()
		if(ignore_root_path)
			for(var/P in pathlist)
				for(var/T in subtypesof(P))
					L[T] = TRUE
		else
			for(var/P in pathlist)
				if(only_root_path)
					L[P] = TRUE
				else
					for(var/T in typesof(P))
						L[T] = TRUE
		return L

/// Empties the list by setting the length to 0. Hopefully the elements get garbage collected
/proc/clearlist(list/list)
	if(istype(list))
		list.len = 0
	return

//Removes any null entries from the list
//Returns TRUE if the list had nulls, FALSE otherwise
/proc/listclearnulls(list/L)
	return (L.RemoveAll(null) > 0)

/*
 * Returns list containing all the entries from first list that are not present in second.
 * If skiprep = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/difflist(list/first, list/second, skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		for(var/e in first)
			if(!(e in result) && !(e in second))
				result += e
	else
		result = first - second
	return result

/*
 * Returns list containing entries that are in either list but not both.
 * If skipref = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/uniquemergelist(list/first, list/second, skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		result = difflist(first, second, skiprep)+difflist(second, first, skiprep)
	else
		result = first ^ second
	return result

//Picks a random element from a list based on a weighting system:
//1. Adds up the total of weights for each element
//2. Gets a number between 1 and that total
//3. For each element in the list, subtracts its weighting from that number
//4. If that makes the number 0 or less, return that element.
/proc/pickweight(list/L)
	var/total = 0
	var/item
	for (item in L)
		if (!L[item])
			L[item] = 1
		total += L[item]

	total *= rand() // Yogs -- Allows for noninteger weights
	for (item in L)
		total -=L [item]
		if (total <= 0)
			return item

	return null

/proc/pickweightAllowZero(list/L) //The original pickweight proc will sometimes pick entries with zero weight.  I'm not sure if changing the original will break anything, so I left it be.
	var/total = 0
	var/item
	for (item in L)
		if (L[item] <= 0)//edited to also allow negatives
			continue //edited to not modify the input list
		total += L[item]

	total = rand(0, total)
	for (item in L)
		if (L[item] <= 0) //edited to skip all numbers not actually added to the total
			continue
		total -= L[item]
		if (total <= 0 && L[item])
			return item

	return null


/**
 * Given a list, return a copy where values without defined weights are given weight 1.
 * For example, fill_with_ones(list(A, B=2, C)) = list(A=1, B=2, C=1)
 * Useful for weighted random choices (loot tables, syllables in languages, etc.)
 */
/proc/fill_with_ones(list/list_to_pad)
	if (!islist(list_to_pad))
		return list_to_pad

	var/list/final_list = list()

	for (var/key in list_to_pad)
		if (list_to_pad[key])
			final_list[key] = list_to_pad[key]
		else
			final_list[key] = 1

	return final_list

/// Takes a weighted list (see above) and expands it into raw entries
/// This eats more memory, but saves time when actually picking from it
/proc/expand_weights(list/list_to_pick)
	if(!length(list_to_pick))
		return list()
	var/list/values = list()
	for(var/item in list_to_pick)
		var/value = list_to_pick[item]
		if(!value)
			continue
		values += value

	var/gcf = greatest_common_factor(values)

	var/list/output = list()
	for(var/item in list_to_pick)
		var/value = list_to_pick[item]
		if(!value)
			continue
		for(var/i in 1 to value / gcf)
			output += item
	return output

/// Takes a list of numbers as input, returns the highest value that is cleanly divides them all
/// Note: this implementation is expensive as heck for large numbers, I only use it because most of my usecase
/// Is < 10 ints
/proc/greatest_common_factor(list/values)
	//Old implementation of this used var/smallest = min(argslist(values)), BUT this doesnt work for large lists! causing byond to spiral down into exception hell hole, THIS works!
	var/smallest = INFINITY
	for(var/entry in values)
		if(entry < smallest)
			smallest = entry

	for(var/i in smallest to 1 step -1)
		var/safe = TRUE
		for(var/entry in values)
			if(entry % i != 0)
				safe = FALSE
				break
		if(safe)
			return i

/// Pick a random element from the list and remove it from the list.
/proc/pick_n_take(list/L)
	RETURN_TYPE(L[_].type)
	if(L.len)
		var/picked = rand(1,L.len)
		. = L[picked]
		L.Cut(picked,picked+1)			//Cut is far more efficient that Remove()

/// Pick a random element from the list and remove it from the list.
/proc/pick_n_take_weighted(list/list_to_pick)
	if(length(list_to_pick))
		var/picked = pick_weight(list_to_pick)
		list_to_pick -= picked
		return picked

/// Returns the top(last) element from the list and removes it from the list (typical stack function)
/proc/pop(list/L)
	if(L.len)
		. = L[L.len]
		L.len--

/// Returns the bottom(first) element from the list and removes it from the list (typical stack function)
/proc/popleft(list/L)
	if(L.len)
		. = L[1]
		L.Cut(1,2)

/proc/sorted_insert(list/L, thing, comparator)
	var/pos = L.len
	while(pos > 0 && call(comparator)(thing, L[pos]) > 0)
		pos--
	L.Insert(pos+1, thing)

/// Returns the next item in a list
/proc/next_list_item(item, list/L)
	var/i
	i = L.Find(item)
	if(i == L.len)
		i = 1
	else
		i++
	return L[i]

/// Returns the previous item in a list
/proc/previous_list_item(item, list/L)
	var/i
	i = L.Find(item)
	if(i == 1)
		i = L.len
	else
		i--
	return L[i]

/// Randomize: Return the list in a random order
/proc/shuffle(list/L)
	if(!L)
		return
	L = L.Copy()

	for(var/i=1, i<L.len, ++i)
		L.Swap(i,rand(i,L.len))

	return L

/// Same as shuffle, but returns nothing and acts on list in place
/proc/shuffle_inplace(list/L)
	if(!L)
		return

	for(var/i=1, i<L.len, ++i)
		L.Swap(i,rand(i,L.len))

/// Returns a list without duplicate entrys
/proc/uniqueList(list/L)
	. = list()
	for(var/i in L)
		. |= i

//same, but returns nothing and acts on list in place (also handles associated values properly)
/proc/uniqueList_inplace(list/L)
	var/temp = L.Copy()
	L.len = 0
	for(var/key in temp)
		if (isnum(key))
			L |= key
		else
			L[key] = temp[key]

/// Sort a list by CKEY
/proc/sortKey(list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_ckey_asc : /proc/cmp_ckey_dsc)

/// Sort datum records in a list
/proc/sortRecord(list/L, field = "name", order = 1)
	GLOB.cmp_field = field
	return sortTim(L, order >= 0 ? /proc/cmp_records_asc : /proc/cmp_records_dsc)

//any value in a list
/proc/sortList(list/L, cmp=/proc/cmp_text_asc)
	return sortTim(L.Copy(), cmp)

//uses sortList() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sortNames(list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_name_asc : /proc/cmp_name_dsc)

/proc/sortUsernames(list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_username_asc : /proc/cmp_username_dsc)

///Converts a bitfield to a list of numbers (or words if a wordlist is provided)
/proc/bitfield_to_list(bitfield = 0, list/wordlist)
	var/list/return_list = list()
	if(islist(wordlist))
		var/max = min(wordlist.len, 24)
		var/bit = 1
		for(var/i in 1 to max)
			if(bitfield & bit)
				return_list += wordlist[i]
			bit = bit << 1
	else
		for(var/bit_number = 0 to 23)
			var/bit = 1 << bit_number
			if(bitfield & bit)
				return_list += bit

	return return_list

/// Returns the key based on the index
#define KEYBYINDEX(L, index) (((index <= length(L)) && (index > 0)) ? L[index] : null)

/proc/count_by_type(list/L, type)
	var/i = 0
	for(var/T in L)
		if(istype(T, type))
			i++
	return i

/// Find a datum record from a list
/proc/find_record(field, value, list/L)
	for(var/datum/data/record/R in L)
		if(R.fields[field] == value)
			return R
	return FALSE


//Move a single element from position fromIndex within a list, to position toIndex
//All elements in the range [1,toIndex) before the move will be before the pivot afterwards
//All elements in the range [toIndex, L.len+1) before the move will be after the pivot afterwards
//In other words, it's as if the range [fromIndex,toIndex) have been rotated using a <<< operation common to other languages.
//fromIndex and toIndex must be in the range [1,L.len+1]
//This will preserve associations ~Carnie
/proc/moveElement(list/L, fromIndex, toIndex)
	if(fromIndex == toIndex || fromIndex+1 == toIndex)	//no need to move
		return
	if(fromIndex > toIndex)
		++fromIndex	//since a null will be inserted before fromIndex, the index needs to be nudged right by one

	L.Insert(toIndex, null)
	L.Swap(fromIndex, toIndex)
	L.Cut(fromIndex, fromIndex+1)


//Move elements [fromIndex,fromIndex+len) to [toIndex-len, toIndex)
//Same as moveElement but for ranges of elements
//This will preserve associations ~Carnie
/proc/moveRange(list/L, fromIndex, toIndex, len=1)
	var/distance = abs(toIndex - fromIndex)
	if(len >= distance)	//there are more elements to be moved than the distance to be moved. Therefore the same result can be achieved (with fewer operations) by moving elements between where we are and where we are going. The result being, our range we are moving is shifted left or right by dist elements
		if(fromIndex <= toIndex)
			return	//no need to move
		fromIndex += len	//we want to shift left instead of right

		for(var/i=0, i<distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex+1)
	else
		if(fromIndex > toIndex)
			fromIndex += len

		for(var/i=0, i<len, ++i)
			L.Insert(toIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(fromIndex, fromIndex+1)

//Move elements from [fromIndex, fromIndex+len) to [toIndex, toIndex+len)
//Move any elements being overwritten by the move to the now-empty elements, preserving order
//Note: if the two ranges overlap, only the destination order will be preserved fully, since some elements will be within both ranges ~Carnie
/proc/swapRange(list/L, fromIndex, toIndex, len=1)
	var/distance = abs(toIndex - fromIndex)
	if(len > distance)	//there is an overlap, therefore swapping each element will require more swaps than inserting new elements
		if(fromIndex < toIndex)
			toIndex += len
		else
			fromIndex += len

		for(var/i=0, i<distance, ++i)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex+1)
	else
		if(toIndex > fromIndex)
			var/a = toIndex
			toIndex = fromIndex
			fromIndex = a

		for(var/i=0, i<len, ++i)
			L.Swap(fromIndex++, toIndex++)

//replaces reverseList ~Carnie
/proc/reverseRange(list/L, start=1, end=0)
	if(L.len)
		start = start % L.len
		end = end % (L.len+1)
		if(start <= 0)
			start += L.len
		if(end <= 0)
			end += L.len + 1

		--end
		while(start < end)
			L.Swap(start++,end--)

	return L

// /tg/ compat
#define reverse_range(args...) reverseRange(args)

//return first thing in L which has var/varname == value
//this is typecaste as list/L, but you could actually feed it an atom instead.
//completely safe to use
/proc/getElementByVar(list/L, varname, value)
	varname = "[varname]"
	for(var/datum/D in L)
		if(D.vars.Find(varname))
			if(D.vars[varname] == value)
				return D

/// remove all nulls from a list
/proc/removeNullsFromList(list/L)
	while(L.Remove(null))
		continue
	return L

//Copies a list, and all lists inside it recusively
//Does not copy any other reference type
/proc/deepCopyList(list/l)
	if(!islist(l))
		return l
	. = l.Copy()
	for(var/i = 1 to l.len)
		var/key = .[i]
		if(isnum(key))
			// numbers cannot ever be associative keys
			continue
		var/value = .[key]
		if(islist(value))
			value = deepCopyList(value)
			.[key] = value
		if(islist(key))
			key = deepCopyList(key)
			.[i] = key
			.[key] = value

//takes an input_key, as text, and the list of keys already used, outputting a replacement key in the format of "[input_key] ([number_of_duplicates])" if it finds a duplicate
//use this for lists of things that might have the same name, like mobs or objects, that you plan on giving to a player as input
/proc/avoid_assoc_duplicate_keys(input_key, list/used_key_list)
	if(!input_key || !istype(used_key_list))
		return
	if(used_key_list[input_key])
		used_key_list[input_key]++
		input_key = "[input_key] ([used_key_list[input_key]])"
	else
		used_key_list[input_key] = 1
	return input_key

//Flattens a keyed list into a list of it's contents
/proc/flatten_list(list/key_list)
	if(!islist(key_list))
		return null
	. = list()
	for(var/key in key_list)
		. |= key_list[key]

/proc/make_associative(list/flat_list)
	. = list()
	for(var/thing in flat_list)
		.[thing] = TRUE

//Picks from the list, with some safeties, and returns the "default" arg if it fails
#define DEFAULTPICK(L, default) ((islist(L) && length(L)) ? pick(L) : default)

/* Definining a counter as a series of key -> numeric value entries

 * All these procs modify in place.
*/

/proc/counterlist_scale(list/L, scalar)
	var/list/out = list()
	for(var/key in L)
		out[key] = L[key] * scalar
	. = out

/proc/counterlist_sum(list/L)
	. = 0
	for(var/key in L)
		. += L[key]

/proc/counterlist_normalise(list/L)
	var/avg = counterlist_sum(L)
	if(avg != 0)
		. = counterlist_scale(L, 1 / avg)
	else
		. = L

/proc/counterlist_combine(list/L1, list/L2)
	for(var/key in L2)
		var/other_value = L2[key]
		if(key in L1)
			L1[key] += other_value
		else
			L1[key] = other_value

/// Turns an associative list into a flat list of keys
/proc/assoc_to_keys(list/input)
	var/list/keys = list()
	for(var/key in input)
		keys += key
	return keys

/proc/compare_list(list/l,list/d)
	if(!islist(l) || !islist(d))
		return FALSE

	if(l.len != d.len)
		return FALSE

	for(var/i in 1 to l.len)
		if(l[i] != d[i])
			return FALSE

	return TRUE

///sort any value in a list
/proc/sort_list(list/list_to_sort, cmp=/proc/cmp_text_asc)
	return sortTim(list_to_sort.Copy(), cmp)

///uses sort_list() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sort_names(list/list_to_sort, order=1)
	return sortTim(list_to_sort.Copy(), order >= 0 ? GLOBAL_PROC_REF(cmp_name_asc) : GLOBAL_PROC_REF(cmp_name_dsc))

/// Runtimes if the passed in list is not sorted
/proc/assert_sorted(list/list, name, cmp = GLOBAL_PROC_REF(cmp_numeric_asc))
	var/last_value = list[1]

	for (var/index in 2 to list.len)
		var/value = list[index]

		if (call(cmp)(value, last_value) < 0)
			stack_trace("[name] is not sorted. value at [index] ([value]) is in the wrong place compared to the previous value of [last_value] (when compared to by [cmp])")

		last_value = value

/// Compares 2 lists, returns TRUE if they are the same
/proc/deep_compare_list(list/list_1, list/list_2)
	if(!islist(list_1) || !islist(list_2))
		return FALSE

	if(list_1 == list_2)
		return TRUE

	if(list_1.len != list_2.len)
		return FALSE

	for(var/i in 1 to list_1.len)
		var/key_1 = list_1[i]
		var/key_2 = list_2[i]
		if (islist(key_1) && islist(key_2))
			if(!deep_compare_list(key_1, key_2))
				return FALSE
		else if(key_1 != key_2)
			return FALSE
		if(istext(key_1) || islist(key_1) || ispath(key_1) || isdatum(key_1) || key_1 == world)
			var/value_1 = list_1[key_1]
			var/value_2 = list_2[key_1]
			if (islist(value_1) && islist(value_2))
				if(!deep_compare_list(value_1, value_2))
					return FALSE
			else if(value_1 != value_2)
				return FALSE
	return TRUE

/**
 * Picks a random element from a list based on a weighting system.
 * For example, given the following list:
 * A = 6, B = 3, C = 1, D = 0
 * A would have a 60% chance of being picked,
 * B would have a 30% chance of being picked,
 * C would have a 10% chance of being picked,
 * and D would have a 0% chance of being picked.
 * You should only pass integers in.
 */
/proc/pick_weight(list/list_to_pick)
	var/total = 0
	var/item
	for(item in list_to_pick)
		if(!list_to_pick[item])
			list_to_pick[item] = 0
		total += list_to_pick[item]

	total = rand(1, total)
	for(item in list_to_pick)
		total -= list_to_pick[item]
		if(total <= 0 && list_to_pick[item])
			return item

	return null

/// ORs two lazylists together without inserting errant nulls, returning a new list and not modifying the existing lists.
#define LAZY_LISTS_OR(left_list, right_list)\
	(length(left_list)\
		? length(right_list)\
			? (left_list | right_list)\
			: left_list.Copy()\
		: length(right_list)\
			? right_list.Copy()\
			: null\
	)
