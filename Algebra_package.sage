# +---------------------------------+
# |  Algebra package package v6.0   |
# |  Date: 2026-03-19               |
# |  Author: Jozef Hanc             |
# +---------------------------------+

print("Downloading the package Algebra...")
import numpy as np

from sympy.printing import latex as Latex
from IPython.display import Math 
import re

spfun = lambda f,A: A.apply_map(lambda x: 0 if x.is_zero() else f(x))

def exact(x):
    def exact_entry(a):
        try:
            return a.exactify().radical_expression()
        except Exception:
            try:
                return a.radical_expression()
            except Exception:
                try:
                    return QQ(a)
                except Exception:
                    return a

    try:
        return x.apply_map(exact_entry)
    except AttributeError:
        return exact_entry(x)

def _copy_matrix(A):
    """
    Return a mutable copy of A.

    The original matrix A is not changed by the row operations below.
    """
    return copy(A)


def _check_row_index(A, i):
    """
    Check whether i is a valid row index of A.

    Indexing is 0-based:
        0, 1, ..., A.nrows() - 1
    """
    if not (0 <= i < A.nrows()):
        raise IndexError("Row index out of range.")


def _check_two_row_indices(A, i, j):
    """
    Check whether i and j are valid row indices of A.
    """
    _check_row_index(A, i)
    _check_row_index(A, j)


def rescale_row(A, i, a):
    """
    Return a new matrix obtained from A by multiplying row i by a.

    Operation:
        row_i <- a * row_i

    The original matrix A is not changed.
    """
    _check_row_index(A, i)

    B = _copy_matrix(A)
    B.rescale_row(i, a)

    return B


def add_multiple_of_row(A, i, j, a):
    """
    Return a new matrix obtained from A by adding a multiple of row j to row i.

    Operation:
        row_i <- row_i + a * row_j

    The original matrix A is not changed.
    """
    _check_two_row_indices(A, i, j)

    B = _copy_matrix(A)
    B.add_multiple_of_row(i, j, a)

    return B


def swap_rows(A, i, j):
    """
    Return a new matrix obtained from A by swapping rows i and j.

    Operation:
        row_i <-> row_j

    The original matrix A is not changed.
    """
    _check_two_row_indices(A, i, j)

    B = _copy_matrix(A)
    B.swap_rows(i, j)

    return B


def set_row(A, i, u):
    """
    Return a new matrix obtained from A by replacing row i by the vector u.

    Operation:
        row_i <- u

    The original matrix A is not changed.
    """
    _check_row_index(A, i)

    if len(u) != A.ncols():
        raise ValueError("The new row must have length equal to the number of columns of A.")

    B = _copy_matrix(A)
    B.set_row(i, vector(A.base_ring(), u))

    return B

# definition of Levi-Civita symbol
eps = lambda p: sign(prod(p[j] - p[i] for i in range(len(p)) for j in range(i+1, len(p))))

v = lambda plist: vector(plist)

radical = lambda D: D.apply_map(lambda x: x.radical_expression())



def smatrix(name, m, n=1):
    """
    Create a symbolic vector or matrix with indexed variable names.
    
    Parameters:
        name (str): Base name for the variables (e.g., 'v' gives v0, v1, ...)
        m (int): Number of rows (for matrix) or length (for vector)
        n (int, optional): Number of columns. Default is 1 (creates a vector).
        ring: The ring for the matrix/vector elements. Default is SR (Symbolic Ring).
    
    Returns:
        vector: If n == 1, returns a vector of length m with elements name0, name1, ...
        matrix: Otherwise, returns an m×n matrix with elements name{i}{j}
    """
    # Create a symbolic vector when n == 1
    if n == 1:
        return vector(SR, [var(f"{name}{i}") for i in range(m)])
    
    # Create a symbolic m×n matrix with indexed entries
    return matrix(SR, m, n, lambda i, j: var(f"{name}{i}{j}"))


from sage.all import matrix as sage_matrix, vector as sage_vector, SR, var
from sage.misc.functional import norm as sage_norm

from functools import wraps

#def Norm(v):
#    # Convert input to a matrix to ensure .T exists
#    M = matrix(v)
#    # For a row vector v, M.T * M gives a square matrix 
#    # For a column vector v, M * M.T gives the square of the norm in the trace
#    # However, to be mathematically consistent with complex matrices and vector:
#    return (M.H * M).trace().sqrt()

from functools import wraps
from sage.misc.functional import norm as sage_norm

@wraps(sage_norm)
def norm(x, p=None):
    """
    Extended Sage norm.

    Behavior:
    - norm(x): preserve Sage default behavior, except for 1xn or nx1 matrices,
      where return the exact Frobenius/Euclidean norm.
    - norm(x, p='frob'): for any matrix, return the exact Frobenius norm.
    - norm(x, p=1), norm(x, p=2), norm(x, p=oo), norm(x, p=Infinity):
      for matrices, delegate to x.norm(p).
    - for non-matrices, delegate to Sage's original norm(x).
    """

    is_matrix = (
        hasattr(x, 'nrows') and
        hasattr(x, 'ncols') and
        hasattr(x, 'H')
    )

    if not is_matrix:
        if p is None:
            return sage_norm(x)
        try:
            return x.norm(p)
        except Exception:
            raise TypeError("parameter p is not supported for this object")

    # x is a matrix
    is_vector_shaped_matrix = (x.nrows() == 1 or x.ncols() == 1)

    # Default call norm(x)
    if p is None:
        if is_vector_shaped_matrix:
            return ((x.H * x).trace()).sqrt()
        return sage_norm(x)

    # Exact Frobenius for matrices
    if p == 'frob':
        return ((x.H * x).trace()).sqrt()

    # Usual Sage matrix norms
    if p in (1, 2, oo, Infinity):
        return x.norm(p)

    raise ValueError("for matrices, p must be one of 1, 2, oo, Infinity, 'frob'")

