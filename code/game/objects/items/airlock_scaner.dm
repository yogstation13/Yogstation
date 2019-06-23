/obj/item/airlock_scaner
	name = "airlock scaner"
	desc = "a tool used to idetifying accses requiremnts without disassembling airlocks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint sprayer"
	item_state = "paint sprayer"

	w_class = WEIGHT_CLASS_SMALL

	materials = list(MAT_METAL=50, MAT_GLASS=50)

	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT

/obj/item/airlock_scaner/proc/show_accses(/obj/item/electronics/airlock/electronics, mob/user)
	var/t1 = ""

	if(electronics.one_access)
		t1 += "Restriction Type: At least one access required<br>"
	else
		t1 += "Restriction Type: All accesses required<br>"


	var/accesses = ""
	accesses += "<div align='center'><b>Access</b></div>"
	accesses += "<table style='width:100%'>"
	accesses += "<tr>"
	for(var/i = 1; i <= 7; i++)
		accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
	accesses += "</tr><tr>"
	for(var/i = 1; i <= 7; i++)
		accesses += "<td style='width:14%' valign='top'>"
		for(var/A in get_region_accesses(i))
			if(A in electronics.accesses)
				accesses += "<font color=\"red\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font> "
			else
				accesses += "[replacetext(get_access_desc(A), " ", "&nbsp")] "
			accesses += "<br>"
		accesses += "</td>"
	accesses += "</tr></table>"
	t1 += "<tt>[accesses]</tt>"

	t1 += "<p><a href='?src=[REF(src)];close=1'>Close</a></p>\n"

	var/datum/browser/popup = new(user, "airlock_scan", "Access Scan", 900, 500)
	popup.set_content(t1)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()
	onclose(user, "airlock_scan")
