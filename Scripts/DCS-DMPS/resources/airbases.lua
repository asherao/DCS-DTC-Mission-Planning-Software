-- Airbase coordinates and altitude for all DCS maps
-- Makes tables for use in DMPS

--[[ Information can be retreived by using the following in a doLua in a mission:
local bases = world.getAirbases()
local lat
local lon
local alt

for i = 1, #bases do
	local nameOfAirbase = bases[i]:getCallsign()
	lat, lon, alt = coord.LOtoLL(bases[i]:getPoint())
	env.info('["' .. nameOfAirbase .. '"] = { latitude = ' .. lat .. ', longitude = ' .. lon .. ', altitude = ' .. alt .. '},')
end

trigger.action.outText('Done. Results are in dcs.log.',300)
--]]

airbases_caucasus = 
{
    ["Anapa-Vityazevo"] = { latitude = 45.013174733772, longitude = 37.359783477556, altitude = 43.00004196167},
    ["Krasnodar-Center"] = { latitude = 45.087429883845, longitude = 38.925202300775, altitude = 30.01003074646},
    ["Novorossiysk"] = { latitude = 44.673329604127, longitude = 37.78622606048, altitude = 40.010040283203},
    ["Krymsk"] = { latitude = 44.961383022734, longitude = 37.985886938697, altitude = 20.010303497314},
    ["Maykop-Khanskaya"] = { latitude = 44.671440257355, longitude = 40.021427482236, altitude = 180.01019287109},
    ["Gelendzhik"] = { latitude = 44.567674586004, longitude = 38.004146350528, altitude = 22.009923934937},
    ["Sochi-Adler"] = { latitude = 43.439378434051, longitude = 39.924231880466, altitude = 30.010034561157},
    ["Krasnodar-Pashkovsky"] = { latitude = 45.046099641543, longitude = 39.203066906325, altitude = 34.010036468506},
    ["Sukhumi-Babushara"] = { latitude = 42.852741071635, longitude = 41.142447588488, altitude = 13.338506698608},
    ["Gudauta"] = { latitude = 43.124233340197, longitude = 40.564175768401, altitude = 21.01003074646},
    ["Batumi"] = { latitude = 41.603279859649, longitude = 41.60927548351, altitude = 10.044037818909},
    ["Senaki-Kolkhi"] = { latitude = 42.238728081573, longitude = 42.061021312856, altitude = 13.239942550659},
    ["Kobuleti"] = { latitude = 41.932105353453, longitude = 41.876483823101, altitude = 18.01001739502},
    ["Kutaisi"] = { latitude = 42.17915393769, longitude = 42.4956840774, altitude = 45.010047912598},
    ["Mineralnye Vody"] = { latitude = 44.218646823807, longitude = 43.100679733081, altitude = 320.01031494141},
    ["Nalchik"] = { latitude = 43.51007143853, longitude = 43.625108736098, altitude = 430.01040649414},
    ["Mozdok"] = { latitude = 43.791303250938, longitude = 44.620327262102, altitude = 154.61184692383},
    ["Tbilisi-Lochini"] = { latitude = 41.674720064437, longitude = 44.946875226153, altitude = 479.69479370117},
    ["Soganlug"] = { latitude = 41.641163266787, longitude = 44.947183065317, altitude = 449.41024780273},
    ["Vaziani"] = { latitude = 41.637735936262, longitude = 45.01909093846, altitude = 464.50045776367},
    ["Beslan"] = { latitude = 43.208500987381, longitude = 44.588922553543, altitude = 524.00579833984}
}

