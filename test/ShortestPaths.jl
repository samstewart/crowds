using Base.Test;

@testset "ShortestPaths" begin
	using CA.ShortestPaths;
	using CA.Grid;

	@testset "explored(c, density)" begin

		@test !ShortestPaths.explored((1,1), typemax(Int64) * ones(Int64, 2, 2));

		@test ShortestPaths.explored((1,1), [0 typemax(Int64); typemax(Int64) typemax(Int64)]);
	end

	@testset "isWavefrontCell(c, density)" begin

		@test ShortestPaths.isWavefrontCell((1,1), [0 0; 0 0],  [0 typemax(Int64); typemax(Int64) typemax(Int64)], zeros(Bool, 2, 2));
		
		@test !ShortestPaths.isWavefrontCell((2,1),[0 0; 0 0],  [0 typemax(Int64); typemax(Int64) typemax(Int64)], zeros(Bool, 2, 2));
		
		@test collect(filter(c -> ShortestPaths.isWavefrontCell(c, [0 0; 0 0], [0 typemax(Int64); typemax(Int64) typemax(Int64)], zeros(Bool, 2, 2)), cells([0 0; 0 0]))) == [(1,1)]
	end

	@testset "scoreAdjacent(src, dst, scores, density)" begin
		
		@test ShortestPaths.scoreAdjacent((1,1), (2,1), [1 3; 2 3], [1 2; 2 3]) == (1 + 2 +1);
	end

	@testset "computescores(density, obstacles, exits): check physical distances" begin

		@test computeScores([0 0; 0 0], BitArray([0 1; 0 0]), BitArray([0 0; 0 1])) == [2 0; 1 0];

		@test computeScores([0 0 0; 0 0 0; 0 0 0], BitArray(zeros(3,3)), BitArray([0 0 0; 0 0 1; 0 0 0])) == [3 2 1; 2 1 0; 3 2 1]

	end	

	@testset "computescores(density, obstacles, exits): check obstacle avoidence" begin

		@test computeScores([0 0; 0 0], BitArray([0 0; 0 0]), BitArray([1 0; 0 0])) == [0 1; 1 2];

		@test computeScores(zeros(Int64, 3,3), BitArray([0 0 0; 0 1 0; 0 0 0]), BitArray([0 0 0; 0 0 1; 0 0 0])) == [3 2 1; 4 0 0; 3 2 1];
	end


	@testset "computescores(density, obstacles, exits): check shortest path with respect to density" begin
	
		@test computeScores([0 1; 1 0], BitArray([0 0; 0 0]), BitArray([1 0; 0 0])) == [0 2; 2 3];

		@test computeScores([0 1; 0 0], BitArray([0 0; 0 0]), BitArray([0 0; 0 1])) == [2 2; 1 0];

		@test computeScores([0 2; 0 0], BitArray([0 0; 0 0]), BitArray([0 0; 0 1])) == [2 3; 1 0];

		@test computeScores([0 0 0; 0 0 0; 0 0 0], BitArray(zeros(3,3)), BitArray([0 0 0; 0 0 1; 0 0 0])) == [3 2 1; 2 1 0; 3 2 1]

		@test computeScores([0 0 0; 0 1 0; 0 0 0], BitArray( zeros(3,3) ), BitArray( [0 0 0; 0 0 1; 0 0 0]) ) == [3 2 1; 3 2 0; 3 2 1]

		# will avoid guy sitting in the middle of the grid
		@test computeScores([0 0 0; 0 2 0; 0 0 0], BitArray(zeros(3,3)), BitArray([0 0 0; 0 0 1; 0 0 0])) == [3 2 1; 4 3 0; 3 2 1]

	end

end	
