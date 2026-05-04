# version 7.1

# +------------------------------+
# |  Show package v7.1           |
# |  Date: 2026-03-23            |
# |  Author: Dominik Borovsky    |
# +------------------------------+

print("Downloading the package Show...")

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
    try:
        ops = f.operands()
        if len(ops) == 0:  # No operands means it's a simple variable/constant
            return True
        if ops[0].operator() == None:
            return True
        else:
            return False
    except (AttributeError, IndexError):
        return True  # If we can't check, assume it's not composite
		
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
        # Skip if f is just a variable (no variables() method or returns empty)
        try:
            f_vars = f.variables()
        except AttributeError:
            # f is probably just a variable itself
            continue
            
        for v in f_vars:
            sv = str(v) + 's'
            sn = str(v) + '_'
            temp[sv] = SR.var(sn, latex_name=latex(v))
            shorts_v[v] = temp[sv]

    for f in lf:
        # Check if f is a function (has an operator)
        try:
            f_op = f.operator()
            if f_op is None:
                # f is just a variable, add it to shorts_v if not already there
                if f not in shorts_v:
                    sv = str(f) + 's'
                    sn = str(f) + '_'
                    temp[sv] = SR.var(sn, latex_name=latex(f))
                    shorts_v[f] = temp[sv]
                continue
        except AttributeError:
            continue
            
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


def shorts_der(lder, notation="auto_leibniz", partial=None, collect_derivatives=True, dfrac=True):
    '''
    lder - list of derivatives
    notation - "auto_leibniz", "auto_euler", "leibniz_partial", "leibniz_total", "subscript", "euler_partial", "euler_D"
    partial - True (use ∂), False (use d), None (auto-detect based on type)
    collect_derivatives - True (collect repeated derivatives), False (don't collect)
    dfrac - True (use dfrac), False (use frac)
    
    Returns dictionary mapping derivatives to their symbolic shortcuts
    '''
    
    shorts_der = {}
    
    for der in lder:
        # Get derivative information
        der_idxs = der.operator().parameter_set()
        ivars = der.operands()
        list_ivars = [ivars[k] for k in der_idxs]
        list_ivars_str = [str(ivar).split('(')[0] for ivar in list_ivars]
        dvar = fv_ops(der)[-1]
        
        # Create temporary variable name
        str_der = 'd'+ str(dvar).split('(')[0] + 'd' + 'd'.join(list_ivars_str)
        derv = str(str_der) + 's'
        dern = str(str_der) + '_'
        
        # Get all LaTeX representations
        latex_dict = nice_derivative_latex(der, collect_derivatives=collect_derivatives)
        der_type = latex_dict["type"]
        
        # Determine which LaTeX notation to use
        if notation == "auto_leibniz":
            if partial is None:
                # Auto-detect: diff → leibniz_total, D → leibniz_partial
                if der_type == "diff":
                    latex_name = latex_dict["latex"]["leibniz_total"][0 if dfrac else 1]
                else:  # der_type == "D"
                    latex_name = latex_dict["latex"]["leibniz_partial"][0 if dfrac else 1]
            elif partial:
                latex_name = latex_dict["latex"]["leibniz_partial"][0 if dfrac else 1]
            else:
                latex_name = latex_dict["latex"]["leibniz_total"][0 if dfrac else 1]
                    
        elif notation == "auto_euler":
            # Auto-detect: diff → euler D, D → euler partial
            if der_type == "diff":
                latex_name = latex_dict["latex"]["euler"][1]  # D form
            else:  # der_type == "D"
                latex_name = latex_dict["latex"]["euler"][0]  # partial form

            
        elif notation == "subscript":
            latex_name = latex_dict["latex"]["subscript"]
            
        elif notation == "euler_partial":
            latex_name = latex_dict["latex"]["euler"][0]  # partial form
            
        elif notation == "euler_D":
            latex_name = latex_dict["latex"]["euler"][1]  # D form
            
        elif notation == "leibniz":
            # Manual choice based on partial parameter
            if partial is None:
                # Auto-detect based on type
                if der_type == "diff":
                    latex_name = latex_dict["latex"]["leibniz_total"][0 if dfrac else 1]
                else:
                    latex_name = latex_dict["latex"]["leibniz_partial"][0 if dfrac else 1]
            elif partial:
                latex_name = latex_dict["latex"]["leibniz_partial"][0 if dfrac else 1]
            else:
                latex_name = latex_dict["latex"]["leibniz_total"][0 if dfrac else 1]
                
        elif notation == "euler":
            # Manual choice based on partial parameter
            if partial is None:
                # Auto-detect based on type
                if der_type == "diff":
                    latex_name = latex_dict["latex"]["euler"][1]  # D form
                else:
                    latex_name = latex_dict["latex"]["euler"][0]  # partial form
            elif partial:
                latex_name = latex_dict["latex"]["euler"][0]  # partial form
            else:
                latex_name = latex_dict["latex"]["euler"][1]  # D form
        else:
            # Default fallback
            latex_name = latex_dict["latex"]["leibniz_partial"][0 if dfrac else 1]
        
        # Create the symbolic variable with the chosen LaTeX name
        locals()[derv] = var(dern, latex_name=latex_name)
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


