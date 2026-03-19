# version 6.0
print("Downloading the package...")
import numpy as np

from sympy.printing import latex as Latex
from IPython.display import Math 
import re

# definition of Levi-Civita symbol
eps = lambda p: sign(prod(p[j] - p[i] for i in range(len(p)) for j in range(i+1, len(p))))

v = lambda plist: vector(plist)

radical = lambda D: D.apply_map(lambda x: x.radical_expression())

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

def QR(B, exact=True, digits=None):
    if exact:
        Q, R = B._sympy_().QRdecomposition()
        Q, R = Q._sage_(), R._sage_()
        return Q, R

    else:
        Q, R = B.change_ring(CDF).QR()

        if digits is not None:
            Q = Q.apply_map(lambda x: x.n(digits=digits))
            R = R.apply_map(lambda x: x.n(digits=digits))

        return Q, R

def SVD(B, exact=True, digits=None, full=True, sort=True):

    m, n = B.dimensions()

    if exact:
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

        if digits is not None:
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

def showURL(url, ht=424):

    '''shortcut for IFrame displaying various media at given url address;
       for interactive SageMath worksheets it is appropriate height 424 and width 100%
    '''
    from IPython.display import IFrame
    return IFrame(url, width='100%', height=ht)


def showGeo(url, ht=424):
    """
    Generates an iframe URL for a GeoGebra applet with specified display settings.

    Parameters:
    url (str): The URL of the GeoGebra applet.
    ht (int): The height of the iframe. The default is 424.

    Note: These parameters are appropriate for SageMath worksheets.

    Returns:
    IFrame: An IFrame object that embeds the GeoGebra applet with 'Reset' and 'Fullscreen' icons.
    """

    from IPython.display import IFrame
    # Extract the id from the given URL
    applet_id = url.split('/')[-1]
    
    # Construct the new URL in the desired iframe format with additional parameters
    transformed_url = (
        f"https://www.geogebra.org/material/iframe/id/{applet_id}/sfsb/true/"
        "smb/false/stb/false/stbh/false/ai/false/asb/false/sri/true/rc/false/"
        "ld/false/sdz/false/ctl/false"
    )
    
    # Return the IFrame object for embedding
    return IFrame(transformed_url, width='100%', height=ht)

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


# +------------------------------+
# |  Show package v5.0           |
# |  Date: 2026-03-19            |
# |  Author: Dominik Borovsky    |
# +------------------------------+

# ----Identifiers-----

def is_function(f):
    if "<class 'sage.symbolic.function_factory.function_factory.<locals>.NewSymbolicFunction'>" == str(type(f.operator())):
        return True
    else:
        return False
		
def is_not_composite_function(f):
    '''
    Returns True if f is not a composite function
    '''
    if f.operands()[0].operator()==None:
        return True
    else:
        return False
		
def is_symbolic_function(f):
    operands = f.operands()
    free_variables = list(f.free_variables())
    
    if operands == free_variables and operands != []:
        return True
    else:
        return False

def is_iterable(obj):
    # Check if it's a standard iterable (but not a string)
    if hasattr(obj, '__iter__') and not isinstance(obj, str):
        return True
    # Check if it supports indexing (like Sage vectors)
    return hasattr(obj, '__getitem__') and hasattr(obj, '__len__')

def is_derivative(expr):
    type_expr = str(type(expr.operator()))
    if type_expr=="<class 'sage.symbolic.operators.FDerivativeOperator'>":
        return True
    else:
        return False

# ----Extractors-----

def opsdiff(df):
    '''
    Returns operand of given derivation df
    '''
    df_function = df.operator().function()
    df_operands = df.operands()
    return df_function(*df_operands)


