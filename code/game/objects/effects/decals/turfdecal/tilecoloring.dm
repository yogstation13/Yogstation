/obj/effect/turf_decal/tile
	name = "tile decal"
	icon_state = "tile_corner"
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110

/obj/effect/turf_decal/tile/Initialize()
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/tile/blue
	name = "blue corner"
	color = "#52B4E9"

/obj/effect/turf_decal/tile/blue/opposingcorners //Two corners on opposite ends of each other (i.e. Top Right to Bottom Left). Allows for faster mapping and less complicated turf decal storage.
	icon_state = "tile_opposing_corners"
	name = "opposing blue corners"

/obj/effect/turf_decal/tile/blue/half
	icon_state = "tile_half"
	name = "blue half"

/obj/effect/turf_decal/tile/blue/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted blue half"

/obj/effect/turf_decal/tile/blue/anticorner
	icon_state = "tile_anticorner"
	name = "blue anticorner"

/obj/effect/turf_decal/tile/blue/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted blue anticorner"

/obj/effect/turf_decal/tile/blue/fourcorners //The reason why we have four corners is to replace the trend of having all four corners on a tile be taken up by four individual corners, while still allowing the visual contrast between the decal and the floor tile.
	icon_state = "tile_fourcorners"
	name = "blue fourcorners"

/obj/effect/turf_decal/tile/blue/full
	icon_state = "tile_full"
	name = "blue full"

/obj/effect/turf_decal/tile/blue/diagonal_centre
	icon_state = "diagonal_centre"
	name = "blue diagonal centre"

/obj/effect/turf_decal/tile/blue/diagonal_edge
	icon_state = "diagonal_edge"
	name = "blue diagonal edge"

/// Green tiles

/obj/effect/turf_decal/tile/green
	name = "green corner"
	color = "#9FED58"

/obj/effect/turf_decal/tile/green/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing green corners"

/obj/effect/turf_decal/tile/green/half
	icon_state = "tile_half"
	name = "green half"

/obj/effect/turf_decal/tile/green/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted green half"

/obj/effect/turf_decal/tile/green/anticorner
	icon_state = "tile_anticorner"
	name = "green anticorner"

/obj/effect/turf_decal/tile/green/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted green anticorner"

/obj/effect/turf_decal/tile/green/fourcorners
	icon_state = "tile_fourcorners"
	name = "green fourcorners"

/obj/effect/turf_decal/tile/green/full
	icon_state = "tile_full"
	name = "green full"

/obj/effect/turf_decal/tile/green/diagonal_centre
	icon_state = "diagonal_centre"
	name = "green diagonal centre"

/obj/effect/turf_decal/tile/green/diagonal_edge
	icon_state = "diagonal_edge"
	name = "green diagonal edge"

/// Yellow tiles

/obj/effect/turf_decal/tile/yellow
	name = "yellow corner"
	color = "#EFB341"

/obj/effect/turf_decal/tile/yellow/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing yellow corners"

/obj/effect/turf_decal/tile/yellow/half
	icon_state = "tile_half"
	name = "yellow half"

/obj/effect/turf_decal/tile/yellow/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted yellow half"

/obj/effect/turf_decal/tile/yellow/anticorner
	icon_state = "tile_anticorner"
	name = "yellow anticorner"

/obj/effect/turf_decal/tile/yellow/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted yellow anticorner"

/obj/effect/turf_decal/tile/yellow/fourcorners
	icon_state = "tile_fourcorners"
	name = "yellow fourcorners"

/obj/effect/turf_decal/tile/yellow/full
	icon_state = "tile_full"
	name = "yellow full"

/obj/effect/turf_decal/tile/yellow/diagonal_centre
	icon_state = "diagonal_centre"
	name = "yellow diagonal centre"

/obj/effect/turf_decal/tile/yellow/diagonal_edge
	icon_state = "diagonal_edge"
	name = "yellow diagonal edge"

/// Red tiles

/obj/effect/turf_decal/tile/red
	name = "red corner"
	color = "#DE3A3A"

