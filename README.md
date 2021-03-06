# MatrixEquations.jl

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3556377.svg)](https://doi.org/10.5281/zenodo.3556867)
[![Travis](https://travis-ci.com/andreasvarga/MatrixEquations.jl.svg?branch=master)](https://travis-ci.com/andreasvarga/MatrixEquations.jl)
[![codecov.io](https://codecov.io/gh/andreasvarga/MatrixEquations.jl/coverage.svg?branch=master)](https://codecov.io/gh/andreasvarga/MatrixEquations.jl?branch=master)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://andreasvarga.github.io/MatrixEquations.jl/dev/)
[![The MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](https://github.com/andreasvarga/MatrixEquations.jl/blob/master/LICENSE.md)

**Solution of some control system related matrix equations using [Julia](http://julialang.org)**

## Compatibility

Julia 1.0 and higher.

## How to Install

````JULIA
pkg> add MatrixEquations
pkg> test MatrixEquations
````

## About

This collection of Julia functions is an attemp to implement high performance
numerical software to solve classes of Lyapunov, Sylvester and Riccati matrix equations
at a performance level comparable with efficient structure exploiting Fortran implementations, as those available in the Systems and Control Library [SLICOT](http://slicot.org/).
This goal has been fully achieved for Lyapunov and Sylvester equation solvers, for which the
codes for both real and complex data perform at practically same performance level as similar functions available in
the MATLAB Control System Toolbox (which rely on SLICOT).

The available functions in the `MatrixEquation.jl` package cover both standard
and generalized continuous and discrete Lyapunov, Sylvester and Riccati equations for both real and complex data. The functions for the solution of Lyapunov and Sylvester equations rely on efficient structure
exploiting solvers for which the input data are in Schur or generalized Schur forms. A comprehensive set of Lyapunov and Sylvester operators has been implemented, which allow the estimation of condition numbers of these operators. The implementation of Riccati equation solvers employ orthogonal Schur vectors
based methods and their extensions to linear matrix pencil based reduction approaches. The calls of all functions with adjoint (in complex case) or transposed (in real case) arguments are fully supported by appropriate computational algorithms, thus the matrix copying operations are mostly avoided.

The current version of the package includes the following functions:

**Solution of Lyapunov equations**

* **lyapc**   Solution of the continuous Lyapunov equations `AX+XA'+C = 0` and `AXE'+EXA'+C = 0`.
* **lyapd**  Solution of discrete Lyapunov equations `AXA'-X +C = 0` and `AXA'-EXE'+C = 0`.
* **plyapc**  Solution of the positive continuous Lyapunov equations `AX+XA'+BB' = 0` and `AXE'+EXA'+BB' = 0`.
* **plyapd**  Solution of the positive discrete Lyapunov equations `AXA'-X +C = 0` and `AXA'-EXE'+C = 0`.

 **Solution of algebraic  Riccati equations**

* **arec**  Solution of the continuous Riccati equations `AX+XA'-XRX+Q = 0` and
 `A'X+XA-(XB+S)R^(-1)(B'X+S')+Q = 0`.
* **garec** Solution of the generalized continuous Riccati equation
 `A'XE+E'XA-(A'XB+S)R^(-1)(B'XA+S')+Q = 0`.
* **ared** Solution of the discrete Riccati equation
 `A'XA - X - (A'XB+S)(R+B'XB)^(-1)(B'XA+S') + Q = 0`.
* **gared**  Solution of the generalized discrete Riccati equation
 `A'XA - E'XE - (A'XB+S)(R+B'XB)^(-1)(B'XA+S') + Q = 0`.

 **Solution of Sylvester equations and systems**

* **sylvc** Solution of the (continuous) Sylvester equation `AX+XB = C`.
* **sylvd** Solution of the (discrete) Sylvester equation `AXB+X = C`.
* **gsylv** Solution of the generalized Sylvester equation `AXB+CXD = E`.
* **sylvsys** Solution of the Sylvester system of matrix equations `AX+YB = C, DX+YE = F`.
* **dsylvsys** Solution of the dual Sylvester system of matrix equations `AX+DY = C, XB+YE = F`.

**Norm, condition and separation estimation**

* **opnorm1**  Computation of the 1-norm of a linear operator.
* **opnorm1est** Estimation of 1-norm of a linear operator.
* **oprcondest** Estimation of the reciprocal 1-norm condition number of a linear operator.
* **opsepest** Estimation of the 1-norm separation a linear operator.

The general solvers of Lyapunov and Sylvester equations rely on a set of specialized solvers for real or complex matrices in appropriate Schur forms. For testing purposes, a set of solvers for Sylvester equations has been implemented, which employ the Kronecker-product expansion of the equations. These solvers are not recommended for large order matrices. The norms, reciprocal condition numbers and separations can be estimated for a comprehensive set of predefined Lyapunov and Sylvester operators. A complete list of implemented functions is available [here](https://sites.google.com/site/andreasvargacontact/home/software/matrix-equations-in-julia).

## Future plans

The collection of tools will be extended by adding new functionality, such as expert solvers which additionally compute error bounds and condition estimates. Further, performance improvements are planned to be implemented employing more efficient and accurate low dimensional linear system solvers available in LAPACK, using static arrays for manipulation of small order matrices, and exploring block variant solvers for Lyapunov and Sylvester equations.