airbases_persianGulf = 
{
    ["Abu Musa Island"] = { latitude = 25.875041761239, longitude = 55.021382072783,    altitude = 5.0000047683716},
    ["Bandar Abbas Intl"] = { latitude = 27.203638553985, longitude = 56.3703560378,    altitude = 5.587854385376},
    ["Bandar Lengeh"] = { latitude = 26.530817420578, longitude = 54.813116140778,      altitude = 24.653238296509},
    ["Al Dhafra AFB"] = { latitude = 24.25792911231, longitude = 54.534202504328,       altitude = 16.000015258789},
    ["Dubai Intl"] = { latitude = 25.248265300858, longitude = 55.379295777402,         altitude = 5.0000047683716},
    ["Al Maktoum Intl"] = { latitude = 24.888624487709, longitude = 55.174919966811,    altitude = 37.618499755859},
    ["Fujairah Intl"] = { latitude = 25.105735807567, longitude = 56.340423943738,      altitude = 18.52036857605},
    ["Tunb Island AFB"] = { latitude = 26.251538702312, longitude = 55.311280020098,    altitude = 13.000012397766},
    ["Havadarya"] = { latitude = 27.159927526116, longitude = 56.183089447173,          altitude = 15.458337783813},
    ["Khasab"] = { latitude = 26.179806360704, longitude = 56.24317158197,              altitude = 14.490728378296},
    ["Lar"] = { latitude = 27.674804842122, longitude = 54.368317250382,                altitude = 803.32891845703},
    ["Al Minhad AFB"] = { latitude = 25.026805920475, longitude = 55.383678016973,      altitude = 58.147457122803},
    ["Qeshm Island"] = { latitude = 26.76633161238, longitude = 55.918070160223,        altitude = 8.0288496017456},
    ["Sharjah Intl"] = { latitude = 25.322796067752, longitude = 55.531388153673,       altitude = 29.999982833862},
    ["Sirri Island"] = { latitude = 25.903343862392, longitude = 54.548214653399,       altitude = 5.4417409896851},
    ["Tunb Kochak"] = { latitude = 26.243605485601, longitude = 55.149352101732,        altitude = 4.6420245170593},
    ["Sir Abu Nuayr"] = { latitude = 25.216154518016, longitude = 54.23693990531,       altitude = 7.6827998161316},
    ["Kerman"] = { latitude = 30.257695568151, longitude = 56.958269051762,             altitude = 1751.4256591797},
    ["Shiraz Intl"] = { latitude = 29.533103964275, longitude = 52.609894223947,        altitude = 1487.0014648438},
    ["Sas Al Nakheel"] = { latitude = 24.448211362508, longitude = 54.514696522843,     altitude = 2.9455180168152},
    ["Bandar-e-Jask"] = { latitude = 25.650484470488, longitude = 57.792125537415,      altitude = 7.9505105018616},
    ["Abu Dhabi Intl"] = { latitude = 24.464722760717, longitude = 54.639226001065,     altitude = 28.000028610229},
    ["Al-Bateen"] = { latitude = 24.434059322946, longitude = 54.450706215697,          altitude = 3.6506268978119},
    ["Kish Intl"] = { latitude = 26.529651099908, longitude = 53.964909162786,          altitude = 35.000034332275},
    ["Al Ain Intl"] = { latitude = 24.276767283196, longitude = 55.611735832913,        altitude = 248.0495300293},
    ["Lavan Island"] = { latitude = 26.815354172873, longitude = 53.3416042246,         altitude = 22.910652160645},
    ["Jiroft"] = { latitude = 28.731593220974, longitude = 57.664118826397,             altitude = 812.00085449219},
    ["Ras Al Khaimah Intl"] = { latitude = 25.602262321804, longitude = 55.941864730965,    altitude = 21.589021682739},
    ["Liwa AFB"] = { latitude = 23.660697450016, longitude = 53.812497591899,               altitude = 121.93011474609}
}

