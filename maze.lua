-- [[ Public ]] --

local Maze = {};
Maze.__index = Maze;

function Maze.new(MazeMap: {[number]: {boolean}}, Start: {[string]: number}, End: {[string]: number})
	-- MazeMap: A matrix that respresents the layout of the maze being solved.
	-- Start: A 2D vector which represents the start of the maze
	-- End: A 2D vector which represents the end of the maze

	local self = {}; -- Setting a metatable to the object to call methods on metatable in the future
	self.MazeMap = MazeMap;
	self.Start = Start;
	self.End = End;

	return (setmetatable(self, Maze));
end;

function Maze:_getSurroundingTiles(tileRow: number, tileColumn: number) -- Backend method that will be used by other methods and not in the object directly
	local surroundingTiles = 0;
	for coordinateType = 1, 2 do
		for direction = -1, 1, 2 do
			local x = coordinateType == 1 and tileColumn + direction or tileColumn
			local y = coordinateType == 2 and tileRow + direction or tileRow
			if (self.MazeMap[y] == nil or self.MazeMap[y][x] == nil) then
				continue;
			end;
			if (self.MazeMap[y][x] == true) then -- Checks if there is a tile surrounding the tile being checked by method at -1 to 1 x and at -1 to 1 y relatively
				surroundingTiles += 1;
			end;
		end;
	end;
	return (surroundingTiles);
end;

function Maze:_updatePath()
	for y in pairs(self.MazeMap) do -- Exclude "value" for index, value since only x, y are relevant
		for x in pairs(self.MazeMap[y]) do
			if (self:_getSurroundingTiles(y, x) <= 1 and not ((x == self.Start.X and y == self.Start.Y) or (x == self.End.X and y == self.End.Y))) then
				-- If there is less than one tile surrounding the tile AND the tile is not the start or end, mark it as not a part of the solution.
				self.MazeMap[y][x] = false; 
			end;
		end;
	end;
	return (self.MazeMap)
end;

function Maze:_matchPaths(oldPath: {[number]: {boolean}}, newPath: {[number]: {boolean}})
	local matchingPath = true;
	for y in pairs(oldPath) do
		for x, valid in pairs(oldPath[y]) do
			if (newPath[y][x] ~= valid) then -- check if path has been modified
				matchingPath = false;
				break;
			end;
		end;
	end;
	return (matchingPath);
end;

function Maze:GetPath()
	local previousMap = self.MazeMap;
	local newMap do
		repeat
			previousMap = newMap or self.MazeMap;
			newMap = self:_updatePath();
		until self:_matchPaths(previousMap, newMap); -- Checking for something is equivalant to checking if it's not equal to false or "nil"
	end;

	return (newMap);
end;

return (Maze);
