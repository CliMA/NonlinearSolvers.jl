if get(ARGS, 1, "Array") == "CuArray"
    using CUDA
    const ArrayType = CUDA.CuArray
    CUDA.allowscalar(false)
else
    const ArrayType = Array
end

using Test
using NLSolvers

@testset "NLSolvers tests" begin
    function f!(F, x)
        t = Tuple(x)
        F_nt = ntuple(Val(length(F))) do i
            i == 1 && (F_i = (t[1] + 3) * (t[2]^3 - 7) + 18)
            i == 2 && (F_i = sin(t[2] * exp(t[1]) - 1))
            F_i
        end
        F .= F_nt
    end

    function j!(J, x)
        t = Tuple(x)
        u = exp(t[1]) * cos(t[2] * exp(t[1]) - 1)
        J_nt = ntuple(Val(length(J))) do i
            i == 1 && (J_ij = t[2]^3 - 7)
            i == 2 && (J_ij = t[2] * u)
            i == 3 && (J_ij = 3 * t[2]^2 * (t[1] + 3))
            i == 4 && (J_ij = u)
            return J_ij
        end
        J[:] .= J_nt
    end
    FT = Float64
    N = 2
    x_initial = FT[0.1; 1.2]
    correct_sol = FT[0, 1]

    @show ArrayType
    x_initial = ArrayType(x_initial)

    @testset "Compact solution converging" begin
        # Jacobian provided
        nls = NewtonsMethod(f!, j!, x_initial)
        sol = solve!(nls)
        @test all(isapprox.(correct_sol, Array(sol.root); atol = 10eps(FT)))
        @test sol.converged == true

        # Jacobian-free
        nls = NewtonsMethodAD(f!, x_initial)
        sol = solve!(nls)
        @test all(isapprox.(correct_sol, Array(sol.root); atol = 10eps(FT)))
        @test sol.converged == true
    end

    @testset "Compact solution non-converging" begin
        # Jacobian provided
        nls = NewtonsMethod(f!, j!, x_initial)
        sol = solve!(nls, CompactSolution(), SolutionTolerance(eps(FT)), 1)
        @test sol.converged == false

        # Jacobian-free
        nls = NewtonsMethodAD(f!, x_initial)
        sol = solve!(nls, CompactSolution(), SolutionTolerance(eps(FT)), 1)
        @test sol.converged == false
    end

    if x_initial isa Array
        @testset "Verbose solution" begin
            # Jacobian provided
            nls = NewtonsMethod(f!, j!, x_initial)
            sol = solve!(nls, VerboseSolution())
            @test all(isapprox.(correct_sol, Array(sol.root); atol = 10eps(FT)))
            @test sol.converged
            @test sol.err[end] < 10eps(FT)
            @test hasproperty(sol, :iter_performed)
            @test sol.root_history isa Vector{typeof(nls.x1)}
            @test sol.err_history isa Vector{typeof(nls.x1)}

            # Jacobian-free
            nls = NewtonsMethodAD(f!, x_initial)
            sol = solve!(nls, VerboseSolution())
            @test all(isapprox.(correct_sol, Array(sol.root); atol = 10eps(FT)))

            @test sol.converged
            @test sol.err[end] < 10eps(FT)
            @test hasproperty(sol, :iter_performed)
            @test sol.root_history isa Vector{typeof(nls.x1)}
            @test sol.err_history isa Vector{typeof(nls.x1)}
        end
    end
end
