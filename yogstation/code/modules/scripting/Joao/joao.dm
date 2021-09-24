//The datum that's actually passed to the external scripting language, typically modified in-place.
/datum/script_packet
    var/datum/signal/subspace/vocal/signal // The message
    var/datum/script_error/err // A possible error. Left with errcode at 0 if there was no error.
/datum/script_packet/New(var/datum/signal/subspace/vocal/p)
    signal = p
    err = new

/datum/script_error
    var/what = "Nothing. :)" // Describes the error. Must be a string.
    var/code = 0; // 0 indicates success. Everything else indicates failure. Must be an integer.

/client/proc/execute_joao()
    set category = "Misc.Server Debug"
    set name = "Execute Joao Script"

    if(!check_rights(R_DEBUG))
        return

    var/script_text = input("Input Joao program:","Execute Joao Script", null) as message|null
    if(!script_text)
        return

    var/datum/signal/subspace/vocal/newsign = new // This runtimes, actually.
    newsign.data = list() // I guess, lol
    newsign.data["name"] = "source"
    newsign.data["message"] = "message"
    newsign.frequency = 1459;
    var/datum/script_packet/packet = new(newsign)
    var/ret = run_script(script_text,packet)
    if(packet.err.code < 0)
        message_admins("<span class='adminnotice'>Joao crashed! Error: [packet.err.what]</span>")
        return;
    if(packet.err.code)
        message_admins("<span class='adminnotice'>Joao runtimed! Error: [packet.err.what]</span>")
        return;
    if(!ret)
        message_admins("<span class='adminnotice'>Joao execution failed in a mysterious way!</span>")
        return;
    message_admins("<span class='adminnotice'>Joao execution successful!</span>")
    message_admins(packet.signal.data["message"])

/proc/run_script(script, datum/script_packet/sig) // Dummy proc; the real proc is within extools.
    return "Joao has not been initialized!"