@wraps(sage_matrix)
def matrix(*args, **kwargs):
    if len(args) == 4 and args[0] == SR and isinstance(args[3], str):
        _, m, n, name = args

        try:
            m = int(m)
            n = int(n)
        except Exception:
            raise TypeError("In matrix(SR, m, n, name, ...), m and n must be integers.")

        if m < 0 or n < 0:
            raise ValueError("In matrix(SR, m, n, name, ...), require m >= 0 and n >= 0.")

        indexing = kwargs.pop('indexing', 'python')
        if indexing not in ('python', 'natural'):
            raise ValueError("indexing must be 'python' or 'natural'.")

        shift = 0 if indexing == 'python' else 1
        base_latex = kwargs.pop('latex_name', None)

        def make_var(i, j):
            ii, jj = i + shift, j + shift
            if base_latex is None:
                return var(f"{name}{ii}{jj}", **kwargs)
            return var(
                f"{name}{ii}{jj}",
                latex_name=f"{base_latex}_{{{ii}{jj}}}",
                **kwargs
            )

        return sage_matrix(m, n, lambda i, j: make_var(i, j))

    return sage_matrix(*args, **kwargs)


matrix.__doc__ = (matrix.__doc__ or "") + r"""

Extension:
    If called as matrix(SR, m, n, name) with name a string, it creates
    an m x n symbolic matrix with indexed variable names.

Parameters for the extension:
    name (str): Base name for the variables.
    m (int): Number of rows.
    n (int): Number of columns.
    indexing (str, optional): 'natural' for indexing from 1, or
        'python' for indexing from 0. Default is 'natural'.
    **kwargs: Passed to var(...), e.g. domain='real', latex_name=r'\alpha'.

Returns for the extension:
    matrix: An m x n symbolic matrix with entries name{i}{j}.

Example:
    matrix(SR, m, n, 'a') returns the symbolic matrix
    [a11 a12 ...;
     a21 a22 ...;
     ...         ].

    matrix(SR, m, n, 'a', indexing='python') returns
    [a00 a01 ...;
     a10 a11 ...;
     ...         ].

    matrix(SR, m, n, 'a', latex_name=r'\alpha') uses LaTeX names
    \alpha_{11}, \alpha_{12}, ...
"""


@wraps(sage_vector)
def vector(*args, **kwargs):
    if len(args) == 3 and args[0] == SR and isinstance(args[2], str):
        _, n, name = args

        try:
            n = int(n)
        except Exception:
            raise TypeError("In vector(SR, n, name, ...), n must be an integer.")

        if n < 0:
            raise ValueError("In vector(SR, n, name, ...), require n >= 0.")

        indexing = kwargs.pop('indexing', 'python')
        if indexing not in ('python', 'natural'):
            raise ValueError("indexing must be 'python' or 'natural'.")

        shift = 0 if indexing == 'python' else 1
        base_latex = kwargs.pop('latex_name', None)

        def make_var(i):
            ii = i + shift
            if base_latex is None:
                return var(f"{name}{ii}", **kwargs)
            return var(
                f"{name}{ii}",
                latex_name=f"{base_latex}_{{{ii}}}",
                **kwargs
            )

        return sage_vector([make_var(i) for i in range(n)])

    return sage_vector(*args, **kwargs)


vector.__doc__ = (vector.__doc__ or "") + r"""

Extension:
    If called as vector(SR, n, name) with name a string, it creates
    a symbolic vector with indexed variable names.

Parameters for the extension:
    name (str): Base name for the variables.
    n (int): Length of the vector.
    indexing (str, optional): 'natural' for indexing from 1, or
        'python' for indexing from 0. Default is 'natural'.
    **kwargs: Passed to var(...), e.g. domain='real', latex_name=r'\alpha'.

Returns for the extension:
    vector: A symbolic vector with entries name1, name2, ..., namen,
    or name0, name1, ..., name(n-1) if indexing='python'.

Example:
    vector(SR, n, 'a') returns the symbolic vector
    (a1, a2, ..., an).

    vector(SR, n, 'a', indexing='python') returns
    (a0, a1, ..., a(n-1)).

    vector(SR, n, 'a', latex_name=r'\alpha') uses LaTeX names
    \alpha_1, \alpha_2, ...
"""

def chop(A, eps=1e-10):
    R = A.base_ring()

    def chop_entry(x):
        re = 0 if abs(x.real()) < eps else x.real()
        im = 0 if abs(x.imag()) < eps else x.imag()
        return re if im == 0 else re + im*I

    return matrix(R, A.nrows(), A.ncols(), map(chop_entry, A.list()))

def singularvalues(A, exact=True, digits=None, sort=True):
    if exact:
        s = A._sympy_().singular_values()
        s = [x._sage_() for x in s]

        if sort:
            try:
                s = sorted(s, key=lambda x: x.n(), reverse=True)
            except Exception:
                pass

        return s

    else:
        s = A.change_ring(CDF).singular_values()

        if digits is not None:
            s = [x.n(digits=digits) for x in s]

        return s

def sort_svd_sage(U, S, V):
    sing = list(S.diagonal())
    sing_num = [s.n() for s in sing]
    perm = sorted(range(len(sing_num)), key=lambda i: sing_num[i], reverse=True)

    U_new = U.matrix_from_columns(perm)
    V_new = V.matrix_from_columns(perm)
    S_new = diagonal_matrix([sing[i] for i in perm])

    return U_new, S_new, V_new

def QR(B, digits=None):
    if digits is None:
        Q, R = B._sympy_().QRdecomposition()
        Q, R = Q._sage_(), R._sage_()
        return Q, R

    else:
        Q, R = B.change_ring(CDF).QR()
        Q = Q.apply_map(lambda x: x.n(digits=digits))
        R = R.apply_map(lambda x: x.n(digits=digits))
        return Q, R

