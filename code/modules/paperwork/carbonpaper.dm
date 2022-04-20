/obj/item/paper/carbon
	name = "paper"
	icon_state = "paper_stack"
	item_state = "paper"
	icon = 'icons/obj/bureaucracy.dmi'
	var/copied = FALSE
	var/iscopy = FALSE


/obj/item/paper/carbon/update_icon()
	if(iscopy)
		if(written.len)
			icon_state = "cpaper_words"
			return
		icon_state = "cpaper"
	else if (copied)
		if(written.len)
			icon_state = "paper_words"
			return
		icon_state = "paper"
	else
		if(written.len)
			icon_state = "paper_stack_words"
			return
		icon_state = "paper_stack"

/obj/item/paper/carbon/verb/removecopy()
	set name = "Remove carbon copy"
	set category = "Object"
	set src in usr

	if (!copied)
		var/obj/item/paper/carbon/copy = new /obj/item/paper/carbon (loc)
		var/copyinfo = info
		copyinfo = clearcolor(copyinfo)
		copy.info += copyinfo + "</font>"
		//Now for copying the new $written var
		for(var/L in written)
			if(istype(L,/datum/langtext))
				var/datum/langtext/oldL = L
				var/datum/langtext/newL = new(clearcolor(oldL.text),oldL.lang)
				copy.written += newL
			else
				copy.written += L
		copy.name = name
		copy.fields = fields
		copy.stamps = stamps
		if(stamped)
			copy.stamped = stamped.Copy()
		copy.copy_overlays(src, TRUE)

		copied = TRUE
		copy.copied = TRUE
		copy.iscopy = TRUE
		update_icon()
		copy.update_icon()
		usr.put_in_hands(copy)
	else
		to_chat(usr, span_warning("There are no more carbon copies attached to this paper!"))

/obj/item/paper/carbon/proc/clearcolor(text) // Breaks all font color spans in the HTML text.
	return replacetext(replacetext(text, "<font face=\"[CRAYON_FONT]\" color=", "<font face=\"[CRAYON_FONT]\" nocolor="), "<font face=\"[PEN_FONT]\" color=", "<font face=\"[PEN_FONT]\" nocolor=") //This basically just breaks the existing color tag, which we need to do because the innermost tag takes priority.
