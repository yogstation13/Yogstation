/*
 * Paper
 * also scraps of paper
 *
 * lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!
 */

/datum/langtext // A datum to describe a piece of writing that stores a language value with it.
	var/text = "" // The text that is written.
	var/datum/language/lang // the language it's written in.
/datum/langtext/New(t,datum/language/l)
	text = t
	lang = l

/obj/item/paper
	name = "paper"
	gender = NEUTER
	icon = 'yogstation/icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	sharpness = SHARP_EDGED //Paper cuts
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	dog_fashion = /datum/dog_fashion/head
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	grind_results = list(/datum/reagent/cellulose = 3)

	var/info = "" // What's prewritten on the paper. Appears first and is a special snowflake callback to how paper used to work.
	var/coloroverride // A hexadecimal as a string that, if set, overrides the font color of the whole document. Used by photocopiers
	var/datum/language/infolang // The language info is written in. If left NULL, info will default to being omnilingual and readable by all.
	var/list/written //What's written on the paper by people. Stores /datum/langtext values, plus plaintext values that mark where fields are.
	var/stamps		//The (text for the) stamps on the paper.
	var/fields = 0	//Amount of user created fields
	var/list/stamped
	var/rigged = 0
	var/spam_flag = 0
	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0
	var/next_write_time = 0 // prevent crash exploit


/obj/item/paper/pickup(user)
	if(contact_poison && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(contact_poison,contact_poison_volume)
			contact_poison = null
	..()


/obj/item/paper/attack_hand(mob/living/carbon/human/user) //Basically repurposed light tube code
	..()
	if(prob(1))
		var/mob/living/carbon/human/butterfingers = user
		if(butterfingers.gloves)
			to_chat(user, span_notice("The paper slides uncomfortably across your gloved palm."))
		else
			to_chat(user, span_warning("You cut yourself on the paper!"))
			var/obj/item/bodypart/affecting = butterfingers.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
			if(affecting && affecting.receive_damage(1)) //One brute damage
				butterfingers.update_damage_overlays()


/obj/item/paper/Initialize()
	. = ..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	written = list()
	update_icon()


/obj/item/paper/update_icon()

	if(resistance_flags & ON_FIRE)
		icon_state = "paper_onfire"
		return
	if(info || length(written))
		icon_state = "paper_words"
		return
	icon_state = "paper"


/obj/item/paper/examine(mob/user, force = FALSE)
	. = ..()
	var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/paper)
	assets.send(user)

	if(in_range(user, src) || isobserver(user) || force)
		if(user.is_literate() || force)
			user << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>[name]</TITLE></HEAD><BODY>[render_body(user)]<HR>[stamps]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
		else
			user << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>[name]</TITLE></HEAD><BODY>[stars(render_body(user))]<HR>[stamps]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
	else
		. += span_warning("You're too far away to read it!")


/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if(usr.incapacitated() || !usr.is_literate())
		return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(HAS_TRAIT(H, TRAIT_CLUMSY) && prob(25))
			to_chat(H, span_warning("You cut yourself on the paper! Ahhhh! Ahhhhh!"))
			H.damageoverlaytemp = 9001
			H.update_damage_hud()
			return
	var/n_name = stripped_input(usr, "What would you like to label the paper?", "Paper Labelling", null, MAX_NAME_LEN)
	if((loc == usr && usr.stat == CONSCIOUS))
		name = "paper[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)


/obj/item/paper/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku..."))
	return (BRUTELOSS)

/obj/item/paper/proc/reset_spamflag()
	spam_flag = FALSE

/obj/item/paper/attack_self(mob/user)
	user.examinate(src)
	if(rigged && (SSevents.holidays && SSevents.holidays[APRIL_FOOLS]))
		if(!spam_flag)
			spam_flag = TRUE
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			addtimer(CALLBACK(src, .proc/reset_spamflag), 20)


