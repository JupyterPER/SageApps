import matplotlib.pyplot as plt
import numpy as np

q_slider=slider([0, 0.01 .. 0.99], default=0.1,label=r'$q$ =')

np.random.seed(1010)
var('m')
k = 15
okraje = polygon([[-k,-k], [-k,k] , [k,k], [k,-k]], frame=True, color='black', alpha=0.85, fill=True, zorder=0)
hviezdy = points(np.random.uniform(-15, 15, size=(100,2)), color='gold')
q_p = 0.8
gamma_p = 1/sqrt(1-q_p^2) 
body_p = [(10*cos(m)/gamma_p, 10*sin(m)) for m in [0,0.01..2*pi]]
planeta = polygon(body_p, color='salmon')
@interact
def kontrakcia(q=q_slider):
    q = float(q)
    gamma = 1/sqrt(1-q^2)
    body_r = [(10*cos(m)/gamma, 10*sin(m)) for m in [0,0.01..2*pi]] 
    meranie = line(body_r, color='lawngreen') 
    (okraje  + planeta + hviezdy + meranie).show(figsize=[5,5])