def SVD(B, digits=None, full=True, sort=True):

    m, n = B.dimensions()

    if digits is None:
        U, S, V = B._sympy_().singular_value_decomposition()
        U, S, V = U._sage_(), S._sage_(), V._sage_()

        # SymPy reduced SVD may return singular values unsorted
        if sort:
            try:
                U, S, V = sort_svd_sage(U, S, V)
            except Exception:
                pass

        if full:

            # check if already full
            if not (U.ncols() == m and V.ncols() == n and S.dimensions() == (m, n)):

                r = U.ncols()

                ker_Ut = matrix(U.transpose().right_kernel().basis()).transpose()
                ker_Vt = matrix(V.transpose().right_kernel().basis()).transpose()

                U = QR(U.augment(ker_Ut))[0]
                V = QR(V.augment(ker_Vt))[0]
                S = S.stack(matrix(m - r, r, 0)).augment(matrix(m, n - r, 0))

        return U, S, V

    else:
        U, S, V = B.change_ring(CDF).SVD()

        U = U.apply_map(lambda x: x.n(digits=digits))
        S = S.apply_map(lambda x: x.n(digits=digits))
        V = V.apply_map(lambda x: x.n(digits=digits))

        return U, S, V



# multiple independent symbolic equations solving
def rsolve(eqs, var, *args, **kwargs):
    if not isinstance(var, (list, tuple)):
        var = [var]
    sols = solve(eqs, var, *args, **kwargs)
    return [s for s in sols if all(v.subs(s).is_real() for v in var)]
msolve = lambda eqs, var, domain='real': [
    rsolve(equation, var) if domain == 'real' else solve(equation, var) 
    for equation in eqs]

# symbolic vector equations solving
vsolve = lambda vector, vars: solve([component for component in vector], vars)

# General Solve procedure setting numeric, real or positive
def Solve(eqs, var, numeric=False, real=True, positive=None, *args, **kwargs):
    if not isinstance(var, (list, tuple)):
        var = [var]
    sols = solve(eqs, var, *args, **kwargs)
    res = []
    for s in sols:
        ok = True
        for v in var:
            val = v.subs(s)
            if real and not val.is_real():
                ok = False
                break
            if positive is True and bool(val < 0):
                ok = False
                break
            if positive is False and bool(val >= 0):
                ok = False
                break
        if ok:
            res.append(s)
    if numeric:
        res = [s.lhs()==s.rhs().n() for s in res]        
    return res

# limits from equations
def Limit(expr, **kwargs):
    """
    Compute the limit of a symbolic expression.

    Parameters:
    - expr: The symbolic expression to compute the limit of.
    - **kwargs: Additional keyword arguments to pass to the limit function.

    Returns:
    - result: The computed limit of the expression.
    """
    from operator import eq
    from sage.symbolic.expression import Expression

    # Check if the expression is an equality
    if isinstance(expr, Expression) and expr.operator() == eq:
        # Compute the limit of the left-hand side and right-hand side separately
        result = limit(expr.lhs(), **kwargs) == limit(expr.rhs(), **kwargs)
    else:
        # Compute the limit of the expression
        result = limit(expr, **kwargs)

    return result

def is_matrix(expr):
    # Ak má expr metódy nrows() a ncols(), považujeme ho za maticu.
    if hasattr(expr, 'nrows') and hasattr(expr, 'ncols') and callable(expr.nrows) and callable(expr.ncols):
        return True
    # Ak expr má metódu column(), ide o vektor, ktorý môže byť chápaný ako matica (stĺpcová).
    if hasattr(expr, 'column') and callable(expr.column):
        try:
            expr.column()  # pokus o prevod na stĺpcovú maticu
            return True
        except Exception:
            return False
    # Inak to nie je maticový objekt.
    return False


def trig_form(expr, simplify=True):
    # Ak je expr maticou (alebo vektorom, ktorý uvažujeme ako maticu)
    if is_matrix(expr):
        M = expr.apply_map(lambda x: x._maxima_().demoivre()._sage_())
        if simplify:
            M = M.apply_map(lambda x: x.simplify_trig().reduce_trig())
    else:
        # Pre výraz, ktorý nie je maticou ani vektorom
        M = expr._maxima_().demoivre()._sage_()
        if simplify:
            M = M.simplify_trig().reduce_trig()
    return M

def Re(expr, simplify=True):
    # Ak je expr maticou (alebo vektorom)
    if is_matrix(expr):
        M = expr.apply_map(lambda x: x._maxima_().realpart()._sage_())
        if simplify:
            M = M.apply_map(lambda x: x.canonicalize_radical().expand())
    else:
        M = expr._maxima_().realpart()._sage_()
        if simplify:
            M = M.canonicalize_radical().expand()
    return M

j = I*0+sqrt(-1)

def Im(expr, simplify=True):
    # Ak je expr maticou (alebo vektorom)
    if is_matrix(expr):
        M = expr.apply_map(lambda x: x._maxima_().imagpart()._sage_())
        if simplify:
            M = M.apply_map(lambda x: x.canonicalize_radical().expand())
    else:
        M = expr._maxima_().imagpart()._sage_()
        if simplify:
            M = M.canonicalize_radical().expand()
    return M


def Abs(expr, simplify=False):
    # Ak je expr maticou (alebo vektorom)
    if is_matrix(expr):
        M = expr.apply_map(lambda x: x._maxima_().cabs()._sage_())
        if simplify:
            M = M.apply_map(lambda x: x.canonicalize_radical().expand())
    else:
        M = expr._maxima_().cabs()._sage_()
        if simplify:
            M = M.canonicalize_radical().expand()
    return M


