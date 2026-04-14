# +---------------------------------+
# |  Algebra package package v6.0   |
# |  Date: 2026-03-19               |
# |  Author: Jozef Hanc             |
# +---------------------------------+

print("Downloading the package...")
import numpy as np

from sympy.printing import latex as Latex
from IPython.display import Math 
import re

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
from functools import wraps

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

def p2de_type(DD):
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

print('The package was successfully loaded!!!')  
