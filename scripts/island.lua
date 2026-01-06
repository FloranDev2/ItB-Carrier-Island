
-- create island
local island = easyEdit.island:add("Carrier_island_id")

island.name = "Carrier"

-- appends all assets in the path relative to mod's resource path
island:appendAssets("img/island/")

-- see the easyEdit wiki for details on everything below
island.shift = Point(14,13)
island.magic = Point(145,102)

island.regionData = {
	RegionInfo(Point( 50, 20), Point(-35,-30), 100), --0
	RegionInfo(Point(111, 47), Point( 10,-65), 100), --1
	RegionInfo(Point(229, 47), Point(-10,-25), 100), --2
	RegionInfo(Point( 82, 66), Point(-25, 10), 100), --3
	RegionInfo(Point( 82,143), Point(-10, 30), 100), --4
	RegionInfo(Point(178,178), Point( 20, 20), 100), --5
	RegionInfo(Point(278,115), Point(  0, 10), 100), --6
	RegionInfo(Point(229,108), Point(-15,-20), 100)  --7

	--[[
	RegionInfo(Point(  0,  0), Point(  0,  0), 100), --0
	RegionInfo(Point( 61, 27), Point(  0,  0), 100), --1
	RegionInfo(Point(179, 27), Point(  0,  0), 100), --2
	RegionInfo(Point( 32, 46), Point(  0,  0), 100), --3
	RegionInfo(Point( 32,123), Point(  0,  0), 100), --4
	RegionInfo(Point(128,158), Point(  0,  0), 100), --5
	RegionInfo(Point(228, 95), Point(  0,  0), 100), --6
	RegionInfo(Point(179, 88), Point(  0,  0), 100)  --7
	]]
}

island.network = {
	{1,3},     --0
	{0,2,3,4}, --1
	{1,6,7},   --2
	{0,1,4},   --3
	{0,3,5},   --4
	{4,6,7},   --5
	{2,5,7},   --6
	{2,5,6}    --7
}
