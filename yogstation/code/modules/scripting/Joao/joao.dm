/client/proc/execute_joao()
    set category = "Misc.Server Debug"
    set name = "Execute Joao Script"

    if(!check_rights(R_DEBUG))
        return

    var/script_text = input("Input Joao program:","Execute Joao Script", null) as text|null
    if(!script_text)
        return

    var/datum/signal/subspace/vocal/newsign = new
    newsign.data["name"] = "source"
    newsign.data["message"] = "message"
    newsign.frequency = 1459;
    var/ret = run_script(script_text,newsign)
    if(!ret)
        message_admins("<span class='adminnotice'>Joao execution failed!</span>")
    else
        message_admins(newsign.data["message"])

/proc/run_script(script, datum/signal/subspace/vocal/sig) // Dummy proc; the real proc is within extools.
    return "Joao has not been initialized!"