def short_not(expr, simplify=False, notation="auto_leibniz", partial=None, collect_derivatives=True, dfrac=True):
    '''
    expr - expression to apply short notation
    simplify - whether to simplify the expression first
    notation - notation style for derivatives ("auto_leibniz", "auto_euler", "leibniz_partial", "leibniz_total", "subscript", "euler_partial", "euler_D", "leibniz", "euler")
    partial - True (use ∂), False (use d), None (auto-detect based on type)
    collect_derivatives - True (collect repeated derivatives), False (don't collect)
    dfrac - True (use \\dfrac), False (use \\frac)
    '''
    if simplify:
        expr = expr.expand().reduce_trig().canonicalize_radical().expand().reduce_trig()
    functions_operands = fv_ops(expr)
    lf = only_functions(functions_operands)
    lder = only_derivatives(functions_operands)
    subs_functions = shorts_f(lf)
    subs_derivatives = shorts_der(lder, notation=notation, partial=partial, 
                                   collect_derivatives=collect_derivatives, dfrac=dfrac)
    expr_subs = expr.subs(subs_derivatives).subs(subs_functions)
    return expr_subs


def short_not_nested_list(nested_list, simplify=False, notation="auto_leibniz", partial=None, collect_derivatives=True, dfrac=True):
    def recurse(item):
        if is_iterable(item):
            item = list(item)
        if isinstance(item, list):
            return [recurse(sub_item) for sub_item in item]
        else:
            return short_not(item, simplify=simplify, notation=notation, 
                           partial=partial, collect_derivatives=collect_derivatives, dfrac=dfrac)
    
    return recurse(nested_list)

def short_not_list(list_terms, simplify=False, notation="auto_leibniz", partial=None, collect_derivatives=True, dfrac=True):
    return [short_not(term, simplify=simplify, notation=notation, 
                     partial=partial, collect_derivatives=collect_derivatives, dfrac=dfrac) 
            for term in list_terms]

def short_not_matrix(matr, simplify=False, notation="auto_leibniz", partial=None, collect_derivatives=True, dfrac=True):
    rows_matrix = list(matr)
    short_not_matr = [short_not_list(row, simplify=simplify, notation=notation, 
                                     partial=partial, collect_derivatives=collect_derivatives, dfrac=dfrac) 
                      for row in rows_matrix]
    short_not_matrix = matrix(short_not_matr)
    return short_not_matrix

def short_not_vector(vec, simplify=False, notation="auto_leibniz", partial=None, collect_derivatives=True, dfrac=True):
    n, m = matrix(vec).dimensions()
    if n>m:
        vector = short_not_matrix(vec, simplify=simplify, notation=notation, 
                                 partial=partial, collect_derivatives=collect_derivatives, dfrac=dfrac)
    else:
        vector = short_not_matrix([vec], simplify=simplify, notation=notation, 
                                 partial=partial, collect_derivatives=collect_derivatives, dfrac=dfrac)
    return vector


# ----Displayers-----

latex_f = lambda f: latex(f).split(r'\left(')[0]

