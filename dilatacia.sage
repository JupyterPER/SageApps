@interact
def dilatacia(q=input_box(label=r'$q$ =',default=0.1, width=65), t_R=slider([0..70],default=1,label=r'$t_R$ =')):
    q, t_R = float(q), float(t_R)
    if q<1 and q>0:
        gamma = 1/sqrt(1-q^2)
        t_Z = float(gamma*t_R)
        output_str = 'Pri ceste raketou trvajúcej <b><font color="green">%3.f</font></b> rokov, <br> rýchlosťou <b><font color="red">%7.5f%%</font></b> rýchlosti svetla <br> ubehne na Zemi <b><font color="blue">%5.6f</font></b> rokov.' % (t_R, q * 100, t_Z)
    elif q>1 or q<0:
        output_str = 'Takou rýchlosťou nemôžeme cestovať.'
    pretty_print(html(output_str))
