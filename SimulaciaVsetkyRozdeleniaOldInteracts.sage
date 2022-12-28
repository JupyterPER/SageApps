#!/usr/bin/env python
# coding: utf-8

# **Diplomová práca**, Bc. Martina Loncová, PF UPJŠ v Košiciach  
# ***
# # **Všetky rozdelenia - interaktívna simulácia**
# 
# 
# **Rozdelenie:**  normálne `'Normalne'`, exponenciálne `'Exponencialne'`, binomické `'Binomicke'`, geometrické `'Geometricke'`, Poissonovo `'Poissonovo'`

# In[1]:


# rozdelenie
# ovladace
zoznam = {'Normálne rozdelenie':'Normalne', 
          'Binomické rozdelenie':'Binomicke', 
          'Geometrické rozdelenie':'Geometricke',
          'Exponenciálne rozdelenie':'Exponencialne',
          'Poissonovo rozdelenie':'Poissonovo'}
distribution = selector(zoznam.keys(), label='$ $')

def zobraz_simulaciu(rozdelenie ='Normálne rozdelenie'):
    typ = zoznam[rozdelenie]
    url='https://raw.githubusercontent.com/JupyterPER/SageMathExamples/main/'
    load(url+typ+'Rozdelenie-OldInteracts.sage')

#simulacia
@interact
def _(rozdelenie = distribution):
    zobraz_simulaciu(rozdelenie=rozdelenie)


# In[ ]:




