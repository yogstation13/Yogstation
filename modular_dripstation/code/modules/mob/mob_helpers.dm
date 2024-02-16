/proc/stars(n, pr)
	n = html_encode(n)
	if (pr == null)
		pr = 25
	if (pr <= 0)
		return null
	else
		if (pr >= 100)
			return n
	var/te = n
	var/t = ""
	n = length_char(n)

	for(var/p = 1 to min(n,MAX_BROADCAST_LEN))
		if ((copytext_char(te, p, p + 1) == " " || prob(pr)))
			t = text("[][]", t, copytext_char(te, p, p + 1))
		else
			t = text("[]*", t)
	if(n > MAX_BROADCAST_LEN)
		t += "..." //signals missing text
	return sanitize(t)
/**
  * Makes you speak like you're drunk
  */
/proc/slur(phrase)
	phrase = html_decode(phrase)
	var/leng = length_char(phrase)
	. = ""
	var/newletter = ""
	var/rawchar = ""
	for(var/i = 1, i <= leng, i += length_char(rawchar))
		rawchar = newletter = phrase[i]
		if(rand(1, 3) == 3)
			var/lowerletter = lowertext(newletter)
			if(lowerletter == "o")
				newletter = "u"
			else if(lowerletter == "s")
				newletter = "ch"
			else if(lowerletter == "a")
				newletter = "ah"
			else if(lowerletter == "u")
				newletter = "oo"
			else if(lowerletter == "c")
				newletter = "k"
			else if(lowerletter == "о")
				newletter ="у"
			else if(lowerletter =="с")
				newletter ="ч"
			else if(lowerletter == "а")
				newletter ="ах"
			else if(lowerletter == "ц")
				newletter ="к"
			else if(lowerletter == "э")
				newletter ="о"
			else if(lowerletter == "г")
				newletter ="х"
		if(rand(1, 20) == 20)
			if(newletter == " ")
				newletter = "...эээааааээа..."
			else if(newletter == ".")
				newletter = " *РЫГ*."
		switch(rand(1, 20))
			if(1)
				newletter += "'"
			if(10)
				newletter += "[newletter]"
			if(20)
				newletter += "[newletter][newletter]"
			else
				newletter += ""
		. += "[newletter]"
	return sanitize(.)

/// Makes you talk like you got cult stunned, which is slurring but with some dark messages
/proc/cultslur(phrase) // Inflicted on victims of a stun talisman
	phrase = html_decode(phrase)
	var/leng = length_char(phrase)
	. = ""
	var/newletter = ""
	var/rawchar = ""
	for(var/i = 1, i <= leng, i += length_char(rawchar))
		rawchar = newletter = phrase[i]
		if(rand(1, 2) == 2)
			var/lowerletter = lowertext(newletter)
			if(lowerletter == "о")
				newletter = "у"
			else if(lowerletter == "т")
				newletter = "ч"
			else if(lowerletter == "а")
				newletter = "ах"
			else if(lowerletter == "c")
				newletter = " НАР "
			else if(lowerletter == "с")
				newletter = " СИ "
		if(rand(1, 4) == 4)
			if(newletter == " ")
				newletter = " нет надежды... "
			else if(newletter == "Х")
				newletter = " ОНО ИДЁТ... "

		switch(rand(1, 15))
			if(1)
				newletter = "'"
			if(2)
				newletter += "агн"
			if(3)
				newletter = "фз"
			if(4)
				newletter = "нглу"
			if(5)
				newletter = "глор"
			else
				newletter += ""
		. += newletter
	return sanitize(.)

///Adds stuttering to the message passed in
/proc/stutter(phrase)
	phrase = html_decode(phrase)
	var/leng = length(phrase)
	. = ""
	var/newletter = ""
	var/rawchar
	for(var/i = 1, i <= leng, i += length(rawchar))
		rawchar = newletter = phrase[i]
		if(prob(80) && !(lowertext(newletter) in list("а", "е", "и", "о", "у", " ")))
			if(prob(10))
				newletter = "[newletter]-[newletter]-[newletter]-[newletter]"
			else if(prob(20))
				newletter = "[newletter]-[newletter]-[newletter]"
			else if (prob(5))
				newletter = ""
			else
				newletter = "[newletter]-[newletter]"
		. += newletter
	return sanitize(.)

///Convert a message to derpy speak
/proc/derpspeech(message, stuttering)
	message = replacetext(message, " я ", " ")
	message = replacetext(message, " есть ", " ")
	message = replacetext(message, " ты ", "ти")
	message = replacetext(message, "помогите", "памагити")
	message = replacetext(message, "grief", "grife")
	message = replacetext(message, "космос", "spess")
	message = replacetext(message, "карп", "крип")
	message = replacetext(message, "причина", "почини")
	if(prob(50))
		message = uppertext(message)
		message += "[stutter(pick("!", "!!", "!!!"))]"
	if(!stuttering && prob(15))
		message = stutter(message)
	return message

/proc/lizardspeech(message)
	var/static/regex/lizard_hiss = new("с+", "г")
	var/static/regex/lizard_hiSS = new("С+", "г")
	if(message[1] != "*")
		message = lizard_hiss.Replace(message, "ссс")
		message = lizard_hiSS.Replace(message, "ССС")
	return message

/**
  * Turn text into complete gibberish!
  *
  * text is the inputted message, and any value higher than 70 for chance will cause letters to be replaced instead of added
  */
/proc/Gibberish(text, replace_characters = FALSE, chance = 50)
	text = html_decode(text)
	. = ""
	var/rawchar = ""
	var/letter = ""
	var/lentext = length_char(text)
	for(var/i = 1, i <= lentext, i += length_char(rawchar))
		rawchar = letter = text[i]
		if(prob(chance))
			if(replace_characters)
				letter = ""
			for(var/j in 1 to rand(0, 2))
				letter += pick("#", "@", "*", "&", "%", "$", "/", "<", ">", ";", "*", "*", "*", "*", "*", "*", "*")
		. += letter
	return sanitize(.)
