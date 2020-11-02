/datum/minimap
	var/icon/map_icon
	var/icon/meta_icon
	var/icon/overlay_icon
	var/list/color_area_names = list()
	var/minx
	var/maxx
	var/miny
	var/maxy
	var/z_level
	var/id = 0

/datum/minimap/proc/send(mob/user)
	if(!SSassets.cache["minimap-[id].png"])
		SSassets.transport.register_asset("minimap-[id].png", map_icon)
		SSassets.transport.register_asset("minimap-[id]-meta.png", meta_icon)
	SSassets.transport.send_assets(user, list("minimap-[id].png" = map_icon, "minimap-[id]-meta.png" = meta_icon))

/datum/minimap/New(z, x1 = 1, y1 = 1, x2 = world.maxx, y2 = world.maxy)
	var/static/id_counter = 1
	id = id_counter++
	z_level = z

	var/crop_x1 = x2
	var/crop_x2 = x1
	var/crop_y1 = y2
	var/crop_y2 = y1

	// do the generating
	map_icon = new('html/blank.png')
	meta_icon = new('html/blank.png')
	map_icon.Scale(x2-x1+1, y2-y1+1) // arrays start at 1
	meta_icon.Scale(x2-x1+1, y2-y1+1)
	var/list/area_to_color = list()
	for(var/turf/T in block(locate(x1,y1,z),locate(x2,y2,z)))
		var/area/A = T.loc
		var/img_x = T.x - x1 + 1 // arrays start at 1
		var/img_y = T.y - y1 + 1
		if(!istype(A, /area/space) || istype(T, /turf/closed/wall))
			crop_x1 = min(crop_x1, T.x)
			crop_x2 = max(crop_x2, T.x)
			crop_y1 = min(crop_y1, T.y)
			crop_y2 = max(crop_y2, T.y)
		var/meta_color = area_to_color[A]
		if(!meta_color)
			meta_color = rgb(rand(0,255),rand(0,255),rand(0,255)) // technically conflicts could happen but it's like very unlikely and it's not that big of a deal if one happens
			area_to_color[A] = meta_color
			color_area_names[meta_color] = A.name
		meta_icon.DrawBox(meta_color, img_x, img_y)
		if(istype(T, /turf/closed/wall))
			map_icon.DrawBox("#000000", img_x, img_y)
		else if(!istype(A, /area/space))
			var/color = A.minimap_color || "#FF00FF"
			if(locate(/obj/machinery/power/solar) in T)
				color = "#02026a"
			if((locate(/obj/effect/spawner/structure/window) in T) || (locate(/obj/structure/grille) in T))
				color = BlendRGB(color, "#000000", 0.5)
			map_icon.DrawBox(color, img_x, img_y)
	map_icon.Crop(crop_x1, crop_y1, crop_x2, crop_y2)
	meta_icon.Crop(crop_x1, crop_y1, crop_x2, crop_y2)
	minx = crop_x1
	maxx = crop_x2
	miny = crop_y1
	maxy = crop_y2
	overlay_icon = new(map_icon)
	overlay_icon.Scale(16, 16)

/obj/item/map
	name = "map"
	gender = NEUTER
	icon = 'yogstation/icons/obj/bureaucracy.dmi'
	icon_state = "map"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	resistance_flags = FLAMMABLE
	max_integrity = 50
	var/list/minimaps = list()

/obj/item/map/attackby(obj/item/P, mob/living/carbon/human/user, params)
	if(P.is_hot())
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
								"<span class='userdanger'>You miss the map and accidentally light yourself on fire!</span>")
			user.dropItemToGround(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!(in_range(user, src))) //to prevent issues as a result of telepathically lighting a paper
			return

		user.dropItemToGround(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()
		return
	return ..()

/obj/item/map/station
	name = "station map"
	desc = "A handy map showing the locations of all the departments on the station so you don't get lost"

/obj/item/map/station/Initialize()
	..()
	minimaps += SSmapping.station_minimaps
	update_icon()

/obj/item/map/update_icon()
	cut_overlays()
	var/datum/minimap/map = minimaps[1]
	if(!map) return
	var/image/I = image(map.overlay_icon)
	I.pixel_x = 8
	I.pixel_y = 8
	add_overlay(I)

/obj/item/map/interact(mob/user)
	if(!in_range(user, src) && !isobserver(user))
		to_chat(user, "<span class='warning'>You're too far away to read it!</span>")
		return
	if(!minimaps || !minimaps.len)
		to_chat(user, "<span class='warning'>This map is blank!</span>")
		return
	var/datum/minimap/first_map = minimaps[1]
	var/info = ""
	var/datas = list();
	for(var/I in 1 to minimaps.len)
		var/datum/minimap/map = minimaps[I]
		map.send(user)
		var/map_filename = SSassets.transport.get_asset_url("minimap-[map.id].png")
		var/map_meta_filename = SSassets.transport.get_asset_url("minimap-[map.id]-meta.png")
		info += "<img src='[map_filename]' id='map-[I]'><img src='[map_meta_filename]' style='display: none' id='map-[I]-meta'><div id='label-[I]'></div>"
		datas += json_encode(map.color_area_names);
	user << browse({"
<!DOCTYPE html>
<HTML>
<HEAD>
<meta charset='UTF-8'>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<script>
function hexify(num) {
	if(!num) num = 0;
	num = num.toString(16);
	if(num.length == 1) num = "0" + num;
	return num;
}
window.onload = function() {
	var datas = \[[jointext(datas, ",")]]
	if(window.HTMLCanvasElement) {
		for(var i = 0; i < [minimaps.len]; i++) {
			(function() {
				var data = datas\[i];
				var img = document.getElementById("map-" + (i+1));
				if(!img) return;
				var canvas = document.createElement("canvas");
				canvas.width = img.width * 2;
				canvas.height = img.height * 2;

				var ctx = canvas.getContext('2d');
				ctx.msImageSmoothingEnabled = false;
				ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
				img.parentNode.replaceChild(canvas, img);

				ctx = document.createElement("canvas").getContext('2d');
				ctx.canvas.width = img.width;
				ctx.canvas.height = img.height;
				ctx.drawImage(document.getElementById("map-" + (i+1) + "-meta"), 0, 0);
				var imagedata = ctx.getImageData(0, 0, img.width, img.height);

				var label = document.getElementById("label-" + (i+1));
				canvas.onmousemove = function(e) {
					var rect = canvas.getBoundingClientRect();
					var x = Math.floor(e.offsetX * img.width / rect.width);
					var y = Math.floor(e.offsetY * img.height / rect.height);
					var color_idx = x * 4 + (y * 4 * imagedata.width);
					var color = "#" + hexify(imagedata.data\[color_idx]) + hexify(imagedata.data\[color_idx+1]) + hexify(imagedata.data\[color_idx+2]);
					label.textContent = data\[color];
					canvas.title = data\[color];
				}
				canvas.onmouseout = function(e) {
					label.textContent = "";
					canvas.title = "";
				}
			})();
		}
	}
}
</script>
<STYLE>
	img, canvas {
		width: 100%
	}
</STYLE>
<TITLE>[name]</TITLE>
</HEAD>
<BODY>[info]</BODY>
</HTML>"}, "window=minimap;size=768x[round(768 / first_map.map_icon.Width() * first_map.map_icon.Height() + 50)]")
	onclose(user, "minimap")
