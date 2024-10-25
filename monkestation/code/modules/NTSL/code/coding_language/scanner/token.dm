/*
 * Token
 * Represents an entity and position in the source code.
 */
/datum/token
	var/value
	var/line
	var/column

/datum/token/New(value, line = 0, column = 0)
	src.value = value
	src.line = line
	src.column = column

/datum/token/string

/datum/token/symbol

/datum/token/word

/datum/token/keyword

/datum/token/number

/datum/token/number/New()
	. = ..()
	if(isnum(value))
		return
	src.value = text2num(value)
	ASSERT(!isnull(value))

/datum/token/end