def fv_ops(f, output='list'):
    '''
    Returns list:
    
    [op_1, op_2,...]
    
    or dictionary:
    
    {op_1: l_1, op_1: l_1,...}
    
    where:
    - op_1, op_2,... are all operands of any given nested function or expression f
    - l_1, l_2,...   number of level, at which the operand occurs in the composition, starting with 1
    
    If f is function itself, it is included in the list or dictionary with assigned level 0.
    '''
    if not hasattr(f, "operands"):
        return [f]
    ops = list(f.operands()) + [f]
    ops_lop = {op:1 for op in ops}
    temp_ops_lop = ops_lop
    l = 2
    while temp_ops_lop != {}:
        new_temp_ops_lop = {}
        for op in temp_ops_lop.keys():
            sub_ops = op.operands()
            if sub_ops != []:
                sub_ops_lop = {op:l for op in sub_ops}
                new_temp_ops_lop.update(sub_ops_lop)
        ops_lop.update(new_temp_ops_lop)
        temp_ops_lop = new_temp_ops_lop
        l = l+1
    
    diff_ops = {}
    for op_lop in ops_lop.keys():
        if type(op_lop.operator()) == sage.symbolic.operators.FDerivativeOperator:
            diff_ops[opsdiff(op_lop)] = ops_lop[op_lop]
    ops_lop = {**ops_lop, **diff_ops}
    
    if is_function(f):
        ops_lop[f] = 0
    elif type(f.operator())==sage.symbolic.operators.FDerivativeOperator:
        ops_lop[f.operator().function()(*f.operands())] = 0
    
    if output=='list':
        return list(ops_lop.keys())
    elif output=='dict':
        return ops_lop


def only_functions(lexpr):
    '''
    lexpr - list of expressions
    
    Returns list of expressions, which are symbolic functions, 
    e.g [f(x,y), f(g(x,y),h(x,y)),...]
    ''' 
    return [expr for expr in lexpr if is_function(expr)]

def only_derivatives(lexpr):
    '''
    lexpr - list of expressions
    
    Returns list of expressions, which are symbolic functions, 
    e.g [f(x,y), f(g(x,y),h(x,y)),...]
    ''' 
    return [expr for expr in lexpr if is_derivative(expr)]

def only_variables_expr(expr):
    functions_variables = fv_ops(expr)
    list_functions = only_functions(functions_variables)
    list_variables = []
    for fun in list_functions:
        list_variables += fun.operands()
    return list(set(list_variables))


def only_variables(obj):
    if is_iterable(obj):
        list_obj = list(obj)
        list_variables = []
        
        def recurse(item):
            if is_iterable(item):
                item = list(item)
                for sub_item in item:
                    recurse(sub_item)
            else:
                # item is an expression, extract its variables
                list_variables.extend(only_variables_expr(item))
        
        recurse(list_obj)
        return list(set(list_variables))
    else:
        return only_variables_expr(obj)



# ----Shorteners-----

def shorts_f(lf):
    shorts = {}
    shorts_v = {}
    temp = {}

    for f in lf:
        for v in f.variables():
            sv = str(v) + 's'
            sn = str(v) + '_'
            temp[sv] = SR.var(sn, latex_name=latex(v))
            shorts_v[v] = temp[sv]

    for f in lf:
        fv = str(f.operator()) + 's'
        fn = str(f.operator()) + '_'
        temp[fv] = SR.var(fn, latex_name=latex_f(f))
        shorts[f] = temp[fv]
        shorts[f.subs(shorts_v)] = temp[fv]

        if not is_not_composite_function(f):
            f_op_ops = {}
            for op in f.operands():
                opv = str(op.operator()) + 's'
                opn = str(op.operator()) + '_'
                temp[opv] = SR.var(opn, latex_name=latex(op.operator()))
                f_op_ops[op] = temp[opv]
            shorts[f.subs(f_op_ops)] = temp[fv]

    return {**shorts_v, **shorts}


