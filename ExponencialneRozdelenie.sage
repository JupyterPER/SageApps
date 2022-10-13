#!/usr/bin/env python
# coding: utf-8

# **Diplomová práca**, Bc. Martina Loncová, PF UPJŠ v Košiciach  
# 
# # <font color=green>Pravdepodobnostné rozdelenie výberovej štatistiky  </font>
# ## Interaktívny hárok

# **Nastavenia** 

# In[14]:


# nacitanie kniznic a prikazov
import numpy as np
from numpy import array as v, float64 as dc
from numpy import sqrt, mean, std as S

# vlastný štýl grafov
import matplotlib.pyplot as plt
plt.style.use('seaborn-whitegrid')
boxstyle = {'boxstyle':'round', 'fc':'w'}

# náhodný výber bude stále rovnaký
S1 = lambda vzorka: np.std(vzorka, ddof = 1)


# In[15]:


# grafické prvky
from ipywidgets import BoundedIntText, BoundedFloatText, IntSlider, Checkbox, Dropdown 
from ipywidgets import Box, Label, Layout, interactive_output
from IPython.display import display as Display

# ovladace
#seed = Checkbox(value=False, description='seed')
hustota = Checkbox(value=False, description='zobraz hustotu')
velkost_vzorky = BoundedIntText(value=1000, min=100, max=1000000, step=100)
populacna_stredna_hodnota = BoundedFloatText(value=1, min=-500, max=500, step=0.1)
pocet_stlpcov = IntSlider(value=40, min=0, max=100, step=5, continuous_update=False)

# panel
vzhlad = Layout(display='flex', flex_flow='row', justify_content='space-between')

ovladace = [
    Box([Label(value='$\\textbf{Exponenciálne rozdelenie}$'), hustota], layout=vzhlad),
    Box([Label(value='Parameter $\\delta$'), populacna_stredna_hodnota], layout=vzhlad),
    Box([Label(value='Veľkosť vzorky $n$'), velkost_vzorky], layout=vzhlad),
    Box([Label(value='Histogram $-$ počet stĺpcov'),  pocet_stlpcov], layout=vzhlad),
   ]

panel = Box(ovladace, layout=Layout(display='flex', flex_flow='column', 
                                    border='solid 2px', align_items='stretch',  width='60%'))


# # **Exponenciálne rozdelenie s interaktívnou simuláciou**

# **Náhodný výber vzorky o veľkosti $\boldsymbol{n}$ z populácie s parametrom $\delta$**

# In[16]:


def vytvor_histogram(bins=40, n=1000, δ=1, digits = 4, density = False):

    # generovanie vzorky
    np_random = np.random.seed(0) 
    vzorka = np.random.exponential(δ,n)

    # číselná sumarizácia - výberový priemer a výberová smerodajná odchýlka (zo vzorky)
    δ_hat, s = mean(vzorka), S(vzorka)
   
    # grafická sumarizácia - histogram s vyznačeným populačným priemerom a priemerom zo vzorky
    hn = histogram(vzorka, bins = bins, color ='lightgreen', density=True)
    xmin, xmax, ymin, ymax = hn[0].get_minmax_data().values()
    
    c = line([(δ,0),(δ,1/δ)], color = 'red', thickness=2)
    cv = line([(δ_hat,0),(δ_hat,1/δ)], color = 'blue', thickness=1)
    
    Td=text("$\\delta$ = "+str(round(δ,digits)), (0.9,0.95), color='blue', bounding_box=boxstyle, axis_coords=True)
    Tdhat=text("$\\hat{\\delta}$ = "+str(round(δ_hat,digits)), (0.9,0.86), color='red', bounding_box=boxstyle, axis_coords=True)
    Ts=text("$s$ = "+str(round(s,digits)), (0.9,0.77), color='red', bounding_box=boxstyle, axis_coords=True)
    
    g = hn+c+cv+Td+Tdhat+Ts
    
    if density: 
        g += plot(1/δ*exp(-x/δ), (x, 0, 7*δ), color='gray', linestyle='--')
        
    g.show(figsize=[6,4], frame = True, ymax=1/δ, xmin=0, xmax= δ+6*δ)


# In[18]:


# interaktivna simulacia
simulacia = interactive_output(vytvor_histogram, {'bins':pocet_stlpcov, 'n':velkost_vzorky, 
                                                  'δ':populacna_stredna_hodnota, 'density':hustota})
#simulacia.layout.width = '65%'
Display(panel, simulacia)

