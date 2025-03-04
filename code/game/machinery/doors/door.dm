//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
#define DOOR_REPAIR_AMOUNT 50	//amount of health regained per stack amount used

/obj/machinery/door
	name = "Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = CLOSED_DOOR_LAYER
	var/open_layer = OPEN_DOOR_LAYER
	var/closed_layer = CLOSED_DOOR_LAYER

	var/visible = 1
	var/p_open = 0
	var/operating = 0 //If true, the door is currently in an open or close cycle
	var/forcing = null //If true, someone is currently attempting to force this door open
	var/autoclose = 0
	var/glass = 0
	var/normalspeed = 1
	var/heat_proof = 0 // For glass airlocks/opacity firedoors
	var/air_properties_vary_with_direction = 0
	max_health = 150

	var/destroy_hits = 10 //How many strong hits it takes to destroy the door
	var/min_force = 10 //minimum amount of force needed to damage the door with a melee weapon or unarmed attack
	var/force_resist	=	1	//Used to determine whether a mob can force this door open with its bare hands
	var/force_time = 20 SECONDS

	var/hitsound = 'sound/weapons/smash.ogg' //sound door makes when hit with a weapon
	var/obj/item/stack/material/repairing
	var/block_air_zones = 1 //If set, air zones cannot merge across the door even when it is opened.
	var/close_door_at = 0 //When to automatically close the door, if possible
	var/list/connections = list("0", "0", "0", "0")
	var/list/blend_objects = list(/obj/structure/wall_frame, /obj/structure/window, /obj/structure/grille) // Objects which to blend with

	//Multi-tile doors
	dir = SOUTH
	var/width = 1

	// turf animation
	var/atom/movable/overlay/c_animation = null

	atmos_canpass = CANPASS_PROC


	//A list of areas we are on or bordering
	var/list/border_areas = list()

/* //Too many balance problems, needs some reconsidering
/obj/machinery/door/meddle()
	if (!density)
		close()
	else
		//Opening doors only works pre marker activation
		var/obj/machinery/marker/M = get_marker()
		if (!M.active)
			open()

	.=..()

*/

/obj/machinery/door/attack_generic(var/mob/user, var/damage, var/attack_verb, var/environment_smash)
	if(environment_smash >= 1)
		damage = max(damage, min_force)

	if(damage >= min_force)
		visible_message("<span class='danger'>\The [user] [attack_verb] into \the [src]!</span>")
		take_damage(damage)
	else
		visible_message("<span class='notice'>\The [user] bonks \the [src] harmlessly.</span>")
	attack_animation(user)

/obj/machinery/door/New()
	. = ..()
	if(density)
		layer = closed_layer
		update_heat_protection(get_turf(src))
	else
		layer = open_layer


	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size

	health = max_health
	update_connections(1)
	update_icon()

	update_nearby_tiles(need_rebuild=1)

/obj/machinery/door/Initialize(var/mapload)
	set_extension(src, /datum/extension/penetration/proc_call, .proc/CheckPenetration)
	if (isturf(loc))
		if (mapload)
			SSslow.doors_needing_areas.Add(src)	//Add ourselves for area updating later
		else
			update_areas()
	. = ..()

//Since this is a crazy expensive proc to run, we space it out in random intervals over the first five minutes of the round
/obj/machinery/door/proc/update_areas()
	for (var/area/AB in border_areas)
		AB.unregister_door(src)

	border_areas = list(get_area(src))//Always add our own area

	var/list/raytrace_turfs = list()

	for (var/turf/T as anything in turfs_in_view(world.view))
		var/area/A = get_area(T)
		if (!(A in border_areas))
			raytrace_turfs += T

	//34.2 with
	//25.1 without
	//43.5 with sleep
	raytrace_turfs = check_trajectory_mass(raytrace_turfs, src, pass_flags=PASS_FLAG_TABLE|PASS_FLAG_FLYING, allow_sleep = TRUE)

	for (var/turf/T as anything in raytrace_turfs)
		if (raytrace_turfs[T])
			border_areas |= get_area(T)

	for (var/area/AB in border_areas)
		AB.register_door(src)

/obj/machinery/door/Destroy()
	for (var/area/AB in border_areas)
		AB.unregister_door(src)
	border_areas = list()
	set_density(0)
	update_nearby_tiles()
	. = ..()

/obj/machinery/door/Process()
	if(close_door_at && world.time >= close_door_at)
		if(autoclose)
			close_door_at = next_close_time()
			close()
		else
			close_door_at = 0

