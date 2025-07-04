/datum/outfit/job/clf
	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	back = /obj/item/storage/backpack/lightpack
	suit_contents = list(
		/obj/item/explosive/grenade/stick = 2,
	)

/datum/outfit/job/clf/standard
	name = "CLF Standard"
	jobtype = /datum/job/clf/standard

	head = /obj/item/clothing/head/strawhat
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pill_bottle/zoom

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/storage/box/m94 = 1,
	)

/datum/outfit/job/clf/standard/uzi
	belt = /obj/item/storage/belt/knifepouch
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/storage/box/m94 = 2,
		/obj/item/ammo_magazine/smg/uzi/extended = 8,
	)

/datum/outfit/job/clf/standard/skorpion
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/storage/box/m94 = 1,
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/ammo_magazine/smg/skorpion = 7,
	)

/datum/outfit/job/clf/standard/mpi_km
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/standard

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km = 6,
	)

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/storage/box/m94 = 2,
		/obj/item/explosive/plastique = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
	)

/datum/outfit/job/clf/standard/shotgun
	belt = /obj/item/storage/belt/shotgun/mixed
	suit_store = /obj/item/weapon/gun/shotgun/pump/standard

	backpack_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
	)

/datum/outfit/job/clf/standard/fanatic
	head = /obj/item/clothing/head/headband/rambo
	wear_suit = /obj/item/clothing/suit/storage/marine/boomvest
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/storage/box/m94 = 1,
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/explosive/grenade/phosphorus/upp = 1,
		/obj/item/ammo_magazine/smg/skorpion = 5,
	)

/datum/outfit/job/clf/standard/som_smg
	belt = /obj/item/storage/belt/marine/som/som_smg
	suit_store = /obj/item/weapon/gun/smg/som/basic

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/storage/box/m94 = 2,
		/obj/item/explosive/plastique = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
	)

/datum/outfit/job/clf/standard/garand
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/rifle/garand

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/garand = 6,
	)
	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/storage/box/m94 = 2,
		/obj/item/explosive/plastique = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
	)

/datum/outfit/job/clf/medic
	name = "CLF Medic"
	jobtype = /datum/job/clf/medic

	belt = /obj/item/storage/belt/lifesaver/full/upp
	head = /obj/item/clothing/head/tgmcberet/bloodred
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/skorpion
	l_pocket = /obj/item/storage/pouch/medical_injectors/medic

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/roller = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 1,
	)

/datum/outfit/job/clf/medic/uzi
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness
	r_pocket = /obj/item/storage/holster/flarepouch

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/roller = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 1,
		/obj/item/ammo_magazine/smg/uzi/extended = 7,
	)
	r_pocket_contents = list(
		/obj/item/weapon/gun/grenade_launcher/single_shot/flare = 1,
		/obj/item/explosive/grenade/flare = 6,
	)

/datum/outfit/job/clf/medic/skorpion
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness
	r_pocket = /obj/item/storage/holster/flarepouch

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/roller = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 1,
		/obj/item/ammo_magazine/smg/skorpion = 7,
	)
	r_pocket_contents = list(
		/obj/item/weapon/gun/grenade_launcher/single_shot/flare = 1,
		/obj/item/explosive/grenade/flare = 6,
	)

/datum/outfit/job/clf/medic/paladin
	suit_store = /obj/item/weapon/gun/shotgun/pump/cmb/mag_harness
	r_pocket = /obj/item/storage/pouch/shotgun

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/roller = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 1,
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/ammo_magazine/handful/flechette = 2,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 3,
		/obj/item/ammo_magazine/handful/flechette = 4,
	)

/datum/outfit/job/clf/specialist
	name = "CLF Specialist"
	jobtype = /datum/job/clf/specialist

	belt = /obj/item/storage/belt/marine
	w_uniform = /obj/item/clothing/under/colonist/webbing
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/helmet/marine
	r_pocket = /obj/item/storage/pouch/pistol
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid

	backpack_contents = list(
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 2,
		/obj/item/ammo_magazine/pistol/highpower = 2,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/explosive/plastique = 2,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/pistol/highpower = 2,
		/obj/item/weapon/gun/pistol/highpower = 1,
	)
	webbing_contents = list(
		/obj/item/explosive/grenade/stick = 4,
		/obj/item/explosive/grenade/smokebomb = 1,
	)

/datum/outfit/job/clf/specialist/dpm
	suit_store = /obj/item/weapon/gun/rifle/dpm

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/dpm = 6,
	)

/datum/outfit/job/clf/specialist/clf_heavyrifle
	suit_store = /obj/item/weapon/gun/clf_heavyrifle
	back = /obj/item/shotgunbox/clf_heavyrifle
	belt = /obj/item/storage/belt/utility/full

/datum/outfit/job/clf/specialist/clf_heavymachinegun
	suit_store = /obj/item/weapon/gun/kord
	belt = /obj/item/storage/belt/sparepouch

	belt_contents = list(
		/obj/item/ammo_magazine/kord = 3,
	)

/datum/outfit/job/clf/leader
	name = "CLF Leader"
	jobtype = /datum/job/clf/leader

	belt = /obj/item/storage/belt/marine
	w_uniform = /obj/item/clothing/under/colonist/webbing
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/militia
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/pistol
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid

	suit_contents = list(
		/obj/item/binoculars = 1,
		/obj/item/radio = 1,
	)
	backpack_contents = list(
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/storage/box/mre = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 2,
		/obj/item/ammo_magazine/pistol/highpower = 2,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/explosive/plastique = 2,
	)
	r_pocket_contents = list(
		/obj/item/ammo_magazine/pistol/highpower = 2,
		/obj/item/weapon/gun/pistol/highpower = 1,
	)
	webbing_contents = list(
		/obj/item/explosive/grenade/stick = 4,
		/obj/item/explosive/grenade/smokebomb = 1,
	)

/datum/outfit/job/clf/leader/assault_rifle
	suit_store = /obj/item/weapon/gun/rifle/m16/ugl

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 6,
	)

/datum/outfit/job/clf/leader/mpi_km
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/grenadier
	belt = /obj/item/storage/belt/marine/som

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km = 6,
	)

/datum/outfit/job/clf/leader/som_rifle
	suit_store = /obj/item/weapon/gun/rifle/som/basic
	belt = /obj/item/storage/belt/marine/som

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/som = 6,
	)
	webbing_contents = list(
		/obj/item/ammo_magazine/handful/micro_grenade = 2,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/cluster = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
	)

/datum/outfit/job/clf/leader/upp_rifle
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer/standard

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/type71 = 6,
	)
	webbing_contents = list(
		/obj/item/explosive/grenade/stick = 2,
		/obj/item/ammo_magazine/flamer_tank/mini = 2,
		/obj/item/explosive/grenade/smokebomb = 1,
	)

/datum/outfit/job/clf/leader/lmg_d
	suit_store = /obj/item/weapon/gun/rifle/lmg_d/magharness
	belt = /obj/item/storage/belt/marine/som

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/lmg_d = 6,
	)