def Arg(expr, simplify=False):
    # Ak je expr maticou (alebo vektorom)
    if is_matrix(expr):
        M = expr.apply_map(lambda x: x._maxima_().carg()._sage_())
        if simplify:
            M = M.apply_map(lambda x: x.canonicalize_radical().expand())
    else:
        M = expr._maxima_().carg()._sage_()
        if simplify:
            M = M.canonicalize_radical().expand()
    return M

def algebra_form(expr, simplify=False):
    # Ak je expr maticou (alebo vektorom)
    if is_matrix(expr):
        M = expr.apply_map(lambda x: x._maxima_().rectform()._sage_())
        if simplify:
            M = M.apply_map(lambda x: x.canonicalize_radical().expand())
    else:
        M = expr._maxima_().rectform()._sage_()
        if simplify:
            M = M.canonicalize_radical().expand()
    return M

def euler_form(expr, numeric=False, digits=16,
               simplify=True, force_atan2_subst=True, simplify_absarg=False):
    """
    Euler/polar form using your Abs/Arg (Maxima cabs/carg).

    - For symbolic: returns Abs(z) * exp(I*Arg(z), hold=True) with cleanup.
    - For numeric=True: additionally evaluates Abs/Arg to decimals with given digits.
    """

    _is_matrix = is_matrix
    _exp, _I = exp, I
    _atan2, _sin, _cos = atan2, sin, cos

    def _simp_trig(e):
        return e.simplify_trig().reduce_trig() if simplify else e

    def _postprocess_theta(theta):
        th = _simp_trig(theta)
        if force_atan2_subst:
            try:
                vars_ = th.variables()
            except Exception:
                vars_ = ()
            for v in vars_:
                th = th.subs(_atan2(_sin(v), _cos(v)) == v)
        return _simp_trig(th)

    def _one(z):
        r = Abs(z, simplify=simplify_absarg)
        th = Arg(z, simplify=simplify_absarg)

        if numeric:
            r = r.n(digits=digits)
            th = th.n(digits=digits)
            return r * _exp(_I * th, hold=True)

        r = _simp_trig(r)
        th = _postprocess_theta(th)

        # Ak sa |z| zjednoduší na 1, vráť priamo exp(i*theta)
        if r == 1:
            return _exp(_I * th, hold=True)

        return r * _exp(_I * th, hold=True)

    if _is_matrix(expr):
        return expr.apply_map(_one)
    return _one(expr)

def replace_column(A, j, col):
    M = matrix(A)         # fresh matrix
    M.set_column(j, col)  # mutate the copy
    return M

# numerical solution
def nsolve(eqs, *args, **kwargs):
    return [sol.lhs() == sol.rhs().n() for sol in solve(eqs, *args, **kwargs)]

# solving pde of 1st order using sympy
# https://docs.sympy.org/latest/modules/solvers/pde.html
def separate(pde,u,X,Y):
    from sympy import pde_separate
    sep = pde_separate(pde._sympy_(), u._sympy_(), [X._sympy_(), Y._sympy_()])
    return sep[0]._sage_() == sep[1]._sage_()  

def pde_type(pde):
    from sympy.solvers.pde import classify_pde
    from IPython.display import Markdown
    return Markdown(classify_pde(pde._sympy_())[0])

def pdesolve(pde):
    from sympy.solvers.pde import pdsolve 
    sol = pdsolve(pde._sympy_())._sage_()
    return sol

def pde2_type(DD):
    if   DD == 0: print(f'Discriminant={DD}, parabolic')
    elif DD > 0 : print(f'Discriminant={DD} > 0, hyperbolic')
    else        : print(f'Discriminant={DD} < 0, eliptic')    

def separate_SchE(SchE, psi, phi, T):
    phix = phi.diff(x)
    Hphi = var('Hphi', latex_name=r'H\varphi(\xi)')
    sep = separate(SchE.subs(Hpsi == psi.diff(x)), psi, phi, T)
    return sep.subs(phix == Hphi)

def showURL(url, ht=550):

    '''shortcut for IFrame displaying various media at given url address;
       for interactive SageMath worksheets it is appropriate height 424 and width 100%
    '''
    from sage.misc.html import html
    return pretty_print(html.iframe(url, width='100%', height=ht))


def showGeo(url, ht=550):
    """
    Generates an iframe URL for a GeoGebra applet with specified display settings.

    Parameters:
    url (str): The URL of the GeoGebra applet.
    ht (int): The height of the iframe. The default is 424.

    Note: These parameters are appropriate for SageMath worksheets.

    Returns:
    IFrame: An IFrame object that embeds the GeoGebra applet with 'Reset' and 'Fullscreen' icons.
    """

    from sage.misc.html import html
    # Extract the id from the given URL
    applet_id = url.split('/')[-1]
    
    # Construct the new URL in the desired iframe format with additional parameters
    transformed_url = (
        f"https://www.geogebra.org/material/iframe/id/{applet_id}/sfsb/true/"
        "smb/false/stb/false/stbh/false/ai/false/asb/false/sri/true/rc/false/"
        "ld/false/sdz/false/ctl/false"
    )
    
    # Return the IFrame object for embedding
    return pretty_print(html.iframe(transformed_url, width='100%', height=ht))