/obj/machinery/door/proc/can_open(var/forced = FALSE)
	if(!density || operating || !ticker)
		return 0
	return 1

/obj/machinery/door/proc/can_close()
	if(density || operating || !ticker || (stat & BROKEN))
		return 0
	return 1

/obj/machinery/door/Bumped(atom/AM)
	if(p_open || operating) return
	if(ismob(AM))
		var/mob/M = AM
		if(world.time - M.last_bumped <= 10) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.restrained() && (!issmall(M) || ishuman(M)))
			bumpopen(M)
		return

	if(istype(AM, /mob/living/bot))
		var/mob/living/bot/bot = AM
		if(check_access(bot.botcard))
			if(density)
				open()
		return

	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && (allowed(mecha.occupant) || check_access_list(mecha.operation_req_access)))
				open()
			else
				do_animate("deny")
		return
	if(istype(AM, /obj/structure/bed/chair/wheelchair))
		var/obj/structure/bed/chair/wheelchair/wheel = AM
		if(density)
			if(wheel.pulling && (allowed(wheel.pulling)))
				open()
			else
				do_animate("deny")
		return
	return


/obj/machinery/door/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group) return !block_air_zones
	if(istype(mover) && mover.checkpass(PASS_FLAG_GLASS))
		return !opacity
	return !density


/obj/machinery/door/proc/bumpopen(mob/user as mob)
	if(operating)	return
	if(user.last_airflow > world.time - vsc.airflow_delay) //Fakkit
		return
	add_fingerprint(user)
	if(density)
		if(allowed(user))
			open()
		else
			do_animate("deny")
	return

/obj/machinery/door/bullet_act(var/obj/item/projectile/Proj)
	..()

	var/damage = Proj.get_structure_damage()

	// Emitter Blasts - these will eventually completely destroy the door, given enough time.
	if (damage > 90)
		destroy_hits--
		if (destroy_hits <= 0)
			visible_message("<span class='danger'>\The [name] disintegrates!</span>")
			switch (Proj.damage_type)
				if(BRUTE)
					new /obj/item/stack/material/steel(loc, 2)
					new /obj/item/stack/rods(loc, 3)
				if(BURN)
					new /obj/effect/decal/cleanable/ash(loc) // Turn it to ashes!
			qdel(src)

	if(damage)
		//cap projectile damage so that there's still a minimum number of hits required to break the door
		take_damage(min(damage, 100))



/obj/machinery/door/hitby(AM as mob|obj, var/speed=5)

	..()
	visible_message("<span class='danger'>[name] was hit by [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 15 * (speed/5)
	else
		tforce = AM:throwforce * (speed/5)
	playsound(loc, hitsound, 100, 1)
	take_damage(tforce)
	return

/obj/machinery/door/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/door/attack_hand(mob/user as mob)
	return attackby(user, user)

/obj/machinery/door/attack_tk(mob/user as mob)
	if(requiresID() && !allowed(null))
		return
	..()

/obj/machinery/door/attackby(obj/item/I as obj, mob/user as mob)
	add_fingerprint(user, 0, I)

	if(istype(I, /obj/item/stack/material) && I.get_material_name() == get_material_name())
		if(stat & BROKEN)
			to_chat(user, "<span class='notice'>It looks like \the [src] is pretty busted. It's going to need more than just patching up now.</span>")
			return
		if(health >= max_health)
			to_chat(user, "<span class='notice'>Nothing to fix!</span>")
			return
		if(!density)
			to_chat(user, "<span class='warning'>\The [src] must be closed before you can repair it.</span>")
			return

		//figure out how much metal we need
		var/amount_needed = (max_health - health) / DOOR_REPAIR_AMOUNT
		amount_needed = ceil(amount_needed)

		var/obj/item/stack/stack = I
		var/transfer
		if (repairing)
			transfer = stack.transfer_to(repairing, amount_needed - repairing.amount)
			if (!transfer)
				to_chat(user, "<span class='warning'>You must weld or remove \the [repairing] from \the [src] before you can add anything else.</span>")
		else
			repairing = stack.split(amount_needed, force=TRUE)
			if (repairing)
				repairing.loc = src
				transfer = repairing.amount
				repairing.uses_charge = FALSE //for clean robot door repair - stacks hint immortal if true

		if (transfer)
			to_chat(user, "<span class='notice'>You fit [transfer] [stack.singular_name]\s to damaged and broken parts on \the [src].</span>")

		return

	if(repairing && isWelder(I))
		if(!density)
			to_chat(user, "<span class='warning'>\The [src] must be closed before you can repair it.</span>")
			return

		to_chat(user, "<span class='notice'>You start to fix dents and weld \the [repairing] into place.</span>")
		if(I.use_tool(user, src, WORKTIME_NORMAL, QUALITY_WELDING, FAILCHANCE_NORMAL))
			to_chat(user, "<span class='notice'>You finish repairing the damage to \the [src].</span>")
			health = between(health, health + repairing.amount*DOOR_REPAIR_AMOUNT, max_health)
			update_icon()
			qdel(repairing)
			repairing = null
		return

	if(repairing && isCrowbar(I))
		to_chat(user, "<span class='notice'>You remove \the [repairing].</span>")
		playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
		repairing.loc = user.loc
		repairing = null
		return

	if(check_force(I, user))
		return

	if(operating > 0 || isrobot(user))	return //borgs can't attack doors open because it conflicts with their AI-like interaction with them.

	if(operating) return
	if(allowed(user) && operable())
		if(density)
			open()
		else
			close()
		return

	//Attacking with empty hands
	if (I == user)
		if (check_unarmed_force(I))
			return

	if(density)
		do_animate("deny")
	update_icon()
	return

/obj/machinery/door/emag_act(var/remaining_charges)
	if(density && operable())
		do_animate("emag")
		sleep(6)
		open()
		operating = -1
		return 1

//psa to whoever coded this, there are plenty of objects that need to call attack() on doors without bludgeoning them.
/obj/machinery/door/proc/check_force(obj/item/I as obj, mob/user as mob)
	if(density &&  user.a_intent == I_HURT && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card))
		var/obj/item/weapon/W = I
		user.set_click_cooldown(DEFAULT_ATTACK_COOLDOWN)

		if(W.damtype == BRUTE || W.damtype == BURN)
			hit(user, W, W.force)
			return TRUE


