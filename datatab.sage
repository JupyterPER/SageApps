from numpy import array as c
import plotly.graph_objects as go
import pandas as pd
import numpy as np
from IPython.display import YouTubeVideo
from IPython.display import IFrame
from sage.rings.real_mpfr import RR
#import_statements(RR)
from sage.ext.fast_callable import fast_callable
#import_statements(fast_callable)

# vlastný štýl grafov
#import matplotlib.pyplot as plt
#plt.style.use('seaborn-darkgrid')

def py_func(f):
    r'''
    Kovertuj Sage symbolicku funkciu na Pythonovsku
    '''
    vars = f.variables()
    return fast_callable(f(*vars), vars=vars)

def show_colwidth(df, col_width = 150):
    with pd.option_context('display.max_colwidth', col_width):
        display(df)

def show_allrowscols(df, fullcolwidth=False, col_width=150):
    with pd.option_context('display.max_rows', None, 'display.max_columns', None): 
        if fullcolwidth:
            show_colwidth(df, col_width)
        else:
            display(df)    


def data(xh, yh, f, digits=3, table_labels=['x','y'], typ='skalar'):
    r''' 
    Vyrob data pre tabulkovy - numericky popis funkcie f(x,y) dvoch premennych 
    zo zoznamov hodnot velicin xh, yh.
    
    * xh su hodnoty v prvom stlpci
    * yh su hodnoty v prvom riadku
    
    Volitelne parametre:
    
    * digits - pocet platnych cislic vo vystupe
    * table_labels - mena premennych, ktore sa maju zobrazit v prikaze table (mozu byt aj Latexovske)
    * typ funkcie viacerych premennych - skalarne alebo vektorove pole
    
    '''
    # parameters
    data = [[table_labels[1]+' \\ '+table_labels[0]]+list(map(lambda y: y.n(digits=digits),yh))]
    
    # data
    for x in xh:
        riadok = [x.n(digits=digits)]
        for y in yh:
            if typ == 'skalar': 
                riadok += [RR(f(x,y)).n(digits=digits)]
            else:
                riadok += [f(x,y).n(digits=digits)]
        data += [riadok]
            
    #ouput
    return data

print('The package successfully loaded')
