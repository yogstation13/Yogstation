/datum/stack
	var/list/contents = new

/datum/stack/proc/Push(value)
	contents += value

/datum/stack/proc/Pop()
	if(!length(contents))
		return null
	. = contents[length(contents)]
	contents.len--

///returns the item on the top of the stack without removing it
/datum/stack/proc/Top()
	if(!length(contents))
		return null
	return contents[length(contents)]

/datum/stack/proc/Copy() as /datum/stack
	var/datum/stack/new_stack = new()
	new_stack.contents = contents.Copy()
	return new_stack

/datum/stack/proc/Clear()
	contents.Cut()
