#!/usr/bin/env python
# coding: utf-8

# **Diplomová práca**, Bc. Martina Loncová, PF UPJŠ v Košiciach  
# 
# # <font color=green>Pravdepodobnostné rozdelenia a vlastnosti výberových štatistík  </font>
# ## Interaktívny matematický hárok - všetky rozdelenia

# **Nastavenia - Pythonovské knižnice** 

# In[1]:


# ignorovanie upozornení
import warnings
warnings.filterwarnings("ignore")

# nacitanie pythonovskych kniznic a prikazov
import numpy as np
from numpy import array as v, float64 as dc
from numpy import sqrt, mean, std as S
# smerodajna vychylka S1
S1 = lambda vzorka: np.std(vzorka, ddof = 1)
from scipy.stats import geom, binom

# vlastny styl grafov
import matplotlib.pyplot as plt
plt.style.use('seaborn-whitegrid')
boxstyle = {'boxstyle':'round', 'fc':'w'}
get_ipython().run_line_magic('matplotlib','inline')

# prikazy pre graficke prvky
from ipywidgets import BoundedIntText, BoundedFloatText, IntSlider, FloatSlider, Checkbox, Dropdown, SelectionSlider 
from ipywidgets import Box, Label, Layout, interactive_output,HBox
from IPython.display import display as Display

# graficke ovladace
hustota = Checkbox(value=False, description='hustota rozdelenia')
adaptive_axes = Checkbox(value=False,  description='adaptívne osi')
data = Dropdown(options=['priemery', 'odchýlky (s)', 'odchýlky (s1)'], value='priemery', description='')

parameter1 = BoundedFloatText(value=0, min=-500, max=500, step=0.1)
parameter2 = BoundedFloatText(value=1, min=1, max=100, step=0.1)
pocet_vyberov = BoundedIntText(value = 500, min=100, max=1000000, step=100)
pocet_stlpcov = IntSlider(value=20, min=5, max=100, step=5, continuous_update=False)

velkosti_vzorky = [1, 2, 5, 7, 10, 20, 50, 100] + [200, 300, .. 1000] + [2000, 3000, .. 10000]
velkost_vzorky = SelectionSlider(options = velkosti_vzorky, value=1, continuous_update=False)
max_vyska = [0.1, 0.2, 0.3, 0.4, 0.5, 1, 1.5, 2, 5, 10, 20, 50, 100]
y_max = SelectionSlider(options = [round(item,1) for item in max_vyska], value=1, continuous_update=False)
vzhlad = Layout(display='flex', flex_flow='row', justify_content='space-between')


# **Nastavenie - grafické ovládacie prvky**

# In[2]:


# ovladace
zoznam = {'Normálne rozdelenie':'Normalne', 
          'Binomické rozdelenie':'Binomicke', 
          'Geometrické rozdelenie':'Geometricke',
          'Exponenciálne rozdelenie':'Exponencialne',
          'Poissonovo rozdelenie':'Poissonovo'}
distribution = Dropdown(options=zoznam.keys(), value='Normálne rozdelenie', description='')

# ovladaci panel
vzhlad = Layout(display='flex', flex_flow='row', justify_content='space-between')
box = [Box([Label(value='Pravdepodobnostné rozdelenie'),  distribution], layout=vzhlad)]
panelR = Box(box, layout=Layout(display='flex', flex_flow='column', 
                                    border='solid 2px', align_items='stretch',  width='60.5%'))


# In[3]:


# Nacitanie simulacie
def zobraz_simulaciu(rozdelenie ='Normálne rozdelenie'):
    typ = zoznam[rozdelenie]
    #get_ipython().run_line_magic('run', typ+'Rozdelenie-Adaptive.ipynb')
    load(typ+'Rozdelenie-Adaptive.sage')

# interaktivna simulacia
simulacia = interactive_output(zobraz_simulaciu, {'rozdelenie':distribution})
Display(panelR, simulacia)

