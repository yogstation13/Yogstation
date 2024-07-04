/obj/item/bodypart
	var/yogs_draw_robot_hair = FALSE
	///Does the bodypart have a "static" portion? Example is Vox limbs, the hand part is always the same golden-brown color, while the arm is different colors according to the Vox skin tone 
	var/has_static_sprite_part = FALSE
	///For species with different icon-based skin tones, like Vox
	var/limb_icon_variant
	var/limb_icon_file
