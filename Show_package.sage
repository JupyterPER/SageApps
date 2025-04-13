# version 4.0

from sympy.printing import latex as Latex
from IPython.display import Math 
import re

# definition of Levi-Civita symbol
eps = lambda p: sign(prod(p[j] - p[i] for i in range(len(p)) for j in range(i+1, len(p))))

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
    return hasattr(expr, 'nrows') and hasattr(expr, 'ncols') and callable(expr.nrows) and callable(expr.ncols)

def trig_form(expr, simplify=True):
    M = expr._maxima_().demoivre()._sage_()
    if simplify:
        if is_matrix(M):
            M = M.apply_map(lambda x: x.simplify_trig().reduce_trig())
        else:
            M.simplify_trig().reduce_trig()
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


def is_function(f):
    if "<class 'sage.symbolic.function_factory.function_factory.<locals>.NewSymbolicFunction'>" == str(type(f.operator())):
        return True
    else:
        return False

#################    
def opsdiff(df):
    '''
    Returns operand of given derivation df
    '''
    df_function = df.operator().function()
    df_operands = df.operands()
    return df_function(*df_operands)

#################    
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

    ops = f.operands()
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

#################    
def is_not_composite_function(f):
    '''
    Returns True if f is not a composite function
    '''
    if f.operands()[0].operator()==None:
        return True
    else:
        return False

#################    
def only_functions(lexpr):
    '''
    lexpr - list of expressions
    
    Returns list of expressions, which are symbolic functions, 
    e.g [f(x,y), f(g(x,y),h(x,y)),...]
    ''' 
    return [expr for expr in lexpr if is_function(expr)==True]


#################    
def shorts(lf):
    '''
    lf - list of functions
    
    Returns
    '''
    
    shorts_f = {}
    shorts_v = {}
    
    # shortcuts for variables
    for f in lf:
        f_vars = f.variables()
        for v in f_vars:
            sv = str(v)+'s'
            sn = str(v)+'_'
            locals()[sv] = var(sn, latex_name=latex(v))
            shorts_v[v] = locals()[sv]
    
    # shortcuts for values of functions
    for f in lf:
        # temporary variable for shortcut e.g. fs
        fv = str(f.operator()) + 's'
        fn = str(f.operator()) + '_'
        locals()[fv] = var(fn, latex_name=str(f.operator()))
        # substitution with original viariables e.g. f(x,y,z): fs
        shorts_f[f] = locals()[fv]
        # substitution with original shortcut viariables e.g. f(xs,ys,zs): fs
        shorts_f[f.subs(shorts_v)] = locals()[fv]
        # substitution with operands as viariable, e.g. for f(g(x,y), h(x,y)) we get item f(gs,hs): fs
        if not is_not_composite_function(f):
            f_op = f.operands()
            f_op_ops = {}
            for op in f_op:
                    opv = str(op.operator()) + 's'
                    opn = str(op.operator()) + '_'
                    locals()[opv] = var(opn, latex_name=latex(op.operator()))
                    f_op_ops[op] = locals()[opv]
            shorts_f[f.subs(f_op_ops)] = locals()[fv]
    
    return {**shorts_v, **shorts_f}

##############################
is_symbolic_function = lambda f: True if f.operands()==list(f.free_variables()) and f.operands()!=[] else False

def is_iterable(obj):
    try:
        iter(obj)
        return True
    except TypeError:
        return False

################
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
        str_opr = str(op.operator())
        # shorts with dot notation for derivatives of functions
        if 'D[' in str_opr and op.nops()==1:
            f1 = op.operator().function()
            locals()[str(f1)+'_'] = var(str(f1))
            ndif = len(op.operator().parameter_set())
            f_latex = latex(locals()[str(f1)+'_']).split(r'\left(')[0]
            dnf = ndif*'d' + str(f1)
            latex_name = r'\d' + (ndif-1)*'d' + 'ot{' + f_latex + '}'
            locals()[dnf] = var(dnf, latex_name=latex_name)
            shorts[op] = locals()[dnf]
        # functions as variables
        elif is_function(op):
            f2 = op.operator()
            locals()['v' + str(f2)] = var(str(f2))
            shorts[op] = locals()['v' + str(f2)]
    
    return shorts

def dot_not(expr, simplify=True):
    if simplify:
        expr = expr.expand().reduce_trig().canonicalize_radical().expand().reduce_trig()
    shorts = newton_shorts(expr)
    return Subs(expr, shorts)

#################
def short_not(expr, simplify=True):
    if simplify:
        expr = expr.expand().reduce_trig().canonicalize_radical().expand().reduce_trig()
    lf = only_functions(fv_ops(expr))
    values = shorts(lf)
    return expr._sympy_().subs(values)


def short_not_nested_list(nested_list, simplify=True):
    def recurse(item):
        if is_iterable(item):
            item = list(item)
        if isinstance(item, list):
            return [recurse(sub_item) for sub_item in item]
        else:
            return short_not(item, simplify=simplify)
    
    return recurse(nested_list)

def short_not_list(list_terms, simplify=True):
    return [short_not(term, simplify=simplify) for term in list_terms]

def short_not_matrix(matr, simplify=True):
    from sympy import Matrix as SymMatrix
    rows_matrix = list(matr)
    short_not_matr = [short_not_list(row,simplify=simplify) for row in rows_matrix]
    sym_matrix = SymMatrix(short_not_matr)
    return sym_matrix

def short_not_vector(vec, simplify=True):
    from sympy import Matrix as SymMatrix
    n, m = Matrix(vec).dimensions()
    if n>m:
        sym_vector = short_not_matrix(vec, simplify=simplify)
    else:
        sym_vector = short_not_matrix([vec], simplify=simplify)
    return sym_vector

#################
def replace_total_with_partial_diff(latex_string):
    # Pattern to match total differentials in the form \frac{d}{d g_{}} f_{}
    pattern = r'\\frac{d}{d\s*([a-zA-Z])_{(\{\})?}}'
    
    def replace_func(match):
        variable = match.group(1)
        brackets = match.group(2) or ''  # Use empty string if no brackets
        return r'\frac{\partial}{\partial ' + variable + '_{' + brackets + '}}'
    
    # Replace all occurrences
    return re.sub(pattern, replace_func, latex_string)

def showmath_short(expr, partial=True, compact = False, vector_or_matrix=False):
    latex_code = Latex(expr)
    if partial:
        latex_code = replace_total_with_partial_diff(latex_code)
    if vector_or_matrix:
        latex_code = latex_code.replace('\\left[','\\left(').replace('\\right]','\\right)')
    if not compact:
        latex_code = latex_code.replace('\\frac','\\dfrac')
    # latex_code = '\\displaystyle ' + latex_code 
    return display(html('$'+latex_code+'$'))

#################

def Show(expr, partial=True, compact=False, simplify=True, notation='leibniz'):
    if notation=='leibniz':
        if is_iterable(expr):
            if 'list' in str(type(expr)):
                return showmath_short(short_not_nested_list(expr, simplify), partial, compact)
            if 'matrix' in str(type(expr)):
                return showmath_short(short_not_matrix(expr, simplify), partial, compact, vector_or_matrix=True)
            if 'free_module.FreeModule_ambient_field_with_category' in str(type(expr)):
                return showmath_short(short_not_vector(expr, simplify), partial, compact, vector_or_matrix=True)
        else:
            return showmath_short(short_not(expr, simplify), partial, compact)
    elif notation=='dot':
        return show(dot_not(expr, simplify))
        
print('The package was successfully loaded!!!')  
