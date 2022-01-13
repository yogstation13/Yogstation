GLOBAL_VAR_INIT(ai_triangulation_width, 4)
/atom/proc/can_triangulate()

	var/obj/machinery/ai/data_core/n1 
	var/obj/machinery/ai/data_core/n2 

	for(var/obj/machinery/ai/data_core/D in GLOB.data_cores)
		if(!n1)
			n1 = D
			continue
		if(!n2)
			n2 = D
			continue

	var/direction = get_dir(n1, n2)


	
	var/atom/n1_p1 = get_step(get_step(n1, turn(direction, 90)), turn(direction, 90))
	var/atom/n1_p2 = get_step(get_step(n1, turn(direction, -90)), turn(direction, -90))
	n1_p1.color = "#FF0000"
	n1_p2.color = "#FF0000"


	var/atom/n2_p1 = get_step(get_step(n2, turn(direction, 90)), turn(direction, 90))
	var/atom/n2_p2 = get_step(get_step(n2, turn(direction, -90)), turn(direction, -90))
	n2_p1.color = "#FF0000"
	n2_p2.color = "#FF0000"

	if(get_dist(n1_p1, n2_p1) > get_dist(n1_p1, n2_p2))
		var/atom/temp = n2_p1
		n2_p1 = n2_p2
		n2_p2 = temp

	var/odd = FALSE
	var/list/point = list(src.x, src.y)
	var/list/polygon = list(to_coord_list(n1_p1), to_coord_list(n1_p2), to_coord_list(n2_p1), to_coord_list(n2_p2))

	var/j = polygon.len
	for(var/i = 1, i < (polygon.len + 1), i++)
		if(((polygon[i][2] >= point[2]) != (polygon[j][2] >= point[2])) && (point[1] <= ((polygon[j][1] - polygon[i][1]) * (point[2] - polygon[i][2]) / (polygon[j][2] - polygon[i][2]) + polygon[i][1])))
			if(!odd)
				odd = TRUE
			else
				odd = FALSE
		j = i
	
	if(odd)
		src.color = "#00FF00"
