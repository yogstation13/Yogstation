/////////////////////////
//YOG DRONE VERBS//
////////////////////////
/mob/living/simple_animal/drone/verb/toggle_nightvision()
	set name = "Toggle Nightvision"
	set desc = "Toggles your ability to see in the dark."
	set category = "Drone"
	if (lighting_alpha == 140)
		lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE // 255
		to_chat(src,"<span class='notice'>You deactivate your nightvision.")
	else
		lighting_alpha = 140
		to_chat(src,"<span class='notice'>You reactivate your nightvision.")
	update_sight()