airbases_syria =
{
    ["Abu al-Duhur"] = { latitude = 35.731462428174, longitude = 37.118801734534,           altitude = 250.00024414063},
    ["Adana Sakirpasa"] = { latitude = 36.988281127829, longitude = 35.291372307265,        altitude = 17.000017166138},
    ["Al Qusayr"] = { latitude = 34.566877297302, longitude = 36.5854147754,                altitude = 527.00054931641},
    ["An Nasiriyah"] = { latitude = 33.92656597361, longitude = 36.875344527767,            altitude = 837.16253662109},
    ["Tha'lah"] = { latitude = 32.698127092337, longitude = 36.402739209399,                altitude = 725.75042724609},
    ["Beirut-Rafic Hariri"] = { latitude = 33.836465479357, longitude = 35.487416760577,    altitude = 12.000012397766},
    ["Damascus"] = { latitude = 33.415340013895, longitude = 36.504254828586,               altitude = 612.00061035156},
    ["Marj as Sultan South"] = { latitude = 33.487483451402, longitude = 36.475050826595,   altitude = 611.96624755859},
    ["Al-Dumayr"] = { latitude = 33.604657449318, longitude = 36.735832718421,              altitude = 630.00061035156},
    ["Eyn Shemer"] = { latitude = 32.441791483481, longitude = 35.001899624572,             altitude = 28.576030731201},
    ["Gaziantep"] = { latitude = 36.951397233614, longitude = 37.464512889798,              altitude = 697.21142578125},
    ["H4"] = { latitude = 32.536851104207, longitude = 38.206376228872,                     altitude = 688.00067138672},
    ["Haifa"] = { latitude = 32.80645293353, longitude = 35.04502076035,                    altitude = 6.0000066757202},
    ["Hama"] = { latitude = 35.116099484431, longitude = 36.72547347191,                    altitude = 300.00030517578},
    ["Hatay"] = { latitude = 36.371269972814, longitude = 36.298090184913,                      altitude = 77.175567626953},
    ["Incirlik"] = { latitude = 36.994254281542, longitude = 35.412713065757,                   altitude = 47.783618927002},
    ["Jirah"] = { latitude = 36.094487121629, longitude = 37.951086106528,                      altitude = 356.71685791016},
    ["Khalkhalah"] = { latitude = 33.06361028266, longitude = 36.559784748722,                  altitude = 712.33355712891},
    ["King Hussein Air College"] = { latitude = 32.348793954817, longitude = 36.270213489366,   altitude = 672.00067138672},
    ["Kiryat Shmona"] = { latitude = 33.212372031645, longitude = 35.592419825247,              altitude = 93.483139038086},
    ["Bassel Al-Assad"] = { latitude = 35.411589930353, longitude = 35.95003283514,             altitude = 28.363424301147},
    ["Marj as Sultan North"] = { latitude = 33.500422745428, longitude = 36.466321617972,       altitude = 611.83978271484},
    ["Marj Ruhayyil"] = { latitude = 33.279509844412, longitude = 36.446981161337,              altitude = 658.59417724609},
    ["Megiddo"] = { latitude = 32.597578671655, longitude = 35.220203497046,                    altitude = 55.000053405762},
    ["Mezzeh"] = { latitude = 33.482713511778, longitude = 36.235064059083,                     altitude = 718.09167480469},
    ["Minakh"] = { latitude = 36.522812218953, longitude = 37.033622455645,                     altitude = 492.00051879883},
    ["Aleppo"] = { latitude = 36.182211524331, longitude = 37.210383232385,                     altitude = 382.19104003906},
    ["Palmyra"] = { latitude = 34.558235536659, longitude = 38.331123062337,                    altitude = 386.22402954102},
    ["Qabr as Sitt"] = { latitude = 33.458606617206, longitude = 36.356880859456,               altitude = 650.57080078125},
    ["Ramat David"] = { latitude = 32.666055265719, longitude = 35.165455922777,                altitude = 32.239345550537},
    ["Kuweires"] = { latitude = 36.18937442608, longitude = 37.570439309206,                altitude = 366.00036621094},
    ["Rayak"] = { latitude = 33.84290182523, longitude = 35.976931824797,                   altitude = 894.38146972656},
    ["Rene Mouawad"] = { latitude = 34.583953310218, longitude = 35.9986872567,             altitude = 4.410843372345},
    ["Rosh Pina"] = { latitude = 32.97928167649, longitude = 35.572651208285,           altitude = 263.91259765625},
    ["Sayqal"] = { latitude = 33.680052164369, longitude = 37.204068911005,             altitude = 693.00067138672},
    ["Shayrat"] = { latitude = 34.494640308217, longitude = 36.894468654443,            altitude = 803.97332763672},
    ["Tabqa"] = { latitude = 35.755613770805, longitude = 38.551250775516,              altitude = 335.00033569336},
    ["Taftanaz"] = { latitude = 35.973223381816, longitude = 36.785894108748,           altitude = 311.00030517578},
    ["Tiyas"] = { latitude = 34.522531432479, longitude = 37.645765105063,              altitude = 548.00054931641},
    ["Wujah Al Hajar"] = { latitude = 34.286960508475, longitude = 35.683990308563,     altitude = 188.67385864258},
    ["Gazipasa"] = { latitude = 36.297823085147, longitude = 32.286068490305,           altitude = 11.104940414429},
    ["Deir ez-Zor"] = { latitude = 35.280828897833, longitude = 40.190671143219,        altitude = 204.59194946289},
    ["Nicosia"] = { latitude = 35.150919822632, longitude = 33.275002451661,            altitude = 210.00021362305},
    ["Akrotiri"] = { latitude = 34.594065664734, longitude = 32.974818319372,           altitude = 18.946063995361},
    ["Kingsfield"] = { latitude = 35.016621196807, longitude = 33.721655835024,         altitude = 84.00008392334},
    ["Paphos"] = { latitude = 34.72239325815, longitude = 32.471801697209,              altitude = 12.305082321167},
    ["Larnaca"] = { latitude = 34.865619667975, longitude = 33.613584325006,            altitude = 5.0000047683716},
    ["Lakatamia"] = { latitude = 35.106311731529, longitude = 33.321670653775,          altitude = 231.00024414063},
    ["Ercan"] = { latitude = 35.159249791336, longitude = 33.49011058133,               altitude = 95.000091552734},
    ["Gecitkale"] = { latitude = 35.236403909864, longitude = 33.707277702803,          altitude = 45.000045776367},
    ["Pinarbashi"] = { latitude = 35.278334798852, longitude = 33.26701429987,          altitude = 235.00022888184},
    ["Naqoura"] = { latitude = 33.10790532693, longitude = 35.127285739707,             altitude = 115.27894592285},
    ["H3"] = { latitude = 32.940993052246, longitude = 39.732582868536,                 altitude = 774.86505126953},
    ["H3 Northwest"] = { latitude = 33.070356444511, longitude = 39.60662588777,        altitude = 785.70843505859},
    ["H3 Southwest"] = { latitude = 32.738030133825, longitude = 39.612247285995,       altitude = 814.00079345703},
    ["Ruwayshid"] = { latitude = 32.403696420912, longitude = 39.142215977076,          altitude = 908.02374267578},
    ["Sanliurfa"] = { latitude = 37.460456062347, longitude = 38.912852189935,          altitude = 823.94732666016},
    ["Kharab Ishk"] = { latitude = 36.546920540733, longitude = 38.587524391694,        altitude = 431.39971923828},
    ["Tal Siman"] = { latitude = 36.263473166914, longitude = 38.924054611964,          altitude = 299.00030517578},
    ["Raj al Issa East"] = { latitude = 35.021918232008, longitude = 35.900560445898,   altitude = 0},
    ["Raj al Issa West"] = { latitude = 35.021918232008, longitude = 35.900560445898,   altitude = 0},
    ["At Tanf"] = { latitude = 33.506450284054, longitude = 38.614884032103,            altitude = 710.00073242188}
}