def set_simp(spec="ctf"):
    """
    Build a simplifier `simp` from a spec that can be:
      - a string of shortcuts, e.g. "c", "ct", "ctf", "fct"
      - a tuple/list of shortcuts or method names, e.g. ("c","reduce_trig","f")
      - a tuple/list of callables taking one arg, e.g. (lambda x: x.simplify_full(),)

    Shortcuts:
      c -> canonicalize_radical
      t -> reduce_trig
      f -> factor

    Works both for symbolic expressions and matrices of symbolic expressions.
    """

    shortcut = {
        "c": "canonicalize_radical",
        "t": "reduce_trig",
        "f": "factor",
    }

    if isinstance(spec, str):
        steps_in = list(spec)
    elif isinstance(spec, (tuple, list)):
        steps_in = list(spec)
    else:
        raise TypeError("spec must be a string, tuple, or list")

    def apply_step(obj, step):
        # 1. Ak objekt vie krok aplikovať priamo, použijeme to
        if callable(step):
            try:
                return step(obj)
            except Exception:
                # 2. Ak je to matica, skúsime krok po prvkoch
                if hasattr(obj, "apply_map"):
                    return obj.apply_map(step)
                raise

        raise TypeError(f"Invalid step {step!r}, expected callable")

    steps = []
    for item in steps_in:
        if callable(item):
            steps.append(item)
            continue

        if not isinstance(item, str):
            raise TypeError(f"Step {item!r} must be a string or callable")

        method_name = shortcut.get(item, item)

        def make_step(name):
            def step(y):
                # ak má objekt metódu priamo, zavolaj ju
                if hasattr(y, name):
                    return getattr(y, name)()

                # ak ide o maticu, aplikuj po prvkoch
                if hasattr(y, "apply_map"):
                    return y.apply_map(lambda z: getattr(z, name)())

                raise AttributeError(f"Object {y!r} has no method {name!r}")
            return step

        steps.append(make_step(method_name))

    def simp(objekt):
        y = objekt
        for step in steps:
            y = apply_step(y, step)
        return y

    return simp


def Collect(expr, *kwargs):
    '''
    Collects terms containing common variables  using Maxima:
    - expr: an expression
    - *kwargs: given variables
    '''
    exprm = expr.expand().maxima_methods()
    return exprm.collectterms(*kwargs)._sage_()

def Subs(expression, substitutions):
    '''
    Substitution proccesed by Sympy:
    - expr: an expression in which are desired the substitutions
    - substitutions: list of equations [old_expr_1 == new_expr_1, old_expr_2 = new_expr_2, ...]
                     or dictionary {old_expr_1:new_expr_1, old_expr_2: new_expr_2, ...}
    '''
    if type(substitutions) is list:
        substitutions = {eq.lhs():eq.rhs() for eq in substitutions}
    return expression._sympy_().subs(substitutions)._sage_()

def der(f,g):
    """
    derivative of function f with respect function g
     - f can be an algebraic expression
     - g can be a symbolic variable, function or expression
    """
    gvar = var('gvar')
    result = f.subs(g == gvar).diff(gvar).subs(gvar == g) 
    return result

# ============================================================
# Parciálna diferenciálna rovnica 2. rádu:
#
# 3*u_xx + 2*u_xy + 3*u_yy - 8*u_x + 2*u_y + 4*u = 0
#
# Cieľ:
# 1. určiť typ PDE,
# 2. odstrániť zmiešanú deriváciu pomocou lineárnej transformácie,
# 3. odstrániť prvé derivácie substitúciou u = exp(a*r+b*s)*v,
# 4. škálovaním dostať finálny kanonický tvar.
#
# Kód je čistý SageMath.
# ============================================================


# ------------------------------------------------------------
# Pomocné funkcie
# ------------------------------------------------------------

def chain_rule_2D(old_fun, new_fun, old_vars, trans_funcs, trans_exprs, new_vars):
    """
    Automaticky vytvorí substitúcie reťazového pravidla do 2. rádu.

    old_fun:
        pôvodná závislá funkcia, napr. u(x,y)

    new_fun:
        tá istá závislá funkcia v nových premenných, napr. u(r,s)

    old_vars:
        pôvodné nezávislé premenné, napr. (x,y)

    trans_funcs:
        pomocné funkcie nových premenných závislé od pôvodných,
        napr. (rho(x,y), sigma(x,y))

    trans_exprs:
        konkrétne transformačné vzťahy,
        napr. ((x+y)/sqrt(2), (x-y)/sqrt(2))

    new_vars:
        nové nezávislé premenné, napr. (r,s)

    Výstup:
        zoznam substitúcií pre:
        u,
        u_x, u_y,
        u_xx, u_yy, u_xy.
    """

    x, y = old_vars
    Rfun, Sfun = trans_funcs
    Rexpr, Sexpr = trans_exprs
    r, s = new_vars

    # zložená funkcia u(R(x,y), S(x,y))
    composed = new_fun.subs(r == Rfun, s == Sfun)

    # derivácie transformačných funkcií
    trans_rules = []

    derivs_trans = [
        (x,), (y,),
        (x, 2), (y, 2), (x, y)
    ]

    for F, Fexpr in zip(trans_funcs, trans_exprs):
        for d in derivs_trans:
            trans_rules.append(diff(F, *d) == diff(Fexpr, *d))

    # po použití reťazového pravidla sa vrátime k symbolom nových premenných
    back_to_new_vars = [
        Rfun == r,
        Sfun == s
    ]

    # pravidlá pre závislú funkciu a jej derivácie
    rules = [
        old_fun == new_fun
    ]

    derivs_u = [
        (x,), (y,),
        (x, 2), (y, 2), (x, y)
    ]

    for d in derivs_u:
        lhs = diff(old_fun, *d)
        rhs = diff(composed, *d).subs(trans_rules).subs(back_to_new_vars).expand()
        rules.append(lhs == rhs)

    return rules


def dependent_substitution_2D(old_fun, new_expr, ivars):
    """
    Substitúcia závislej premennej do 2. rádu.

    Napríklad:
        u(r,s) = exp(a*r+b*s)*v(r,s)

    Vytvorí substitúcie pre:
        u,
        u_r, u_s,
        u_rr, u_ss, u_rs.
    """

    r, s = ivars

    rules = [
        old_fun == new_expr
    ]

    derivs = [
        (r,), (s,),
        (r, 2), (s, 2), (r, s)
    ]

    for d in derivs:
        rules.append(diff(old_fun, *d) == diff(new_expr, *d).expand())

    return rules


