##### NewtonsMethod

export NewtonsMethod

"""
    NewtonsMethod(
            f!::F!,
            j!::J!,
            x_init::A,
        ) where {F! <: Function, J! <: Function, A <: AbstractArray}

A non-linear system of equations type.

# Fields
$(DocStringExtensions.FIELDS)
"""
struct NewtonsMethod{FT, F!, J!, A, JA} <: AbstractNonlinearSolverMethod{FT}
    "Function to find the root of"
    f!::F!
    "Jacobian of `f!`"
    j!::J!
    "Initial guess"
    x_init::A
    "Storage"
    x1::A
    "Storage"
    J::JA
    "Storage"
    J⁻¹::JA
    "Storage"
    F::A
    function NewtonsMethod(
        f!::F!,
        j!::J!,
        x_init::A,
    ) where {F! <: Function, J! <: Function, A <: AbstractArray}
        x1 = similar(x_init)
        J = similar(x_init, (length(x_init), length(x_init)))
        J⁻¹ = similar(J)
        F = similar(x_init)
        JA = typeof(J)
        FT = eltype(x_init)
        return new{FT, F!, J!, A, JA}(f!, j!, x_init, x1, J, J⁻¹, F)
    end
end

method_args(m::NewtonsMethod) = (m.x_init, m.x1, m.f!, m.F, m.j!, m.J, m.J⁻¹)
function solve!(
    ::NewtonsMethod,
    x0::AT,
    x1::AT,
    f!::F!,
    F::FA,
    j!::J!,
    J::JA,
    J⁻¹::J⁻¹A,
    soltype::SolutionType,
    tol::AbstractTolerance{FT},
    maxiters::Int,
) where {FA, J⁻¹A, JA, F! <: Function, J! <: Function, AT, FT}

    x_history = init_history(soltype, AT)
    F_history = init_history(soltype, AT)
    if soltype isa VerboseSolution
        f!(F, x0)
        j!(J, x0)
        push_history!(x_history, x0, soltype)
        push_history!(F_history, F, soltype)
    end
    for i in 1:maxiters
        f!(F, x0)
        j!(J, x0)
        x1 .= x0 .- J \ F
        push_history!(x_history, x1, soltype)
        push_history!(F_history, F, soltype)
        if tol(x0, x1, F)
            return SolutionResults(
                soltype,
                x1,
                true,
                F,
                i,
                x_history,
                F_history,
            )
        end
        x0 = x1
    end
    return SolutionResults(
        soltype,
        x0,
        false,
        F,
        maxiters,
        x_history,
        F_history,
    )
end
