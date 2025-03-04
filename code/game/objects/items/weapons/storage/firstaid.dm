/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 */

/*
 * First Aid Kits
 */
/obj/item/weapon/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"

	throw_range = 8
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = DEFAULT_BOX_STORAGE
	use_sound = 'sound/effects/storage/box.ogg'

/obj/item/weapon/storage/firstaid/empty
	icon_state = "firstaid"
	name = "First-Aid (empty)"

/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

	startswith = list(
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/ointment = 2,
		/obj/item/weapon/storage/pill_bottle/antidexafen,
		/obj/item/weapon/storage/pill_bottle/paracetamol,
		/obj/item/stack/medical/splint
		)

/obj/item/weapon/storage/firstaid/trauma
	name = "trauma first-aid kit"
	desc = "It's an emergency medical kit for when people brought ballistic weapons to a laser fight."
	icon_state = "radfirstaid"
	item_state = "firstaid-advanced"

	startswith = list(
		/obj/item/weapon/storage/med_pouch/trauma = 4
		)

/obj/item/weapon/storage/firstaid/trauma/New()
	..()
	icon_state = pick("radfirstaid", "radfirstaid2", "radfirstaid3")

/obj/item/weapon/storage/firstaid/fire
	name = "fire first-aid kit"
	desc = "It's an emergency medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

	startswith = list(
		/obj/item/weapon/storage/med_pouch/burn = 4
		)

/obj/item/weapon/storage/firstaid/fire/New()
	..()
	icon_state = pick("ointment","firefirstaid")

/obj/item/weapon/storage/firstaid/toxin
	name = "toxin first aid"
	desc = "Used to treat when you have a high amount of toxins in your body."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

	startswith = list(
		/obj/item/weapon/storage/med_pouch/toxin = 4
		)

/obj/item/weapon/storage/firstaid/toxin/New()
	..()
	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

/obj/item/weapon/storage/firstaid/o2
	name = "oxygen deprivation first aid"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

	startswith = list(
		/obj/item/weapon/storage/med_pouch/oxyloss = 4
		)

/obj/item/weapon/storage/firstaid/adv
	name = "advanced first-aid kit"
	desc = "Contains advanced medical treatments."
	icon_state = "purplefirstaid"
	item_state = "firstaid-advanced"

	startswith = list(
		/obj/item/weapon/storage/pill_bottle/assorted,
		/obj/item/stack/medical/advanced/bruise_pack = 3,
		/obj/item/stack/medical/advanced/ointment = 2,
		/obj/item/stack/medical/splint
		)

/obj/item/weapon/storage/firstaid/combat
	name = "combat medical kit"
	desc = "Contains advanced medical treatments."
	icon_state = "bezerk"
	item_state = "firstaid-advanced"

	startswith = list(
		/obj/item/weapon/storage/pill_bottle/bicaridine,
		/obj/item/weapon/storage/pill_bottle/dermaline,
		/obj/item/weapon/storage/pill_bottle/dexalin_plus,
		/obj/item/weapon/storage/pill_bottle/dylovene,
		/obj/item/weapon/storage/pill_bottle/tramadol,
		/obj/item/weapon/storage/pill_bottle/spaceacillin,
		/obj/item/stack/medical/splint,
		)

/obj/item/weapon/storage/firstaid/stab
	name = "stabilisation first aid"
	desc = "Stocked with medical pouches and a stasis bag."
	icon_state = "stabfirstaid"
	item_state = "firstaid-advanced"

	startswith = list(
		/obj/item/weapon/storage/med_pouch/trauma,
		/obj/item/weapon/storage/med_pouch/burn,
		/obj/item/weapon/storage/med_pouch/oxyloss,
		/obj/item/weapon/storage/med_pouch/toxin,
		/obj/item/bodybag/cryobag
		)

