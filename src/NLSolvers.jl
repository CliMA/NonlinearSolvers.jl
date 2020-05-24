"""
    NLSolvers

A set of solvers for systems of non-linear equations
"""
module NLSolvers

using DocStringExtensions

export AbstractNonLinearSystem,
    NonLinearSystem

"""
    AbstractNonLinearSystem

A super type for non-linear systems
"""
abstract type AbstractNonLinearSystem end

"""
    NonLinearSystem(f!::F!, x_init::A) where {F!, A<:AbstractArray}

A non-linear system of equations type.

# Fields
$(DocStringExtensions.FIELDS)
"""
struct NonLinearSystem{F!, A} <: AbstractNonLinearSystem
  "Function to find the root of"
  f!::F!
  "Initial guess"
  x_init::A
  "Storage for solution"
  sol::A
  function NonLinearSystem(f!::F!, x_init::A) where {F!, A<:AbstractArray}
    sol = similar(x_init)
    return new{F!, A}(f!, x_init, sol)
  end
end

end