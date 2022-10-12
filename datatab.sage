from sage.ext.fast_callable import fast_callable
#import_statements(fast_callable)

# vlastný štýl grafov
#import matplotlib.pyplot as plt
#plt.style.use('seaborn-darkgrid')

def py_func(f):
    r'''
    Conversion of a Sage symbolic to a Python function
    '''
    vars = f.variables()
    return fast_callable(f(*vars), vars=vars)

print('The package successfully loaded')
