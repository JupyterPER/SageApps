import matplotlib.pyplot as plt
import numpy as np
np.random.seed(1010)

q_slider=slider([0, 0.01 .. 1.00], default=0.7,label=r'$q$ =')

var('m')
k = 15
okraje = polygon([[-k,-k], [-k,k] , [k,k], [k,-k]], frame=True, color='black', alpha=0.85, fill=True, zorder=0)
hviezdy = points(np.random.uniform(-15, 15, size=(100,2)), color='gold')
@interact
def kontrakcia(q=q_slider):
    q = float(q)
    gamma = 1/sqrt(1-q^2)    
    body = [(10*cos(m)/gamma, 10*sin(m)) for m in [0,0.01..2*pi]]
    planeta = polygon(body, color='aquamarine') 
    (okraje  + planeta + hviezdy).show(figsize=[5,5])