/obj/machinery/door/proc/check_unarmed_force(mob/user as mob)
	//Using bare hands to force the door open
	if (user.a_intent == I_GRAB)
		return user.force_door(src)
	else if (user.a_intent == I_HURT)
		return user.strike_door(src)
	return FALSE

/obj/machinery/door/proc/hit(var/mob/user, var/atom/hitter, var/damage, var/ignore_resistance = FALSE)
	if (user)
		user.do_attack_animation(src)
	var/reduced_damage = apply_resistance(damage, ignore_resistance)
	if(reduced_damage <= 0)
		return 0
	else
		playsound(loc, hitsound, reduced_damage, 1) //Volume of sound depends how hard we hit it
		//Heavy hits will shake the door.
		shake_animation(round(reduced_damage*0.5))
		take_damage(damage, ignore_resistance)

		if(health < max_health * 0.25)
			visible_message("\The [src] looks like it's about to break!" )
		else if(health < max_health * 0.5)
			visible_message("\The [src] looks seriously damaged!" )
		else if(health < max_health * 0.75)
			visible_message("\The [src] shows signs of damage!" )

		return reduced_damage

/obj/machinery/door/proc/take_damage(var/damage, var/ignore_resistance = FALSE)
	var/initialhealth = health

	if ((atom_flags & ATOM_FLAG_INDESTRUCTIBLE))
		return

	damage = apply_resistance(damage, ignore_resistance)
	if (!damage)
		return

	health = max(0, health - damage)
	if(health <= 0 && initialhealth > 0)
		break_open()

	update_icon()
	return

/obj/machinery/door/proc/apply_resistance(var/damage, var/ignore_resistance = FALSE)
	if (ignore_resistance)
		return damage

	damage -= min_force

	return max(damage, 0)

/obj/machinery/door/examine(mob/user)
	. = ..()
	if(health <= 0)
		to_chat(user, "\The [src] is broken!")
	else if(health < max_health / 4)
		to_chat(user, "\The [src] looks like it's about to break!")
	else if(health < max_health / 2)
		to_chat(user, "\The [src] looks seriously damaged!")
	else if(health < max_health * 3/4)
		to_chat(user, "\The [src] shows signs of damage!")

//When a door takes catastrophic damage it will open
/obj/machinery/door/proc/break_open()
	set_broken()
	open(TRUE)


/obj/machinery/door/proc/set_broken()
	stat |= BROKEN
	visible_message("<span class = 'warning'>\The [name] breaks!</span>")
	update_icon()


