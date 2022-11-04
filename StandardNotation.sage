def der(f,g):
    """
    derivative of function f with respect function g
     - f can be an algebraic expression
     - g can be a symbolic variable, function or expression
    """
    gvar = var('gvar')
    result = f.subs(g == gvar).diff(gvar).subs(gvar == g) 
    return result


def Collect(expr, *kwargs):
    '''
    Collects terms containing common variables  using Maxima:
    - expr: an expression
    - *kwargs: given variables
    '''
    exprm = expr.maxima_methods()
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
    
#from IPython.display import Math
#import sympy as sym
from sympy.printing import latex as Latex

def showmath(expr, partial=True, compact = False):
    latex_code = Latex(expr)
    if partial:
        latex_code = latex_code.replace('{d','{\\partial')
    if not compact:
        latex_code = '$\\displaystyle '+latex_code.replace('\frac','\dfrac')+'$'
    return html(latex_code)
    
def short_not(expr, values=shorts, simplify=True):
    if simplify:
        expr = expr.subs(shorts).canonicalize_radical().reduce_trig()
    return expr._sympy_().subs({eq.lhs():eq.rhs() for eq in values})

def Show(expr, values=shorts, simplify=True):
    return showmath(short_not(expr, values=values, simplify=simplify))

print('The package was successfully loaded!!!')
