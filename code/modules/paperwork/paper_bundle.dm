/obj/item/paper_bundle
	name = "paper bundle"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = 1.0
	throw_range = 2
	throw_speed = 1
	layer = 4
	pressure_resistance = 1
	attack_verb = list("bapped")
	var/amount = 0 //Amount of items clipped to the paper
	var/page = 1
	var/screen = 0
	/// If this was sent via admin fax, allows anyone to see/interact with it
	var/admin_faxed = FALSE

/obj/item/paper_bundle/attackby(var/obj/item/W, var/mob/user)
	..()
	var/obj/item/paper/P
	if(istype(W, /obj/item/paper))
		P = W
		if (istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if (!C.iscopy && !C.copied)
				to_chat(user, span_notice("Take off the carbon copy first."))
				add_fingerprint(user)
				return
		amount++
		if(screen == 2)
			screen = 1
		to_chat(user, span_notice("You add [(P.name == "paper") ? "the paper" : P.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name]."))
		user.dropItemToGround(P)
		P.loc = src
	else if(istype(W, /obj/item/photo))
		amount++
		if(screen == 2)
			screen = 1
		to_chat(user, span_notice("You add [(W.name == "photo") ? "the photo" : W.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name]."))
		user.dropItemToGround(W)
		W.loc = src
	else if(W.is_hot())
		burnpaper(W, user)
	else if(istype(W, /obj/item/paper_bundle))
		user.dropItemToGround(W)
		for(var/obj/O in W)
			O.loc = src
			O.add_fingerprint(usr)
			src.amount++
			if(screen == 2)
				screen = 1
		to_chat(user, span_notice("You add \the [W.name] to [(src.name == "paper bundle") ? "the paper bundle" : src.name]."))
		qdel(W)
	else
		if(istype(W, /obj/item/pen) || istype(W, /obj/item/toy/crayon))
			usr << browse("", "window=[name]") //Closes the dialog
		P = src[page]
		P.attackby(W, user)
	update_icon()
	attack_self(usr) //Update the browsed page.
	add_fingerprint(usr)
	return

/obj/item/paper_bundle/proc/burnpaper(obj/item/P, mob/user)
	var/class = "<span class='warning'>"
	if(P.is_hot() && !user.restrained())
		if(istype(P, /obj/item/lighter))
			class = "<span class='rose'>"
		user.visible_message("[class][user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!</span>", \
		"[class]You hold \the [P] up to \the [src], burning it slowly.</span>")
		if(do_after(user, 2 SECONDS, src))
			user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
			"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")
			if(user.get_inactive_hand_index() == src)
				user.dropItemToGround(src)
			new /obj/effect/decal/cleanable/ash(src.loc)
			qdel(src)
		else
			to_chat(user, span_warning("You must hold \the [P] steady to burn \the [src]."))

/obj/item/paper_bundle/examine(mob/user)
	if(..(user, 1))
		src.show_content(user)
	else
		to_chat(user, span_notice("It is too far away."))
	return

/obj/item/paper_bundle/proc/show_content(mob/user as mob)
	var/dat
	var/obj/item/W = src[page]
	dat += "<DIV STYLE='float:left; text-align:left; width:33.33333%'><A href='?src=\ref[src];prev_page=1'>[screen != 0 ? "Previous Page" : ""]</DIV>"
	dat += "<DIV STYLE='float:left; text-align:center; width:33.33333%'><A href='?src=\ref[src];remove=1'>[admin_faxed ? "" : "Remove [(istype(W, /obj/item/paper)) ? "paper" : "photo"]"]</A></DIV>"
	dat += "<DIV STYLE='float:left; text-align:right; width:33.33333%'><A href='?src=\ref[src];next_page=1'>[screen != 2 ? "Next Page" : ""]</A></DIV><BR><HR>"
	if(istype(src[page], /obj/item/paper))
		var/obj/item/paper/P = W
		var/dist = get_dist(src, user)
		if(dist < 2 || admin_faxed)
			dat += "[P.render_body(user)]<HR>[P.stamps]"
		else 
			dat += "[stars(P.render_body(user))]<HR>[P.stamps]"
		user << browse(dat, "window=[name]")
	else if(istype(src[page], /obj/item/photo))
		var/obj/item/photo/P = W
		var/datum/picture/picture2 = P.picture
		user << browse_rsc(picture2.picture_image, "tmp_photo.png")
		user << browse(dat + "<html><head><title>[P.name]</title></head>" \
		+ "<body style='overflow:hidden'>" \
		+ "<div> <img src='tmp_photo.png' width = '180'" \
		+ "[P.scribble ? "<div> Written on the back:<br><i>[P.scribble]</i>" : ""]"\
		+ "</body></html>", "window=[name]")

