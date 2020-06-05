using Test
using NLSolvers
using StaticArrays
using NLsolve

@testset "CPU tests" begin
    function f!(F, x)
        F[1] = (x[1]+3)*(x[2]^3-7)+18
        F[2] = sin(x[2]*exp(x[1])-1)
    end
    FT = Float64
    results = nlsolve(f!, FT[0.1; 1.2], autodiff = :forward)
    @test all(isapprox.(results.zero, FT[0, 1], atol = sqrt(eps(FT))))

    x_initial = FT[ 0.1; 1.2]
    nl_sys = NonLinearSystem(f!, x_initial)

end