/obj/effect/turf_decal/tile/red/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing red corners"

/obj/effect/turf_decal/tile/red/half
	icon_state = "tile_half"
	name = "red half"

/obj/effect/turf_decal/tile/red/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted red half"

/obj/effect/turf_decal/tile/red/anticorner
	icon_state = "tile_anticorner"
	name = "red anticorner"

/obj/effect/turf_decal/tile/red/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted red anticorner"

/obj/effect/turf_decal/tile/red/fourcorners
	icon_state = "tile_fourcorners"
	name = "red fourcorners"

/obj/effect/turf_decal/tile/red/full
	icon_state = "tile_full"
	name = "red full"

/obj/effect/turf_decal/tile/red/diagonal_centre
	icon_state = "diagonal_centre"
	name = "red diagonal centre"

/obj/effect/turf_decal/tile/red/diagonal_edge
	icon_state = "diagonal_edge"
	name = "red diagonal edge"
	
/// Purple tiles

/obj/effect/turf_decal/tile/purple
	name = "purple corner"
	color = "#D381C9"

/obj/effect/turf_decal/tile/purple/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing purple corners"

/obj/effect/turf_decal/tile/purple/half
	icon_state = "tile_half"
	name = "purple half"

/obj/effect/turf_decal/tile/purple/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted purple half"

/obj/effect/turf_decal/tile/purple/anticorner
	icon_state = "tile_anticorner"
	name = "purple anticorner"

/obj/effect/turf_decal/tile/purple/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted purple anticorner"

/obj/effect/turf_decal/tile/purple/fourcorners
	icon_state = "tile_fourcorners"
	name = "purple fourcorners"

/obj/effect/turf_decal/tile/purple/full
	icon_state = "tile_full"
	name = "purple full"

/obj/effect/turf_decal/tile/purple/diagonal_centre
	icon_state = "diagonal_centre"
	name = "purple diagonal centre"

/obj/effect/turf_decal/tile/purple/diagonal_edge
	icon_state = "diagonal_edge"
	name = "purple diagonal edge"

/// Brown tiles

/obj/effect/turf_decal/tile/brown
	name = "brown corner"
	color = "#A46106"

/obj/effect/turf_decal/tile/brown/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing brown corners"

/obj/effect/turf_decal/tile/brown/half
	icon_state = "tile_half"
	name = "brown half"

/obj/effect/turf_decal/tile/brown/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted brown half"

/obj/effect/turf_decal/tile/brown/anticorner
	icon_state = "tile_anticorner"
	name = "brown anticorner"
/obj/effect/turf_decal/tile/brown/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted brown anticorner"

/obj/effect/turf_decal/tile/brown/fourcorners
	icon_state = "tile_fourcorners"
	name = "brown fourcorners"

/obj/effect/turf_decal/tile/brown/full
	icon_state = "tile_full"
	name = "brown full"

/obj/effect/turf_decal/tile/brown/diagonal_centre
	icon_state = "diagonal_centre"
	name = "brown diagonal centre"

/obj/effect/turf_decal/tile/brown/diagonal_edge
	icon_state = "diagonal_edge"
	name = "brown diagonal edge"

/// Neutral tiles

/obj/effect/turf_decal/tile/neutral
	name = "neutral corner"
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/tile/neutral/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing neutral corners"

/obj/effect/turf_decal/tile/neutral/half
	icon_state = "tile_half"
	name = "neutral half"

/obj/effect/turf_decal/tile/neutral/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted neutral half"

/obj/effect/turf_decal/tile/neutral/anticorner
	icon_state = "tile_anticorner"
	name = "neutral anticorner"

/obj/effect/turf_decal/tile/neutral/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted neutral anticorner"

/obj/effect/turf_decal/tile/neutral/fourcorners
	icon_state = "tile_fourcorners"
	name = "neutral fourcorners"

/obj/effect/turf_decal/tile/neutral/full
	icon_state = "tile_full"
	name = "neutral full"

