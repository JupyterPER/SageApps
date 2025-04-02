# nacitanie kniznic
import numpy as np
import pandas as pd

# import metrolopy as uc
# import sigfig as sf
import sys
import os
import tempfile
import zipfile
import urllib.request
import warnings

# Disable DeprecationWarnings
warnings.filterwarnings("ignore", category=DeprecationWarning)
warnings.filterwarnings("ignore", category=FutureWarning)  # Also helpful for some packages
#warnings.filterwarnings('ignore') # setting ignore as a parameter

from IPython.display import YouTubeVideo
from numpy import array as v
sv = lambda zoznam: vector(zoznam)
from numpy import float64 as dc
from numpy import sqrt
from scipy.stats import sem
from numpy import mean
from numpy import std as npstd
from IPython.display import IFrame

std = lambda x: npstd(x,ddof=1)


#************Metrolopy******************
# Create a temporary directory
temp_dir = tempfile.mkdtemp()

# Download the repository as a zip file
zip_url = "https://github.com/nrc-cnrc/MetroloPy/archive/refs/heads/master.zip"
zip_path = os.path.join(temp_dir, "metrolopy.zip")
print(f"Downloading the package...")
urllib.request.urlretrieve(zip_url, zip_path)

# Extract the zip file
with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    zip_ref.extractall(temp_dir)

# The extracted folder will have a name like "MetroloPy-master"
# Find the correct directory name
extracted_dir = None
for item in os.listdir(temp_dir):
    if os.path.isdir(os.path.join(temp_dir, item)) and item.startswith("MetroloPy-"):
        extracted_dir = os.path.join(temp_dir, item)
        break

sys.path.insert(0, extracted_dir)

import metrolopy as uc

uc.gummy.style = '+-'

def budget(gvel, gnames, form = 'full', notation='decimal', transpose = True):
    indirect = gnames[0]
    direct = gnames[1:]
    table = gvel[0].budget(gvel[1:], xnames = direct)
    if form != 'full':
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
        else:
            table = db.fillna('')
        if transpose:
            table = table.transpose()
    return table

def ipyurl(url, storage='google', medium = 'image'):
    if medium == 'image':
        if storage=='google':
            url = url.replace('file/d/','uc?id=').replace('/view?usp=sharing', '')
        else:
            url = url.replace('?dl=0','?raw=1')
    if medium == 'table':
            url = url.replace('edit','preview')
    return url

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

def showURL(url, ht=424):

    '''shortcut for IFrame displaying various media at given url address;
       for interactive SageMath worksheets it is appropriate height 424 and width 100%
    '''
    from IPython.display import IFrame
    return IFrame(url, width='100%', height=ht)

def read_google_table(url):
    """
    Read data from a Google Sheets URL and return it as a pandas DataFrame.

    Parameters:
    - url (str): The URL of the Google Sheets document.
                 The URL should be in one of the following formats:
                 - 'https://docs.google.com/spreadsheets/d/{id}/edit#gid={gid}' (copied from address bar, document must be in a publicly accessible folder)
                 - 'https://docs.google.com/spreadsheets/d/{id}/preview#gid={gid}'
                 - 'https://docs.google.com/spreadsheets/d/{id}/edit?usp=sharing' (obtained through the Share option)

    Returns:
    - pandas.DataFrame: A DataFrame containing the data from the Google Sheets document.
                        If the URL is not valid, returns an error message string.

    Example usage:
    >>> url = 'https://docs.google.com/spreadsheets/d/1WF2bZoDZhYQWek2tSNjB-Lg6EeD78sUfTENOdCGJyIA/edit#gid=1118323065'
    >>> df = read_google_table(url)
    >>> print(df.head())

    Note:
    - The Google Sheets document must be publicly accessible.
    - The function assumes that the data in the Google Sheets document is in a format compatible with CSV export.
    """
    if 'edit#' in url:
        URL = url.replace('edit#', 'export?format=csv&')
    elif 'preview#' in url:
        URL = url.replace('preview#', 'export?format=csv&')
    elif 'edit?usp=sharing' in url:
        URL = url.replace('edit?usp=sharing', 'export?format=csv')
    else:
        return "Not valid URL, see 'help(read_google_table)'."
    gdf = pd.read_csv(URL)
    gdf = gdf.replace('\n',' ', regex=True)
    gdf.columns = [col.replace('\n', ' ') for col in gdf.columns]
    return gdf
