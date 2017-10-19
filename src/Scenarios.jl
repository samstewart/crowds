module Scenarios
	using Grid
	using World

	function twoOffsetDoors(n)
		density = rand(0:1, n, n)

		obstacles = wallCells(density);

		density[obstacles] = 0;

		exits = BitArray(zeros(Bool, n, n));
		
		exit1 = (Integer(round(.50 * n)), 1);

		exit2 = (Integer(round(.80 * n)), Integer(round(.30 * n)));

		obstacles[:, last(exit2)] = true;

		makeExit!(exits, obstacles, exit1);
		
		obstacles[exit2] = false;

		density, obstacles, exits;
	end

	function entranceTube(n)
		halfn = Integer(round(.5 * n));

		density = rand(0:1, n, n)

		obstacles = wallCells(density);
		
		# two lanes in the middle (1 people wide)

		obstacles[halfn:n, halfn - 1] = true;
		obstacles[halfn:n, halfn + 1] = true;

		exits = BitArray(zeros(Bool, n, n));

		makeExit!(exits, obstacles, (n, halfn));

		density[obstacles] = 0;

		density, obstacles, exits;
	end

	function maze(n)
		density = rand(0:1, n, n)

		obstacles = wallCells(density);

		
		# make doorways with a width of 1 person and lanes a width of 4 people
		for y = 5:4:(n - 3)
			obstacles[:, y] = true;

			# then make a door
			obstacles[rand(2:(n -1)), y] = false;
		end


		exits = BitArray(zeros(Bool, n, n));

		makeExit!(exits, obstacles, (Integer(round(.5 * n)), 1));

		density[obstacles] = 0;

		density, obstacles, exits;
	end

	function randomFilledRoom(n)
		density = rand(0:1, n, n)

		obstacles = wallCells(density);

		density[obstacles] = 0;

		exits = BitArray(zeros(Bool, n, n));

		makeExit!(exits, obstacles, (n, Integer(round(.5 * n))));
		
		density, obstacles, exits;
	end
end