def shorts_der(lder):
    '''
    lder - list of derivatives
    
    Returns
    '''
    
    shorts_der = {}
    
    for der in lder:
        # temporary variable for shortcut e.g. fs
        der_idxs = der.operator().parameter_set()
        ivars = der.operands()
        list_ivars = [ivars[k] for k in der_idxs]
        list_ivars_str = [str(ivar).split('(')[0] for ivar in list_ivars]
        dvar = fv_ops(der)[-1]
        str_der = 'd'+ str(dvar).split('(')[0] + 'd' + 'd'.join(list_ivars_str)
        derv = str(str_der) + 's'
        dern = str(str_der) + '_'
        locals()[derv] = var(dern, latex_name=nice_derivative_latex(der))
        shorts_der[der] = locals()[derv]
    
    return shorts_der

def newton_shorts(expr):
    '''
    Returns dictionary:
    
    {df1: dotf1, df2: dotf2,..., f1: vf1, f2: vf2,...}
    
    where:
    f1, f2,... are symbolic functions in the given expressions
    vf1, vf2,... are corresponding symbolic variables 
    df1, df2,...  are all symbolic derivations, which occurs in the given expression expr
    dotf1, dotf2, ... are corresponding symbolic variables with dot notation implemented in LaTeX output
    
    '''
    shorts = {}
    ops = fv_ops(expr)
    
    for op in ops:
        # shorts with dot notation for derivatives of functions
        if is_derivative(op) and op.nops()==1:
            f1 = op.operator().function()
            locals()[str(f1)+'s'] = var('_' + str(f1) + '_')
            ndif = len(op.operator().parameter_set())
            f_latex = latex(only_functions(fv_ops(op))[0]).split(r'\left(')[0]
            dnf = ndif*'d' + str(f1)
            if ndif<4:
                latex_name = r'\d' + (ndif-1)*'d' + 'ot{' + f_latex + '}'
            else:
                latex_name = r'\stackrel{' + str(ndif) + r'}{\dot{' + f_latex + r'}}'
            locals()[dnf] = var(dnf, latex_name=latex_name)
            shorts[op] = locals()[dnf]
    return shorts



# ----Replacers-----

def dot_not(expr, simplify=False):
    if simplify:
        expr = expr.expand().reduce_trig().canonicalize_radical().expand().reduce_trig()
    shorts_newton = newton_shorts(expr)
    functions_operands = fv_ops(expr)
    lf = only_functions(functions_operands)
    lder = only_derivatives(functions_operands)
    subs_functions = shorts_f(lf)
    subs_derivatives = shorts_der(lder)
    return expr.subs(shorts_newton).subs(subs_derivatives).subs(subs_functions)


def short_not(expr, simplify=False):
    if simplify:
        expr = expr.expand().reduce_trig().canonicalize_radical().expand().reduce_trig()
    functions_operands = fv_ops(expr)
    lf = only_functions(functions_operands)
    lder = only_derivatives(functions_operands)
    subs_functions = shorts_f(lf)
    subs_derivatives = shorts_der(lder)
    expr_subs = expr.subs(subs_derivatives).subs(subs_functions)
    return expr_subs


def short_not_nested_list(nested_list, simplify=False):
    def recurse(item):
        if is_iterable(item):
            item = list(item)
        if isinstance(item, list):
            return [recurse(sub_item) for sub_item in item]
        else:
            return short_not(item, simplify=simplify)
    
    return recurse(nested_list)

def short_not_list(list_terms, simplify=False):
    return [short_not(term, simplify=simplify) for term in list_terms]

def short_not_matrix(matr, simplify=False):
    rows_matrix = list(matr)
    short_not_matr = [short_not_list(row,simplify=simplify) for row in rows_matrix]
    short_not_matrix = matrix(short_not_matr)
    return short_not_matrix

def short_not_vector(vec, simplify=False):
    n, m = matrix(vec).dimensions()
    if n>m:
        vector = short_not_matrix(vec, simplify=simplify)
    else:
        vector = short_not_matrix([vec], simplify=simplify)
    return vector


