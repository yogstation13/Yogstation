/mob/proc/get_say()
	var/msg = input(src, null, "say \"text\"") as text
	say_verb(msg)