def collect_in_derivatives(expr, fun, ivars):
    """
    Upraví výraz tak, aby bol čitateľnejší:
    vyberie členy podľa derivácií funkcie.
    """

    r, s = ivars

    expr2 = expr.expand()
    expr2 = expr2.collect(diff(fun, r, 2))
    expr2 = expr2.collect(diff(fun, s, 2))
    expr2 = expr2.collect(diff(fun, r, s))
    expr2 = expr2.collect(diff(fun, r))
    expr2 = expr2.collect(diff(fun, s))
    expr2 = expr2.collect(fun)

    return expr2

def make_pde2(coefs, ivars, fun_name='u', equation=False, rhs=0):
    """
    Vytvorí lineárnu PDE 2. rádu v dvoch premenných zo zoznamu koeficientov.

    coefs:
        [A, B, C, D, E, F]

    Ak je zoznam kratší než 6, chýbajúce koeficienty sa doplnia nulami.

    Príklady:
        [3, 2, 3, -8, 2, 4]
            -> 3*u_xx + 2*u_xy + 3*u_yy - 8*u_x + 2*u_y + 4*u

        [3, 2, 3]
            -> 3*u_xx + 2*u_xy + 3*u_yy

        [3]
            -> 3*u_xx

    vars:
        (x, y)

    fun_name:
        meno závislej funkcie, štandardne 'u'

    equation:
        False -> vráti ľavú stranu PDE
        True  -> vráti rovnicu PDE == rhs

    Výstup:
        (PDE, u)
    """

    if len(coefs) > 6:
        raise ValueError("Zoznam koeficientov môže mať najviac 6 prvkov: [A, B, C, D, E, F].")

    coefs = list(coefs) + [0]*(6 - len(coefs))

    A, B, C, D, E, F = [SR(c) for c in coefs]

    x, y = ivars
    u = function(fun_name)(x, y)

    lhs = (
        A*diff(u, x, 2)
        + B*diff(u, x, y)
        + C*diff(u, y, 2)
        + D*diff(u, x)
        + E*diff(u, y)
        + F*u
    ).expand()

    if equation:
        return lhs == rhs, u
    else:
        return lhs, u

der2 = lambda f,u,v: der(der(f,u),v)

# ------------------------------------------------------------
# Difference-equation sequences in SageMath
# ------------------------------------------------------------
#
# This code defines a small helper tool for recursively generated
# sequences written in a mathematical SageMath style.
#
# Instead of defining a sequence by a Python lambda function, for example
#
#     a = lambda n: a0 if n == 0 else a(n-1)/n
#
# we can write the recurrence as a symbolic difference equation:
#
#     a = sequence('a')
#     a = desequence(a(n+1) == a(n)/(n+1), [a(0) == a0])
#
# The resulting object behaves like a sequence:
#
#     a(k)          returns the k-th term a_k
#     a.list(N)     returns [a_0, ..., a_{N-1}]
#     a.series(N)   returns a_0 + a_1*x + ... + a_{N-1}*x^(N-1)
#
# The tool also stores useful information:
#
#     a.values      computed sequence values
#     a.initials    initial conditions
#     a.equation    defining difference equation
#
# The purpose is not to solve recurrences in closed form, but to generate
# terms recursively from explicit recurrence rules.
# ------------------------------------------------------------


def sequence(*args, **kwargs):
    """
    Create a symbolic placeholder for a sequence.

    This is a semantic wrapper around SageMath's function(...).
    It accepts the same positional and keyword arguments as function(...).

    Example:
        a = sequence('a')
        eq = a(n+1) == a(n)/(n+1)
    """
    return function(*args, **kwargs)
  
class ShowableList(list):
    """
    A Python list with an additional .show() method.

    Example:
        seq.list(8).show()

    is equivalent to:
        show(seq.list(8))
    """

    def show(self):
        return show(list(self))


class ShowableDict(dict):
    """
    A Python dictionary with an additional .show() method.

    Example:
        seq.values.show()

    is equivalent to:
        show(seq.values)
    """

    def show(self):
        return show(dict(self))