def nice_derivative_latex(der, collect_derivatives=True):
    sder = str(der)
    nops = len(der.arguments())
    
    if 'diff' in sder and nops==1:
        derivative_type = 'diff'
        # Standard notation
        der_idxs = der.operator().parameter_set()
        ivars = der.operands()
        list_ivars = [ivars[k] for k in der_idxs]
        dvar = fv_ops(der)[-1]
        dvar_name = fv_ops(der)[-1].operator()
        dvar_latex_name = latex_f(dvar)
        list_ivars_latex = [latex_f(var) for var in list_ivars]
        
    elif 'D[' in sder or nops>1:
        derivative_type = 'D'
        # Euler's D-notation
        der_idxs = der.operator().parameter_set()
        ivars = der.operands()
        list_ivars = [ivars[k] for k in der_idxs]
        list_ivars_shorts = shorts_f(list_ivars)
        list_ivars_subs = [latex_f(list_ivars_shorts[k]) for k in list_ivars]
        dvar = fv_ops(der)[-1]
        dvar_name = fv_ops(der)[-1].operator()
        dvar_latex_name = latex_f(dvar)
        list_ivars_latex = list_ivars_subs
    
    else:
        # If neither diff nor D[ is found, return empty or error
        return {"type": None, "latex": {}}
    
    # Generate all LaTeX notations
    return {
        "type": derivative_type,
        "latex": {
            "leibniz_partial": [
                nice_derivative_fvs_latex(dvar_latex_name, list_ivars_latex, 
                                 collect_derivatives=collect_derivatives, partial=True, dfrac=True),
                nice_derivative_fvs_latex(dvar_latex_name, list_ivars_latex, 
                                 collect_derivatives=collect_derivatives, partial=True, dfrac=False)
            ],
            "leibniz_total": [
                nice_derivative_fvs_latex(dvar_latex_name, list_ivars_latex, 
                                 collect_derivatives=collect_derivatives, partial=False, dfrac=True),
                nice_derivative_fvs_latex(dvar_latex_name, list_ivars_latex, 
                                 collect_derivatives=collect_derivatives, partial=False, dfrac=False)
            ],
            "subscript": nice_derivative_fvs_latex(dvar_latex_name, list_ivars_latex, 
                                          collect_derivatives=collect_derivatives, subscript=True),
            "euler": [
                nice_derivative_fvs_latex(dvar_latex_name, list_ivars_latex, 
                                 collect_derivatives=collect_derivatives, euler=True, euler_symbol="\\partial"),
                nice_derivative_fvs_latex(dvar_latex_name, list_ivars_latex, 
                                 collect_derivatives=collect_derivatives, euler=True, euler_symbol="D")
            ]
        }
    }
                

