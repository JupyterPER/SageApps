@interact
def dilatacia(q=input_box(label=r'$q$ =',default=0.1, width=65), t_R=slider([0..70],default=1,label=r'$T_R$ =')):
    q, t_R = float(q), float(t_R)
    if q<1 and q>0:
        gamma = 1/sqrt(1-q^2)
        t_Z = float(gamma*t_R)
        output_str = 'Pri ceste raketou trvajúcej %3.f rokov, \nrýchlosťou %7.5f%% rýchlosti svetla \nubehne na Zemi %5.6f rokov.' %(t_R, q*100, t_Z)
    elif q>1 or q<0:
        output_str = 'Takou rýchlosťou nemôžeme cestovať.'
    pretty_print(output_str)