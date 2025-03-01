/atom/movable/proc/mods_bring_them_to_life_fancy(size = 1)
    ADD_TRAIT(src, TRAIT_IMMOBILIZED, ADMIN_TRAIT)

    var/matrix/matrix_zero = matrix()
    matrix_zero.Scale(0,0)
    transform = matrix_zero

    var/matrix/matrix_one = matrix()

    var/list/created_heaven = list()
    var/turf/our_turf = get_turf(src)
    var/list/turfs = CORNER_BLOCK_OFFSET(our_turf, 2+size, 2+size, -1, -1)

    alpha = 0

    // Create and animate with delay based on distance
    for(var/turf/turf as anything in turfs)
        var/obj/effect/heaven = new /obj/effect/hell(turf)
        heaven.alpha = 0
        created_heaven += heaven

        // Calculate distance from center
        var/dist = get_dist(our_turf, turf)
        var/delay = (dist * 0.1) SECONDS  // 0.1 seconds delay per tile distance

        // Animate with calculated delay
        animate(heaven, alpha = 255, time = 2 SECONDS, delay = delay)
        // Fade out and delete after animation
        animate(alpha = 0, time = 2 SECONDS, delay = 4 SECONDS)
        QDEL_IN(heaven, 6 SECONDS)

    // Animate central object
    animate(src, transform = matrix_one, alpha = 255, time = 2 SECONDS)
    playsound(src,'monkestation/code/modules/veth_misc_items/unholy_spawn/adminspawn1.ogg',50,1)
    addtimer(CALLBACK(src, PROC_REF(remove_immobilize)), 2 SECONDS)

/atom/movable/proc/remove_immobilize()
    REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, ADMIN_TRAIT)