/obj/item/paper/attack_ai(mob/living/silicon/ai/user)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		usr << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>[name]</TITLE></HEAD><BODY>[render_body(user)]<HR>[stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	else
		usr << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>[name]</TITLE></HEAD><BODY>[stars(render_body(user))]<HR>[stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")

/obj/item/paper/proc/render_body(mob/user,links = FALSE)
	var/text = ""// The actual text displayed. Starts with & defaults to $info.
	if(coloroverride)
		text = "<font color='#[coloroverride]'>"
	text += info
	if(istype(infolang) && !user.has_language(infolang))
		var/datum/language/paperlang = GLOB.language_datum_instances[infolang]
		text = paperlang.scramble_HTML(text)

	for(var/i=1,i<=written.len;++i) // Needs to be a normal for-loop because I need the indices.
		var/x = written[i]
		if(istype(x,/datum/langtext))
			var/datum/langtext/X = x
			if(user.has_language(X.lang))
				text += X.text
			else
				var/datum/language/paperlang = GLOB.language_datum_instances[X.lang]
				text += paperlang.scramble_HTML(X.text)
		else if(links)
			text += span_paper_field("" + "<font face=\"[PEN_FONT]\"><A href='?src=[REF(src)];write=[i]'>write</A></font>" + "")
	if(links)
		text += span_paper_field("" + "<font face=\"[PEN_FONT]\"><A href='?src=[REF(src)];write=end'>write</A></font>" + "")
	if(coloroverride)
		text += "</font>"
	return text

/obj/item/paper/proc/clearpaper()
	stamps = null
	LAZYCLEARLIST(stamped)
	cut_overlays()
	update_icon()


/obj/item/paper/proc/parsepencode(t, obj/item/pen/P, mob/user, iscrayon = 0)
	if(length(t) < 1)		//No input means nothing needs to be parsed
		return

	t = parsemarkdown(t, user, iscrayon)

	if(!iscrayon)
		t = "<font face=\"[P.font]\" color=[P.colour]>[t]</font>"
	else
		var/obj/item/toy/crayon/C = P
		t = "<font face=\"[CRAYON_FONT]\" color=[C.paint_color]><b>[t]</b></font>"

	var/list/T = splittext(t,PAPER_FIELD,1,0,TRUE) // The list of subsections.. Splits the text on where paper fields have been created.
	//The TRUE marks that we're keeping these "seperator" paper fields; they're included in this list.
	return T // :)

/obj/item/paper/proc/reload_fields() // Useful if you made the paper programicly and want to include fields. Also runs updateinfolinks() for you.
	fields = 0
	var/laststart = 1
	while(fields < 15)
		var/i = findtext(info, "<span class=\"paper_field\">", laststart)
		if(i == 0)
			break
		laststart = i+1
		fields++


/obj/item/paper/proc/openhelp(mob/user)
	user << browse({"<HTML><HEAD><meta charset='UTF-8'><TITLE>Paper Help</TITLE></HEAD>
	<BODY>
		You can use backslash (\\) to escape special characters.<br>
		<br>
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		# text : Defines a header.<br>
		|text| : Centers the text.<br>
		**text** : Makes the text <b>bold</b>.<br>
		*text* : Makes the text <i>italic</i>.<br>
		^text^ : Increases the <font size = \"4\">size</font> of the text.<br>
		%s : Inserts a signature of your name in a foolproof way.<br>
		%f : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		((text)) : Decreases the <font size = \"1\">size</font> of the text.<br>
		* item : An unordered list item.<br>
		&nbsp;&nbsp;* item: An unordered list child item.<br>
		--- : Adds a horizontal rule.
	</BODY></HTML>"}, "window=paper_help")


/obj/item/paper/Topic(href, href_list)
	if(next_write_time > world.time) //Nsv13 possible paper exploit
		return
	..()
	var/literate = usr.is_literate()
	if(!usr.canUseTopic(src, BE_CLOSE, literate))
		return
	if(href_list["help"])
		openhelp(usr)
		return
	if(href_list["write"])
		next_write_time = world.time + 1 SECONDS //possible paper exploit
		var/t =  stripped_multiline_input("Enter what you want to write:", "Write", no_trim=TRUE)
		if(!t || !usr.canUseTopic(src, BE_CLOSE, literate))
			return
		var/obj/item/i = usr.get_active_held_item()	//Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = 0
		if(!istype(i, /obj/item/pen))
			if(!istype(i, /obj/item/toy/crayon))
				return
			iscrayon = 1

		if(!in_range(src, usr) && loc != usr && !istype(loc, /obj/item/clipboard) && loc.loc != usr && usr.get_active_held_item() != i)	//Some check to see if he's allowed to write
			return
		log_paper("[key_name(usr)] writing to paper [t]")
		var/list/T = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html nibblets

		if(T.len)	//No input from the user means nothing needs to be added
			var/list/templist = list() // All the stuff we're adding to $written
			for(var/text in T)
				if(text == PAPER_FIELD)
					templist += text
				else
					var/datum/langtext/L = new(text,usr.get_selected_language())
					templist += L
			var/id = href_list["write"]
			if(id == "end")
				written += templist
			else
				written.Insert(text2num(id),templist) // text2num, otherwise it writes to the hashtable index instead of into the array
			usr << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>[name]</TITLE></HEAD><BODY>[render_body(usr,TRUE)]<HR>[stamps]</BODY><div align='right'style='position:fixed;bottom:0;font-style:bold;'><A href='?src=[REF(src)];help=1'>\[?\]</A></div></HTML>", "window=[name]") // Update the window
			update_icon()


/obj/item/paper/attackby(obj/item/P, mob/living/carbon/human/user, params)
	..()

	if(resistance_flags & ON_FIRE)
		return

	if(is_blind(user))
		return

	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(user.is_literate())
			user << browse("<HTML><HEAD><meta charset='UTF-8'><TITLE>[name]</TITLE></HEAD><BODY>[render_body(user,TRUE)]<HR>[stamps]</BODY><div align='right'style='position:fixed;bottom:0;font-style:bold;'><A href='?src=[REF(src)];help=1'>\[?\]</A></div></HTML>", "window=[name]")
			return
		else
			to_chat(user, span_notice("You don't know how to read or write."))
			return

	else if(istype(P, /obj/item/stamp))

		if(!in_range(src, user))
			return

		var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
		if (isnull(stamps))
			stamps = sheet.css_tag()
		stamps += sheet.icon_tag(P.icon_state)
		var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/bureaucracy.dmi', "paper_[P.icon_state]")
		stampoverlay.pixel_x = rand(-2, 2)
		stampoverlay.pixel_y = rand(-3, 2)

		LAZYADD(stamped, P.icon_state)
		add_overlay(stampoverlay)

		to_chat(user, span_notice("You stamp the paper with your rubber stamp."))

	if(P.is_hot())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message(span_warning("[user] accidentally ignites [user.p_them()]self!"), \
								span_userdanger("You miss the paper and accidentally light yourself on fire!"))
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return

		user.dropItemToGround(src)
		user.visible_message(span_danger("[user] lights [src] ablaze with [P]!"), span_danger("You light [src] on fire!"))
		fire_act()

	if(istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
		if (istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if (!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return
		var/obj/item/paper_bundle/B = new(src.loc)
		if (name != "paper")
			B.name = name
		else if (P.name != "paper" && P.name != "photo")
			B.name = P.name
		user.dropItemToGround(P)
		user.dropItemToGround(src)
		user.put_in_hands(B)

		to_chat(user, "<span class='notice'>You clip the [P.name] to [(src.name == "paper") ? "the paper" : src.name].</span>")
		src.loc = B
		P.loc = B
		B.amount = 2
		B.update_icon()

	add_fingerprint(user)

/obj/item/paper/fire_act(exposed_temperature, exposed_volume)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		icon_state = "paper_onfire"
		info = "[stars(info)]"


/obj/item/paper/extinguish()
	..()
	update_icon()

/*
 * Construction paper
 */

/obj/item/paper/construction

/obj/item/paper/construction/Initialize()
	. = ..()
	color = pick("FF0000", "#33cc33", "#ffb366", "#551A8B", "#ff80d5", "#4d94ff")

/*
 * Natural paper
 */

/obj/item/paper/natural/Initialize()
	. = ..()
	color = "#FFF5ED"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"
	slot_flags = null

/obj/item/paper/crumpled/update_icon()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