/obj/item/weapon/storage/firstaid/surgery
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport and automatically sterilizes the content between uses."
	icon_state = "surgerykit"
	item_state = "firstaid-surgery"

	storage_slots = 14
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = null
	use_sound = 'sound/effects/storage/briefcase.ogg'

	can_hold = list(
		/obj/item/weapon/bonesetter,
		/obj/item/weapon/cautery,
		/obj/item/weapon/tool/saw/circular,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/retractor,
		/obj/item/weapon/scalpel,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/nanopaste
		)

	startswith = list(
		/obj/item/weapon/bonesetter,
		/obj/item/weapon/cautery,
		/obj/item/weapon/tool/saw/circular,
		/obj/item/weapon/hemostat,
		/obj/item/weapon/retractor,
		/obj/item/weapon/scalpel,
		/obj/item/weapon/surgicaldrill,
		/obj/item/weapon/bonegel,
		/obj/item/weapon/FixOVein,
		/obj/item/stack/medical/advanced/bruise_pack,
		)

/*
 * Pill Bottles
 */
/obj/item/weapon/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 21
	can_hold = list(/obj/item/weapon/reagent_containers/pill,/obj/item/weapon/dice,/obj/item/weapon/paper)
	allow_quick_gather = 1
	use_to_pickup = 1
	use_sound = 'sound/effects/storage/pillbottle.ogg'
	var/wrapper_color
	var/label

/obj/item/weapon/storage/pill_bottle/afterattack(mob/living/target, mob/living/user, proximity_flag)
	if(!proximity_flag || !istype(target) || target != user)
		return 1
	if(!contents.len)
		to_chat(user, "<span class='warning'>It's empty!</span>")
		return 1
	var/zone = user.zone_sel.selecting
	if(zone == BP_MOUTH && target.can_eat())
		user.visible_message("<span class='notice'>[user] pops a pill from \the [src].</span>")
		playsound(get_turf(src), 'sound/effects/peelz.ogg', 50)
		var/list/peelz = filter_list(contents,/obj/item/weapon/reagent_containers/pill/)
		if(peelz.len)
			var/obj/item/weapon/reagent_containers/pill/P = pick(peelz)
			remove_from_storage(P)
			P.attack(target,user)
			return 1

/obj/item/weapon/storage/pill_bottle/Initialize()
	. = ..()
	update_icon()

/obj/item/weapon/storage/pill_bottle/update_icon()
	overlays.Cut()
	if(wrapper_color)
		var/image/I = image(icon, "pillbottle_wrap")
		I.color = wrapper_color
		overlays += I

/obj/item/weapon/storage/pill_bottle/antitox
	name = "pill bottle (Dylovene)"
	desc = "Contains pills used to counter toxins."

	startswith = list(/obj/item/weapon/reagent_containers/pill/antitox = 21)
	wrapper_color = COLOR_GREEN

/obj/item/weapon/storage/pill_bottle/bicaridine
	name = "pill bottle (Bicaridine)"
	desc = "Contains pills used to stabilize the severely injured."

	startswith = list(/obj/item/weapon/reagent_containers/pill/bicaridine = 21)
	wrapper_color = COLOR_MAROON

/obj/item/weapon/storage/pill_bottle/dexalin_plus
	name = "pill bottle (Dexalin Plus)"
	desc = "Contains pills used to treat extreme cases of oxygen deprivation."

	startswith = list(/obj/item/weapon/reagent_containers/pill/dexalin_plus = 21)
	wrapper_color = COLOR_CYAN_BLUE

/obj/item/weapon/storage/pill_bottle/dexalin
	name = "pill bottle (Dexalin)"
	desc = "Contains pills used to treat oxygen deprivation."

	startswith = list(/obj/item/weapon/reagent_containers/pill/dexalin = 21)
	wrapper_color = COLOR_LIGHT_CYAN

/obj/item/weapon/storage/pill_bottle/dermaline
	name = "pill bottle (Dermaline)"
	desc = "Contains pills used to treat burn wounds."

	startswith = list(/obj/item/weapon/reagent_containers/pill/dermaline = 21)
	wrapper_color = "#e8d131"

/obj/item/weapon/storage/pill_bottle/dylovene
	name = "pill bottle (Dylovene)"
	desc = "Contains pills used to treat toxic substances in the blood."

	startswith = list(/obj/item/weapon/reagent_containers/pill/dylovene = 21)
	wrapper_color = COLOR_GREEN

/obj/item/weapon/storage/pill_bottle/inaprovaline
	name = "pill bottle (Inaprovaline)"
	desc = "Contains pills used to stabilize patients. Will normalise heart rates, minimize brain damage from oxygen loss and otherwise secure a patient for a short time."

	startswith = list(/obj/item/weapon/reagent_containers/pill/inaprovaline = 21)
	wrapper_color = COLOR_PALE_BLUE_GRAY

