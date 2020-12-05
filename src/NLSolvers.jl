"""
    NLSolvers

A set of solvers for systems of non-linear equations
"""
module NLSolvers

using DocStringExtensions
using ForwardDiff

export solve!

const FTypes = Union{AbstractFloat, AbstractArray}

"""
    AbstractNLSolverMethod

A super type for non-linear systems
"""
abstract type AbstractNLSolverMethod{FTypes} end

"""
    method_args(method::AbstractNLSolverMethod)

Return tuple of positional args for `AbstractNLSolverMethod`.
"""
function method_args end

include("tolerance_types.jl")
include("solution_types.jl")

include("newton_method.jl")
include("newton_method_ad.jl")

# Main entry point: Dispatch to specific method
"""
    solve!(
        method::AbstractNLSolverMethod{FT},
        soltype::SolutionType = CompactSolution(),
        tol::Union{Nothing, AbstractTolerance} = nothing,
        maxiters::Union{Nothing, Int} = 10_000,
    )

Solve the non-linear system given
 - `method` the numerical method
 - `soltype` the solution type (`CompactSolution` or `VerboseSolution`)
 - `tol` the stopping tolerance
 - `maxiters` the maximum number of iterations to perform
"""
function solve!(
    method::AbstractNLSolverMethod{FT},
    soltype::SolutionType = CompactSolution(),
    tol::Union{Nothing, AbstractTolerance} = nothing,
    maxiters::Union{Nothing, Int} = 10_000,
) where {FT <: FTypes, F <: Function}
    if tol === nothing
        tol = ResidualTolerance{eltype(FT)}(sqrt(eps(FT)))
    end
    return solve!(method, method_args(method)..., soltype, tol, maxiters)
end

end