/obj/effect/turf_decal/tile/neutral/diagonal_centre
	icon_state = "diagonal_centre"
	name = "neutral diagonal centre"

/obj/effect/turf_decal/tile/neutral/diagonal_edge
	icon_state = "diagonal_edge"
	name = "neutral diagonal edge"

/// Dark tiles

/obj/effect/turf_decal/tile/dark
	name = "dark corner"
	color = "#0e0f0f"

/obj/effect/turf_decal/tile/dark/opposingcorners
	icon_state = "tile_opposing_corners"
	name = "opposing dark corners"

/obj/effect/turf_decal/tile/dark/half
	icon_state = "tile_half"
	name = "dark half"

/obj/effect/turf_decal/tile/dark/half/contrasted
	icon_state = "tile_half_contrasted"
	name = "contrasted dark half"

/obj/effect/turf_decal/tile/dark/anticorner
	icon_state = "tile_anticorner"
	name = "dark anticorner"

/obj/effect/turf_decal/tile/dark/anticorner/contrasted
	icon_state = "tile_anticorner_contrasted"
	name = "contrasted dark anticorner"

/obj/effect/turf_decal/tile/dark/fourcorners
	icon_state = "tile_fourcorners"
	name = "dark fourcorners"

/obj/effect/turf_decal/tile/dark/full
	icon_state = "tile_full"
	name = "dark full"

/obj/effect/turf_decal/tile/dark/diagonal_centre
	icon_state = "diagonal_centre"
	name = "dark diagonal centre"

/obj/effect/turf_decal/tile/dark/diagonal_edge
	icon_state = "diagonal_edge"
	name = "dark diagonal edge"

/// Weird snowflake ones

/obj/effect/turf_decal/tile/bar
	name = "bar corner"
	color = "#791500"
	alpha = 130

/obj/effect/turf_decal/tile/random // so many colors
	name = "colorful corner"
	color = "#E300FF" //bright pink as default for mapping

/obj/effect/turf_decal/tile/random/Initialize()
	color = "#[random_short_color()]"
	. = ..()

/obj/effect/turf_decal/trimline
	layer = TURF_PLATING_DECAL_LAYER
	alpha = 110
	icon_state = "trimline_box"

/obj/effect/turf_decal/trimline/Initialize()
	if(SSevents.holidays && SSevents.holidays[APRIL_FOOLS])
		color = "#[random_short_color()]"
	. = ..()

/// White trimlines

/obj/effect/turf_decal/trimline/white
	color = "#FFFFFF"

/obj/effect/turf_decal/trimline/white/line
	name = "trim decal"
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/white/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/white/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/white/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/white/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/white/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/white/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/white/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/white/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/white/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/white/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/white/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/white/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/white/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/white/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/white/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/white/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/white/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/white/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/white/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/white/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/white/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/white/warning/lower
	icon_state = "trimline_warn_lower"

/obj/effect/turf_decal/trimline/white/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"

/// Red trimlines

/obj/effect/turf_decal/trimline/red
	color = "#DE3A3A"

/obj/effect/turf_decal/trimline/red/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/red/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/red/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/red/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/red/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/red/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/red/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/red/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/red/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/red/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/red/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/red/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/red/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/red/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/red/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/red/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/red/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/red/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/red/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/red/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/red/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/red/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/red/warning/lower
	icon_state = "trimline_warn_lower"

/obj/effect/turf_decal/trimline/red/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"

/// Green trimlines

/obj/effect/turf_decal/trimline/green
	color = "#9FED58"

/obj/effect/turf_decal/trimline/green/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/green/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/green/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/green/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/green/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/green/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/green/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/green/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/green/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/green/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/green/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/green/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/green/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/green/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/green/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/green/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/green/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/green/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/green/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/green/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/green/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/green/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/green/warning/lower
	icon_state = "trimline_warn_lower"

/obj/effect/turf_decal/trimline/green/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"

/// Blue trimlines

/obj/effect/turf_decal/trimline/blue
	color = "#52B4E9"

/obj/effect/turf_decal/trimline/blue/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/blue/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/blue/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/blue/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/blue/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/blue/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/blue/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/blue/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/blue/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/blue/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/blue/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/blue/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/blue/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/blue/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/blue/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/blue/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/blue/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/blue/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/blue/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/blue/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/blue/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/blue/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/blue/warning/lower
	icon_state = "trimline_warn_lower"

/obj/effect/turf_decal/trimline/blue/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"

/// Yellow trimlines

/obj/effect/turf_decal/trimline/yellow
	color = "#EFB341"

/obj/effect/turf_decal/trimline/yellow/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/yellow/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/yellow/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/yellow/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/yellow/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/yellow/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/yellow/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/yellow/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/yellow/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/yellow/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/yellow/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/yellow/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/yellow/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/yellow/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/yellow/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/yellow/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/yellow/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/yellow/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/yellow/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/yellow/warning/lower
	icon_state = "trimline_warn_lower"

/obj/effect/turf_decal/trimline/yellow/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"

/// Purple trimlines

/obj/effect/turf_decal/trimline/purple
	color = "#D381C9"

/obj/effect/turf_decal/trimline/purple/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/purple/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/purple/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/purple/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/purple/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/purple/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/purple/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/purple/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/purple/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/purple/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/purple/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/purple/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/purple/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/purple/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/purple/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/purple/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/purple/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/purple/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/purple/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/purple/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/purple/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/purple/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/purple/warning/lower
	icon_state = "trimline_warn_lower"

/obj/effect/turf_decal/trimline/purple/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"

/// Brown trimlines

/obj/effect/turf_decal/trimline/brown
	color = "#A46106"

/obj/effect/turf_decal/trimline/brown/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/brown/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/brown/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/brown/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/brown/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/brown/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/brown/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/brown/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/brown/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/brown/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/brown/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/brown/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/brown/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/brown/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/brown/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/brown/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/brown/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/brown/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/brown/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/brown/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/brown/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/brown/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/brown/warning/lower
	icon_state = "trimline_warn_lower"

/obj/effect/turf_decal/trimline/brown/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"

/// Neutral trimlines

/obj/effect/turf_decal/trimline/neutral
	color = "#D4D4D4"
	alpha = 50

/obj/effect/turf_decal/trimline/neutral/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/neutral/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/neutral/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/neutral/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/neutral/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/neutral/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/neutral/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/neutral/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/neutral/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/neutral/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/neutral/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/neutral/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/neutral/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/neutral/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/neutral/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/neutral/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/neutral/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/neutral/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/neutral/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/neutral/warning/lower
	icon_state = "trimline_warn_lower"

/obj/effect/turf_decal/trimline/neutral/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"

/// DarkBlue trimlines
/obj/effect/turf_decal/trimline/darkblue
	color = "#384e6d"
	alpha = 220

/obj/effect/turf_decal/trimline/darkblue/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/darkblue/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/darkblue/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/darkblue/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/darkblue/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/darkblue/warning
	icon_state = "trimline_warn"
	alpha = 150

/obj/effect/turf_decal/trimline/darkblue/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/darkblue/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/warning
	icon_state = "trimline_warn_fill"
		alpha = 150

/obj/effect/turf_decal/trimline/darkblue/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/darkblue/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/darkblue/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/darkblue/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"
	alpha = 150

/obj/effect/turf_decal/trimline/darkblue/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/darkblue/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/darkblue/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/darkblue/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/darkblue/warning/lower
	icon_state = "trimline_warn_lower"
	alpha = 150

/obj/effect/turf_decal/trimline/darkblue/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"
	alpha = 150

/// Secred trimlines

/obj/effect/turf_decal/trimline/secred
	color = "#D12A2B"
	alpha = 220

/obj/effect/turf_decal/trimline/secred/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/secred/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/secred/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/secred/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/secred/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/secred/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/secred/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/secred/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/secred/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/secred/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/secred/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/secred/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/secred/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/secred/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/secred/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/secred/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/secred/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/secred/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/secred/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/secred/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/secred/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/secred/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/secred/warning/lower
	icon_state = "trimline_warn_lower"
	alpha = 160

