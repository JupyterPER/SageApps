#!/usr/bin/env python
# coding: utf-8

# **Diplomová práca**, Bc. Martina Loncová, PF UPJŠ v Košiciach  
# 
# # <font color=green>Pravdepodobnostné rozdelenie a vlastnosti výberových štatistík  </font>
# ## Interaktívny matematický hárok

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
plt.style.use('seaborn-v0_8-whitegrid')
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


# graficke ovladace
parameter1.value = 1
pocet_stlpcov.value, pocet_stlpcov.step = 7, 2
y_max.value = 0.5

# ovladaci panel
dist_name, m_name, sigma_name = '\\textbf{Po}', '\\mu', '\\sigma'
p1_name, p2_name ='\\lambda', ''
par_name = p1_name#+','+p2_name

ovladace = [
    Box([Label(value='$'+dist_name+'\\boldsymbol{('+par_name+')}\\phantom{'+par_name+'}$'), data], layout=vzhlad),
    Box([Label(value='Parameter $'+p1_name+'$'), parameter1], layout=vzhlad),
    #Box([Label(value='Parameter $'+p2_name+'$'), parameter2], layout=vzhlad),
    Box([Label(value='Veľkosť vzorky $n$'), velkost_vzorky], layout=vzhlad),
    Box([Label(value='Počet vzoriek $N$'), pocet_vyberov], layout=vzhlad),
    Box([hustota, adaptive_axes], layout=vzhlad),
    Box([Label(value='histogram $-$ počet stĺpcov'),  pocet_stlpcov], layout=vzhlad),
    Box([Label(value='maximum na osi $y$'),  y_max], layout=vzhlad),
   ]

panelS = Box(ovladace[:-3], layout=Layout(display='flex', flex_flow='column', 
                                    border='solid 2px', align_items='stretch',  width='60%'))
panelG = Box(ovladace[-3:], layout=Layout(display='flex', flex_flow='column', border='solid 1px', 
                                          align_items='stretch',  width='60%'))


# In[3]:


#Display(panelS, panelG)


# # **Poissonovo rozdelenie s interaktívnou simuláciou**

# **Náhodný výber vzorky o veľkosti $\boldsymbol{n}$ z populácie s parametrom $\lambda$**

# In[4]:


# Výber vzorky veľkosti n realizovaný N-krát s rozdelenia so strednou hodnotou m a odchylkou n

def zobraz_histogram(bins, n, N, p1, p2, ymax,  density = False,  data='priemery', adaptive = True, digits= 4):

    
    # charakteristiky rozdelenia
    m, sigma = p1, p2
    sigma = m # pre rozdelenie odchylka = stredna hodnota
    
    # generovanie N vzoriek velkost n
    np_random = np.random.seed(0) 
    priemery = []
    odchylky = []
    odchylky1 = []
    for pokus in [1 .. N]:
        vzorka = np.random.poisson(m, n)
        priemery += [mean(vzorka)]
        odchylky += [S(vzorka)]
        odchylky1 += [S1(vzorka)]
        
    # číselná sumarizácia - odhad strednej hodnoty m, odchylky s a odchylky s1
    m_hat, s, s1 = mean(priemery), mean(odchylky), mean(odchylky1)
        
    Tm = text(f"${m_name}$ = {str(round(m,digits))}", (0.9,0.95), color='green', bounding_box=boxstyle, axis_coords=True)
    Tsigma = text(f"${sigma_name}$ = {str(round(m,digits))}", (0.9,0.95), color='green', bounding_box=boxstyle, axis_coords=True) 
    Tm_hat = text(f"$\\hat{m_name}$ = {str(round(m_hat,digits))}", (0.9,0.86), color='red', bounding_box=boxstyle, axis_coords=True)
    Ts = text("$s$ = "+ str(round(s,digits)), (0.9,0.86), color='blue', bounding_box=boxstyle, axis_coords=True)
    
    if n == 1: Ts1 = text("$s_1$ = neexistuje", (0.9,0.77), color='red', bounding_box=boxstyle, axis_coords=True)
    else: Ts1 = text("$s_1$ = "+ str(round(s1,digits)), (0.9,0.77), color='red', bounding_box=boxstyle, axis_coords=True)
    
    # graficka sumarizacia - vyber dat a nastavenie
    rozdelenie = {'priemery': {'parameter':m, 'odhad': m_hat, 'hodnoty':priemery, 'color':['green','red'], 
                               'xmin':0, 'xmax':m+6*sigma, 'text': Tm+Tm_hat}, 
                  'odchýlky (s)': {'parameter':sigma, 'odhad': s, 'hodnoty':odchylky, 'color':['green','blue'],
                               'xmin':0, 'xmax':3*sigma, 'text': Tsigma+Ts+Ts1}, 
                  'odchýlky (s1)': {'parameter':sigma, 'odhad': s1, 'hodnoty':odchylky1, 'color':['green','red'], 
                                'xmin':0, 'xmax':3*sigma, 'text': Tsigma+Ts+Ts1}}
    
    hodnoty = rozdelenie[data]['hodnoty']
    xmin, xmax = rozdelenie[data]['xmin'], rozdelenie[data]['xmax']
    parameter = rozdelenie[data]['parameter']
    farba_parameter = rozdelenie[data]['color'][0]
    odhad = rozdelenie[data]['odhad']
    farba_odhad = rozdelenie[data]['color'][1]
    Text = rozdelenie[data]['text']
    
    # graficka sumarizacia - histogram podla typu dat - priemery, odchylky s, odchylky s1
    if (data == 'odchýlky (s1)') and (n==1): display(html('odchýlky $s_1$ nie sú pre $n=1$ definované'))
    else:
        hN = histogram(hodnoty, bins=bins, align='mid', color ='lightyellow', density=True)
        
        if adaptive: 
            xmin, xmax, ymin, ymax = hN[0].get_minmax_data().values()
            y_max.disabled=True
        else:
            y_max.disabled=False
        
        c_parameter = line([(parameter,0),(parameter,ymax*1.1)], color = farba_parameter, thickness=1.5)
        c_odhad = line([(odhad,0),(odhad,ymax*1.1)], color = farba_odhad, thickness=1)
        g = hN + c_parameter + c_odhad + Text
    
        if data == 'priemery' and density: 
            body = [(k, m^k*exp(-m)/factorial(k)) for  k in [0,1 .. m+6*sigma] ]
            g += line(body, color='gray', linestyle='--', marker='o')
        
        g.show(figsize=[6,4], frame = True, ymax=ymax, xmin=xmin, xmax=xmax)


# In[5]:


# interaktivna simulacia
simulacia = interactive_output(zobraz_histogram, {'bins':pocet_stlpcov, 
                                                  'n':velkost_vzorky, 
                                                  'N':pocet_vyberov,
                                                  'p1':parameter1,
                                                  'p2':parameter2,
                                                  'ymax': y_max, 
                                                  'density':hustota,
                                                   'data':data,
                                                  'adaptive':adaptive_axes})
Display(panelS, simulacia, panelG)

