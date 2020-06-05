using Test
using NLSolvers
using StaticArrays
using Adapt
using CUDAdrv
using CUDAnative
using CuArrays

CuArrays.allowscalar(false)
@testset "GPU tests" begin
    function f!(F, x)
        F[1] = (x[1]+3)*(x[2]^3-7)+18
        F[2] = sin(x[2]*exp(x[1])-1)
    end

    for FT in [Float32, Float64]
        N = 5
        _X0 = SArray{Tuple{N}, FT}(rand(FT, N))
        _X1 = SArray{Tuple{N}, FT}(rand(FT, N) .+ 1000)

        # Move to the GPU
        X0 = adapt(CuArray, _X0)
        X1 = adapt(CuArray, _X1)
        nl_sys = NonLinearSystem(f!, X0)
        @test isbits(nl_sys)
    end

end
