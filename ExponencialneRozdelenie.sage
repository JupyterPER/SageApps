#!/usr/bin/env python
# coding: utf-8

# **Diplomová práca**, Bc. Martina Loncová, PF UPJŠ v Košiciach  
# 
# # <font color=green>Pravdepodobnostné rozdelenie výberovej štatistiky  </font>
# ## Interaktívny matematický hárok

# **Nastavenia - Python** 

# In[1]:


# nacitanie pythonovskych kniznic a prikazov
import numpy as np
from numpy import array as v, float64 as dc
from numpy import sqrt, mean, std as S
# smerodajna vychylka S1
S1 = lambda vzorka: np.std(vzorka, ddof = 1)

# vlastny styl grafov
import matplotlib.pyplot as plt
plt.style.use('seaborn-whitegrid')
boxstyle = {'boxstyle':'round', 'fc':'w'}

# ignorovanie upozornení
import warnings
warnings.filterwarnings("ignore")


# **Nastavenie - grafické ovládacie prvky**

# In[2]:


# graficke prvky
from ipywidgets import BoundedIntText, BoundedFloatText, IntSlider, FloatSlider, Checkbox, Dropdown, SelectionSlider 
from ipywidgets import Box, Label, Layout, interactive_output
from IPython.display import display as Display

# ovladace
hustota = Checkbox(value=False, description='hustota')
data = Dropdown(options=['priemery', 'odchýlky (s)', 'odchýlky (s1)'], value='priemery', description='')

populacna_stredna_hodnota = BoundedFloatText(value=1, min=-500, max=500, step=0.1)
pocet_vyberov = BoundedIntText(value = 500, min=100, max=1000000, step=100)
pocet_stlpcov = IntSlider(value=20, min=5, max=100, step=5, continuous_update=False)

velkosti_vzorky = [1, 2, 5, 10, 20, 50, 100] + [200, 300, .. 1000] + [2000, 3000, .. 10000]
velkost_vzorky = SelectionSlider(options = velkosti_vzorky, value=1, continuous_update=False)
max_vyska = [0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100]
y_max = SelectionSlider(options = [round(item,1) for item in max_vyska], value=1, continuous_update=False)

# ovladaci panel
vzhlad = Layout(display='flex', flex_flow='row', justify_content='space-between')

ovladace = [
    Box([Label(value='$\\textbf{Exp}\\boldsymbol{(\\delta)}\\quad$'), hustota, data], layout=vzhlad),
    Box([Label(value='Parameter $\\delta$'), populacna_stredna_hodnota], layout=vzhlad),
    Box([Label(value='Veľkosť vzorky $n$'), velkost_vzorky], layout=vzhlad),
    Box([Label(value='Počet vzoriek $N$'), pocet_vyberov], layout=vzhlad),
    Box([Label(value='histogram $-$ počet stĺpcov'),  pocet_stlpcov], layout=vzhlad),
    Box([Label(value='maximum na osi $y$'),  y_max], layout=vzhlad),
   ]

panelS = Box(ovladace[:-2], layout=Layout(display='flex', flex_flow='column', 
                                    border='solid 2px', align_items='stretch',  width='60%'))
panelG = Box(ovladace[-2:], layout=Layout(display='flex', flex_flow='column', border='solid 1px', 
                                          align_items='stretch',  width='60%'))


# # **Exponenciálne rozdelenie s interaktívnou simuláciou**

# **Náhodný výber vzorky o veľkosti $\boldsymbol{n}$ z populácie s parametrom $\delta$**

# In[3]:


# Výber vzorky veľkosti n realizovaný N-krát s rozdelenia so strednou hodnotou mu a odchylkov nu

