# version 3.1

from sympy.printing import latex as Latex

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

#################
def showmath_short(expr, partial=True, compact = False):
    latex_code = Latex(expr)
    if partial:
        latex_code = latex_code.replace('d','\\partial')
    if not compact:
        latex_code = '\\displaystyle '+latex_code.replace('\\frac','\\dfrac')
    return display(html('′+latexcode+′'+latex_code+''))

#################
def Show(expr, partial=True, compact=False, simplify=True, notation='leibniz'):
    if notation=='leibniz':
        return showmath_short(short_not(expr, simplify), partial, compact)
    elif notation=='dot':
        return show(dot_not(expr, simplify))
        
print('The package was successfully loaded!!!')       