def nice_derivative_fvs_latex(function_name, variables, collect_derivatives=True, partial=True, dfrac=True, euler=False, subscript=False, euler_symbol=None):
    """
    Create LaTeX for mixed partial derivatives.
    
    Args:
        function_name (str): Name of the function (e.g., 'f', 'g', 'theta')
        variables (list): List of variables in order of differentiation
                         (e.g., ['x', 'y'] for ∂²f/∂y∂x)
        collect_derivatives (bool): If True, collect repeated derivatives 
                                   (e.g., ∂x ∂x → (∂x)²)
        partial (bool): If True, use partial derivative notation (∂). 
                       If False, use ordinary derivative notation (d)
        dfrac (bool): If True, use dfrac for display-style fractions.
                     If False, use frac for inline-style fractions
        euler (bool): If True, use Euler operator notation (e.g., D_xy f, ∂_xy f).
                     When True, overrides dfrac parameter.
        subscript (bool): If True, use subscript notation (e.g., f_x, f_{xy}).
                         When True, overrides partial, dfrac, and euler parameters.
        euler_symbol (str): Symbol to use for Euler notation. Can be 'D', '\\partial', 
                           or any custom symbol. If None, uses 'D' when partial=False 
                           and '\\partial' when partial=True.
    
    Returns:
        str: LaTeX string for the mixed partial derivative
    """
    if not variables:
        return function_name
    
    # Subscript notation
    if subscript:
        if collect_derivatives:
            # Collect repeated variables: ['x', 'x', 'y'] → f_{x²y}
            from collections import Counter
            var_counts = Counter(reversed(variables))
            
            subscript_parts = []
            for var, count in var_counts.items():
                if count == 1:
                    subscript_parts.append(var)
                else:
                    subscript_parts.append(f"{var}^{{{count}}}")
            
            subscript_str = "".join(subscript_parts)
        else:
            # No collection: ['x', 'y'] → f_xy (reversed order)
            subscript_str = "".join(reversed(variables))
        
        return f"{function_name}_{{{subscript_str}}}"
    
    # Euler operator notation
    if euler:
        # Choose operator symbol
        if euler_symbol is not None:
            op_symbol = euler_symbol
        else:
            op_symbol = "\\partial" if partial else "D"
        
        # Single operator with collected subscripts
        if collect_derivatives:
            # Collect repeated variables: D_{x²y} f or ∂_{x²y} f
            from collections import Counter
            var_counts = Counter(reversed(variables))
            
            subscript_parts = []
            for var, count in var_counts.items():
                if count == 1:
                    subscript_parts.append(var)
                else:
                    subscript_parts.append(f"{var}^{{{count}}}")
            
            subscript_str = "".join(subscript_parts)
        else:
            # No collection: D_{xy} f (reversed order)
            subscript_str = "".join(reversed(variables))
        
        return f"{op_symbol}_{{{subscript_str}}}\\left({function_name}\\right)"
    
    # Standard Leibniz notation (fraction form)
    # Choose derivative symbol
    d_symbol = "\\partial" if partial else "d"
    
    # Choose fraction command
    frac_cmd = "\\dfrac" if dfrac else "\\frac"
    
    # Calculate order
    order = len(variables)
    
    if collect_derivatives:
        # Count occurrences of each variable
        from collections import Counter
        var_counts = Counter(reversed(variables))
        
        # Create denominator parts with collected powers
        denominator_parts = []
        for var, count in var_counts.items():
            if count == 1:
                denominator_parts.append(f"{d_symbol} {var}")
            else:
                denominator_parts.append(f"{d_symbol} {var}^{{{count}}}")
        
        denominator = " ".join(denominator_parts)
    else:
        # Create the denominator in reverse order, no collection
        denominator_parts = [f"{d_symbol} {var}" for var in reversed(variables)]
        denominator = " ".join(denominator_parts)
    
    # Only add exponent if order > 1
    if order == 1:
        numerator = f"{d_symbol} {function_name}"
    else:
        numerator = f"{d_symbol}^{{{order}}} {function_name}"
    
    return f"{frac_cmd}{{{numerator}}}{{{denominator}}}"


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


def showmath_short(expr, partial=None, compact=False, vector_or_matrix=False):
    '''
    expr - expression to display in LaTeX
    partial - (obsolete, kept for backward compatibility)
    compact - (obsolete, kept for backward compatibility) 
    vector_or_matrix - True to use parentheses instead of brackets for vectors/matrices
    '''
    latex_code = str(latex(expr))
    
    # Only keep the vector/matrix bracket replacement
    if vector_or_matrix:
        latex_code = latex_code.replace('\\left[','\\left(').replace('\\right]','\\right)')

    # May cause problems with exponents like ^(2/3)
    if not compact:
        latex_code = latex_code.replace(r'\frac', r'\dfrac')
    
    return '$' + latex_code + '$'

# ----Finalizers----

def short_not_general(expr, notation="auto", partial=None, collect_derivatives=True, compact=False, simplify=False):
    '''
    expr - expression, list, matrix, or vector to apply short notation
    notation - notation style for derivatives ("auto", "auto_leibniz", "auto_euler", etc.)
    partial - True (use ∂), False (use d), None (auto-detect based on type)
    collect_derivatives - True (collect repeated derivatives), False (don't collect)
    compact - True (use \\frac instead of \\dfrac), False (use \\dfrac)
    simplify - whether to simplify the expression first
    '''
    # Handle notation shortcuts
    if notation == "auto":
        notation = "auto_leibniz"
    
    # Convert compact to dfrac parameter (compact=True means dfrac=False)
    dfrac = not compact
    
    if is_iterable(expr):
        if 'list' in str(type(expr)):
            return showmath_short(short_not_nested_list(expr, simplify=simplify, notation=notation, partial=partial, collect_derivatives=collect_derivatives, dfrac=dfrac), partial, compact)
        if 'matrix' in str(type(expr)):
            return showmath_short(short_not_matrix(expr, simplify=simplify, notation=notation, 
                                                   partial=partial, collect_derivatives=collect_derivatives, 
                                                   dfrac=dfrac), 
                                 partial, compact, vector_or_matrix=True)
        if 'free_module.FreeModule_ambient_field_with_category' in str(type(expr)):
            return showmath_short(short_not_vector(expr, simplify=simplify, notation=notation, 
                                                   partial=partial, collect_derivatives=collect_derivatives, 
                                                   dfrac=dfrac), 
                                 partial, compact, vector_or_matrix=True)
    else:
        return showmath_short(short_not(expr, simplify=simplify, notation=notation, 
                                        partial=partial, collect_derivatives=collect_derivatives, 
                                        dfrac=dfrac), 
                             partial, compact, vector_or_matrix=False)



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
    Mirrors short_not_general() structure.
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


