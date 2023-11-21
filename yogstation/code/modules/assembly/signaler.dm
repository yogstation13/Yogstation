/obj/item/assembly/signaler
	var/static/list/label_colors = list("red", "green", "blue", "cyan", "magenta", "yellow", "white")
	var/label_color = "green"

/obj/item/assembly/signaler/update_overlays()
	. = ..()
	if(label_color)
		attached_overlays = list()
		var/mutable_appearance/A = mutable_appearance(icon, "signaller_color")
		A.color = label_color
		. += A
		attached_overlays += A

/obj/item/assembly/signaler/anomaly
	label_color = null
