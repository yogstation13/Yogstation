/client/proc/debug_typeof()
	set name = "List-Subtypes" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set desc = "Lists the subtypes of the type you input."
	set category = "Misc.Server Debug"

	if(!check_rights(R_DEBUG))
		return

	var/msg = input("Enter the type you want the subtypes of (Example: /obj/effect/hallucination)","Subtype List") as text|null
	if(!msg)
		return

	var/list/a = subtypesof(msg)
	if(!a.len)
		to_chat(src,"<span class='warning'>That type doesn't seem to exist!</span>", confidential=TRUE)
		return
	if(a.len > 100)
		if(alert("That type has [a.len] derived types. Are you sure you want to have all of them spammed into your chatbox?",,"Yes","No") != "Yes")
			return

	to_chat(usr,"<span class='notice'>Subtypes of [msg] ([a.len] Entries):</span>", confidential=TRUE)
	for(var/x in a)
		to_chat(usr,"[x]", confidential=TRUE)