def zobraz_histogram(bins = 20, n = 1, N = 500, digits = 4, m = 1, sigma = 1, ymax=1, 
                     density = False, data='priemery'):
    
    sigma = m # pre exponencialne odchylka = stredna hodnota
    
    # generovanie N vzoriek velkost n
    np_random = np.random.seed(0) 
    priemery = []
    odchylky = []
    odchylky1 = []
    for pokus in [1 .. N]:
        vzorka = np.random.exponential(m, n)
        priemery += [mean(vzorka)]
        odchylky += [S(vzorka)]
        odchylky1 += [S1(vzorka)]
        
    # číselná sumarizácia - odhad strednej hodnoty m, odchylky sa odchylky s1
    m_hat, s, s1 = mean(priemery), mean(odchylky), mean(odchylky1)
        
    m_name = "\\delta"
    Tm = text(f"${m_name}$ = {str(round(m,digits))}", (0.9,0.95), color='green', bounding_box=boxstyle, axis_coords=True)
    Tm_hat = text(f"$\\hat{m_name}$ = {str(round(m_hat,digits))}", (0.9,0.86), color='red', bounding_box=boxstyle, axis_coords=True)
    Ts = text("$s$ = "+ str(round(s,digits)), (0.9,0.77), color='blue', bounding_box=boxstyle, axis_coords=True)
    
    if n == 1: Ts1 = text("$s_1$ = neexistuje", (0.9,0.68), color='brown', bounding_box=boxstyle, axis_coords=True)
    else: Ts1 = text("$s_1$ = "+ str(round(s1,digits)), (0.9,0.68), color='brown', bounding_box=boxstyle, axis_coords=True)
    
    # graficka sumarizacia - vyber dat a nastavenie
    rozdelenie = {'priemery': {'parameter':m, 'odhad': m_hat, 'hodnoty':priemery, 'color':['green','red'], 
                               'xmin':m-sigma, 'xmax':m+6*sigma}, 
                  'odchýlky (s)': {'parameter':m, 'odhad': s, 'hodnoty':odchylky, 'color':['green','blue'],
                               'xmin':m-sigma, 'xmax':m+sigma}, 
                  'odchýlky (s1)': {'parameter':m, 'odhad': s, 'hodnoty':odchylky1, 'color':['green','brown'], 
                                'xmin':m-sigma, 'xmax':m+sigma}}
    
    hodnoty = rozdelenie[data]['hodnoty']
    xmin, xmax = rozdelenie[data]['xmin'], rozdelenie[data]['xmax']
    parameter = rozdelenie[data]['parameter']
    farba_parameter = rozdelenie[data]['color'][0]
    odhad = rozdelenie[data]['odhad']
    farba_odhad = rozdelenie[data]['color'][1]
        
    # graficka sumarizacia - histogram podla typu dat - priemery, odchylky s, odchylky s1
    if (data == 'odchýlky (s1)') and (n==1): display(html('odchýlky $s_1$ nie sú pre $n=1$ definované'))
    else:
        hN = histogram(hodnoty, bins=bins, color ='yellow', density=True)
        c_parameter = line([(parameter,0),(parameter,ymax*1.1)], color = farba_parameter, thickness=1.5)
        c_odhad = line([(odhad,0),(odhad,ymax*1.1)], color = farba_odhad, thickness=1)
        g = hN + c_parameter + c_odhad + Tm + Tm_hat + Ts + Ts1
    
        if data == 'priemery' and density: 
            g += plot(1/m*exp(-x/m), (x, 0, 7*m), color='gray', linestyle='--')
        
        g.show(figsize=[6,4], frame = True, ymax=ymax, xmin=xmin, xmax=xmax)


# In[4]:


# interaktivna simulacia
simulacia = interactive_output(zobraz_histogram, {'bins':pocet_stlpcov, 
                                                  'n':velkost_vzorky, 
                                                  'N':pocet_vyberov,
                                                  'm':populacna_stredna_hodnota,
                                                  'ymax': y_max, 
                                                  'density':hustota,
                                                  'data':data})
Display(panelS, simulacia, panelG)
