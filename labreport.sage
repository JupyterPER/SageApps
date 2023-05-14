# nacitanie kniznic
import numpy as np
import pandas as pd
import metrolopy as uc
# import sigfig as sf
import warnings
warnings.filterwarnings('ignore') # setting ignore as a parameter

from IPython.display import YouTubeVideo
from numpy import array as v
from numpy import float64 as dc
from numpy import sqrt
from scipy.stats import sem
from numpy import mean
from numpy import std as npstd
from IPython.display import IFrame

std = lambda x: npstd(x,ddof=1)

uc.gummy.style = '+-'

def budget(gvel, gnames, form = 'full', notation='decimal', transpose = True):
    indirect = gnames[0]
    direct = gnames[1:]
    table = gvel[0].budget(gvel[1:], xnames = direct)
    if form != 'final':
        db = table.df.astype(float, errors='ignore')
        db.set_index(['Component'], inplace=True)
        db = db.reindex(direct+[indirect])
        db.drop(columns='s', inplace=True)
        db['vars'] = (db['u']*db['|dy/dx|'])**2
        db.loc[indirect,'vars'] = db['vars'].sum() 
        db.loc[indirect,'|dy/dx|'] = 1 
        db['rel. vars %'] = db['vars']/db.loc[indirect,'u']**2*100
        db['rel. u %'] = db['u']/db['Value']*100
        db.set_index(['Unit'], append=True, inplace=True)
        if notation == 'decimal':
            table = db.fillna('').astype(str)
        elif notation == 'sci':  
            table = db.transpose().fillna('')
        else:
            table = db.fillna('')
        if transpose:
            table = table.transpose()
    return table

def ipyurl(url, storage='google', medium = 'image'):
    if medium == 'image':
        if storage=='google':
            url = ''.join(["'",url.replace('file/d/','uc?id=').replace('/view?usp=sharing', ''), "'"])
        else:
            url = ''.join(["'",url.replace('?dl=0','?raw=1'), "'"])
    if medium == 'table':
            url = ''.join(["'",url.replace('edit','preview'), "'"])
    return print('url='+url)

def frame_wrapping(df, fillna=True):
    def format_line_break(value):
        if isinstance(value, str):
            value = value.replace('\n', '<br>')
        return value
    
    if fillna:
        # Replace column names containing 'Unnamed' with empty strings
        df.columns = [col if 'Unnamed' not in col else '' for col in df.columns]
    
        # Replace NaN values with empty strings
        df = df.fillna('')
    
    wrapped_df  = df.style.format(formatter=format_line_break)
    return wrapped_df 

from IPython.display import display, HTML
display(HTML("<style>.container { width:100% !important; }</style>"))

# from googletrans import Translator
# translator = Translator()
# trENGSK = lambda text:translator.translate(text, src='en', dest='sk').text.replace('.','. ')

# from molmass import Formula as vzorec
# from mendeleev import element as prvok
# from scipy.constants import R as Rv, zero_Celsius as Z0, N_A as NA
# from scipy.constants import find, physical_constants as konst

print('The contents of the package have been loaded successfully.')