airbases_marianaIslands = 
{
	["Rota Intl"] = { latitude = 14.174905098823, longitude = 145.23248560973, altitude = 173.38017272949},
	["Saipan Intl"] = { latitude = 15.115121634075, longitude = 145.71879827825, altitude = 65.000068664551},
	["Tinian Intl"] = { latitude = 14.997429376954, longitude = 145.60830605924, altitude = 73.154266357422},
	["Antonio B. Won Pat Intl"] = { latitude = 13.479569370694, longitude = 144.78477470703, altitude = 77.79207611084},
	["Olf Orote"] = { latitude = 13.436469450733, longitude = 144.6413730227, altitude = 28.364225387573},
	["Andersen AFB"] = { latitude = 13.57604707035, longitude = 144.91745889539, altitude = 166.12214660645},
	["Pagan Airstrip"] = { latitude = 18.122779139405, longitude = 145.76191440812, altitude = 16.033027648926},
	["North West Field"] = { latitude = 13.629365787313, longitude = 144.86661164669, altitude = 159.00015258789}
}

airbases_nevada =
{
	["Creech"] = { latitude = 36.584429875554, longitude = -115.68681060569, altitude = 952.94458007813},
	["Groom Lake"] = { latitude = 37.21913894289, longitude = -115.78531067518, altitude = 1369.8676757813},
	["McCarran International"] = { latitude = 36.076670073498, longitude = -115.16219006293, altitude = 661.37609863281},
	["Nellis"] = { latitude = 36.225662018016, longitude = -115.04380774353, altitude = 561.30914306641},
	["Beatty"] = { latitude = 36.868394298081, longitude = -116.78608313042, altitude = 967.13366699219},
	["Boulder City"] = { latitude = 35.943681644578, longitude = -114.86055178579, altitude = 646.66363525391},
	["Echo Bay"] = { latitude = 36.310471394437, longitude = -114.46933764146, altitude = 472.03369140625},
	["Henderson Executive"] = { latitude = 35.96746878808, longitude = -115.13347108341, altitude = 759.43688964844},
	["Jean"] = { latitude = 35.773785550964, longitude = -115.32570272555, altitude = 860.87591552734},
	["Laughlin"] = { latitude = 35.165905267476, longitude = -114.55986431857, altitude = 200.00019836426},
	["Lincoln County"] = { latitude = 37.793389585399, longitude = -114.41923699635, altitude = 1467.6899414063},
	["Mesquite"] = { latitude = 36.827345248734, longitude = -114.06033514493, altitude = 566.48736572266},
	["Mina"] = { latitude = 38.374546852088, longitude = -118.09349931622, altitude = 1390.5122070313},
	["North Las Vegas"] = { latitude = 36.213364566271, longitude = -115.18673756618, altitude = 679.27984619141},
	["Pahute Mesa"] = { latitude = 37.094831346541, longitude = -116.31539962949, altitude = 1541.3635253906},
	["Tonopah"] = { latitude = 38.058024445654, longitude = -117.07591711356, altitude = 1644.1396484375},
	["Tonopah Test Range"] = { latitude = 37.78403952166, longitude = -116.77330290767, altitude = 1686.8143310547},
}

