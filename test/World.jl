using Base.Test;

@testset "World" begin
	push!(LOAD_PATH, "/home/ubuntu/workspace/crowds/src/");
	
	using World;
	
	@testset "isless(scored_cell1, scored_cell2)" begin

		@test World.isless((.2, (1,1)) , (.3, (1,1)));

		@test World.isless((.2, (1,1)), (.2, (1,1)));

	end	

	@testset "peopledCells(density)" begin

		@test World.peopledCells([1.0 0; 0.0 1.0]) == BitArray([true false; false true]);
	end	


	@testset "movePeopleBetweenCells!(density, src_cell, dst_cell)" begin

		A = [1 0; 0.0 0];

		World.movePeopleBetweenCells!(A, (1,1), (2,1));

	end

	@testset "makePeopleExit!(density, exits)" begin

		A = [0 0 0; 0 0 2;  0 0 0];
		
		World.makePeopleExit!(A, BitArray([0 0 0; 0 0 1; 0 0 0]));


		@test A == zeros(Int64, 3,3);
	end	


	@testset "maxPeople(density)" begin

		@test World.maxPeople([0 0; 1 0]) == 1;

	end

	@testset "legalNeighbors(density, obstacles, p)" begin

		@test collect(World.legalNeighbors(zeros(2,2), zeros(Bool, 2,2), (1,1))) == [(2, 1), (1, 2)];
		
		@test collect(World.legalNeighbors(zeros(2,2), BitArray([0 1; 0 0]), (1,1))) == [(2, 1)];
		
		@test collect(World.legalNeighbors([0 0; 1 0], zeros(Bool, 2, 2), (1,1))) == [(1, 2)];
	end
	
	@testset "hasLegalNeighbors(density, obstacles, p)" begin

		@test World.hasLegalNeighbors(zeros(2,2), zeros(Bool, 2,2), (1,1));
		
		@test World.hasLegalNeighbors(zeros(2,2), BitArray([0 1; 0 0]), (1,1));
		
		@test World.hasLegalNeighbors([0 0; 1 0], zeros(Bool, 2, 2), (1,1));
	
		@test ! World.hasLegalNeighbors(zeros(2,2), BitArray([0 1; 1 0]), (1,1));
		
		@test ! World.hasLegalNeighbors([0 1; 1 0], zeros(Bool, 2, 2), (1,1));
		
	end
	
	@testset "hasPeopleAndNotObstacle(density, obstacles, p)" begin

		@test ! World.hasPeopleAndNotObstacle( zeros(2,2), zeros(Bool, 2,2), (1,1) );
		
		@test ! World.hasPeopleAndNotObstacle( zeros(2,2), BitArray([1 0; 0 0]), (1,1) );
		
		@test World.hasPeopleAndNotObstacle( [1 0; 0 0], zeros(Bool, 2,2), (1,1) );
	end
	
	@testset "isLegalNeighbor(density, obstacles, p)" begin

		@test World.isLegalNeighbor( zeros(2,2), zeros(Bool, 2,2), (1,1) );
		
		@test ! World.isLegalNeighbor( zeros(2,2), BitArray([0 1; 0 0]), (1,2) );
		
		@test ! World.isLegalNeighbor( [0 0; 1 0], zeros(Bool, 2,2), (2,1) );

	end
	
	@testset "nonObstacleNeighbors(density, obstacles, p)" begin

		@test collect(World.nonObstacleNeighbors( zeros(2,2), zeros(Bool, 2,2), (1,1) )) == [(2,1), (1,2)];
		
		@test collect(World.nonObstacleNeighbors( zeros(2,2), BitArray([0 1; 0 0]), (1,1) ))  == [(2,1)];
		
		@test collect(World.nonObstacleNeighbors( [0 0; 1 0], zeros(Bool, 2,2), (1,1) )) == [(2,1), (1,2)];

	end
	
	
	@testset "scoredNeighbors(scores, density, obstacles, p)" begin

		@test World.scoredNeighbors([0 1; 0 0], zeros(Int64, 2,2), zeros(Bool, 2,2), (1,1)) == [(0, (2,1)), (1, (1,2))];

		@test World.scoredNeighbors([0 1; 0 0], zeros(Int64, 2,2), BitArray([0 0; 1 0]), (1,1)) == [(1, (1,2))];

		@test World.scoredNeighbors([0 0; 0 0], zeros(Int64, 2,2), BitArray([0 0; 1 0]), (1,1)) == [(0, (1,2))];
		
	end

	@testset "update(density, obstacles, exits)" begin

		density = [1 0; 0 0];

		exits 	= BitArray([false false; false true]);
		obstacles = BitArray([false false; false false]);
		density = World.update(density, obstacles, exits);

		@test density == [0 0; 1 0] || density == [0 1; 0 0];

		density = World.update(density, obstacles, exits);

		@test density == zeros(2,2);

		density = [2 0; 0 0];
		
		density = World.update(density, obstacles, exits);

		@test density == [1 1; 0 0] || density == [1 0; 1 0];	

		density = World.update(density, obstacles, exits);

		@test sum(density) == 1;

		density = World.update(density, obstacles, exits);

		@test sum(density) == 0;

	end
end
