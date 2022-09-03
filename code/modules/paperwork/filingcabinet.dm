/* Filing cabinets!
 * Contains:
 *		Filing Cabinets
 *		Security Record Cabinets
 *		Medical Record Cabinets
 *		Employment Contract Cabinets
 */


/*
 * Filing Cabinets
 */
/obj/structure/filingcabinet
	name = "filing cabinet"
	desc = "A large cabinet with drawers."
	icon = 'yogstation/icons/obj/bureaucracy.dmi'
	icon_state = "filingcabinet"
	density = TRUE
	anchored = TRUE

/obj/structure/filingcabinet/chestdrawer
	name = "chest drawer"
	icon_state = "chestdrawer"

/obj/structure/filingcabinet/chestdrawer/wheeled
	name = "rolling chest drawer"
	desc = "A small cabinet with drawers. This one has wheels!"
	anchored = FALSE

/obj/structure/filingcabinet/filingcabinet	//not changing the path to avoid unnecessary map issues, but please don't name stuff like this in the future -Pete
	icon_state = "tallcabinet"

/obj/structure/filingcabinet/colored/blue
	name = "blue cabinet"
	colour = "#47679b" // Command Color

/obj/structure/filingcabinet/colored/red
	name = "red cabinet"
	colour = "#AE4B3D" // Security Color

/obj/structure/filingcabinet/colored/green
	name = "green cabinet"
	colour = "#58944f" // Service Color

/obj/structure/filingcabinet/colored/purple
	name = "purple cabinet"
	colour = "#993399" // Science Color

/obj/structure/filingcabinet/colored/yellow
	name = "yellow cabinet"
	colour = "#c7b01a" // Engineering Color

/obj/structure/filingcabinet/colored/lightblue
	name = "light-blue cabinet"
	colour = "#498FBD" // Medical Color

/obj/structure/filingcabinet/colored
	/// Colours for the coloured subtype
	var/colour = "#2e2c2b"
	icon_state = "coloredcabinet_frame"
	name = "colored cabinet"

/obj/structure/filingcabinet/colored/update_icon()
	cut_overlays()
	var/mutable_appearance/cab = mutable_appearance(icon, "coloredcabinet_trim")
	cab.color = colour
	add_overlay(cab)

/obj/structure/filingcabinet/Initialize(mapload)
	. = ..()
	update_icon()
	if(mapload)
		for(var/obj/item/I in loc)
			if(istype(I, /obj/item/paper) || istype(I, /obj/item/folder) || istype(I, /obj/item/photo))
				I.forceMove(src)

/obj/structure/filingcabinet/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 2)
		for(var/obj/item/I in src)
			I.forceMove(loc)
	qdel(src)

/obj/structure/filingcabinet/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/pen))
		var/str = reject_bad_text(stripped_input(user, "Label Cabinet(Blank to reset)", "Set label","", MAX_NAME_LEN))
		if(str)
			name = str
		else
			name = initial(name)
		return
	if(istype(P, /obj/item/paper) || istype(P, /obj/item/folder) || istype(P, /obj/item/photo) || istype(P, /obj/item/documents))
		if(!user.transferItemToLoc(P, src))
			return
		to_chat(user, span_notice("You put [P] in [src]."))
		if(istype(src, /obj/structure/filingcabinet/colored))
			var/obj/structure/filingcabinet/colored/cab = src
			var/mutable_appearance/opentrim = mutable_appearance(icon, "coloredcabinet-open-trim")
			var/mutable_appearance/open = mutable_appearance(icon, "coloredcabinet-open")
			opentrim.color = cab.colour
			var/overlays = list(opentrim, open)
			add_overlay(overlays)
			sleep(0.5 SECONDS)
			cut_overlay(overlays)
		else
			icon_state = "[initial(icon_state)]-open"
			sleep(0.5 SECONDS)
			icon_state = initial(icon_state)
			updateUsrDialog()
	else if(P.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("You begin to [anchored ? "unwrench" : "wrench"] [src]."))
		if(P.use_tool(src, user, 20, volume=50))
			to_chat(user, span_notice("You successfully [anchored ? "unwrench" : "wrench"] [src]."))
			anchored = !anchored
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, span_warning("You can't put [P] in [src]!"))
	else
		return ..()


