/obj/item/folder
	name = "folder"
	desc = "A folder."
	icon = 'yogstation/icons/obj/bureaucracy.dmi'
	icon_state = "folder"
	w_class = WEIGHT_CLASS_SMALL
	pressure_resistance = 2
	resistance_flags = FLAMMABLE

/obj/item/folder/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins filing an imaginary death warrant! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/folder/blue
	desc = "A blue folder."
	icon_state = "folder_blue"

/obj/item/folder/red
	desc = "A red folder."
	icon_state = "folder_red"

/obj/item/folder/yellow
	desc = "A yellow folder."
	icon_state = "folder_yellow"

/obj/item/folder/white
	desc = "A white folder."
	icon_state = "folder_white"


/obj/item/folder/update_overlays()
	. = ..()
	if(contents.len)
		. += "folder_paper"


/obj/item/folder/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/paper) || istype(W, /obj/item/photo) || istype(W, /obj/item/documents))
		if(!user.transferItemToLoc(W, src))
			return
		to_chat(user, span_notice("You put [W] into [src]."))
		update_appearance(UPDATE_ICON)
	else if(istype(W, /obj/item/pen))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the cover of [src]!"))
			return
		var/inputvalue = stripped_input(user, "What would you like to label the folder?", "Folder Labelling", "", MAX_NAME_LEN)

		if(!inputvalue)
			return

		if(user.canUseTopic(src, BE_CLOSE))
			name = "folder[(inputvalue ? " - '[inputvalue]'" : null)]"


/obj/item/folder/attack_self(mob/user)
	var/dat = "<HTML><HEAD><meta charset='UTF-8'><title>[name]</title></HEAD><BODY>"

	for(var/obj/item/I in src)
		dat += "<A href='byond://?src=[REF(src)];remove=[REF(I)]'>Remove</A> - <A href='byond://?src=[REF(src)];read=[REF(I)]'>[I.name]</A><BR>"
	dat += "</BODY></HTML>"
	user << browse(dat, "window=folder")
	onclose(user, "folder")
	add_fingerprint(usr)

/obj/item/folder/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(contents.len)
		to_chat(user, span_warning("You can't fold this folder with something still inside!"))
		return
	to_chat(user, span_notice("You fold [src] flat."))
	var/obj/item/I = new /obj/item/stack/sheet/cardboard
	qdel(src)
	user.put_in_hands(I)

/obj/item/folder/Topic(href, href_list)
	..()
	if(usr.stat || usr.restrained())
		return

	if(usr.contents.Find(src))

		if(href_list["remove"])
			var/obj/item/I = locate(href_list["remove"]) in src
			if(istype(I))
				I.forceMove(usr.loc)
				usr.put_in_hands(I)

		if(href_list["read"])
			var/obj/item/I = locate(href_list["read"]) in src
			if(istype(I))
				usr.examinate(I)

		//Update everything
		attack_self(usr)
		update_appearance(UPDATE_ICON)

/obj/item/folder/documents
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of Nanotrasen Corporation. Unauthorized distribution is punishable by death.\""

/obj/item/folder/documents/Initialize(mapload)
	. = ..()
	new /obj/item/documents/nanotrasen(src)
	update_appearance(UPDATE_ICON)

/obj/item/folder/syndicate
	icon_state = "folder_syndie"
	name = "folder- 'TOP SECRET'"
	desc = "A folder stamped \"Top Secret - Property of The Syndicate.\""

/obj/item/folder/syndicate/red
	icon_state = "folder_sred"

/obj/item/folder/syndicate/red/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/red(src)
	update_appearance(UPDATE_ICON)

/obj/item/folder/syndicate/blue
	icon_state = "folder_sblue"

/obj/item/folder/syndicate/blue/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/blue(src)
	update_appearance(UPDATE_ICON)

/obj/item/folder/syndicate/mining/Initialize(mapload)
	. = ..()
	new /obj/item/documents/syndicate/mining(src)
	update_appearance(UPDATE_ICON)