airbases_normandy = 
{
	["Saint Pierre du Mont"] = { latitude = 49.389798010651, longitude = -0.94718266342205, altitude = 31.479330062866},
	["Lignerolles"] = { latitude = 49.177205679543, longitude = -0.7958757334612, altitude = 123.42208099365},
	["Cretteville"] = { latitude = 49.332240012696, longitude = -1.3723779380226, altitude = 28.970609664917},
	["Maupertus"] = { latitude = 49.648178828944, longitude = -1.4571358571432, altitude = 134.4774017334},
	["Brucheville"] = { latitude = 49.366981077377, longitude = -1.2230279213479, altitude = 13.913147926331},
	["Meautis"] = { latitude = 49.282648343461, longitude = -1.3081396300953, altitude = 25.325466156006},
	["Cricqueville-en-Bessin"] = { latitude = 49.369319237096, longitude = -1.0072100114739, altitude = 24.763647079468},
	["Lessay"] = { latitude = 49.204178350976, longitude = -1.4934234355577, altitude = 20.000019073486},
	["Sainte-Laurent-sur-Mer"] = { latitude = 49.36675380539, longitude = -0.8824032643885, altitude = 44.444278717041},
	["Biniville"] = { latitude = 49.440505741062, longitude = -1.4731015058198, altitude = 32.471389770508},
	["Cardonville"] = { latitude = 49.34523486575, longitude = -1.0474283884291, altitude = 30.951379776001},
	["Deux Jumeaux"] = { latitude = 49.345278583008, longitude = -0.97161044424325, altitude = 37.679191589355},
	["Chippelle"] = { latitude = 49.2391148928, longitude = -0.98038615665025, altitude = 38.041233062744},
	["Beuzeville"] = { latitude = 49.417372643629, longitude = -1.305002879718, altitude = 34.831809997559},
	["Azeville"] = { latitude = 49.479646014419, longitude = -1.324802841581, altitude = 22.806873321533},
	["Picauville"] = { latitude = 49.398516941571, longitude = -1.418533835482, altitude = 22.107479095459},
	["Le Molay"] = { latitude = 49.265216714199, longitude = -0.87589868085048, altitude = 31.954740524292},
	["Longues-sur-Mer"] = { latitude = 49.345151300429, longitude = -0.71158690392176, altitude = 68.611747741699},
	["Carpiquet"] = { latitude = 49.171764334807, longitude = -0.44799386568305, altitude = 57.000102996826},
	["Bazenville"] = { latitude = 49.301185444271, longitude = -0.57147718061433, altitude = 60.873630523682},
	["Sainte-Croix-sur-Mer"] = { latitude = 49.319851511578, longitude = -0.50921081860912, altitude = 48.796699523926},
	["Beny-sur-Mer"] = { latitude = 49.293694134644, longitude = -0.42630152319567, altitude = 60.732845306396},
	["Rucqueville"] = { latitude = 49.250934748799, longitude = -0.5707826008541, altitude = 58.80305480957},
	["Sommervieu"] = { latitude = 49.300287630575, longitude = -0.67900958382261, altitude = 56.978862762451},
	["Lantheuil"] = { latitude = 49.269369279491, longitude = -0.54523999071826, altitude = 53.291923522949},
	["Evreux"] = { latitude = 49.020414248382, longitude = 1.2119731697217, altitude = 129.00012207031},
	["Chailey"] = { latitude = 50.944852966358, longitude = -0.046775200622604, altitude = 41.12504196167},
	["Needs Oar Point"] = { latitude = 50.782224389189, longitude = -1.4255767695516, altitude = 9.1562595367432},
	["Funtington"] = { latitude = 50.860868223746, longitude = -0.87725550669251, altitude = 50.156299591064},
	["Tangmere"] = { latitude = 50.846186787328, longitude = -0.71335408590138, altitude = 14.517134666443},
	["Ford_AF"] = { latitude = 50.817854409042, longitude = -0.59847895414584, altitude = 8.8593835830688},
	["Argentan"] = { latitude = 48.771226854351, longitude = -0.0361607768347, altitude = 195.00019836426},
	["Goulet"] = { latitude = 48.753495622427, longitude = -0.10779973229473, altitude = 188.00018310547},
	["Barville"] = { latitude = 48.47845426012, longitude = 0.31732564159199, altitude = 141.0001373291},
	["Essay"] = { latitude = 48.521391694994, longitude = 0.25096382203079, altitude = 154.54702758789},
	["Hauterive"] = { latitude = 48.496112357228, longitude = 0.20367125211349, altitude = 145.35595703125},
	["Vrigny"] = { latitude = 48.668772183898, longitude = 0.002107477445553, altitude = 180.00018310547},
	["Conches"] = { latitude = 48.938754402589, longitude = 0.96813784137685, altitude = 165.00016784668},
}