/obj/structure/filingcabinet/ui_interact(mob/user)
	. = ..()
	if(contents.len <= 0)
		to_chat(user, span_notice("[src] is empty."))
		return

	var/dat = "<center><table>"
	var/i
	for(i=contents.len, i>=1, i--)
		var/obj/item/P = contents[i]
		dat += "<tr><td><a href='?src=[REF(src)];retrieve=[REF(P)]'>[P.name]</a></td></tr>"
	dat += "</table></center>"
	user << browse("<html><head><meta charset='UTF-8'><title>[name]</title></head><body>[dat]</body></html>", "window=filingcabinet;size=350x300")

/obj/structure/filingcabinet/attack_tk(mob/user)
	if(anchored)
		attack_self_tk(user)
	else
		..()

/obj/structure/filingcabinet/attack_self_tk(mob/user)
	if(contents.len)
		if(prob(40 + contents.len * 5))
			var/obj/item/I = pick(contents)
			I.forceMove(loc)
			if(prob(25))
				step_rand(I)
			to_chat(user, span_notice("You pull \a [I] out of [src] at random."))
			return
	to_chat(user, span_notice("You find nothing in [src]."))

/obj/structure/filingcabinet/Topic(href, href_list)
	if(!usr.canUseTopic(src, BE_CLOSE, ismonkey(usr)))
		return
	if(href_list["retrieve"])
		usr << browse(null, "window=filingcabinet") // Close the menu

		var/obj/item/P = locate(href_list["retrieve"]) in src //contents[retrieveindex]
		if(istype(P) && in_range(src, usr))
			usr.put_in_hands(P)
			updateUsrDialog()
			if(istype(src, /obj/structure/filingcabinet/colored))
				var/obj/structure/filingcabinet/colored/cab = src
				var/mutable_appearance/opentrim = mutable_appearance(icon, "coloredcabinet-open-trim")
				var/mutable_appearance/open = mutable_appearance(icon, "coloredcabinet-open")
				opentrim.color = cab.colour
				var/overlays = list(opentrim, open)
				add_overlay(overlays)
				sleep(0.5 SECONDS)
				cut_overlay(overlays)
			else
				icon_state = "[initial(icon_state)]-open"
				sleep(0.5 SECONDS)
				icon_state = initial(icon_state)

/obj/structure/filingcabinet/colored/attackby(obj/item/P, mob/user, params)
	..()
	if(istype(P, /obj/item/toy/crayon/spraycan)) // Colorizer
		var/obj/item/toy/crayon/spraycan/paint = P
		. = TRUE // no afterattack
		paint.check_empty(user, 1) // Can't cheat this smh
		var/colour_choice = input(usr, "Cabinet Color?", "Color Change") as null | color
		if(colour_choice)
			paint.use_charges(user, 1)
			colour = colour_choice
			name = "colored cabinet" // Having a cabinet called 'Purple Cabinet' while it's green colored would be weird
			playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
			update_icon() // reset overlays
		return


/*
 * Security Record Cabinets
 */
/obj/structure/filingcabinet/security
	var/virgin = 1

/obj/structure/filingcabinet/security/proc/populate()
	if(virgin)
		for(var/datum/data/record/G in GLOB.data_core.general)
			var/datum/data/record/S = find_record("name", G.fields["name"], GLOB.data_core.security)
			if(!S)
				continue
			var/obj/item/paper/P = new /obj/item/paper(src)
			P.info = "<CENTER><B>Security Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>"
			P.info += "Gender: [G.fields["gender"]]<BR>"
			P.info += "Age: [G.fields["age"]]<BR>"
			P.info += "Fingerprint: [G.fields["fingerprint"]]<BR>"
			P.info += "Physical Status: [G.fields["p_stat"]]<BR>"
			P.info += "Mental Status: [G.fields["m_stat"]]<BR><BR>"
			P.info += "<CENTER><B>Security Data</B></CENTER><BR>"
			P.info += "Criminal Status: [S.fields["criminal"]]<BR><BR>"
			P.info += "Crimes:<BR>"
			for(var/datum/data/crime/crime in S.fields["crimes"])
				P.info += "\t[crime.crimeName]: [crime.crimeDetails]<BR>"
			P.info += "<BR>"
			P.info += "Important Notes:<BR>"
			P.info += "\t[S.fields["notes"]]<BR><BR>"
			P.info += "<CENTER><B>Comments/Log</B></CENTER><BR>"
			for(var/datum/data/comment/comment in S.fields["comments"])
				P.info += "\t[comment.commentText] - [comment.author] [comment.time]<BR>"
			P.info += "</TT>"
			P.name = "paper - '[G.fields["name"]]'"
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

