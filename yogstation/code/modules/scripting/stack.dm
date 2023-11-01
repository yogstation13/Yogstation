/datum/stack
	var/list/contents = new

/datum/stack/proc/Push(value)
	contents += value

/datum/stack/proc/Pop()
	if(!contents.len)
		return null
	. = contents[contents.len]
	contents.len--

///returns the item on the top of the stack without removing it
/datum/stack/proc/Top()
	if(!contents.len)
		return null
	return contents[contents.len]

/datum/stack/proc/Copy()
	var/datum/stack/new_stack = new()
	new_stack.contents = contents.Copy()
	return new_stack

/datum/stack/proc/Clear()
	contents.Cut()
