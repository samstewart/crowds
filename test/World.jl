using Base.Test;

@testset "World" begin
	using CA.World;
	
	@testset "isless(scored_cell1, scored_cell2)" begin

		@test isless((.2, (1,1)) , (.3, (1,1)));

		@test isless((.2, (1,1)), (.2, (1,1)));

	end	

	@testset "peopledCells(density)" begin

		@test World.peopledCells([1.0 0; 0.0 1.0]) == BitArray([true false; false true]);
	end	


	@testset "movePeopleBetweenCells!(density, src_cell, dst_cell)" begin

		A = [1 0; 0.0 0];

		World.movePeopleBetweenCells!(A, (1,1), (2,1));

	end

	@testset "makePeopleExit!(A, exits)" begin

		A = [0 0 0; 0 0 1; 0 0 0];
		
		World.makePeopleExit!(A, BitArray([0 0 0; 0 0 1; 0 0 0]));


		@test A == zeros(Int64, 3,3);
	end	


	@testset "maxPeople(density)" begin

		@test World.maxPeople([0 0; 1 0]) == 1;

	end


	@testset "bestNeighbor(scores, density, obstacles, p)" begin

		@test World.bestNeighbor([0 1; 0 0], zeros(Int64, 2,2), zeros(Bool, 2,2), (1,1)) == (2,1);

		@test World.bestNeighbor([0 1; 0 0], zeros(Int64, 2,2), BitArray([0 0; 1 0]), (1,1)) == (1,2);

		@test World.bestNeighbor([0 0; 0 0], zeros(Int64, 2,2), BitArray([0 0; 1 0]), (1,1)) in [(2,1), (1,2)];
		
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
