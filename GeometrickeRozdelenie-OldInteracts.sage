#!/usr/bin/env python
# coding: utf-8

# # **Geometrické rozdelenie s interaktívnou simuláciou**

# **Náhodný výber vzorky o veľkosti $\boldsymbol{n}$ z populácie s parametrom $p$**

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

# vlastny styl grafov
import matplotlib.pyplot as plt
plt.style.use('seaborn-whitegrid')
boxstyle = {'boxstyle':'round', 'fc':'w'}
get_ipython().run_line_magic('matplotlib', 'inline')


# In[2]:


# rozdelenie
dist_name = 'Geometrické rozdelenie'
dist_short, m_name, sigma_name = '\\textbf{Geo}', '\\mu', '\\sigma'
p1_name, p2_name = 'p', ''
par_name = p1_name#+','+p2_name

# graficke ovladace
max_vyska = [0.1, 0.2, 0.3, 0.4, 0.5, 1, 1.5, 2, 5, 10, 20, 50, 100]
y_max = slider([round(item,1) for item in max_vyska], label='$y_{max}$', default=0.4)

hustota = checkbox(False, 'hustota')
adaptive_axes = checkbox(False, 'adaptívne')

velkosti_vzorky = [1, 2, 5, 7, 10, 20, 50, 100] + [200, 300, .. 1000] + [2000, 3000, .. 10000]
velkost_vzorky = slider(velkosti_vzorky, label='$n=$')

parameter1 = input_box(label='$'+p1_name+'=$',default=round(0.35,2), width=65)
parametre = input_grid(1, 2, default=[1,0], label='$'+par_name+'$', width=28)

pocet_stlpcov = slider(default=15, vmin=5, vmax=100, step_size=2, label='stĺpce')
pocet_vzoriek = input_box(label='$N=$',default=500, width=65)

typ_data = selector(['priemery', 'odchýlky (s)', 'odchýlky (s1)'], default='priemery', label='dáta',buttons=True)
popis_rozdelenia = text_control(value='$\\hspace{2cm}$<b><i>'+dist_name+
                                ' </i></b>$-$<i><b>náhodný výber </b>(veľkosť vzorky $n$, počet vzoriek $N$)</i>')
ovladanie = selector(['hustota', 'adaptívne osi', 'hustota+adaptívne osi','x'], 
                     nrows=1, label="zobraz", default='x', buttons=True)
hodnoty ={'x':[False,False], 'hustota':[True, False], 'adaptívne osi':[False,True],
              'hustota+adaptívne osi':[True,True]}


# In[3]:


def zobraz_histogram(bins = 15, n = 1, N = 500, digits = 4, p1 = 0.35, p2 = 1, ymax=0.5, 
                     density = False, data='priemery', adaptive=False):
    
    # charakteristiky rozdelenia
    p = p1
    m, sigma = 1/p, sqrt((1-p)/(p^2))
    
    # generovanie N vzoriek velkost n
    np_random = np.random.seed(0) 
    priemery = []
    odchylky = []
    odchylky1 = []
    for pokus in [1 .. N]:
        vzorka = np.random.geometric(p, n)
        priemery += [mean(vzorka)]
        odchylky += [S(vzorka)]
        odchylky1 += [S1(vzorka)]
        
    # číselná sumarizácia - odhad strednej hodnoty m, odchylky s a odchylky s1
    m_hat, s, s1 = mean(priemery), mean(odchylky), mean(odchylky1)
        
    Tm = text(f"${m_name}$ = {str(round(m,digits))}", (0.9,0.95), color='green', bounding_box=boxstyle, axis_coords=True)
    Tm_hat = text(f"$\\hat{m_name}$ = {str(round(m_hat,digits))}", (0.9,0.86), color='red', bounding_box=boxstyle, axis_coords=True)
    Tsigma = text(f"${sigma_name}$ = {str(round(sigma,digits))}", (0.9,0.95), color='green', bounding_box=boxstyle, axis_coords=True)
    Ts = text("$s$ = "+ str(round(s,digits)), (0.9,0.86), color='blue', bounding_box=boxstyle, axis_coords=True)
    
    if n == 1: Ts1 = text("$s_1$ = neexistuje", (0.9,0.77), color='red', bounding_box=boxstyle, axis_coords=True)
    else: Ts1 = text("$s_1$ = "+ str(round(s1,digits)), (0.9,0.77), color='red', bounding_box=boxstyle, axis_coords=True)
    
    # graficka sumarizacia - vyber dat a nastavenie
    rozdelenie = {'priemery': {'parameter':m, 'odhad': m_hat, 'hodnoty':priemery, 'color':['green','red'], 
                               'xmin':0, 'xmax':m+3*sigma, 'text': Tm+Tm_hat}, 
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
        hN = histogram(hodnoty, bins=bins, color ='lightyellow', density=True)
        
        if adaptive: 
            xmin, xmax, ymin, ymax = hN[0].get_minmax_data().values()
            y_max.disabled=True
        else:
            y_max.disabled=False
            
        c_parameter = line([(parameter,0),(parameter,ymax*1.1)], color = farba_parameter, thickness=1.5)
        c_odhad = line([(odhad,0),(odhad,ymax*1.1)], color = farba_odhad, thickness=1)
        g = hN + c_parameter + c_odhad + Text
    
        if data == 'priemery' and density: 
            body = [(k, geom.pmf(k, p)) for  k in [0,1 .. m+6*sigma] ]
            g += line(body, color='gray', linestyle='--', marker='o')
            
        g.show(figsize=[6,4], frame = True, ymax=ymax, xmin=xmin, xmax=xmax)


# In[4]:


#simulacia
@interact
def _(typ = popis_rozdelenia, p1 = parameter1, n = velkost_vzorky,
      N = pocet_vzoriek, bins=pocet_stlpcov, ymax=y_max, grafika = ovladanie, data = typ_data):
    density, adaptive = hodnoty[grafika]
     #p1,p2=param[0]
    zobraz_histogram(p1=p1, n=n, N=N, bins=bins, density=density, adaptive=adaptive, ymax=ymax, data=data)


# In[ ]:




