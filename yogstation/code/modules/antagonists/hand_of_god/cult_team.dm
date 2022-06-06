/datum/team/hog_cult
  name = "HoG Cult"
  member_name = "Cultist"
  var/mob/camera/hog_god/god
  var/energy = 0 
  var/max_energy = 0
  var/permanent_regen = 10 // 10 per ~2 seconds seems ok
  var/nexus 
  var/state = HOG_TEAM_EXISTING
