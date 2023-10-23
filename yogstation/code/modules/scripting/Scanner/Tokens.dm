//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*
	Class: Token
	Represents an entity and position in the source code.
*/
/datum/token
	var/value
	var/line
	var/column

/datum/token/New(v, l = 0, c = 0)
	value = v
	line = l
	column = c

/datum/token/string

/datum/token/symbol

/datum/token/word

/datum/token/keyword

/datum/token/number

/datum/token/number/New()
	. = ..()
	if(isnum(value))
		return
	value=text2num(value)
	ASSERT(!isnull(value))

/datum/token/end