airbases_theChannel = 
{
	["Abbeville Drucat"] = { latitude = 50.149531917406, longitude = 1.8362860929554, altitude = 56.028057098389},
	["Merville Calonne"] = { latitude = 50.615302099484, longitude = 2.6433201424095, altitude = 16.000015258789},
	["Saint Omer Longuenesse"] = { latitude = 50.728779428768, longitude = 2.2275923344968, altitude = 67.000068664551},
	["Dunkirk Mardyck"] = { latitude = 51.029470822466, longitude = 2.2484347681531, altitude = 5.0000047683716},
	["Manston"] = { latitude = 51.344455587934, longitude = 1.3279982667496, altitude = 49.00025177002},
	["Hawkinge"] = { latitude = 51.115113231725, longitude = 1.1605724302277, altitude = 160.00015258789},
	["Lympne"] = { latitude = 51.083691076152, longitude = 1.0124369664514, altitude = 107.00010681152},
	["Detling"] = { latitude = 51.308241263359, longitude = 0.60552410588841, altitude = 190.00018310547},
	["Eastchurch"] = { latitude = 51.390814422965, longitude = 0.84044302594886, altitude = 12.261972427368},
	["High Halden"] = { latitude = 51.122666449012, longitude = 0.68734669867666, altitude = 32.000030517578},
	["Headcorn"] = { latitude = 51.182949227001, longitude = 0.68148244699714, altitude = 35.000034332275},
	["Biggin Hill"] = { latitude = 51.328410172904, longitude = 0.034490518670974, altitude = 168.41766357422},
}