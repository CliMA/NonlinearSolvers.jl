##### NewtonsMethodAD

export NewtonsMethodAD

"""
    NewtonsMethodAD(f!::F!, x_init::A) where {F!, A <: AbstractArray}

A non-linear system of equations type.

# Fields
$(DocStringExtensions.FIELDS)
"""
struct NewtonsMethodAD{FT, F!, A, JA} <: AbstractNLSolverMethod{FT}
    "Function to find the root of"
    f!::F!
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
    function NewtonsMethodAD(f!::F!, x_init::A) where {F!, A <: AbstractArray}
        x1 = similar(x_init)
        J = similar(x_init, (length(x_init), length(x_init)))
        J⁻¹ = similar(J)
        F = similar(x_init)
        JA = typeof(J)
        FT = eltype(x_init)
        return new{FT, F!, A, JA}(f!, x_init, x1, J, J⁻¹, F)
    end
end

method_args(m::NewtonsMethodAD) = (m.x_init, m.x1, m.f!, m.F, m.J, m.J⁻¹)
function solve!(
    ::NewtonsMethodAD,
    x0::AT,
    x1::AT,
    f!::F!,
    F::FA,
    J::JA,
    J⁻¹::J⁻¹A,
    soltype::SolutionType,
    tol::AbstractTolerance{FT},
    maxiters::Int,
) where {FA, J⁻¹A, JA, F! <: Function, AT, FT}

    x_history = init_history(soltype, AT)
    F_history = init_history(soltype, AT)
    if soltype isa VerboseSolution
        f!(F, x0)
        ForwardDiff.jacobian!(J, f!, F, x0)
        push_history!(x_history, x0, soltype)
        push_history!(F_history, F, soltype)
    end
    for i in 1:maxiters
        f!(F, x0)
        ForwardDiff.jacobian!(J, f!, F, x0)
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