def Show(expr, notation='auto', partial=None, collect_derivatives=True, compact=False, simplify=False, time_var=None, zoom=1.0):
    """
    Display mathematical expressions/lists/vectors/matrices with derivatives in a user-friendly notation.
    
    This function formats and displays the given expression (`expr`) using the specified
    notation (Leibniz, Euler, Newton/dot, or auto). It handles automatic selection of notation
    based on the variables present in the expression.
    
    Parameters
    ----------
    expr : sage expression
        The mathematical expression to display.
    notation : str, optional
        The notation style for derivatives:
        - 'auto' or 'auto_leibniz': Automatically choose Leibniz notation based on variables
        - 'auto_euler': Automatically choose Euler notation based on variables
        - 'leibniz_partial': Leibniz with ∂
        - 'leibniz_total': Leibniz with d
        - 'leibniz': Use partial parameter to decide
        - 'euler_partial': Euler with ∂
        - 'euler_D': Euler with D
        - 'euler': Use partial parameter to decide
        - 'subscript': Subscript notation (f_x, f_{xy})
        - 'dot': Newton's dot notation (˙)
        For 'auto': Automatically choose notation based on variables
            - More than one variable: Uses partial Leibniz notation (`∂/∂t`).
            - Only one variable, not time: Uses non-partial Leibniz notation.
            - Only one variable, and it is time: Uses Newton's dot notation (`˙`).
            - Otherwise, uses partial Leibniz notation.
        Default is 'auto'.
    partial : bool or None, optional
        If True, use ∂. If False, use d. If None, auto-detect based on derivative type.
        Default is None.
    collect_derivatives : bool, optional
        If True, collect repeated derivatives (e.g., ∂x∂x → ∂²/∂x²). Default is True.
    compact : bool, optional
        If True, use \frac instead of dfrac for more compact display. Default is False.
    simplify : bool, optional
        If True, simplify the expression before display. Default is False.
    time_var : str or sage symbol, optional
        The symbol to use for time. If None, tries to use 't' or a default time variable.
        Default is None.
    zoom : float, optional
        Zoom ratio for the displayed expression. Default is 1.0 (100%).
        Use 1.5 for 150%, 0.8 for 80%, etc.

    
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
    
    # Get the latex string
    if notation == 'auto':
        l_vars = only_variables(expr)
        if len(l_vars) > 1:
            latex_str = short_not_general(expr, notation='auto_leibniz', partial=partial, 
                                          collect_derivatives=collect_derivatives, 
                                          compact=compact, simplify=simplify)
        elif len(l_vars) == 1 and time_var not in l_vars:
            latex_str = short_not_general(expr, notation='auto_leibniz', partial=partial, collect_derivatives=collect_derivatives, compact=compact, simplify=simplify)
        elif len(l_vars) == 1 and time_var in l_vars:
            latex_str = short_not_newton(expr, compact=compact, simplify=simplify)
        else:
            latex_str = short_not_general(expr, notation='auto_leibniz', partial=partial, 
                                          collect_derivatives=collect_derivatives, 
                                          compact=compact, simplify=simplify)
    elif notation == 'leibniz':
        latex_str = short_not_general(expr, notation='leibniz', partial=partial, 
                                      collect_derivatives=collect_derivatives, 
                                      compact=compact, simplify=simplify)
    elif notation == 'dot':
        latex_str = short_not_newton(expr, compact=compact, simplify=simplify)
    else:
        latex_str = short_not_general(expr, notation=notation, partial=partial, 
                                      collect_derivatives=collect_derivatives, 
                                      compact=compact, simplify=simplify)
    
    # Apply zoom if not 1.0
    if zoom != 1.0:
        html_str = f'<span style="font-size: {zoom * 100}%;">{latex_str}</span>'
    else:
        html_str = latex_str
    
    display(html(html_str))


def Show_latex(expr, notation='auto', partial=None, collect_derivatives=True, compact=False, simplify=False, time_var=None, zoom=1.0):
    """
    Returns LaTeX of mathematical expressions/lists/vectors/matrices with derivatives in a user-friendly notation.
    
    This function formats the given expression (`expr`) using the specified
    notation (Leibniz, Euler, Newton/dot, or auto). It handles automatic selection of notation
    based on the variables present in the expression.
    
    Parameters
    ----------
    expr : sage expression
        The mathematical expression to display.
    notation : str, optional
        The notation style for derivatives:
        - 'auto' or 'auto_leibniz': Automatically choose Leibniz notation based on variables
        - 'auto_euler': Automatically choose Euler notation based on variables
        - 'leibniz_partial': Leibniz with ∂
        - 'leibniz_total': Leibniz with d
        - 'leibniz': Use partial parameter to decide
        - 'euler_partial': Euler with ∂
        - 'euler_D': Euler with D
        - 'euler': Use partial parameter to decide
        - 'subscript': Subscript notation (f_x, f_{xy})
        - 'dot': Newton's dot notation (˙)
        For 'auto': Automatically choose notation based on variables
            - More than one variable: Uses partial Leibniz notation (`∂/∂t`).
            - Only one variable, not time: Uses non-partial Leibniz notation.
            - Only one variable, and it is time: Uses Newton's dot notation (`˙`).
            - Otherwise, uses partial Leibniz notation.
        Default is 'auto'.
    partial : bool or None, optional
        If True, use ∂. If False, use d. If None, auto-detect based on derivative type.
        Default is None.
    collect_derivatives : bool, optional
        If True, collect repeated derivatives (e.g., ∂x∂x → ∂²/∂x²). Default is True.
    compact : bool, optional
        If True, use \frac instead of dfrac for more compact display. Default is False.
    simplify : bool, optional
        If True, simplify the expression before display. Default is False.
    time_var : str or sage symbol, optional
        The symbol to use for time. If None, tries to use 't' or a default time variable.
        Default is None.
    zoom : float, optional
        Zoom ratio for the displayed expression. Default is 1.0 (100%).
        Use 1.5 for 150%, 0.8 for 80%, etc.
    
    Returns
    -------
    str
        The formatted LaTeX of an expression/object.
    """
    # ... same logic as Show but return the string instead of displaying
    
    if time_var is None:
        try:
            time_var = t
        except NameError:
            time_var = var('t')
    
    if notation == 'auto':
        l_vars = only_variables(expr)
        if len(l_vars) > 1:
            latex_str = short_not_general(expr, notation='auto_leibniz', partial=partial, collect_derivatives=collect_derivatives, compact=compact, simplify=simplify)
        elif len(l_vars) == 1 and time_var not in l_vars:
            latex_str = short_not_general(expr, notation='auto_leibniz', partial=partial, collect_derivatives=collect_derivatives, compact=compact, simplify=simplify)
        elif len(l_vars) == 1 and time_var in l_vars:
            latex_str = short_not_newton(expr, compact=compact, simplify=simplify)
        else:
            latex_str = short_not_general(expr, notation='auto_leibniz', partial=partial, 
                                          collect_derivatives=collect_derivatives, 
                                          compact=compact, simplify=simplify)
    elif notation == 'leibniz':
        latex_str = short_not_general(expr, notation='auto_leibniz', partial=partial, 
                                      collect_derivatives=collect_derivatives, 
                                      compact=compact, simplify=simplify)
    elif notation == 'dot':
        latex_str = short_not_newton(expr, compact=compact, simplify=simplify)
    else:
        latex_str = short_not_general(expr, notation=notation, partial=partial, 
                                      collect_derivatives=collect_derivatives, 
                                      compact=compact, simplify=simplify)
    
    # Apply zoom if not 1.0
    if zoom != 1.0:
        return f'<span style="font-size: {zoom * 100}%;">{latex_str}</span>'
    else:
        return latex_str


# ----------

print('The package was successfully loaded!!!')  