/obj/structure/filingcabinet/security/attack_hand()
	populate()
	. = ..()

/obj/structure/filingcabinet/security/attack_tk()
	populate()
	..()

/*
 * Medical Record Cabinets
 */
/obj/structure/filingcabinet/medical
	var/virgin = 1

/obj/structure/filingcabinet/medical/proc/populate()
	if(virgin)
		for(var/datum/data/record/G in GLOB.data_core.general)
			var/datum/data/record/M = find_record("name", G.fields["name"], GLOB.data_core.medical)
			if(!M)
				continue
			var/obj/item/paper/P = new /obj/item/paper(src)
			P.info = "<CENTER><B>Medical Record</B></CENTER><BR>"
			P.info += "Name: [G.fields["name"]] ID: [G.fields["id"]]<BR>\nGender: [G.fields["gender"]]<BR>\nAge: [G.fields["age"]]<BR>\nFingerprint: [G.fields["fingerprint"]]<BR>\nPhysical Status: [G.fields["p_stat"]]<BR>\nMental Status: [G.fields["m_stat"]]<BR>"
			P.info += "<BR>\n<CENTER><B>Medical Data</B></CENTER><BR>\nBlood Type: [M.fields["blood_type"]]<BR>\nDNA: [M.fields["b_dna"]]<BR>\n<BR>\nMinor Disabilities: [M.fields["mi_dis"]]<BR>\nDetails: [M.fields["mi_dis_d"]]<BR>\n<BR>\nMajor Disabilities: [M.fields["ma_dis"]]<BR>\nDetails: [M.fields["ma_dis_d"]]<BR>\n<BR>\nAllergies: [M.fields["alg"]]<BR>\nDetails: [M.fields["alg_d"]]<BR>\n<BR>\nCurrent Diseases: [M.fields["cdi"]] (per disease info placed in log/comment section)<BR>\nDetails: [M.fields["cdi_d"]]<BR>\n<BR>\nImportant Notes:<BR>\n\t[M.fields["notes"]]<BR>\n<BR>\n<CENTER><B>Comments/Log</B></CENTER><BR>"
			var/counter = 1
			while(M.fields["com_[counter]"])
				P.info += "[M.fields["com_[counter]"]]<BR>"
				counter++
			P.info += "</TT>"
			P.name = "paper - '[G.fields["name"]]'"
			virgin = 0	//tabbing here is correct- it's possible for people to try and use it
						//before the records have been generated, so we do this inside the loop.

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/filingcabinet/medical/attack_hand()
	populate()
	. = ..()

/obj/structure/filingcabinet/medical/attack_tk()
	populate()
	..()

/*
 * Employment contract Cabinets
 */

GLOBAL_LIST_EMPTY(employmentCabinets)

/obj/structure/filingcabinet/employment
	var/cooldown = 0
	icon_state = "employmentcabinet"
	var/virgin = 1

/obj/structure/filingcabinet/employment/Initialize()
	. = ..()
	GLOB.employmentCabinets += src

/obj/structure/filingcabinet/employment/Destroy()
	GLOB.employmentCabinets -= src
	return ..()

/obj/structure/filingcabinet/employment/proc/fillCurrent()
	//This proc fills the cabinet with the current crew.
	for(var/record in GLOB.data_core.locked)
		var/datum/data/record/G = record
		if(!G)
			continue
		var/datum/mind/M = G.fields["mindref"]
		if(M && ishuman(M.current))
			addFile(M.current)


/obj/structure/filingcabinet/employment/proc/addFile(mob/living/carbon/human/employee)
	new /obj/item/paper/contract/employment(src, employee)

/obj/structure/filingcabinet/employment/interact(mob/user)
	if(!cooldown)
		if(virgin)
			fillCurrent()
			virgin = 0
		cooldown = 1
		sleep(10 SECONDS) // prevents the devil from just instantly emptying the cabinet, ensuring an easy win.
		cooldown = 0
	else
		to_chat(user, span_warning("[src] is jammed, give it a few seconds."))
	..()
