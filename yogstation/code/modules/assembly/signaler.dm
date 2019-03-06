/obj/item/assembly/signaler
	icon = 'yogstation/icons/obj/assemblies/new_assemblies.dmi'
	var/static/list/label_colors = list("red", "green", "blue", "cyan", "magenta", "yellow", "white")
	var/label_color = "green"

/obj/item/assembly/signaler/Initialize()
	. = ..()
	update_icon()

/obj/item/assembly/signaler/update_icon()
	cut_overlays()
	attached_overlays = list()
	var/mutable_appearance/A = mutable_appearance('yogstation/icons/obj/assemblies/new_assemblies.dmi', "signaller_color")
	A.color = label_color
	add_overlay(A)
	attached_overlays += A
	return ..()