/obj/item/weapon/storage/pill_bottle/kelotane
	name = "pill bottle (Kelotane)"
	desc = "Contains pills used to treat burns."

	startswith = list(/obj/item/weapon/reagent_containers/pill/kelotane = 21)
	wrapper_color = COLOR_SUN

/obj/item/weapon/storage/pill_bottle/peridaxon
	name = "pill bottle (Peridaxon)"
	desc = "Contains pills used to control organ failure."

	startswith = list(/obj/item/weapon/reagent_containers/pill/peridaxon = 15)
	wrapper_color = COLOR_BLACK

/obj/item/weapon/storage/pill_bottle/spaceacillin
	name = "pill bottle (Spaceacillin)"
	desc = "A theta-lactam antibiotic. Effective against many diseases likely to be encountered in space."

	startswith = list(/obj/item/weapon/reagent_containers/pill/spaceacillin = 21)
	wrapper_color = COLOR_PALE_GREEN_GRAY

/obj/item/weapon/storage/pill_bottle/tramadol
	name = "pill bottle (Tramadol)"
	desc = "Contains pills used to relieve pain."

	startswith = list(/obj/item/weapon/reagent_containers/pill/tramadol = 21)
	wrapper_color = COLOR_PURPLE_GRAY

/obj/item/weapon/storage/pill_bottle/sugariron
	name = "pill bottle (Sugar Iron)"
	desc = "Contains pills used to regenerate blood. Less effective than actual blood transfusions."

	startswith = list(/obj/item/weapon/reagent_containers/pill/sugariron = 21)
	wrapper_color = COLOR_RED

//Baycode specific Psychiatry pills.
/obj/item/weapon/storage/pill_bottle/citalopram
	name = "pill bottle (Citalopram)"
	desc = "Mild antidepressant. For use in individuals suffering from depression or anxiety. 15u dose per pill."

	startswith = list(/obj/item/weapon/reagent_containers/pill/citalopram = 21)
	wrapper_color = COLOR_GRAY

/obj/item/weapon/storage/pill_bottle/methylphenidate
	name = "pill bottle (Methylphenidate)"
	desc = "Mental stimulant. For use in individuals suffering from ADHD, or general concentration issues. 15u dose per pill."

	startswith = list(/obj/item/weapon/reagent_containers/pill/methylphenidate = 21)
	wrapper_color = COLOR_GRAY

/obj/item/weapon/storage/pill_bottle/paroxetine
	name = "pill bottle (Paroxetine)"
	desc = "High-strength antidepressant. Only for use in severe depression. 10u dose per pill. <span class='warning'>WARNING: side-effects may include hallucinations.</span>"

	startswith = list(/obj/item/weapon/reagent_containers/pill/paroxetine = 21)
	wrapper_color = COLOR_GRAY

/obj/item/weapon/storage/pill_bottle/antidexafen
	name = "pill bottle (cold medicine)"
	desc = "All-in-one cold medicine. 15u dose per pill. Safe for babies like you!"

	startswith = list(/obj/item/weapon/reagent_containers/pill/antidexafen = 21)
	wrapper_color = COLOR_VIOLET

/obj/item/weapon/storage/pill_bottle/paracetamol
	name = "pill bottle (Paracetamol)"
	desc = "Mild painkiller, also known as Tylenol. Won't fix the cause of your headache (unlike cyanide), but might make it bearable."

	startswith = list(/obj/item/weapon/reagent_containers/pill/paracetamol = 21)
	wrapper_color = "#a2819e"

/obj/item/weapon/storage/pill_bottle/assorted
	name = "pill bottle (assorted)"
	desc = "Commonly found on paramedics, these assorted pill bottles contain all the basics."

	startswith = list(
			/obj/item/weapon/reagent_containers/pill/inaprovaline = 6,
			/obj/item/weapon/reagent_containers/pill/dylovene = 6,
			/obj/item/weapon/reagent_containers/pill/sugariron = 2,
			/obj/item/weapon/reagent_containers/pill/tramadol = 2,
			/obj/item/weapon/reagent_containers/pill/dexalin = 2,
			/obj/item/weapon/reagent_containers/pill/kelotane = 2,
			/obj/item/weapon/reagent_containers/pill/hyronalin
		)

