/client/proc/admin_vox()
//This proc is a slightly-rewritten clone of /mob/living/silicon/ai/proc/announcement()
//Check over there to see what's different, if this ever breaks.
  set category = "Fun"
  set name = "Force AI Vox"
  set hidden = 0

  if(!check_rights(R_ADMIN))
    return

  var/message = input(src, "WARNING: Misuse of this verb can result in you being yelled at by Ross.", "Announcement") as text
//^ Remember to replace "Ross" with whoever owns the server in 20,000 years after Ross either dies of natural causes or is assassinated by Oakboscage
  var/voxType = input(src, "Male or female VOX?", "VOX-gender") in list("male", "female") //yogs - male vox

  if(!message)
    return

  var/list/words = splittext(trim(message), " ")//Turns the received text into an array of words
  var/list/incorrect_words = list()//Stores all the words that we can't say, so we can complain about it later

  if(words.len > 30)
  // While normally the length of an array is something you can only read and never write,
  //in DM, len is actually how you manage the size of the array. Editing it to value to like this is actually totally doable.
    words.len = 30

  if(voxType == "female") // The if for this is OUTSIDE the for-loop, for optimization.
  //Putting it inside makes it check for it every single damned time it parses a word,
  //Which might be super shitty if someone removes the length limit above at some point.
    for(var/word in words) // For each word
      word = lowertext(trim(word)) // We store the words as lowercase, so lowercase the word and trim off any weirdness like newlines
      if(!word) // If we accidentally captured a space or something weird like that
        words -= word // Scratch this one off the list
        continue // and skip over it
      if(!GLOB.vox_sounds[word])
        incorrect_words += word
  else if(voxType == "male") // If we're doing the yog-ly male AI vox voice
    for(var/word in words)
      word = lowertext(trim(word))
      if(!word)
        words -= word
        continue
      if(!GLOB.vox_sounds_male[word])
        incorrect_words += word
  else
    to_chat(src,"<span class='notice'>Unknown or unsupported vox type. Yell at a coder about this.</span>")

  if(incorrect_words.len)
    to_chat(src, "<span class='notice'>These words are not available on the announcement system: [english_list(incorrect_words)].</span>")
    return

  log_admin("[key_name(src)] made an admin AI vocal announcement with the following message: [message].")
  message_admins("[key_name_admin(src)] has forced an AI vox announcement.")
  if(src.mob) // If the admin has a mob, whether it's a ghost or whatever
    for(var/word in words) // Then play it
      play_vox_word(word, src.mob.loc.z, null, voxType) //yogs - male vox
  else // If, for some ungodly reason, the admin lacks a mob
    for(var/word in words) // Then play it on the station's Z-level
    //TODO: Make a define for the station's z-level
      play_vox_word(word, 2, null, voxType) //yogs - male vox
