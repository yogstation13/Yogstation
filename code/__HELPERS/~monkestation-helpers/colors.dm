/// Given a color in the format of "#RRGGBB", will return if the color
/// is dark. Value is mixed with Saturation and Brightness from HSV.
/proc/is_color_dark_with_saturation(color, threshold = 25)
	var/hsl = rgb2num(color, COLORSPACE_HSL)
	return hsl[3] < threshold

/// it checks if a color is dark, but without saturation value.
/// This uses Brightness only, without Saturation from HSV
/proc/is_color_dark_without_saturation(color, threshold = 25)
	return get_color_brightness_from_hex(color) < threshold

/// returns HSV brightness 0 to 100 by color hex
/proc/get_color_brightness_from_hex(A)
	if(!A || length(A) != length_char(A))
		return 0
	var/R = hex2num(copytext(A, 2, 4))
	var/G = hex2num(copytext(A, 4, 6))
	var/B = hex2num(copytext(A, 6, 8))
	return round(max(R, G, B)/2.55, 1)