def desequence(eq, ics):
    """
    Generate terms of a sequence from a SageMath difference equation.

    This is meant as a discrete analogue of SageMath's desolve command,
    but it generates sequence terms recursively rather than finding a
    closed-form symbolic solution.

    INPUT:

        eq  -- a SageMath symbolic equation, for example

                   a(n+1) == a(n)/(n+1)

               or

                   a(n+2) == a(n+1) + a(n)

        ics -- initial conditions. Several forms are allowed:

               Sage-style list of equations:

                   [a(0) == C]
                   [a(0) == 0, a(1) == 1]

               Dictionary with symbolic sequence values as keys:

                   {a(0): C}
                   {a(0): 0, a(1): 1}

               Dictionary with integer indices as keys:

                   {0: C}
                   {0: 0, 1: 1}

    OUTPUT:

        A function seq(k) returning a_k.

        Additional useful commands:

            seq.list(N)          first N terms: a_0, ..., a_{N-1}
            seq.list(N).show()   show(seq.list(N))

            seq.series(N)        finite power series in x
            seq.series(N, y)     finite power series in y
            seq.series(N).show() show(seq.series(N))

            seq.values           dictionary of computed values
            seq.values.show()    show(seq.values)

            seq.equation         original difference equation
            seq.equation.show()  show(seq.equation)

            seq.initials         initial conditions
            seq.initials.show()  show(seq.initials)

    EXAMPLES:

        var('n, C')
        a = function('a')

        eq = a(n+1) == a(n)/(n+1)
        seq = desequence(eq, [a(0) == C])
        seq.list(8)

        # Output:
        # [C, C, 1/2*C, 1/6*C, 1/24*C, 1/120*C, 1/720*C, 1/5040*C]

    Fibonacci example:

        var('n')
        a = function('a')

        eq = a(n+2) == a(n+1) + a(n)
        fib = desequence(eq, [a(0) == 0, a(1) == 1])
        fib.list(10)

        # Output:
        # [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
    """

    lhs = eq.lhs()
    rhs = eq.rhs()

    # Example:
    #     lhs = a(n+1)
    #     sequence_function = a
    #     lhs_index = n+1
    sequence_function = lhs.operator()
    lhs_operands = lhs.operands()

    if len(lhs_operands) != 1:
        raise ValueError("The left-hand side must have the form a(index), for example a(n) or a(n+1).")

    lhs_index = lhs_operands[0]

    # Find the symbolic index variable, usually n.
    index_variables = list(lhs_index.variables())

    if len(index_variables) != 1:
        raise ValueError("The index on the left-hand side must contain exactly one variable, for example n or n+1.")

    index_variable = index_variables[0]

    # Convert initial conditions to the internal form
    #
    #     {0: value_0, 1: value_1, ...}
    #
    # The user may write:
    #
    #     [a(0) == C, a(1) == D]
    #     {a(0): C, a(1): D}
    #     {0: C, 1: D}
    values = ShowableDict()

    def add_initial_condition(key, value):
        """
        Add one initial condition to the internal dictionary values.

        Accepted key forms:
            a(k)      symbolic sequence value
            k         integer index
        """

        if hasattr(key, 'operator') and key.operator() == sequence_function:
            key_operands = key.operands()

            if len(key_operands) != 1:
                raise ValueError("Each initial condition must have the form a(k) == value.")

            index = key_operands[0]
            values[ZZ(index)] = value

        else:
            values[ZZ(key)] = value

    if isinstance(ics, dict):
        for key, value in ics.items():
            add_initial_condition(key, value)

    elif isinstance(ics, (list, tuple)):
        for condition in ics:
            if not hasattr(condition, 'lhs') or not hasattr(condition, 'rhs'):
                raise ValueError("List initial conditions must be equations, for example [a(0) == C].")

            add_initial_condition(condition.lhs(), condition.rhs())

    else:
        raise TypeError("Initial conditions must be a dictionary or a list/tuple of equations.")

    initial_values = ShowableDict(values)

    def solve_for_index(k):
        """
        Find the value of the symbolic index variable needed to compute a_k.

        Example:
            lhs is a(n+1)
            to compute a_k, solve n+1 == k, hence n = k-1.
        """

        sol = solve(lhs_index == k, index_variable)

        if len(sol) != 1:
            raise ValueError("Could not uniquely solve the left-hand index for the recurrence variable.")

        return sol[0].rhs()

    def contains_sequence_function(expr):
        """
        Test whether expr still contains a symbolic occurrence of the
        sequence function, for example a(3) or a(k).

        Sage symbolic expressions do not have an .operators() method.
        Therefore we walk through the expression tree using .operator()
        and .operands().
        """

        try:
            op = expr.operator()
        except (AttributeError, TypeError, ValueError):
            return False

        if op == sequence_function:
            return True

        try:
            operands = expr.operands()
        except (AttributeError, TypeError, ValueError):
            return False

        return any(contains_sequence_function(operand) for operand in operands)

    def term(k):
        k = ZZ(k)

        if k < 0:
            raise ValueError("The sequence index must be nonnegative.")

        if k in values:
            return values[k]

        # Compute all previous terms first.
        for j in range(k):
            term(j)

        # Determine which value of n produces the left-hand side a(k).
        n_value = solve_for_index(k)

        # Substitute this value into the right-hand side.
        expr = rhs.subs({index_variable: n_value})

        # Replace a(0), a(1), ..., a(k-1) by their already computed values.
        for j in range(k):
            expr = expr.subs({sequence_function(j): values[j]})

        # If the expression still contains the sequence function, then the rule
        # was not explicit enough to compute a_k from previous terms only.
        if contains_sequence_function(expr):
            raise ValueError("The recurrence is not explicit in previously computed terms only.")

        values[k] = expr.simplify_full()
        return values[k]

    def list_terms(N):
        N = ZZ(N)

        if N < 0:
            raise ValueError("N must be nonnegative.")

        return ShowableList([term(k) for k in range(N)])

    def series_terms(N, variable=None):
        """
        Return the finite power series

            a_0 + a_1*x + ... + a_{N-1}*x^(N-1)

        By default, the variable is x.

        Examples:
            seq.series(8)       series in x
            seq.series(8, y)    series in y
            seq.series(8, 'y')  also allowed
        """

        N = ZZ(N)

        if N < 0:
            raise ValueError("N must be nonnegative.")

        if variable is None:
            variable = SR.var('x')

        if isinstance(variable, str):
            variable = SR.var(variable)

        return sum((term(k)*variable**k for k in range(N)), SR(0))

    term.list = list_terms
    term.series = series_terms
    term.values = values
    term.equation = eq
    term.initials = initial_values

    return term


