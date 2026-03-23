# +-----------------------------------------------+
# |  LagrangeEquations package v3.0               |
# |  Date: 2026-03-22                             |             
# |  Author: Dominik Borovsky & Jozef Hanc        |
# +-----------------------------------------------+


print("Downloading the package...")

def der(f,g):
    '''
    Derivative of function f with respect to function g
    - f: can be algebraic expression
    - g: can be variable or function
    '''
    gvar = var('gvar')
    result = f.subs(g == gvar).diff(gvar).subs(gvar == g) 
    return result


def LagrangeEqs(T, V, *coords):
    '''
    Lagrange equations for a system with the conservative forces
    - T: kinetic energy 
    - V: potential energy 
    - coords: list of generalized coordinates
    '''
    L = T-V
    eqs = {coor: der(L, coor) == der(L, coor.diff(t) ).diff(t) for coor in coords}
    return eqs


def LE_shorts_f(lf):
    shorts = {}
    temp = {}

    for f in lf:
        fv = str(f.operator()) + '__'
        fn = str(f.operator()) + '__'
        temp[fv] = SR.var(fn, latex_name=latex_f(f))
        
        globals()[fn] = temp[fv]
        
        shorts[f] = temp[fv]

        if not is_not_composite_function(f):
            f_op_ops = {}
            for op in f.operands():
                opv = str(op.operator()) + '__'
                opn = str(op.operator()) + '__'
                temp[opv] = SR.var(opn, latex_name=latex(op.operator()))

                globals()[opn] = temp[opv]
                
                f_op_ops[op] = temp[opv]
            shorts[f.subs(f_op_ops)] = temp[fv]

    return shorts
    
def LE_newton_shorts(lf, ndif):
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
    for f in lf:
        f1 = f.operator()
        globals()[str(f1)+'s'] = var('_' + str(f1) + '_')
        f_latex = latex(only_functions(LE_fv_ops(f))[0]).split(r'\left(')[0]
        dnf = str(f1) + '__' + ndif*'d'
        if ndif<4:
            latex_name = r'\d' + (ndif-1)*'d' + 'ot{' + f_latex + '}'
        else:
            latex_name = r'\stackrel{' + str(ndif) + r'}{\dot{' + f_latex + r'}}'
        globals()[dnf] = var(dnf, latex_name=latex_name)
        shorts[diff(f,t,ndif)] = globals()[dnf]
    return shorts

def LE_shorts(LEqs):
    shorts_dict = {}
    coords = LEqs.keys()
    for coord in coords: 
        lcoord = [coord]
        LE_shorts_f_dict = LE_shorts_f(lcoord)
        shorts_df_dict = LE_newton_shorts(lcoord,1)
        shorts_ddf_dict = LE_newton_shorts(lcoord,2)
        shorts_dict[coord] = {**shorts_ddf_dict, **shorts_df_dict, **LE_shorts_f_dict}
    return shorts_dict


def LE_fv_ops(f, output='list'):
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

def LE_is_parameter(expr):
    if expr.operands()==[] and not expr.is_numeric():
        return True
    else:
        return False

def LE_standardize_raw(LEqs):
    coords = list(LEqs.keys())
    LE_params = set()
    LE_systems = []
    t_var = coords[0].operands()[0]
    for coord in coords:
        lparams = [expr for expr in LE_fv_ops(LEqs[coord]) if LE_is_parameter(expr)]
        LE_params.update(set(lparams))
    LE_params = list(LE_params - {t_var})
    LEqs_shorts = LE_shorts(LEqs)
    shorts_dict = {}
    LE_dvars = {}
    LE_sol_vars = []
    for coord in coords:
        LEqs_coord_shorts = LEqs_shorts[coord]
        shorts_dict.update(LEqs_coord_shorts)
        LEqs_coord_shorts_items = list(LEqs_coord_shorts.items())
        dvars_coord_list = [LEqs_coord_shorts_items[-1][1], LEqs_coord_shorts_items[-2][1]]
        LE_dvars[coord] = dvars_coord_list
        LE_sol_vars.append(LEqs_coord_shorts_items[0][1])
    
    LE_system_aux = [LEqs[coord].subs(shorts_dict) for coord in coords]
    LE_system_aux_sol = solve(LE_system_aux, LE_sol_vars, solution_dict=True)
    for sol in LE_system_aux_sol:
        LE_system = {}
        for coord in coords:
            LE_coord_system = []
            LE_coord_shorts = []
            LEq_new = LEqs[coord].subs(shorts_dict)
            LE_coord_system.append(LEqs_shorts[coord][diff(coord,t,1)])
            coord_dd = sol[LEqs_shorts[coord][diff(coord,t,2)]] # solve(LEq_new, LEqs_shorts[coord][diff(coord,t,2)])[0].rhs()
            LE_coord_system.append(coord_dd)
            LE_system[coord] = LE_coord_system

        LE_systems.append(LE_system)
    return LE_systems, LE_dvars, LE_params, shorts_dict        

def LE_standardize(LEqs):
    coords = list(LEqs.keys())
    LE_standardized = LE_standardize_raw(LEqs)
    LE_systems = []
    LE_dvars = []
    if len(LE_standardized[0])==0:
        print('Unable to standardize.')
    else:
        for sol in LE_standardized[0]:
            LE_system = []
            for coord in coords:
                LE_system += sol[coord]
            LE_systems += LE_system
        for coord in coords:
            LE_dvars += LE_standardized[1][coord]

        return LE_systems, LE_dvars

# ---- Graphs ----




# -- --
def LagrangeEqsQnc(T, V, *coordsQnc):
    '''
    Lagrange equations for a system with the non-conservative forces
    - T: kinetic energy 
    - V: potential energy 
    - coordsQnc: pairs of generalized coordinates and according non-conservative forces
    '''
    L = T-V
    eqs = {coordQnc[0]: der(L, coordQnc[0]) - der(L, coordQnc[0].diff(t) ).diff(t)  == - coordQnc[1]   for coordQnc in coordsQnc}
    return eqs


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



def eqSubs(equation, substitutions):
    '''
    Substitution in a sage equation proccesed by Sympy:
    - equation: a sage equation in which are desired the substitutions
    - substitutions: list of equations [old_expr_1 == new_expr_1, old_expr_2 = new_expr_2, ...]
                     or dictionary {old_expr_1:new_expr_1, old_expr_2: new_expr_2, ...}
    '''
    eq = Subs(equation.lhs(), substitutions)==Subs(equation.rhs(), substitutions)
    return eq


def eqssubs(eqs, substitutions):
    '''
    Substitution in a dictionary of equations using sage build-in function subs:
    - eqs: a dictionary of equations
    - substitutions: list of equations [old_expr_1 == new_expr_1, old_expr_2 = new_expr_2, ...]
                     or dictionary {old_expr_1:new_expr_1, old_expr_2: new_expr_2, ...}
    '''
    subseqs={}
    for key in eqs.keys():
        subseqs[key] = Subs(eqs[key].lhs(),substitutions)== Subs(eqs[key].rhs(),substitutions)
    return subseqs
    

def divEqs(eqs, expr):
    '''
    Module to divide the both sides of equations:
    - eqs: a dictionary of equations
    - expr: an expression used to divide both sides of equations
    '''
    for key in eqs.keys():
        eqs[key] = (eqs[key].lhs()/expr).expand() == (eqs[key].rhs()/expr).expand()
    return eqs


def homogenize(eqs):
    '''
    Transforms equations form the dictionary eqs in form:
    
    f(x,y,...) == g(x,y,...)
    
    into expression:
    
    f(x,y,...) - g(x,y,...)    
    '''
    for key in eqs.keys():
        eqs[key] = eqs[key].lhs() - eqs[key].rhs()
    return eqs


def eqsCollect(eqs, variables):
    '''
    Collects coefficients nearby given variables:
    - eqs: a dictionary of equations
    - variables: a list of given variables
    '''
    for key in eqs.keys():
        for variable in variables:
            eqs[key] = eqs[key].collect(variable)
    return eqs


def Collect(expr, *kwargs):
    '''
    Collects coefficients nearby given variables using Sympy:
    - expr: an expression
    - var: given variable
    '''
    exprm = expr.maxima_methods()
    return exprm.collectterms(*kwargs)._sage_()
    


def coeffs(expr, variable):
    '''
    Extracts coefficients in a given expression expr according a given variable
    '''
    coefflist = expr.coefficients(variable)
    for c in coefflist:
        if c[1]==1:
            return c[0]



def matrixEqs(eqs, variables): 
    '''
    Return matrix of a given system of equations:
    - eqs: a dictionary of equations in the system
    - variables: a list of variables of the given system
    '''
    M = matrix([[coeffs(eqs[key], variable) for variable in variables] for key in eqs.keys()])
    return M

def showURL(url, ht=560):
    '''
    Shortcut of IFrame command to show IFrames of the given url with width 95%.
    '''
    from IPython.display import IFrame
    return IFrame(url, width='95%', height=ht)

def chsites(eq):
    '''
    '''
    return eq.rhs() == eq.lhs()

def showcols(list_of_eqs, shape=[2,2]):
    '''
    Shows given list of equastions or expressions as table.
    - list_of_eqs: list of equastions or expressions 
    - shape=[a,b]: a - number of rows, b - number of columns, default a=2, b=2
    '''
    nullvar = var('nullvar', latex_name=r'\\~')
    latex.matrix_delimiters('.','.')
    n_m = shape[0]*shape[1]
    n_eqs = len(list_of_eqs)
    if n_eqs<=n_m:
        show(matrix(*shape, list_of_eqs + [nullvar for i in range(n_m-n_eqs)]))
    else:
        raise Exception('The number of cells in the table given by the shape must be greater or equal to the number of displayed items.')
    latex.matrix_delimiters('(', ')')

print('The package was successfully loaded!!!')  