/obj/item/weapon/storage/pill_bottle/nanoblood
	name = "pill bottle (Nanoblood)"
	desc = "A pillbottle containing nanoblood pills, capable of rapidly restoring lost blood."

	startswith = list(
			/obj/item/weapon/reagent_containers/pill/nanoblood = 21,
		)


/obj/item/weapon/storage/pill_bottle/tricordrazine
	name = "pill bottle (Tricordrazine)"
	desc = "A pillbottle containing tricordrazine pills. Capable of stimulating regrowth of damaged external tissue."

	startswith = list(
			/obj/item/weapon/reagent_containers/pill/tricordrazine = 21,
		)







/obj/item/weapon/storage/firstaid/ds_healkitmedical //this one should be available in medical, or spawn on medical doctors.
	name = "doctor's first-aid kit"
	desc = "Contains a variety of standard and advanced medical treatments."
	icon_state = "purplefirstaid"
	item_state = "firstaid-advanced"
	max_storage_space = DEFAULT_BACKPACK_STORAGE

	startswith = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/ds_medigel = 2, //medigel should be rare, there should be some on the map, maybe some available in stores but generally speaking should be rare, this is a heal-all solution, it can be applied and will pretty much guarantee survival. the only thing you might need to combine with it is nanoblood, as it does not regenerate blood on its own.
		/obj/item/weapon/storage/pill_bottle/dexalin_plus,
		/obj/item/weapon/storage/pill_bottle/dylovene,
		/obj/item/weapon/storage/pill_bottle/tramadol,
		/obj/item/weapon/storage/pill_bottle/inaprovaline,
		/obj/item/weapon/storage/pill_bottle/nanoblood,
		/obj/item/weapon/storage/pill_bottle/tricordrazine,
		/obj/item/stack/medical/advanced/bruise_pack = 3,
		/obj/item/stack/medical/advanced/ointment = 1,
		/obj/item/device/healthanalyzer
		)

/obj/item/weapon/storage/firstaid/ds_healkitemergency //this one should be found in a few areas, as it is only minor treatments. It can be used to seal wounds of both kinds (burn/brute) but offers minimal restorative properties, so you will not be able to last with these - only endure a little longer while you try to find proper meds.
	name = "emergency first-aid kit"
	desc = "Contains pills and tools to deal with injuries long enough to reach an area where they can be properly treated."
	icon_state = "firstaid"
	max_storage_space = DEFAULT_BACKPACK_STORAGE

	startswith = list(
		/obj/item/weapon/storage/pill_bottle/inaprovaline,
		/obj/item/weapon/storage/pill_bottle/tramadol,
		/obj/item/weapon/storage/pill_bottle/dexalin_plus,
		/obj/item/stack/medical/advanced/bruise_pack
		)

/obj/item/weapon/storage/firstaid/ds_healkitcombat //this one is for ERTs, since they will need to deal with casualties on the move rather than take the time to chug pills or diagnose an issue.
	name = "combat first-aid kit"
	desc = "Contains a variety of treatments designed for rapid application in a combat environment."
	icon_state = "bezerk"
	item_state = "firstaid-advanced"
	max_storage_space = DEFAULT_BACKPACK_STORAGE

	startswith = list(
		/obj/item/weapon/reagent_containers/food/drinks/bottle/ds_medigel = 6, //no need for other chems as this and inaproavline covers all damage types. also no health analyzer as ert medics spawn with one.
		/obj/item/weapon/storage/pill_bottle/inaprovaline, //stabilizes vitals, restores brain damage slightly.
		/obj/item/weapon/storage/pill_bottle/tramadol, // deals with pain
		/obj/item/weapon/storage/pill_bottle/nanoblood, //recovers blood
		/obj/item/weapon/storage/pill_bottle/tricordrazine, //for when the medigel runs out
		/obj/item/weapon/storage/pill_bottle/dexalin_plus, //to ensure oxygenation in the event of injury and such
		/obj/item/stack/medical/advanced/bruise_pack = 3, //stops bleeding, heals 5 brute per wound closed
		/obj/item/stack/medical/advanced/ointment = 1 //heals burns, 25 burn damage per wound closed.
		)
