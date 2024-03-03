extends RichTextLabel

# trying to keep to one entry per artist -ish.
#  romanize! its kinda awkward ngl but everyone can read roman, if i leave them
# in japanese, non-japanese people wont be able to type them in!
#
#  i don't think im actually gonna translate these themselves, nor the string
# containing them, there's a number that mess
# with the edges a little grammatically in a way i dont think will translate.
#
#  the general vibe is stuff i really like that isn't super well known. i try
# to filter out stuff that is super popular because this is supposed to be
# a point-at-other-small-creators thing, although as of right now i'm smaller
# than anyone else here, lol. some stuff slips through for sure though.
#
#  if you're here reading this: no i will not add you to the list, sorz.

var pairs = {
	# nepotism
	"Cloidioid": "me",
	"Hickory 19px": "me",
	"my old uploads as seventhousandk": "me",
	
	# games. to be expanded prob.
	"LUFTRAUSERS": "Vlambeer",
	"Momodora Series": "Bombservice",
	"Eschatos": "Qute Corporation",
	"Kitten Burst": "Lithodelphis",
	"VA-11 Hall-A": "Sukeban Games",
	"Nykra": "ENDESGA",
	"eXceed 3rd": "FLAT & Tennen-sozai",
	"Hellsinker.": "Ruminant’s Whimper",
	"Balatro": "LocalThunk",
	
	# music
	"Be": "potsu and Rav",
	"Watermark": "gaburyu",
	"Watermark (nu_imi EXP)": "nu_imi",
	"atashi janai": "uotak",
	"Toshi Densetsu": "Metro Mew / ECLAIR GROOVE",
	"Sora de Oyasumi": "Aiobahn feat. Nagase Yuka",
	"power!": "hirihiri & Yaca",
	"Brickwall [Cover Ver.]": "hirihiri & Yaca", #two artists two entries it doesnt count
	"turtle thief": "PAS TASTA",
	"Epsilon Love": "six impala",
	"Jeapardy": "Fax Gang",
	"Vertex": "Manabu Namiki",
	"Aeronaut": "Yousuke Yasui",
	"Ubugoe": "Kikuo",
	"peace treaty": "dobi w/ oyeme",
	"LL": "puhyuneco",
	"Alter 17": "puhyuneco", # sorry i jsut love this guy's stuff
	"Let it Fade": "DEON OH",
	"Abyssal Drop": "fu_mou",
	"UNENDING LIGHT": "nuphory X luna lenta",
	"NOTHING WRONG": "doin' fine",
	"9%": "7_7",
	"Kaerimichi": "sagara_nao & nenne", # its my game i get to make an entire maltine section
	"Oyogu Mane": "Kabanagu",
	"all of [MARU-181]-???": "V.A.",
	"all of TECHCORE EVANGELIX": "MEGAREX", # mrx too
	"all of SPD GAR": "MEGAREX",
	"the alien 9 OST": "Kuniaki Haishima et al",
	"Mahou Kajou Lovely You!": "NANORAY",
	"damage": "yem",
	"decline": "nelyom ft. shane mccullough",
	"TAMAGOTCHIS": "foxsky",
	"MIGRAINES": "torr",
	"immortal": "jedwill prod. Underscores",
	"Hope + Repair": "vessence",
	"Yabuite": "Sebon", # yeah he gets 2
	"Flat4": "Sebon",
	"Cyber Kawaii Kunai Girl": "yanagamiyuki",
	"Cyber Kawaii Kunai Girl remix": "hallycore", # yeah im putting it twice, oretachi cyber kawaii kune!
	"the actor": "dynastic",
	"B I G W A V E": "icesawder",
	"thought in night": "newtown romancer",
	"WE'VE GOT GOOD BENEFITS": "Milkfish",
	"Song01": "tsuchinoyouni",
	"Majesty": "False Noise",
	"this is how you made me feel": "Aquath",
	"Endroll": "mikanzil & PSYQUI",
	"Collapsing": "mahziel",
	"SOAR": "cexiria",
	"Innermoon": "Mothtek",
	"infrequent flyers program": "defsharp",
	"smells like earth": "a r u k a.",
	"Re:Shara": "NormalM feat. natsuki karin",
	"Still Here": "Aiyru",
	"emancipate": "mimoto w/ apartment one",
	"Platonic": "unlucksi", # waiter! waiter! more maltine records!
	"Doubutsu": "quoree",
	"UKIYOE": "HYPRDRIVE",
	"(re)percussion": "drama trial",
	"DARK MOON FIREWORKS": "1trillionMPH",
	"nothing is sacred": "sewnfkt",
	"dont leave": "KENTENSHI",
	"Figure": "VITICZ w/ phritz and Hoshimiya Toto",
	"airhead": "goodnight lavender",
	"Physics": "Wolfgun (the whole album)",
	"CRY FOR HELP": "lil art project",
	"Dandelion": "Grandfather Forest",
	"Nothing Less": "knapsack",
	"djijam7widoj": "dive to the heart", # its uhhhh the one with the radially symmetric cuneiform
	"THE INEFFABLE TRUTH": "G JONES",
	
	# yt channels here
}

func _ready():
	clear()
	
	var sel = pairs.keys().pick_random()
	
	append_text("[right]" + tr("ALSO_CHECK_OUT") %[sel, pairs[sel]])
	
	#hidden for now, feels out of place in a demo
	visible = false
