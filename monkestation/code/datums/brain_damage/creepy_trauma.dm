#define OBSESSION_REVEAL_TIME	7.5 MINUTES //! After this amount of time is spent near the target, the obsession trauma will reveal its true nature to health analyzers.
/datum/brain_trauma/special/obsessed
	scan_desc = "monophobia"
	var/revealed = FALSE
	var/static/true_scan_desc = "psychotic schizophrenic delusions"



/datum/brain_trauma/special/obsessed/on_life(seconds_per_tick, times_fired)
	if(!obsession || obsession.stat == DEAD)
		viewing = FALSE//important, makes sure you no longer stutter when happy if you murdered them while viewing
		return
	if(get_dist(get_turf(owner), get_turf(obsession)) > 7)
		viewing = FALSE //they are further than our view range they are not viewing us
		out_of_view()
		return//so we're not searching everything in view every tick
	if(obsession in view(7, owner))
		viewing = TRUE
	else
		viewing = FALSE
	if(viewing)
		owner.add_mood_event("creeping", /datum/mood_event/creeping, obsession.name)
		total_time_creeping += seconds_per_tick SECONDS
		if(!revealed && (total_time_creeping >= OBSESSION_REVEAL_TIME))
			reveal()
		time_spent_away = 0
		if(attachedobsessedobj)//if an objective needs to tick down, we can do that since traumas coexist with the antagonist datum
			attachedobsessedobj.timer -= seconds_per_tick SECONDS //mob subsystem ticks every 2 seconds(?), remove 20 deciseconds from the timer. sure, that makes sense.
	else
		out_of_view()

/datum/brain_trauma/special/obsessed/proc/reveal()
	revealed = TRUE
	scan_desc = true_scan_desc
	to_chat(owner, "<span class='hypnophrase'>The deep, overwhelming concern for <span class='name'>[obsession.name]</span> within you continues to blossom, making you suddenly feel as if your obsessive behavior is somewhat more obvious...</span>")

#undef OBSESSION_REVEAL_TIME