/obj/machinery/door/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(rand_between(500, 650))
		if(2)
			take_damage(rand_between(300, 400))
		if(3)
			if(prob(80))
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
			else
				take_damage(rand_between(100, 150))
			take_damage(rand_between(100, 150))


/obj/machinery/door/update_icon()
	if(connections in list(NORTH, SOUTH, NORTH|SOUTH))
		if(connections in list(WEST, EAST, EAST|WEST))
			set_dir(SOUTH)
		else
			set_dir(EAST)
	else
		set_dir(SOUTH)

	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"
	SSradiation.resistance_cache.Remove(get_turf(src))
	return


/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(p_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("spark")
			if(density)
				flick("door_spark", src)
		if("deny")
			if(density && !(stat & (NOPOWER|BROKEN)))
				flick("door_deny", src)
				playsound(loc, 'sound/machines/buzz-two.ogg', 50, 0)
	return


/obj/machinery/door/proc/open(var/forced = 0)
	set waitfor = FALSE
	if(!can_open(forced))
		return
	operating = 1

	do_animate("opening")
	icon_state = "door0"
	set_opacity(0)
	sleep(3)
	set_density(0)
	update_nearby_tiles()
	sleep(7)
	layer = open_layer
	update_icon()
	set_opacity(0)
	operating = 0

	//Wakeup nearby vines so they can start growing through the open space
	for (var/obj/effect/vine/V in range(1, src))
		V.wake_up()

	if(autoclose)
		close_door_at = next_close_time()

	return 1

/obj/machinery/door/proc/next_close_time()
	return world.time + (normalspeed ? 150 : 5)

/obj/machinery/door/proc/close(var/forced = 0)
	if(!can_close(forced))
		return
	operating = 1

	close_door_at = 0
	do_animate("closing")
	sleep(3)
	set_density(1)
	layer = closed_layer
	update_nearby_tiles()
	sleep(7)
	update_icon()
	if(visible && !glass)
		set_opacity(1)	//caaaaarn!
	operating = 0

	//I shall not add a check every x ticks if a door has closed over some fire.
	var/obj/fire/fire = locate() in loc
	if(fire)
		qdel(fire)
	return

/obj/machinery/door/proc/requiresID()
	return 1

/obj/machinery/door/allowed(mob/M)
	if(!requiresID())
		return ..(null) //don't care who they are or what they have, act as if they're NOTHING
	return ..(M)

/obj/machinery/door/update_nearby_tiles(need_rebuild)
	. = ..()
	for(var/turf/simulated/turf in locs)
		update_heat_protection(turf)
		SSair.mark_for_update(turf)
	return 1

/obj/machinery/door/proc/update_heat_protection(var/turf/simulated/source)
	if(istype(source))
		if(density && (opacity || heat_proof))
			source.thermal_conductivity = DOOR_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)

/obj/machinery/door/Move(new_loc, new_dir)
	update_nearby_tiles()

	. = ..()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size

	if(.)
		deconstruct(null, TRUE)

/obj/machinery/door/proc/CheckPenetration(var/base_chance, var/damage)
	. = damage/max_health*180
	if(glass)
		. *= 2
	. = round(.)

/obj/machinery/door/proc/deconstruct(mob/user, var/moved = FALSE)
	return null

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'

/obj/machinery/door/proc/update_connections(var/propagate = 0)
	var/dirs = 0

	for(var/direction in GLOB.cardinal)
		var/turf/T = get_step(src, direction)
		var/success = 0

		if( istype(T, /turf/simulated/wall))
			success = 1
			if(propagate)
				var/turf/simulated/wall/W = T
				W.update_connections(1)
				W.update_icon()

		else if( istype(T, /turf/simulated/shuttle/wall) ||  istype(T, /turf/unsimulated/wall))
			success = 1
		else
			for(var/obj/O in T)
				for(var/b_type in blend_objects)
					if( istype(O, b_type))
						success = 1

					if(success)
						break
				if(success)
					break

		if(success)
			dirs |= direction
	connections = dirs


//For forcing
/obj/machinery/door/proc/get_force_difficulty()
	. = force_resist



/obj/machinery/door/proc/get_force_time()
	. = force_time * get_force_difficulty()


/obj/machinery/door/repair(var/repair_power, var/datum/repair_source, var/mob/user)
	health = clamp(health+repair_power, 0, max_health)
	if(stat & BROKEN)
		stat &= ~BROKEN
	update_icon()

/obj/machinery/door/repair_needed()
	return max_health - health