# ------------------------------------------------------------
# EXAMPLES
# ------------------------------------------------------------
#
# The examples below are comments only.
# To run an example, copy it into a SageMath input cell without
# the leading comment symbols #.
#
# ------------------------------------------------------------
# Example 1: factorial-type recurrence
# ------------------------------------------------------------
#
# Mathematical recurrence:
#
#     a_{n+1} = a_n/(n+1),     a_0 = C
#
# SageMath code:
#
#     var('n, C')
#     a = function('a')
#
#     eq = a(n+1) == a(n)/(n+1)
#     seq = desequence(eq, [a(0) == C])
#
#     seq.list(8)
#
# Expected output:
#
#     [C, C, 1/2*C, 1/6*C, 1/24*C, 1/120*C, 1/720*C, 1/5040*C]
#
# ------------------------------------------------------------
# Example 2: the same recurrence with dictionary initial condition
# ------------------------------------------------------------
#
#     var('n, C')
#     a = function('a')
#
#     eq = a(n+1) == a(n)/(n+1)
#     seq = desequence(eq, {a(0): C})
#
#     seq.list(8)
#
# Expected output:
#
#     [C, C, 1/2*C, 1/6*C, 1/24*C, 1/120*C, 1/720*C, 1/5040*C]
#
# ------------------------------------------------------------
# Example 3: the same recurrence with integer-index dictionary
# ------------------------------------------------------------
#
#     var('n, C')
#     a = function('a')
#
#     eq = a(n+1) == a(n)/(n+1)
#     seq = desequence(eq, {0: C})
#
#     seq.list(8)
#
# Expected output:
#
#     [C, C, 1/2*C, 1/6*C, 1/24*C, 1/120*C, 1/720*C, 1/5040*C]
#
# ------------------------------------------------------------
# Example 4: Fibonacci sequence
# ------------------------------------------------------------
#
# Mathematical recurrence:
#
#     a_{n+2} = a_{n+1} + a_n,     a_0 = 0, a_1 = 1
#
# SageMath code:
#
#     var('n')
#     a = function('a')
#
#     eq = a(n+2) == a(n+1) + a(n)
#     fib = desequence(eq, [a(0) == 0, a(1) == 1])
#
#     fib.list(10)
#
# Expected output:
#
#     [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
#
# ------------------------------------------------------------
# Example 5: arithmetic sequence
# ------------------------------------------------------------
#
# Mathematical recurrence:
#
#     a_{n+1} = a_n + d,     a_0 = A
#
# SageMath code:
#
#     var('n, A, d')
#     a = function('a')
#
#     eq = a(n+1) == a(n) + d
#     seq = desequence(eq, [a(0) == A])
#
#     seq.list(6)
#
# Expected output:
#
#     [A, A + d, A + 2*d, A + 3*d, A + 4*d, A + 5*d]
#
# ------------------------------------------------------------
# Example 6: geometric sequence
# ------------------------------------------------------------
#
# Mathematical recurrence:
#
#     a_{n+1} = r a_n,     a_0 = A
#
# SageMath code:
#
#     var('n, A, r')
#     a = function('a')
#
#     eq = a(n+1) == r*a(n)
#     seq = desequence(eq, [a(0) == A])
#
#     seq.list(6)
#
# Expected output:
#
#     [A, A*r, A*r^2, A*r^3, A*r^4, A*r^5]
#
# ------------------------------------------------------------
# Example 7: constant sequence after the initial value
# ------------------------------------------------------------
#
# Mathematical recurrence:
#
#     a_{n+1} = 5,     a_0 = C
#
# SageMath code:
#
#     var('n, C')
#     a = function('a')
#
#     eq = a(n+1) == 5
#     seq = desequence(eq, [a(0) == C])
#
#     seq.list(8)
#
# Expected output:
#
#     [C, 5, 5, 5, 5, 5, 5, 5]
#
# Note:
#
#     This is different from eq = a(n) == 5 together with a(0) == C.
#     The equation a(n) == 5 also includes n = 0 unless we explicitly
#     restrict the range of n. Therefore it conflicts with a(0) == C
#     unless C = 5.
#
# ------------------------------------------------------------
# Example 8: second-order recurrence
# ------------------------------------------------------------
#
# Mathematical recurrence:
#
#     a_{n+2} = 3 a_{n+1} - 2 a_n,     a_0 = A, a_1 = B
#
# SageMath code:
#
#     var('n, A, B')
#     a = function('a')
#
#     eq = a(n+2) == 3*a(n+1) - 2*a(n)
#     seq = desequence(eq, [a(0) == A, a(1) == B])
#
#     seq.list(6)
#
# Expected output:
#
#     [A, B, -2*A + 3*B, -6*A + 7*B, -14*A + 15*B, -30*A + 31*B]
#
# ------------------------------------------------------------
# Example 9: inspecting the generated sequence object
# ------------------------------------------------------------
#
#     var('n, C')
#     a = function('a')
#
#     eq = a(n+1) == a(n)/(n+1)
#     seq = desequence(eq, [a(0) == C])
#
#     seq(5)                 # returns a_5
#     seq.list(8)            # returns [a_0, ..., a_7]
#     seq.series(8)          # returns a_0 + a_1*x + ... + a_7*x^7
#     seq.series(8, y)       # returns a_0 + a_1*y + ... + a_7*y^7
#     seq.values             # dictionary of already computed values
#     seq.equation           # original difference equation
#     seq.initials           # initial conditions in internal dictionary form
#
#     seq.list(8).show()     # same idea as show(seq.list(8))
#     seq.series(8).show()   # same idea as show(seq.series(8))
#     seq.values.show()      # same idea as show(seq.values)
#     seq.equation.show()    # same idea as show(seq.equation)
#     seq.initials.show()    # same idea as show(seq.initials)
#
# ------------------------------------------------------------
# Example 10: constructing a finite power series
# ------------------------------------------------------------
#
# Mathematical recurrence:
#
#     a_{n+1} = a_n/(n+1),     a_0 = a0
#
# SageMath code:
#
#     var('n, a0, x, y')
#     a = sequence('a')
#
#     a = desequence(a(n+1) == a(n)/(n+1), [a(0) == a0])
#
#     a.series(8)       # finite series in x
#     a.series(8, y)    # finite series in y
#
# Expected output for a.series(8):
#
#     1/5040*a0*x^7 + 1/720*a0*x^6 + 1/120*a0*x^5
#     + 1/24*a0*x^4 + 1/6*a0*x^3 + 1/2*a0*x^2 + a0*x + a0

print('The package was successfully loaded!!!')  