/obj/effect/turf_decal/trimline/secred/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"
	alpha = 160

/// engiyellow trimlines

/obj/effect/turf_decal/trimline/engiyellow
	color = "#CCB223"
	alpha = 220

/obj/effect/turf_decal/trimline/engiyellow/line
	icon_state = "trimline"

/obj/effect/turf_decal/trimline/engiyellow/corner
	icon_state = "trimline_corner"

/obj/effect/turf_decal/trimline/engiyellow/end
	icon_state = "trimline_end"

/obj/effect/turf_decal/trimline/engiyellow/arrow_cw
	icon_state = "trimline_arrow_cw"

/obj/effect/turf_decal/trimline/engiyellow/arrow_ccw
	icon_state = "trimline_arrow_ccw"

/obj/effect/turf_decal/trimline/engiyellow/warning
	icon_state = "trimline_warn"

/obj/effect/turf_decal/trimline/engiyellow/mid_joiner
	icon_state = "trimline_mid"

/obj/effect/turf_decal/trimline/engiyellow/filled
	icon_state = "trimline_box_fill"

/obj/effect/turf_decal/trimline/engiyellow/filled/line
	icon_state = "trimline_fill"

/obj/effect/turf_decal/trimline/engiyellow/filled/corner
	icon_state = "trimline_corner_fill"

/obj/effect/turf_decal/trimline/engiyellow/filled/end
	icon_state = "trimline_end_fill"

/obj/effect/turf_decal/trimline/engiyellow/filled/arrow_cw
	icon_state = "trimline_arrow_cw_fill"

/obj/effect/turf_decal/trimline/engiyellow/filled/arrow_ccw
	icon_state = "trimline_arrow_ccw_fill"

/obj/effect/turf_decal/trimline/engiyellow/filled/warning
	icon_state = "trimline_warn_fill"

/obj/effect/turf_decal/trimline/engiyellow/filled/mid_joiner
	icon_state = "trimline_mid_fill"

/obj/effect/turf_decal/trimline/engiyellow/filled/shrink_cw
	icon_state = "trimline_shrink_cw"

/obj/effect/turf_decal/trimline/engiyellow/filled/shrink_ccw
	icon_state = "trimline_shrink_ccw"

/obj/effect/turf_decal/trimline/engiyellow/filled/warning/flip
	icon_state = "trimline_warn_fill_flip"

/obj/effect/turf_decal/trimline/engiyellow/filled/line/lower
	icon_state = "trimline_fill_lower"

/obj/effect/turf_decal/trimline/engiyellow/filled/shrink_cw/lower
	icon_state = "trimline_shrink_cw_lower"

/obj/effect/turf_decal/trimline/engiyellow/filled/shrink_ccw/lower
	icon_state = "trimline_shrink_ccw_lower"

/obj/effect/turf_decal/trimline/engiyellow/corner/lower
	icon_state = "trimline_corner_lower"

/obj/effect/turf_decal/trimline/engiyellow/warning/lower
	icon_state = "trimline_warn_lower"
	alpha = 160

/obj/effect/turf_decal/trimline/engiyellow/warning/lower/flip
	icon_state = "trimline_warn_lower_flip"
	alpha = 160

///TESTING

/obj/effect/turf_decal/trimline/atmos/filled/line/lower
	icon_state = "trimline_fill_lower_gap"
	color = "#CCB223"
	alpha = 220

/obj/effect/turf_decal/trimline/atmos/filled/mid_joiner_lower_big
	icon_state = "trimline_mid_fill_lower_big"
	color = "#539085"
	alpha = 220

/obj/effect/turf_decal/trimline/atmos/warning/lower
	icon_state = "trimline_warn_lower_nooutline"
	color = "#539085"
	alpha = 220

/obj/effect/turf_decal/trimline/atmos/warning/lower/nobottom
	icon_state = "trimline_warn_lower_nooutline_bottom"
	color = "#539085"
	alpha = 220
