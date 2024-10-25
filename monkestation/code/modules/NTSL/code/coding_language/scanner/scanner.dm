#define COLUMN_LOCATION (codepos-linepos)

/*
 * n_Scanner
 * An object responsible for breaking up source code into tokens for use by the parser.
 */
/datum/n_Scanner
	var/code
	///A list of fatal errors found by the scanner. If there are any items in this list, then it is not safe to parse the returned tokens.
	var/list/errors = new
	///A list of non-fatal problems in the source code found by the scanner.
	var/list/warnings = new

///Loads source code.
/datum/n_Scanner/proc/LoadCode(c)
	code = c

///Gets the code from a file and calls LoadCode()
/datum/n_Scanner/proc/LoadCodeFromFile(f)
	LoadCode(file2text(f))

///Runs the scanner and returns the resulting list of tokens. Ensure that <LoadCode()> has been called first.
/datum/n_Scanner/proc/Scan()

/*
 * nS_Scanner
 * A scanner implementation for n_Script.
 */
/datum/n_Scanner/nS_Scanner

	///The scanner's position in the source code.
	var/codepos = 1
	var/line = 1
	var/linepos = 0
	var/datum/n_scriptOptions/options

	///List of characters that end a statement. Each item may only be one character long. Default is a semicolon.
	var/list/end_stmt = list(";")
	///List of characters that are ignored by the scanner. Default is whitespace.
	var/list/ignore = list(" ", "\t", "\n")
	///List of characters that can start and end strings. Default is double and single quotes.
	var/list/string_delim = list("\"", "'")
	///List of characters that denote the start of a new token. This list is automatically populated.
	var/list/delim = new


/datum/n_Scanner/nS_Scanner/New(code, datum/n_scriptOptions/options)
	. = ..()
	src.options = options
	src.ignore += ascii2text(13) //Carriage return
	src.delim += ignore + options.symbols + end_stmt + string_delim
	LoadCode(code)

/datum/n_Scanner/nS_Scanner/Destroy(force)
	options = null
	return ..()

/datum/n_Scanner/nS_Scanner/Scan()
	var/list/datum/token/tokens = new
	for(, codepos <= length(code), codepos++)
		var/char = copytext(code, codepos, codepos + 1)
		var/twochar = copytext(code, codepos, codepos + 2) // For finding comment syntax
		if(char == "\n")
			line++
			linepos = codepos

		if(ignore.Find(char))
			continue
		else if(twochar == "//" || twochar == "/*")
			ReadComment()
		else if(end_stmt.Find(char))
			tokens += new /datum/token/end(char, line, COLUMN_LOCATION)
		else if(string_delim.Find(char))
			codepos++ //skip string delimiter
			tokens += ReadString(char)
		else if(options.CanStartID(char))
			tokens += ReadWord()
		else if(options.IsDigit(char))
			tokens += ReadNumber()
		else if(options.symbols.Find(char))
			tokens += ReadSymbol()

	codepos = initial(codepos)
	line = initial(line)
	linepos = initial(linepos)
	return tokens

/**
 * ReadString
 * Reads a string in the source code into a token.
 * Arguments:
 * start - The character used to start the string.
 */
/datum/n_Scanner/nS_Scanner/proc/ReadString(start)
	var/buf
	for(, codepos <= length(code), codepos++)//codepos to length(code))
		var/char = copytext(code, codepos, codepos + 1)
		switch(char)
			if("\\")					//Backslash (\) encountered in string
				codepos++ //Skip next character in string, since it was escaped by a backslash
				char = copytext(code, codepos, codepos + 1)
				switch(char)
					if("\\") //Double backslash
						buf += "\\"
					if("n")				//\n Newline
						buf += "\n"
					else
						if(char == start) //\" Doublequote
							buf += start
						else				//Unknown escaped text
							buf += char
			if("\n")
				. = new /datum/token/string(buf, line, COLUMN_LOCATION)
				errors += new /datum/scriptError("Unterminated string. Newline reached.", .)
				line++
				linepos = codepos
				break
			else
				if(char == start) //string delimiter found, end string
					break
				else
					buf += char //Just a normal character in a string
	if(!.)
		return new /datum/token/string(buf, line, COLUMN_LOCATION)

///Reads characters separated by an item in <delim> into a token.
/datum/n_Scanner/nS_Scanner/proc/ReadWord()
	var/char = copytext(code, codepos, codepos + 1)
	var/buf

	while(!delim.Find(char) && codepos <= length(code))
		buf += char
		char = copytext(code, ++codepos, codepos + 1)
	codepos-- //allow main Scan() proc to read the delimiter
	if(options.keywords.Find(buf))
		return new /datum/token/keyword(buf, line, COLUMN_LOCATION)
	else
		return new /datum/token/word(buf, line, COLUMN_LOCATION)

///Reads a symbol into a token.
/datum/n_Scanner/nS_Scanner/proc/ReadSymbol()
	var/char = copytext(code, codepos, codepos + 1)
	var/buf

	while(options.symbols.Find(buf+char))
		buf += char
		if(++codepos > length(code))
			break
		char = copytext(code, codepos, codepos + 1)

	codepos-- //allow main Scan() proc to read the next character
	return new /datum/token/symbol(buf, line, COLUMN_LOCATION)

///Reads a number into a token.
/datum/n_Scanner/nS_Scanner/proc/ReadNumber()
	var/char = copytext(code, codepos, codepos + 1)
	var/buf
	var/dec = 0

	while(options.IsDigit(char) || (char == "." && !dec))
		if(char == ".")
			dec = 1
		buf += char
		codepos++
		char = copytext(code, codepos, codepos + 1)
	var/datum/token/number/T = new(buf, line, COLUMN_LOCATION)
	if(isnull(text2num(buf)))
		errors += new /datum/scriptError("Bad number: ", T)
		T.value = 0
	codepos-- //allow main Scan() proc to read the next character
	return T

/*
 * ReadComment
 * Reads a comment. Wow.
 * I'm glad I wrote this proc description for you to explain that.
 * Unlike the other Read functions, this one doesn't have to return any tokens,
 * since it's just "reading" comments.
 * All it does is just pass var/codepos through the comments until it reaches the end of'em.
 */
/datum/n_Scanner/nS_Scanner/proc/ReadComment()
	// Remember that we still have that $codepos "pointer" variable to use.
	var/longeur = length(code) // So I don't call for var/code's length every while loop

	if(copytext(code, codepos, codepos + 2) == "//") // If line comment
		++codepos // Eat the current comment start, halfway
		while(++codepos <= longeur) // Second half of the eating, on the first eval
			if(copytext(code, codepos, codepos + 1) == "\n") // then stop on the newline
				line++
				linepos = codepos
				return
	else // If long comment
		++codepos // Eat the current comment start, halfway
		while(++codepos <= longeur) // Ditto, on the first eval
			if(copytext(code, codepos, codepos + 2) == "*/") // then stop on any */ 's'
				++codepos // Eat the comment end
				//but not all of it, because the for-loop this is in
				//will increment it again later.
				return
			else if(copytext(code, codepos, codepos + 1) == "\n") // We still have to count line numbers!
				line++
				linepos = codepos
		//Else if the longcomment didn't end, do an error
		errors += new /datum/scriptError/UnterminatedComment()

#undef COLUMN_LOCATION