/obj/item/paper_bundle/attack_self(mob/user as mob)
	src.show_content(user)
	add_fingerprint(usr)
	update_icon()
	return

/obj/item/paper_bundle/proc/update_screen()
	if(page == amount)
		screen = 2
	else if(page == 1)
		screen = 1
	else if(page == amount+1)
		return

/obj/item/paper_bundle/Topic(href, href_list)
	..()
	if(admin_faxed || (src in usr.contents) || (istype(src.loc, /obj/item/folder) && (src.loc in usr.contents)) || IsAdminGhost(usr))
		usr.set_machine(src)
		if(href_list["next_page"])
			if(page+1 == amount)
				screen = 2
			else if(page == 1)
				screen = 1
			else if(page == amount)
				return
			page++
			playsound(src.loc, "pageturn", 50, 1)
		if(href_list["prev_page"])
			if(page == 1)
				return
			else if(page == 2)
				screen = 0
			else if(page == amount)
				screen = 1
			page--
			playsound(src.loc, "pageturn", 50, 1)
		if(href_list["remove"])
			if(admin_faxed) return // Cannot remove paper from admin faxes
			amount--
			if(amount == 0)
				var/obj/item/paper/P = src[1]
				usr.dropItemToGround(src)
				usr.put_in_hands(P)
				qdel(src)
				return

			var/obj/item/W = src[page]
			usr.put_in_hands(W)
			to_chat(usr, span_notice("You remove the [W.name] from the bundle."))

			if(page >= amount)
				page = amount
			if(page == amount)
				screen = 2
			update_icon()
	else
		to_chat(usr, span_notice("You need to hold it in hand!"))
	if (istype(src.loc, /mob) || istype(src.loc?.loc, /mob))
		src.attack_self(src?.loc)
		updateUsrDialog()
	else if (admin_faxed)
		src.attack_self(usr)
		updateUsrDialog()

/obj/item/paper_bundle/verb/rename()
	set name = "Rename bundle"
	set category = "Object"
	set src in usr

	var/n_name = sanitize(copytext(input(usr, "What would you like to label the bundle?", "Bundle Labelling", null)  as text, 1, MAX_NAME_LEN))
	if((loc == usr && usr.stat == 0))
		name = "[(n_name ? text("[n_name]") : "paper")]"
	add_fingerprint(usr)
	return

/obj/item/paper_bundle/verb/unbundle_paper()
	set name = "Loosen bundle"
	set category = "Object"
	unbundle()

/obj/item/paper_bundle/proc/unbundle()
	set src in usr
	to_chat(usr, span_notice("You loosen the bundle."))
	for(var/obj/O in src)
		O.loc = usr.loc
		O.layer = initial(O.layer)
		O.add_fingerprint(usr)
	usr.dropItemToGround(src)
	qdel(src)
	return

/obj/item/paper_bundle/AltClick(mob/living/user)
	unbundle()

/obj/item/paper_bundle/update_icon()
	cut_overlays()
	var/obj/item/paper/P = src[1]
	icon_state = P.icon_state
	overlays = P.overlays
	underlays = 0
	var/i = 0
	var/photo
	for(var/obj/O in src)
		var/image/img = image('icons/obj/bureaucracy.dmi')
		if(istype(O, /obj/item/paper))
			img.icon_state = O.icon_state
			img.pixel_x -= min(1*i, 2)
			img.pixel_y -= min(1*i, 2)
			pixel_x = min(0.5*i, 1)
			pixel_y = min(  1*i, 2)
			underlays += img
			i++
		else if(istype(O, /obj/item/photo))
			var/obj/item/photo/PR = O
			var/datum/picture/picture2 = PR.picture
			img = picture2.picture_icon
			photo = 1
			add_overlay(img)
	if(i>1)
		desc =  "[i] papers clipped to each other."
	else
		desc = "A single sheet of paper."
	if(photo)
		desc += "\nThere is a photo attached to it."
	add_overlay(image('icons/obj/bureaucracy.dmi', icon_state= "clip"))
	return