# ----Displayers-----

latex_f = lambda f: latex(f).split(r'\left(')[0]

def nice_derivative_latex(der):
    sder = str(der)
    if 'diff' in sder:
        # Standard notation
        der_idxs = der.operator().parameter_set()
        ivars = der.operands()
        list_ivars = [ivars[k] for k in der_idxs]
        dvar = fv_ops(der)[-1]
        dvar_name = fv_ops(der)[-1].operator()
        dvar_latex_name = latex_f(dvar)
        return nice_partial_latex(dvar_latex_name, list_ivars)
    elif 'D[' in sder:
        # Euler's D-notation
        der_idxs = der.operator().parameter_set()
        ivars = der.operands()
        list_ivars = [ivars[k] for k in der_idxs]
        list_ivars_shorts = shorts_f(list_ivars)
        list_ivars_subs = [latex_f(list_ivars_shorts[k]) for k in list_ivars]
        dvar = fv_ops(der)[-1]
        dvar_name = fv_ops(der)[-1].operator()
        dvar_latex_name = latex_f(dvar)
        return nice_partial_latex(dvar_latex_name, list_ivars_subs)
        
        

def nice_partial_latex(function_name, variables, collect_derivatives=True):
    """
    Create LaTeX for mixed partial derivatives.
    
    Args:
        function_name (str): Name of the function (e.g., 'f', 'g', 'theta')
        variables (list): List of variables in order of differentiation
                         (e.g., ['x', 'y'] for ∂²f/∂y∂x)
        collect_derivatives (bool): If True, collect repeated derivatives 
                                   (e.g., ∂x ∂x → (∂x)²)
    
    Returns:
        str: LaTeX string for the mixed partial derivative
    """
    if not variables:
        return function_name
    
    if len(variables) == 1:
        # Single partial derivative
        return f"\\dfrac{{\\partial {function_name}}}{{\\partial {variables[0]}}}"
    
    # Mixed partial derivative
    order = len(variables)
    
    if collect_derivatives:
        # Count occurrences of each variable
        from collections import Counter
        var_counts = Counter(reversed(variables))
        
        # Create denominator parts with collected powers
        denominator_parts = []
        for var, count in var_counts.items():
            if count == 1:
                denominator_parts.append(f"\\partial {var}")
            else:
                denominator_parts.append(f"\\partial {var}^{{{count}}}")
        
        denominator = " ".join(denominator_parts)
    else:
        # Create the denominator: ∂y ∂x (in reverse order, no collection)
        denominator_parts = [f"\\partial {var}" for var in reversed(variables)]
        denominator = " ".join(denominator_parts)
    
    return f"\\dfrac{{\\partial^{{{order}}} {function_name}}}{{{denominator}}}"

def replace_total_with_partial_diff(latex_string):
    # Pattern to match total differentials in the form \frac{d}{d g_{}} f_{}
    pattern = r'\\frac{d}{d\s*([a-zA-Z])_{(\{\})?}}'
    
    def replace_func(match):
        variable = match.group(1)
        brackets = match.group(2) or ''  # Use empty string if no brackets
        return r'\frac{\partial}{\partial ' + variable + '_{' + brackets + '}}'
    
    # Replace all occurrences
    return re.sub(pattern, replace_func, latex_string)

def replace_partial_with_total_diff(latex_string):
    new_latex_string = latex_string.replace(r'\partial', 'd')
    return new_latex_string


def showmath_short(expr, partial=True, compact = False, vector_or_matrix=False):
    latex_code = str(latex(expr))
    if not partial:
        latex_code = replace_partial_with_total_diff(latex_code)
    if vector_or_matrix:
        latex_code = latex_code.replace('\\left[','\\left(').replace('\\right]','\\right)')
    if not compact:
        latex_code = latex_code.replace(r'\frac', r'\dfrac')
    return '$'+latex_code+'$'

# ----Finalizers----

def short_not_leibniz(expr, partial=True, compact=False, simplify=False):
        if is_iterable(expr):
            if 'list' in str(type(expr)):
                return showmath_short(short_not_nested_list(expr, simplify), partial, compact)
            if 'matrix' in str(type(expr)):
                return showmath_short(short_not_matrix(expr, simplify), partial, compact, vector_or_matrix=True)
            if 'free_module.FreeModule_ambient_field_with_category' in str(type(expr)):
                return showmath_short(short_not_vector(expr, simplify), partial, compact, vector_or_matrix=True)
        else:
            return showmath_short(short_not(expr, simplify), partial, compact,  vector_or_matrix=False)



def dot_not_list(list_terms, simplify=False):
    """
    Apply dot_not() elementwise on a list of expressions.
    """
    return [dot_not(term, simplify=simplify) for term in list_terms]


def dot_not_nested_list(nested_list, simplify=False):
    """
    Recursively apply dot_not() to every element of a nested list.
    """
    def recurse(item):
        if is_iterable(item):
            item = list(item)
        if isinstance(item, list):
            return [recurse(sub_item) for sub_item in item]
        else:
            return dot_not(item, simplify=simplify)
    return recurse(nested_list)


def dot_not_matrix(matr, simplify=False):
    """
    Apply dot_not() to every element of a matrix.
    """
    rows_matrix = list(matr)
    sub_matr = [dot_not_list(row, simplify=simplify) for row in rows_matrix]
    return matrix(sub_matr)


def dot_not_vector(vec, simplify=False):
    """
    Apply dot_not() to a vector (represented as a 1-column or 1-row matrix).
    """
    n, m = matrix(vec).dimensions()
    if n > m:
        # column vector
        vector = dot_not_matrix(vec, simplify=simplify)
    else:
        # row vector
        vector = dot_not_matrix([vec], simplify=simplify)
    return vector


def short_not_newton(expr, partial=True, compact=False, simplify=False):
    """
    Build a LaTeX display string (dot notation) for scalar, list, matrix or vector.
    Mirrors short_not_leibniz() structure.
    """
    if is_iterable(expr):
        # handle nested lists
        if 'list' in str(type(expr)):
            return showmath_short(
                dot_not_nested_list(expr, simplify),
                partial=partial, compact=compact
            )
        # handle matrices
        if 'matrix' in str(type(expr)):
            return showmath_short(
                dot_not_matrix(expr, simplify),
                partial=partial, compact=compact, vector_or_matrix=True
            )
        # handle vectors (Sage FreeModule)
        if 'free_module.FreeModule_ambient_field_with_category' in str(type(expr)):
            return showmath_short(
                dot_not_vector(expr, simplify),
                partial=partial, compact=compact, vector_or_matrix=True
            )
    else:
        # scalar case
        return showmath_short(dot_not(expr, simplify), partial=partial, compact=compact)

# ----Show function----

def Show(expr, partial=True, compact=False, simplify=False, notation='auto', time_var=None):

    """
    Display mathematical expressions/lists/vectors/matrices with derivatives in a user-friendly notation.
    
    This function formats and displays the given expression (`expr`) using the specified
    notation (Leibniz, Newton/dot, or auto). It handles automatic selection of notation
    based on the variables present in the expression.
    
    Parameters
    ----------
    expr : sage expression
        The mathematical expression to display.
    partial : bool, optional
        If True, use partial derivatives in Leibniz notation. Default is True.
    compact : bool, optional
        If True, display the expression in a compact form. Default is False.
    simplify : bool, optional
        If True, simplify the expression before display. Default is False.
    notation : {'auto', 'leibniz', 'dot'}, optional
        The notation to use for display:
        - 'leibniz': Use Leibniz notation (∂/∂t).
        - 'dot': Use Newton's dot notation (˙)
        - 'auto': Automatically choose notation based on variables
            - More than one variable: Uses partial Leibniz notation (`∂/∂t`).
            - Only one variable, not time: Uses non-partial Leibniz notation.
            - Only one variable, and it is time: Uses Newton's dot notation (`˙`).
            - Otherwise, uses partial Leibniz notation.
        Default is 'auto'
    time_var : str or sage symbol, optional
        The symbol to use for time. If None, tries to use 't' or a default time variable.
        Default is None.
    
    Returns
    -------
    IPython.display.HTML
        The formatted expression/object as an HTML object, suitable for display in Jupyter notebooks.
    """
    
    if time_var is None:
        try:
            time_var = t
        except NameError:
            time_var = var('t')
    if notation == 'auto':
        l_vars = only_variables(expr)
        if len(l_vars) > 1:
            return html(short_not_leibniz(expr, partial=True, compact=compact, simplify=simplify))
        elif len(l_vars) == 1 and t not in l_vars:
            return html(short_not_leibniz(expr, partial=False, compact=compact, simplify=simplify))
        elif len(l_vars) == 1 and t in l_vars:
            return html(short_not_newton(expr, compact=compact, simplify=simplify))
        else:
            return html(short_not_leibniz(expr, partial=partial, compact=compact, simplify=simplify))

    elif notation == 'leibniz':
        return html(short_not_leibniz(expr, partial=partial, compact=compact, simplify=simplify))

    elif notation == 'dot':
        return html(short_not_newton(expr, partial=partial, compact=compact, simplify=simplify))

def Show_latex(expr, partial=True, compact=False, simplify=False, notation='auto', time_var=None):
    """
    Returns LaTeX of mathematical expressions/lists/vectors/matrices with derivatives in a user-friendly notation.
    
    This function formats the given expression (`expr`) using the specified
    notation (Leibniz, Newton/dot, or auto). It handles automatic selection of notation
    based on the variables present in the expression.
    
    Parameters
    ----------
    expr : sage expression
        The mathematical expression to display.
    partial : bool, optional
        If True, use partial derivatives in Leibniz notation. Default is True.
    compact : bool, optional
        If True, display the expression in a compact form. Default is False.
    simplify : bool, optional
        If True, simplify the expression before display. Default is False.
    notation : {'auto', 'leibniz', 'dot'}, optional
        The notation to use for display:
        - 'leibniz': Use Leibniz notation (∂/∂t).
        - 'dot': Use Newton's dot notation (˙)
        - 'auto': Automatically choose notation based on variables
            - More than one variable: Uses partial Leibniz notation (`∂/∂t`).
            - Only one variable, not time: Uses non-partial Leibniz notation.
            - Only one variable, and it is time: Uses Newton's dot notation (`˙`).
            - Otherwise, uses partial Leibniz notation.
        Default is 'auto'
    time_var : str or sage symbol, optional
        The symbol to use for time. If None, tries to use 't' or a default time variable.
        Default is None.
    
    Returns
    -------
    The formatted LaTeX of an expression/object.
    """
    if time_var is None:
        try:
            time_var = t
        except NameError:
            time_var = var('t')
    if notation == 'auto':
        l_vars = only_variables(expr)
        if len(l_vars) > 1:
            print(short_not_leibniz(expr, partial=True, compact=compact, simplify=simplify))
        elif len(l_vars) == 1 and t not in l_vars:
            print(short_not_leibniz(expr, partial=False, compact=compact, simplify=simplify))
        elif len(l_vars) == 1 and t in l_vars:
            print(short_not_newton(expr, compact=compact, simplify=simplify))
        else:
            print(short_not_leibniz(expr, partial=partial, compact=compact, simplify=simplify))

    elif notation == 'leibniz':
        print(short_not_leibniz(expr, partial=partial, compact=compact, simplify=simplify))

    elif notation == 'dot':
        print(short_not_newton(expr, partial=partial, compact=compact, simplify=simplify))

        
print('The package was successfully loaded!!!')  
