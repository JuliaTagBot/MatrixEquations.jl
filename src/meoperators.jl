"""
    M = trmatop(n, m) 

Define the transposition operator `M: X -> X'` for all `n x m` matrices.
"""
function trmatop(n::Int,m::Int)
  function prod(x)
    X = reshape(x, n, m)
    return adjoint(X)[:]
  end
  function tprod(x)
    X = reshape(x, m, n)
    return adjoint(X)[:]
  end
  function ctprod(x)
    X = reshape(x, m, n)
    return adjoint(X)[:]
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  m == n ? sym = true : sym = false
  return LinearOperator{Int}(n * m, n * m, sym, sym, prod, tprod, ctprod)
end
trmatop(n::Int) = trmatop(n,n)
trmatop(dims::Tuple{Int,Int}) = trmatop(dims[1],dims[2])
"""
    M = trmatop(A) 

Define the transposition operator `M: X -> X'` of all matrices of the size of `A`.
"""
trmatop(A) = trmatop(size(A))
"""
    L = lyapop(A; disc = false, her = false) 

Define, for an `n x n` matrix `A`, the continuous Lyapunov operator `L:X -> AX+XA'`
if `disc = false` or the discrete Lyapunov operator `L:X -> AXA'-X` if `disc = true`.
If `her = false` the Lyapunov operator `L:X -> Y` maps general square matrices `X`
into general square matrices `Y`, and the associated matrix `M = Matrix(L)` is 
``n^2 \\times n^2``.
If `her = true` the Lyapunov operator `L:X -> Y` maps symmetric/Hermitian matrices `X`
into symmetric/Hermitian matrices `Y`, and the associated matrix `M = Matrix(L)` is 
``n(n+1)/2 \\times n(n+1)/2``.
For the definitions of the Lyapunov operators see:

M. Konstantinov, V. Mehrmann, P. Petkov. On properties of Sylvester and Lyapunov
operators. Linear Algebra and its Applications 312:35–71, 2000.
"""
function lyapop(A; disc = false, her = false)
  n = LinearAlgebra.checksquare(A)
  T = eltype(A)
  function prod(x)
    T1 = promote_type(T, eltype(x))
    if her
      X = vec2triu(convert(Vector{T1}, x),her = true)
      if disc
        return triu2vec(utqu(X,A') - X)
      else
        Y = A * X
        return triu2vec(Y + Y')
      end
    else
      X = reshape(convert(Vector{T1}, x), n, n)
      if disc
        Y = A*X*A' - X
      else
        Y = A*X + X*A'
      end
      return Y[:]
    end
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    if her
      X = vec2triu(convert(Vector{T1}, x),her = true)
      if disc
        return triu2vec(utqu(X,A) - X)
      else
        Y = X * A
        return triu2vec(Y + adjoint(Y))
      end
    else
      X = reshape(convert(Vector{T1}, x), n, n)
      if disc
         Y = adjoint(A)*X*A - X
       else
         Y = adjoint(A)*X + X*A
       end
       return Y[:]
    end
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    if her
      X = vec2triu(convert(Vector{T1}, x),her = true)
      if disc
        return triu2vec(utqu(X,A) - X)
      else
        Y = X * A
        return triu2vec(Y + Y')
      end
    else
      X = reshape(convert(Vector{T1}, x), n, n)
      if disc
        return (A'*X*A - X )[:]
      else
        return (A'*X + X*A)[:]
      end
    end
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  her ? N = Int(n*(n+1)/2) : N = n*n
  return LinearOperator{T}(N, N, false, false, prod, tprod, ctprod)
end
"""
    L = lyapop(A, E; disc = false, her = false) 

Define, for a pair `(A,E)` of `n x n` matrices, the continuous Lyapunov operator `L:X -> AXE'+EXA'`
if `disc = false` or the discrete Lyapunov operator `L:X -> AXA'-EXE'` if `disc = true`.
If `her = false` the Lyapunov operator `L:X -> Y` maps general square matrices `X`
into general square matrices `Y`, and the associated matrix `M = Matrix(L)` is 
``n^2 \\times n^2``.
If `her = true` the Lyapunov operator `L:X -> Y` maps symmetric/Hermitian matrices `X`
into symmetric/Hermitian matrices `Y`, and the associated `M = Matrix(L)` is a
``n(n+1)/2 \\times n(n+1)/2``.
For the definitions of the Lyapunov operators see:

M. Konstantinov, V. Mehrmann, P. Petkov. On properties of Sylvester and Lyapunov
operators. Linear Algebra and its Applications 312:35–71, 2000.
"""
function lyapop(A, E; disc = false, her = false)
  n = LinearAlgebra.checksquare(A)
  if n != LinearAlgebra.checksquare(E)
    throw(DimensionMismatch("E must be a square matrix of dimension $n"))
  end
  T = promote_type(eltype(A), eltype(E))
  function prod(x)
    T1 = promote_type(T, eltype(x))
    if her
      X = vec2triu(convert(Vector{T1}, x),her = true)
      if disc
        return triu2vec(utqu(X,A') - utqu(X,E'))
      else
        Y = A * X * E'
        return triu2vec(Y + Y')
      end
    else
      X = reshape(convert(Vector{T1}, x), n, n)
      if disc
        Y = A*X*A' - E*X*E'
      else
        Y = A*X*E' + E*X*A'
      end
      return Y[:]
    end
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    if her
      X = vec2triu(convert(Vector{T1}, x),her = true)
      if disc
        return triu2vec(utqu(X,A) - utqu(X,E))
      else
        Y = E' * X * A
        return triu2vec(Y + Y')
      end
    else
      X = reshape(convert(Vector{T1}, x), n, n)
      if disc
        return (A'*X*A - E'*X*E )[:]
      else
        return (A'*X*E + E'*X*A)[:]
      end
    end
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    if her
      X = vec2triu(convert(Vector{T1}, x),her = true)
      if disc
        return triu2vec(utqu(X,A) - utqu(X,E))
      else
        Y = E' * X * A
        return triu2vec(Y + Y')
      end
    else
      X = reshape(convert(Vector{T1}, x), n, n)
      if disc
        return (A'*X*A - E'*X*E )[:]
      else
        return (A'*X*E + E'*X*A)[:]
      end
    end
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  her ? N = Int(n*(n+1)/2) : N = n*n
  return LinearOperator{T}(N, N, false, false, prod, tprod, ctprod)
end
"""
    LINV = invlyapop(A; disc = false, her = false) 

Define `LINV`, the inverse of the continuous Lyapunov operator `L:X -> AX+XA'` for `disc = false`
or the inverse of the discrete Lyapunov operator `L:X -> AXA'-X` for `disc = true`, where
`A` is an `n x n` matrix.
If `her = false` the inverse Lyapunov operator `LINV:Y -> X` maps general square matrices `Y`
into general square matrices `X`, and the associated matrix `M = Matrix(LINV)` is 
``n^2 \\times n^2``.
If `her = true` the inverse Lyapunov operator `LINV:Y -> X` maps symmetric/Hermitian matrices `Y`
into symmetric/Hermitian matrices `X`, and the associated matrix `M = Matrix(LINV)` is 
``n(n+1)/2 \\times n(n+1)/2``.
For the definitions of the Lyapunov operators see:

M. Konstantinov, V. Mehrmann, P. Petkov. On properties of Sylvester and Lyapunov
operators. Linear Algebra and its Applications 312:35–71, 2000.
"""
function invlyapop(A; disc = false, her = false)
   n = LinearAlgebra.checksquare(A)
   T = eltype(A)
   function prod(x)
    T1 = promote_type(T, eltype(x))
     try
       if her
         Y = vec2triu(convert(Vector{T1}, x),her = true)
         if disc
            return triu2vec(lyapd(A,-Y))
         else
             return triu2vec(lyapc(A,-Y))
         end
       else
         Y = reshape(convert(Vector{T1}, x), n, n)
         if disc
           return sylvd(-A,A',-Y)[:]
         else
           return sylvc(A,A',Y)[:]
         end
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
      if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
     end
   end
   function tprod(x)
    T1 = promote_type(T, eltype(x))
     try
       if her
         Y = vec2triu(convert(Vector{T1}, x),her = true)
         if disc
           return triu2vec(lyapd(A',-Y))
         else
           return triu2vec(lyapc(A',-Y))
         end
       else
         Y = reshape(convert(Vector{T1}, x), n, n)
         if disc
           return sylvd(-A',A,-Y)[:]
         else
            return sylvc(A',A,Y)[:]
         end
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
     end
   end
   function ctprod(x)
    T1 = promote_type(T, eltype(x))
     try
       if her
         Y = vec2triu(convert(Vector{T1}, x),her = true)
         if disc
           return triu2vec(lyapd(A',-Y))
         else
           return triu2vec(lyapc(A',-Y))
         end
       else
         Y = reshape(convert(Vector{T1}, x), n, n)
         if disc
           return sylvd(-A',A,-Y)[:]
         else
           return sylvc(A',A,Y)[:]
         end
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
      end
     end
   end
   F1 = typeof(prod)
   F2 = typeof(tprod)
   F3 = typeof(ctprod)
   her ? N = Int(n*(n+1)/2) : N = n*n
   return LinearOperator{T}(N, N, false, false, prod, tprod, ctprod)
end
"""
    LINV = invlyapop(A, E; disc = false, her = false) 

Define `LINV`, the inverse of the continuous Lyapunov operator `L:X -> AXE'+EXA'` for `disc = false`
or the inverse of the discrete Lyapunov operator `L:X -> AXA'-EXE'` for `disc = true`, where
`(A,E)` is a pair of `n x n` matrices.
If `her = false` the inverse Lyapunov operator `LINV:Y -> X` maps general square matrices `Y`
into general square matrices `X`, and the associated matrix `M = Matrix(LINV)` is 
``n^2 \\times n^2``.
If `her = true` the inverse Lyapunov operator `LINV:Y -> X` maps symmetric/Hermitian matrices `Y`
into symmetric/Hermitian matrices `X`, and the associated matrix `M = Matrix(LINV)` is 
``n(n+1)/2 \\times n(n+1)/2``.
For the definitions of the Lyapunov operators see:

M. Konstantinov, V. Mehrmann, P. Petkov. On properties of Sylvester and Lyapunov
operators. Linear Algebra and its Applications 312:35–71, 2000.
"""
function invlyapop(A, E; disc = false, her = false)
   n = LinearAlgebra.checksquare(A)
   if n != LinearAlgebra.checksquare(E)
     throw(DimensionMismatch("E must be a square matrix of dimension $n"))
   end
   T = promote_type(eltype(A), eltype(E))
   function prod(x)
    T1 = promote_type(T, eltype(x))
     try
       if her
         Y = vec2triu(convert(Vector{T1}, x),her = true)
         if disc
            return triu2vec(lyapd(A,E,-Y))
         else
            return triu2vec(lyapc(A,E,-Y))
         end
       else
         Y = reshape(convert(Vector{T1}, x), n, n)
         if disc
           return gsylv(-A,A',E,E',-Y)[:]
         else
           return gsylv(A,E',E,A',Y)[:]
         end
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
     end
   end
   function tprod(x)
    T1 = promote_type(T, eltype(x))
     try
       if her
         Y = vec2triu(convert(Vector{T1}, x),her = true)
         if disc
            return triu2vec(lyapd(A',E',-Y))
         else
            return triu2vec(lyapc(A',E',-Y))
         end
       else
         Y = reshape(convert(Vector{T1}, x), n, n)
         if disc
            return gsylv(-A',A,E',E,-Y)[:]
         else
            return gsylv(A',E,E',A,Y)[:]
         end
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
     end
   end
   function ctprod(x)
    T1 = promote_type(T, eltype(x))
     try
       if her
         Y = vec2triu(convert(Vector{T1}, x),her = true)
         if disc
           return triu2vec(lyapd(A',E',-Y))
         else
           return triu2vec(lyapc(A',E',-Y))
         end
       else
         Y = reshape(convert(Vector{T1}, x), n, n)
         if disc
           return gsylv(-A',A,E',E,-Y)[:]
         else
           return gsylv(A',E,E',A,Y)[:]
         end
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
      end
     end
   end
   F1 = typeof(prod)
   F2 = typeof(tprod)
   F3 = typeof(ctprod)
   her ? N = Int(n*(n+1)/2) : N = n*n
   return LinearOperator{T}(N, N, false, false, prod, tprod, ctprod)
end
"""
    LINV = invlyapsop(A; disc = false, her = false) 

Define `LINV`, the inverse of the continuous Lyapunov operator `L:X -> AX+XA'` for `disc = false`
or the inverse of the discrete Lyapunov operator `L:X -> AXA'-X` for `disc = true`, where
`A` is an `n x n` matrix in Schur form.
If `her = false` the inverse Lyapunov operator `LINV:Y -> X` maps general square matrices `Y`
into general square matrices `X`, and the associated matrix `M = Matrix(LINV)` is 
``n^2 \\times n^2``.
If `her = true` the inverse Lyapunov operator `LINV:Y -> X` maps symmetric/Hermitian matrices `Y`
into symmetric/Hermitian matrices `X`, and the associated matrix `M = Matrix(LINV)` is 
``n(n+1)/2 \\times n(n+1)/2``.
For the definitions of the Lyapunov operators see:

M. Konstantinov, V. Mehrmann, P. Petkov. On properties of Sylvester and Lyapunov
operators. Linear Algebra and its Applications 312:35–71, 2000.
"""
function invlyapsop(A; disc = false, her = false)
   n = LinearAlgebra.checksquare(A)
   T = eltype(A)
   if !(T <: BlasFloat) 
      T = promote_type(Float64,T)
   end
   if eltype(A) !== T
      A = convert(Matrix{T},A)
   end

   # check A is in Schur form
   if !isschur(A)
       error("The matrix A must be in Schur form")
   end
   cmplx = T<:Complex
   function prod(x)
     T1 = promote_type(T, eltype(x))
     if T !== T1
        if cmplx
           A = convert(Matrix{T1},A)
        else
           T1r = real(T1)
           if T1r !== T
              A = convert(Matrix{T1r},A)
           end
        end
     end
     try
       if her
         Y = vec2triu(convert(Vector{T1}, -x),her = true)
         disc ? lyapds!(A,Y) : lyapcs!(A,Y)
         return triu2vec(Y)
       else
         Y = reshape(convert(Vector{T1}, -x), n, n)
         if disc
            sylvds!(-A,A,Y,adjB = true)
            return Y[:]
         else
            sylvcs!(A,A,Y,adjB = true)
            return -Y[:]
         end
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
     end
   end
   function tprod(x)
     T1 = promote_type(T, eltype(x))
     if T !== T1
        if cmplx
           A = convert(Matrix{T1},A)
        else
           T1r = real(T1)
           if T1r !== T
              A = convert(Matrix{T1r},A)
           end
        end
     end
     try
      if her
        Y = vec2triu(convert(Vector{T1}, -x),her = true)
        disc ? lyapds!(A,Y,adj = true) : lyapcs!(A,Y,adj = true)
        return triu2vec(Y)
      else
        Y = reshape(convert(Vector{T1}, -x), n, n)
        if disc
           sylvds!(-A,A,Y,adjA = true)
           return Y[:]
        else
           sylvcs!(A,A,Y,adjA = true)
         #   realcase = eltype(A) <: AbstractFloat && eltype(Y) <: AbstractFloat
         #   realcase ? (TA,TB) = ('T','N') : (TA,TB) = ('C','N')
         #   Y, scale = LAPACK.trsyl!(TA, TB, A, A, Y)
         #   rmul!(Y, inv(-scale))
            return -Y[:]
        end
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
     end
   end
   function ctprod(x)
     T1 = promote_type(T, eltype(x))
     if T !== T1
       if cmplx
          A = convert(Matrix{T1},A)
       else
          T1r = real(T1)
          if T1r !== T
             A = convert(Matrix{T1r},A)
          end
       end
     end
     try
      if her
        Y = vec2triu(convert(Vector{T1}, -x),her = true)
        disc ? lyapds!(A,Y,adj = true) : lyapcs!(A,Y,adj = true)
        return triu2vec(Y)
      else
        Y = reshape(convert(Vector{T1}, -x), n, n)
        if disc
           sylvds!(-A,A,Y,adjA = true)
           return Y[:]
        else
           sylvcs!(A,A,Y,adjA = true)
         #   realcase = eltype(A) <: AbstractFloat && eltype(Y) <: AbstractFloat
         #   realcase ? (TA,TB) = ('T','N') : (TA,TB) = ('C','N')
         #   Y, scale = LAPACK.trsyl!(TA, TB, A, A, Y)
         #   rmul!(Y, inv(-scale))
           return -Y[:]
        end
      end
    catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
      end
     end
   end
   F1 = typeof(prod)
   F2 = typeof(tprod)
   F3 = typeof(ctprod)
   her ? N = Int(n*(n+1)/2) : N = n*n
   return LinearOperator{T}(N, N, false, false, prod, tprod, ctprod)
end
invlyapsop(A :: Schur; disc = false, her = false) = invlyapsop(A.T,disc = disc,her = her)
invlyapsop(A :: Adjoint; disc = false, her = false) = invlyapsop(A.parent,disc = disc,her = her)'
"""
    LINV = invlyapsop(A, E; disc = false, her = false) 

Define `LINV`, the inverse of the continuous Lyapunov operator `L:X -> AXE'+EXA'` for `disc = false`
or the inverse of the discrete Lyapunov operator `L:X -> AXA'-EXE'` for `disc = true`, where
`(A,E)` is a pair of `n x n` matrices in generalized Schur form.
If `her = false` the inverse Lyapunov operator `LINV:Y -> X` maps general square matrices `Y`
into general square matrices `X`, and the associated matrix `M = Matrix(LINV)` is 
``n^2 \\times n^2``.
If `her = true` the inverse Lyapunov operator `LINV:Y -> X` maps symmetric/Hermitian matrices `Y`
into symmetric/Hermitian matrices `X`, and the associated matrix `M = Matrix(LINV)` is 
``n(n+1)/2 \\times n(n+1)/2``.
For the definitions of the Lyapunov operators see:

M. Konstantinov, V. Mehrmann, P. Petkov. On properties of Sylvester and Lyapunov
operators. Linear Algebra and its Applications 312:35–71, 2000.
"""
function invlyapsop(A, E; disc = false, her = false)
   n = LinearAlgebra.checksquare(A)
   if n != LinearAlgebra.checksquare(E)
     throw(DimensionMismatch("E must be a square matrix of dimension $n"))
   end
   if isa(A,Adjoint) || isa(E,Adjoint)
     error("No calls with adjoint matrices are supported")
   end
   T = promote_type(eltype(A), eltype(E))
   if !(T <: BlasFloat) 
      T = promote_type(Float64,T)
   end
   if eltype(A) !== T
      A = convert(Matrix{T},A)
   end
   if eltype(A) !== T
     A = convert(Matrix{T},A)
   end 
   if eltype(E) !== T
     E = convert(Matrix{T},E)
   end 
   cmplx = T<:Complex

   # check (A,E) is in generalized Schur form
   if !isschur(A,E)
       error("The matrix pair (A,E) must be in generalized Schur form")
   end
   function prod(x)
     T1 = promote_type(T, eltype(x))
     if T !== T1
       if cmplx
         A = convert(Matrix{T1},A)
         E = convert(Matrix{T1},E)
       else
         T1r = real(T1)
         if T1r !== T
            A = convert(Matrix{T1r},A)
            E = convert(Matrix{T1},E)
         end
       end
     end
     try
       if her
         Y = vec2triu(convert(Vector{T1}, -x),her = true)
         disc ? lyapds!(A,E,Y) : lyapcs!(A,E,Y)
         return triu2vec(Y)
       else
         Y = copy(reshape(convert(Vector{T1}, x), n, n))
         disc ? gsylvs!(A,A,-E,E,Y,adjBD = true) :
                gsylvs!(A,E,E,A,Y,adjBD = true,DBSchur = true)
         return Y[:]
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
     end
   end
   function tprod(x)
    T1 = promote_type(T, eltype(x))
    if T !== T1
      if cmplx
         A = convert(Matrix{T1},A)
         E = convert(Matrix{T1},E)
      else
         T1r = real(T1)
         if T1r !== T
            A = convert(Matrix{T1r},A)
            E = convert(Matrix{T1},E)
         end
      end
    end
    try
       if her
         Y = vec2triu(convert(Vector{T1}, -x),her = true)
         disc ? lyapds!(A,E,Y,adj = true) : lyapcs!(A,E,Y,adj = true)
         return triu2vec(Y)
       else
         Y = copy(reshape(convert(Vector{T1}, x), n, n))
         disc ? gsylvs!(A,A,-E,E,Y,adjAC = true) :
                gsylvs!(A,E,E,A,Y,adjAC = true,DBSchur = true)
         return Y[:]
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
     end
   end
   function ctprod(x)
    T1 = promote_type(T, eltype(x))
    if T !== T1
      if cmplx
         A = convert(Matrix{T1},A)
         E = convert(Matrix{T1},E)
      else
         T1r = real(T1)
         if T1r !== T
            A = convert(Matrix{T1r},A)
            E = convert(Matrix{T1},E)
         end
      end
    end
    try
       if her
         Y = vec2triu(convert(Vector{T1}, -x),her = true)
         disc ? lyapds!(A,E,Y,adj = true) : lyapcs!(A,E,Y,adj = true)
         return triu2vec(Y)
       else
         Y = copy(reshape(convert(Vector{T1}, x), n, n))
         disc ? gsylvs!(A,A,-E,E,Y,adjAC = true) :
                gsylvs!(A,E,E,A,Y,adjAC = true,DBSchur = true)
         return Y[:]
       end
     catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
      end
     end
   end
   F1 = typeof(prod)
   F2 = typeof(tprod)
   F3 = typeof(ctprod)
   her ? N = Int(n*(n+1)/2) : N = n*n
   return LinearOperator{T}(N, N, false, false, prod, tprod, ctprod)
end
invlyapsop(AE :: GeneralizedSchur; disc = false, her = false) = invlyapsop(AE.S, AE.T, disc = disc, her = her)
invlyapsop(A :: Adjoint, E :: Adjoint; disc = false, her = false) = invlyapsop(A.parent,E.parent,disc = disc,her = her)'
"""
    M = sylvop(A, B; disc = false) 

Define the continuous Sylvester operator `M: X -> AX+XB` if `disc = false`
or the discrete Sylvester operator `M: X -> AXB+X` if `disc = true`, where `A` and `B` are square matrices.
"""
function sylvop(A, B; disc = false)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  T = promote_type(eltype(A), eltype(B))
  function prod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x), m, n)
    disc ? Y = A * X * B + X : Y = A * X + X * B
    return Y[:]
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x), m, n)
    disc ? Y = adjoint(A)*X*adjoint(B) + X : Y = adjoint(A)*X + X*adjoint(B)
    return Y[:]
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x), m, n)
    disc ? Y = A'*X*B' + X : Y = A'*X + X*B'
    return Y[:]
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(m * n, n * m, false, false, prod, tprod, ctprod)
end
"""
    MINV = invsylvop(A, B; disc = false) 

Define MINV, the inverse of the continuous Sylvester operator  `M: X -> AX+XB` if `disc = false`
or of the discrete Sylvester operator `M: X -> AXB+X` if `disc = true`, where `A` and `B` are square matrices.
"""
function invsylvop(A, B; disc = false)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  T = promote_type(eltype(A), eltype(B))
  function prod(x)
    T1 = promote_type(T, eltype(x))
    C = reshape(convert(Vector{T1}, x), m, n)
    try
      if disc
        return sylvd(A,B,C)[:]
      else
        return sylvc(A,B,C)[:]
      end
    catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    C = reshape(convert(Vector{T1}, x), m, n)
    try
      if disc
        return sylvd(A',B',C)[:]
      else
        return sylvc(A',B',C)[:]
     end
    catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
         throw("ME:SingularException: Singular operator")
       end
    end
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    C = reshape(convert(Vector{T1}, x), m, n)
    try
      if disc
        return sylvd(A',B',C)[:]
      else
        return sylvc(A',B',C)[:]
     end
    catch err
      #  if isnothing(findfirst("LAPACKException",string(err))) &&
      #     isnothing(findfirst("SingularException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing &&
          findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
         throw("ME:SingularException: Singular operator")
       end
    end
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(m * n, n * m, false, false, prod, tprod, ctprod)
end
"""
    MINV = invsylvsop(A, B; disc = false) 

Define MINV, the inverse of the continuous Sylvester operator  `M: X -> AX+XB` if `disc = false`
or of the discrete Sylvester operator `M: X -> AXB+X` if `disc = true`, where `A` and `B` are square matrices in Schur forms.
"""
function invsylvsop(A, B; disc = false)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  T = promote_type(eltype(A), eltype(B))
  if !(T <: BlasFloat) 
     T = promote_type(Float64,T)
  end
  adjA = isa(A,Adjoint)
  adjB = isa(B,Adjoint)
  if eltype(A) !== T
    adjA ? A = convert(Matrix{T},A.parent)'  : A = convert(Matrix{T},A)
  end 
  if eltype(B) !== T
    adjB ? B = convert(Matrix{T},B.parent)' :  B = convert(Matrix{T},B) 
  end 
  cmplx = T<:Complex
  if adjA
     if !isschur(A.parent)
         error("A must be in Schur form")
     end
  else
     if !isschur(A)
        error("A must be in Schur form")
     end
  end
  if adjB
     if !isschur(B.parent)
         error("B must be in Schur form")
     end
  else
     if !isschur(B)
        error("B must be in Schur form")
     end
  end
  function prod(x)
    T1 = promote_type(T, eltype(x))
    C = copy(reshape(convert(Vector{T1}, x), m, n))
    if T !== T1
      if cmplx
         adjA ? A = convert(Matrix{T1},A.parent)' : A = convert(Matrix{T1},A) 
         adjB ? B = convert(Matrix{T1},B.parent)' : B = convert(Matrix{T1},B) 
      else
        T1r = real(T1)
        if T1r !== T
          adjA ? A = convert(Matrix{T1r},A.parent)' : A = convert(Matrix{T1r},A) 
          adjB ? B = convert(Matrix{T1r},B.parent)' : B = convert(Matrix{T1r},B) 
        end
      end
    end
    try
       if disc
          if !adjA & !adjB
             sylvds!(A, B, C, adjA = false, adjB = false)
          elseif !adjA & adjB
             sylvds!(A, B.parent, C, adjA = false, adjB = true)
          elseif adjA & !adjB
             sylvds!(A.parent, B, C, adjA = true, adjB = false)
          else
             sylvds!(A.parent, B.parent, C, adjA = true, adjB = true)
          end
          return C[:]
       else
         if !adjA & !adjB
            sylvcs!(A, B, C, adjA = false, adjB = false)
         elseif !adjA & adjB
            sylvcs!(A, B.parent, C, adjA = false, adjB = true)
         elseif adjA & !adjB
            sylvcs!(A.parent, B, C, adjA = true, adjB = false)
         else
            sylvcs!(A.parent, B.parent, C, adjA = true, adjB = true)
         end
         return C[:]
       end
    catch err
      # if isnothing(findfirst("LAPACKException",string(err)))
      if findfirst("LAPACKException",string(err)) === nothing
         rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    C = copy(reshape(convert(Vector{T1}, x), m, n))
    if T !== T1
      if cmplx
         adjA ? A = convert(Matrix{T1},A.parent)' : A = convert(Matrix{T1},A) 
         adjB ? B = convert(Matrix{T1},B.parent)' : B = convert(Matrix{T1},B) 
      else
        T1r = real(T1)
        if T1r !== T
          adjA ? A = convert(Matrix{T1r},A.parent)' : A = convert(Matrix{T1r},A) 
          adjB ? B = convert(Matrix{T1r},B.parent)' : B = convert(Matrix{T1r},B) 
        end
      end
    end
    try
       if disc
          if !adjA & !adjB
             sylvds!(A, B, C, adjA = true, adjB = true)
          elseif !adjA & adjB
             sylvds!(A, B.parent, C, adjA = true, adjB = false)
          elseif adjA & !adjB
             sylvds!(A.parent, B, C, adjA = false, adjB = true)
          else
             sylvds!(A.parent, B.parent, C, adjA = false, adjB = false)
          end
          return C[:]
       else
         if !adjA & !adjB
            sylvcs!(A, B, C, adjA = true, adjB = true)
         elseif !adjA & adjB
            sylvcs!(A, B.parent, C, adjA = true, adjB = false)
         elseif adjA & !adjB
            sylvcs!(A.parent, B, C, adjA = false, adjB = true)
         else
            sylvcs!(A.parent, B.parent, C, adjA = false, adjB = false)
         end
         return C[:]
         end
    catch err
        # if isnothing(findfirst("LAPACKException",string(err)))
        if findfirst("LAPACKException",string(err)) === nothing
           rethrow()
        else
           throw("ME:SingularException: Singular operator")
        end
     end
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    C = copy(reshape(convert(Vector{T1}, x), m, n))
    if T !== T1
      if cmplx
         adjA ? A = convert(Matrix{T1},A.parent)' : A = convert(Matrix{T1},A) 
         adjB ? B = convert(Matrix{T1},B.parent)' : B = convert(Matrix{T1},B) 
      else
        T1r = real(T1)
        if T1r !== T
          adjA ? A = convert(Matrix{T1r},A.parent)' : A = convert(Matrix{T1r},A) 
          adjB ? B = convert(Matrix{T1r},B.parent)' : B = convert(Matrix{T1r},B) 
        end
      end
    end
    try
       if disc
          if !adjA & !adjB
             sylvds!(A, B, C, adjA = true, adjB = true)
          elseif !adjA & adjB
             sylvds!(A, B.parent, C, adjA = true, adjB = false)
          elseif adjA & !adjB
             sylvds!(A.parent, B, C, adjA = false, adjB = true)
          else
             sylvds!(A.parent, B.parent, C, adjA = false, adjB = false)
          end
          return C[:]
       else
         if !adjA & !adjB
            sylvcs!(A, B, C, adjA = true, adjB = true)
         elseif !adjA & adjB
            sylvcs!(A, B.parent, C, adjA = true, adjB = false)
         elseif adjA & !adjB
            sylvcs!(A.parent, B, C, adjA = false, adjB = true)
         else
            sylvcs!(A.parent, B.parent, C, adjA = false, adjB = false)
         end
         return C[:]
       end
    catch err
        # if isnothing(findfirst("LAPACKException",string(err)))
        if findfirst("LAPACKException",string(err)) === nothing
           rethrow()
        else
           throw("ME:SingularException: Singular operator")
        end
     end
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(m * n, n * m, false, false, prod, tprod, ctprod)
end
invsylvsop(A :: Schur, B :: Schur; disc = false) = invsylvsop(A.T,B.T,disc = disc)
"""
    M = sylvop(A, B, C, D) 

Define the generalized Sylvester operator `M: X -> AXB+CXD`, where `(A,C)` and `(B,D)` a pairs of square matrices.
"""
function sylvop(A, B, C, D)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  if [m; n] != LinearAlgebra.checksquare(C,D)
     throw(DimensionMismatch("A, B, C and D have incompatible dimensions"))
  end
  T = promote_type(eltype(A), eltype(B), eltype(C), eltype(D))
  function prod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x), m, n)
    return (A * X * B + C * X * D)[:]
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x), m, n)
    return (adjoint(A) * X * adjoint(B) + adjoint(C) * X * adjoint(D) )[:]
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x), m, n)
    return (A' * X * B' + C' * X * D' )[:]
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(m * n, n * m, false, false, prod, tprod, ctprod)
end
"""
    MINV = invsylvop(A, B, C, D) 

Define MINV, the inverse of the generalized Sylvester operator `M: X -> AXB+CXD`, 
where (A,C) and (B,D) a pairs of square matrices.
"""
function invsylvop(A, B, C, D)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  if [m; n] != LinearAlgebra.checksquare(C,D)
     throw(DimensionMismatch("A, B, C and D have incompatible dimensions"))
  end
  T = promote_type(eltype(A), eltype(B), eltype(C), eltype(D))
  function prod(x)
    T1 = promote_type(T, eltype(x))
    E = reshape(convert(Vector{T1}, x), m, n)
    try
       return gsylv(A,B,C,D,E)[:]
    catch err
       # if isnothing(findfirst("SingularException",string(err)))
       if findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function tprod(x)
   T1 = promote_type(T, eltype(x))
   E = reshape(convert(Vector{T1}, x), m, n)
    try
       return gsylv(A',B',C',D',E)[:]
    catch err
       # if isnothing(findfirst("SingularException",string(err)))
       if findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    E = reshape(convert(Vector{T1}, x), m, n)
    try
       return gsylv(A',B',C',D',E)[:]
    catch err
       # if isnothing(findfirst("SingularException",string(err)))
       if findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(m * n, n * m, false, false, prod, tprod, ctprod)
end
"""
    MINV = invsylvsop(A, B, C, D; DBSchur = false) 

Define MINV, the inverse of the generalized Sylvester operator `M: X -> AXB+CXD`,
with the pairs `(A,C)` and `(B,D)` in generalized Schur forms. If `DBSchur = true`,
the pair `(D,B)` is in generalized Schur form.
"""
function invsylvsop(A, B, C, D; DBSchur = false)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  if [m; n] != LinearAlgebra.checksquare(C,D)
     throw(DimensionMismatch("A, B, C and D have incompatible dimensions"))
  end
  T = promote_type(eltype(A),eltype(B),eltype(C),eltype(D))
  if !(T <: BlasFloat) 
     T = promote_type(Float64,T)
  end
  adjA = isa(A,Adjoint)
  adjB = isa(B,Adjoint)
  adjC = isa(C,Adjoint)
  adjD = isa(D,Adjoint)
  if adjA !== adjC 
     error("Only calls with pairs (A,C) or (A',C') are allowed")
  end
  if adjB !== adjD
     error("Only calls with pairs (B,D) or (B',D') are allowed")
  end
  if eltype(A) !== T
    adjA ? A = convert(Matrix{T},A.parent)'  : A = convert(Matrix{T},A)
  end 
  if eltype(B) !== T
    adjB ? B = convert(Matrix{T},B.parent)' :  B = convert(Matrix{T},B) 
  end 
  if eltype(C) !== T
   adjC ? C = convert(Matrix{T},C.parent)'  : C = convert(Matrix{T},C)
  end 
  if eltype(D) !== T
    adjD ? D = convert(Matrix{T},D.parent)' :  D = convert(Matrix{T},D) 
  end 
  cmplx = T<:Complex
  adjAC = adjA & adjC
  if adjAC
     if !isschur(A.parent,C.parent)
         error("The pair (A,C) must be in generalized Schur form")
     end
  else
     if !isschur(A,C)
        error("The pair (A,C) must be in generalized Schur form")
     end
  end
  adjBD = adjB & adjD
  if adjBD
     if DBSchur
       if !isschur(D.parent, B.parent)
           error("The pair (D,B) must be in generalized Schur form")
       end
     else
        if !isschur(B.parent, D.parent)
            error("The pair (B,D) must be in generalized Schur form")
        end
     end
  else
     if DBSchur
        if !isschur(D,B)
           error("The pair (D,B) must be in generalized Schur form")
        end
     else
        if !isschur(B,D)
           error("The pair (B,D) must be in generalized Schur form")
        end
     end
  end
  function prod(x)
    T1 = promote_type(T, eltype(x))
    Y = copy(reshape(convert(Vector{T1}, x), m, n))
    if T !== T1
      if cmplx
         adjA ? A = convert(Matrix{T1},A.parent)' : A = convert(Matrix{T1},A) 
         adjB ? B = convert(Matrix{T1},B.parent)' : B = convert(Matrix{T1},B) 
         adjC ? C = convert(Matrix{T1},C.parent)' : C = convert(Matrix{T1},C) 
         adjD ? D = convert(Matrix{T1},D.parent)' : D = convert(Matrix{T1},D) 
         else
        T1r = real(T1)
        if T1r !== T
          adjA ? A = convert(Matrix{T1r},A.parent)' : A = convert(Matrix{T1r},A) 
          adjB ? B = convert(Matrix{T1r},B.parent)' : B = convert(Matrix{T1r},B) 
          adjC ? C = convert(Matrix{T1r},C.parent)' : C = convert(Matrix{T1r},C) 
          adjD ? D = convert(Matrix{T1r},D.parent)' : D = convert(Matrix{T1r},D) 
        end
      end
    end
    try
       if !adjAC & !adjBD
          gsylvs!(A, B, C, D, Y, adjAC = false, adjBD = false, DBSchur = DBSchur)
       elseif !adjAC & adjBD
          gsylvs!(A, B.parent, C, D.parent, Y, adjAC = false, adjBD = true, DBSchur = DBSchur)
       elseif adjAC & !adjBD
          gsylvs!(A.parent, B, C.parent, D, Y, adjAC = true, adjBD = false, DBSchur = DBSchur)
       else
          gsylvs!(A.parent, B.parent, C.parent, D.parent, Y, adjAC = true, adjBD = true, DBSchur = DBSchur)
       end
       return Y[:]
    catch err
       # if isnothing(findfirst("SingularException",string(err)))
       if findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    Y = copy(reshape(convert(Vector{T1}, x), m, n))
    if T !== T1
      if cmplx
         adjA ? A = convert(Matrix{T1},A.parent)' : A = convert(Matrix{T1},A) 
         adjB ? B = convert(Matrix{T1},B.parent)' : B = convert(Matrix{T1},B) 
         adjC ? C = convert(Matrix{T1},C.parent)' : C = convert(Matrix{T1},C) 
         adjD ? D = convert(Matrix{T1},D.parent)' : D = convert(Matrix{T1},D) 
         else
        T1r = real(T1)
        if T1r !== T
          adjA ? A = convert(Matrix{T1r},A.parent)' : A = convert(Matrix{T1r},A) 
          adjB ? B = convert(Matrix{T1r},B.parent)' : B = convert(Matrix{T1r},B) 
          adjC ? C = convert(Matrix{T1r},C.parent)' : C = convert(Matrix{T1r},C) 
          adjD ? D = convert(Matrix{T1r},D.parent)' : D = convert(Matrix{T1r},D) 
        end
      end
    end
    try
       if !adjAC & !adjBD
          gsylvs!(A, B, C, D, Y, adjAC = true, adjBD = true, DBSchur = DBSchur)
       elseif !adjAC & adjBD
          gsylvs!(A, B.parent, C, D.parent, Y, adjAC = true, adjBD = false, DBSchur = DBSchur)
       elseif adjAC & !adjBD
          gsylvs!(A.parent, B, C.parent, D, Y, adjAC = false, adjBD = true, DBSchur = DBSchur)
       else
          gsylvs!(A.parent, B.parent, C.parent, D.parent, Y, adjAC = false, adjBD = false, DBSchur = DBSchur)
       end
       return Y[:]
    catch err
       # if isnothing(findfirst("SingularException",string(err)))
       if findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    Y = copy(reshape(convert(Vector{T1}, x), m, n))
    if T !== T1
      if cmplx
         adjA ? A = convert(Matrix{T1},A.parent)' : A = convert(Matrix{T1},A) 
         adjB ? B = convert(Matrix{T1},B.parent)' : B = convert(Matrix{T1},B) 
         adjC ? C = convert(Matrix{T1},C.parent)' : C = convert(Matrix{T1},C) 
         adjD ? D = convert(Matrix{T1},D.parent)' : D = convert(Matrix{T1},D) 
         else
        T1r = real(T1)
        if T1r !== T
          adjA ? A = convert(Matrix{T1r},A.parent)' : A = convert(Matrix{T1r},A) 
          adjB ? B = convert(Matrix{T1r},B.parent)' : B = convert(Matrix{T1r},B) 
          adjC ? C = convert(Matrix{T1r},C.parent)' : C = convert(Matrix{T1r},C) 
          adjD ? D = convert(Matrix{T1r},D.parent)' : D = convert(Matrix{T1r},D) 
        end
      end
    end
    try
       if !adjAC & !adjBD
          gsylvs!(A, B, C, D, Y, adjAC = true, adjBD = true, DBSchur = DBSchur)
       elseif !adjAC & adjBD
          gsylvs!(A, B.parent, C, D.parent, Y, adjAC = true, adjBD = false, DBSchur = DBSchur)
       elseif adjAC & !adjBD
          gsylvs!(A.parent, B, C.parent, D, Y, adjAC = false, adjBD = true, DBSchur = DBSchur)
       else
          gsylvs!(A.parent, B.parent, C.parent, D.parent, Y, adjAC = false, adjBD = false, DBSchur = DBSchur)
       end
       return Y[:]
    catch err
       # if isnothing(findfirst("SingularException",string(err)))
       if findfirst("SingularException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(m * n, n * m, false, false, prod, tprod, ctprod)
end
invsylvsop(AC :: GeneralizedSchur, BD :: GeneralizedSchur) = invsylvsop(AC.S,BD.S,AC.T,BD.T)

"""
    M = sylvsysop(A, B, C, D) 

Define the operator `M: (X,Y) -> (AX+YB, CX+YD )`, 
where `(A,C)` and `(B,D)` a pairs of square matrices.
"""
function sylvsysop(A, B, C, D)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  T = promote_type(eltype(A), eltype(B))
  if [m; n] != LinearAlgebra.checksquare(C,D)
     throw(DimensionMismatch("A, B, C and D have incompatible dimensions"))
  end
  mn = m*n
  function prod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    Y = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    return ([A * X + Y * B C * X + Y * D])[:]
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    Y = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    return [adjoint(A) * X + adjoint(C) * Y  X * adjoint(B) + Y * adjoint(D)][:]
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    X = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    Y = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    return [A' * X + C' * Y  X * B' + Y * D'][:]
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(2*mn, 2*mn, false, false, prod, tprod, ctprod)
end
"""
    MINV = invsylvsysop(A, B, C, D) 

Define MINV, the inverse of the linear operator `M: (X,Y) -> (AX+YB, CX+YD )`, 
where `(A,C)` and `(B,D)` a pairs of square matrices.
"""
function invsylvsysop(A, B, C, D)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  if [m; n] != LinearAlgebra.checksquare(C,D)
     throw(DimensionMismatch("A, B, C and D have incompatible dimensions"))
  end
  T = promote_type(eltype(A), eltype(B), eltype(C), eltype(D))
  mn = m*n
  function prod(x)
    T1 = promote_type(T, eltype(x))
    E = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    F = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    try
       (X,Y) = sylvsys(A,B,E,C,D,F)
       return [X Y][:]
    catch err
       # if isnothing(findfirst("LAPACKException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    E = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    F = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    try
       (X,Y) = dsylvsys(A',B',E,C',D',F)[:]
       return [X Y][:]
    catch err
       # if isnothing(findfirst("LAPACKException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    E = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    F = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    try
       (X,Y) = dsylvsys(A',B',E,C',D',F)[:]
       return [X Y][:]
    catch err
       # if isnothing(findfirst("LAPACKException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(2*mn, 2*mn, false, false, prod, tprod, ctprod)
end
"""
    MINV = invsylvsyssop(A, B, C, D) 

Define MINV, the inverse of the linear operator `M: (X,Y) -> (AX+YB, CX+YD)`,
with the pairs `(A,C)` and `(B,D)` in generalized Schur forms.
"""
function invsylvsyssop(A, B, C, D)
  m = LinearAlgebra.checksquare(A)
  n = LinearAlgebra.checksquare(B)
  if [m; n] != LinearAlgebra.checksquare(C,D)
     throw(DimensionMismatch("A, B, C and D have incompatible dimensions"))
  end
  T = promote_type(eltype(A),eltype(B),eltype(C),eltype(D))
  if !(T <: BlasFloat) 
     T = promote_type(Float64,T)
  end
  cmplx = T<:Complex
  if isa(A,Adjoint) || isa(B,Adjoint) || isa(C,Adjoint)  || isa(D,Adjoint)
     error("Only calls with (A, B, C, D) without adjoints are allowed")
  end
  if eltype(A) !== T
     A = convert(Matrix{T},A)
  end 
  if eltype(B) !== T
     B = convert(Matrix{T},B) 
  end 
  if eltype(C) !== T
     C = convert(Matrix{T},C)
  end 
  if eltype(D) !== T
     D = convert(Matrix{T},D) 
  end 
  if !isschur(A,C)
     error("The pair (A,C) must be in generalized Schur form")
  end
  if !isschur(B,D)
     error("The pair (B,D) must be in generalized Schur form")
  end
  cmplx ? TA = 'C' : TA = 'T'
  mn = m*n
  function prod(x)
    T1 = promote_type(T, eltype(x))
    E = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    F = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    if T !== T1
      if cmplx
         A = convert(Matrix{T1},A) 
         B = convert(Matrix{T1},B) 
         C = convert(Matrix{T1},C) 
         D = convert(Matrix{T1},D) 
      else
        T1r = real(T1)
        if T1r !== T
         A = convert(Matrix{T1r},A) 
         B = convert(Matrix{T1r},B) 
         C = convert(Matrix{T1r},C) 
         D = convert(Matrix{T1r},D) 
        end
      end
    end
    try
      X, Y = sylvsyss!(A,B,E,C,D,F) 
      return [X Y][:]
    catch err
       # if isnothing(findfirst("LAPACKException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function tprod(x)
    T1 = promote_type(T, eltype(x))
    E = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    F = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    if T !== T1
      if cmplx
         A = convert(Matrix{T1},A) 
         B = convert(Matrix{T1},B) 
         C = convert(Matrix{T1},C) 
         D = convert(Matrix{T1},D) 
      else
        T1r = real(T1)
        if T1r !== T
         A = convert(Matrix{T1r},A) 
         B = convert(Matrix{T1r},B) 
         C = convert(Matrix{T1r},C) 
         D = convert(Matrix{T1r},D) 
        end
      end
    end
    try
      X, Y = dsylvsyss!(A,B,E,C,D,F) 
      return [X Y][:]
    catch err
       # if isnothing(findfirst("LAPACKException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  function ctprod(x)
    T1 = promote_type(T, eltype(x))
    E = reshape(convert(Vector{T1}, x[1:mn]), m, n)
    F = reshape(convert(Vector{T1}, x[mn+1:2*mn]), m, n)
    if T !== T1
      if cmplx
         A = convert(Matrix{T1},A) 
         B = convert(Matrix{T1},B) 
         C = convert(Matrix{T1},C) 
         D = convert(Matrix{T1},D) 
      else
        T1r = real(T1)
        if T1r !== T
         A = convert(Matrix{T1r},A) 
         B = convert(Matrix{T1r},B) 
         C = convert(Matrix{T1r},C) 
         D = convert(Matrix{T1r},D) 
        end
      end
    end
    try
      X, Y = dsylvsyss!(A,B,E,C,D,F) 
      return [X Y][:]
    catch err
       # if isnothing(findfirst("LAPACKException",string(err)))
       if findfirst("LAPACKException",string(err)) === nothing
          rethrow()
       else
          throw("ME:SingularException: Singular operator")
       end
    end
  end
  F1 = typeof(prod)
  F2 = typeof(tprod)
  F3 = typeof(ctprod)
  return LinearOperator{T}(2*mn, 2*mn, false, false, prod, tprod, ctprod)
end
invsylvsyssop(AC :: GeneralizedSchur, BD :: GeneralizedSchur) = invsylvsyssop(AC.S,BD.S,AC.T,BD.T)
