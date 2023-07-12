/datum/hud/living/blobbernaut/New(mob/living/owner)
	. = ..()

	blobpwrdisplay = new /atom/movable/screen/healths/blob/overmind(src)
	blobpwrdisplay.hud = src
	infodisplay += blobpwrdisplay
