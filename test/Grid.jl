using Base.Test

@testset "Grid" begin
	using CA.Grid;

	@testset "custom indexing" begin


		@test getindex([1 1; 2 2], (1,1)) == 1;
	
		A = [1 1; 2 2];
		setindex!(A, 5, (1,1));

		@test getindex(A, (1,1)) == 5;

	end
	
	@testset "shape functions" begin

		@test width(zeros(2,2)) == 2;
		@test height(zeros(2,2)) == 2;
	end

	@testset "neighbors" begin
		@test Grid.up((2,3)) == (2, 2);
		@test Grid.down((2,3)) == (2,4);
		@test Grid.right((2,3)) == (3,3);
		@test Grid.left((2,3)) == (1, 3);
	end

	@testset "neighbors(p, density)" begin
		@test neighbors((1,1), zeros(2,2)) == [(2,1), (1,2)];
		@test neighbors((1,2), zeros(3,3)) == [(2,2), (1,1), (1,3)];

		grid = BitArray([0 0 0; 0 1 0; 0 0 0]);
		@test neighbors(grid, zeros(3,3)) == BitArray([0 1 0; 1 0  1; 0 1 0]);

		@test length(neighbors((3,2), zeros(3,3))) == 3;
		@test length(neighbors((2,3), zeros(3,3))) == 3;
		@test length(neighbors((2,1), zeros(3,3))) == 3;
		@test length(neighbors((2,2), zeros(3,3))) == 4;
	end

	@testset "cells(density)" begin


		@test collect(cells(zeros(2,2))) == [(1,1) (1,2); (2,1) (2,2)];
		
	end


	@testset "nonObstacleNeighbors(p, density, obstacles" begin

		obstacles = [true false; false false];
		@test collect(nonObstacleNeighbors((2,1), [1 1; 2 2], obstacles)) == [(2,2)]

		obstacles = [true false; false true];
		@test isempty(nonObstacleNeighbors((2,1), [1 1; 2 2], obstacles));
	end

	@testset "hasNeighbor(p, density, predicate)" begin

		obstacles = [true false; false false];
		@test hasNeighbor((2,1), [1 1; 2 2], c -> obstacles[c]);

		obstacles = [true false; false true];
		@test !hasNeighbor((2,1), [1 1; 2 2], c -> !obstacles[c]);
	end

	@testset "wallCells(density)" begin

		A = [1 2; 3 4];

		@test wallCells(A) == [true true; true true]; 
		@test sum(wallCells(zeros(3,3))) == 8; 
	end

	@testset "makeExit!(exits, obstacles, exit)" begin
		exits = BitArray([false false; false false]);
		obstacles = BitArray([true false; false false]);

		makeExit!(exits, obstacles, (1,1))

		@test exits == [true false; false false];
		@test obstacles == [false false; false false];
	end
end
