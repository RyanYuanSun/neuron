COMMENT
According to Figure 1 of Bi & Poo 2001 
taup = 16.8 ms and taud = 33.7 ms,
and that 60 paired stimuli can produce a maximum potentiation 
of 1.777, expressed as a multiplicative factor (0.727 for depression).
Assuming that each stimulus pair produces the same multiplicative effect,
a single stimulus pair potentiates by a factor of 1.0096 (0.9947 for depression).
The p and d parameters used in this model 
are the differences between these values and 1.
Time constants are rounded to two significant figures
(following the convention that numbers between 1... and 2... 
require an extra digit).
ENDCOMMENT

NEURON {
  POINT_PROCESS ExpSynSTDP
  RANGE tau, e, i, d, p, taud, taup
  NONSPECIFIC_CURRENT i
}

UNITS {
  (nA) = (nanoamp)
  (mV) = (millivolt)
  (uS) = (microsiemens)
}

PARAMETER {
  tau = 0.1 (ms) <1e-9,1e9>
  e = 0 (mV)
  d = 0.0053 <0,1>: depression factor
  p = 0.0096 <0, 1e9>: potentiation factor
  taud = 34 (ms) : depression effectiveness time constant
  taup = 16.8 (ms) : Bi & Poo (1998, 2001)
}

ASSIGNED {
  v (mV)
  i (nA)
  tpost (ms)
}

STATE {
  g (uS)
}

INITIAL {
  g=0
  tpost = -1e9
  net_send(0, 1)
}

BREAKPOINT {
  SOLVE state METHOD cnexp
  i = g*(v - e)
}

DERIVATIVE state {
  g' = -g/tau
}

FUNCTION factor(Dt (ms)) { : Dt is interval between most recent presynaptic spike
    : and most recent postsynaptic spike
    : calculated as tpost - tpre (i.e. > 0 if pre happens before post)
  : the following rule is the one described by Bi & Poo
  if (Dt>0) {
    factor = 1 + p*exp(-Dt/taup) : potentiation
  } else if (Dt<0) {
    factor = 1 - d*exp(Dt/taud) : depression
  } else {
    factor = 1 : no change if pre and post are simultaneous
  }
}

: w    intrinsic synaptic weight
: k    plasticity factor (k in [0,1) for depression, k>1 for potentiation)
: tpre time of previous postsynaptic spike
NET_RECEIVE(w (uS), k, tpre (ms)) {
  INITIAL { k = 1  tpre = -1e9 }
  if (flag == 0) { : presynaptic spike (after last post so depress)
: printf("Presyn spike--entry flag=%g t=%g w=%g k=%g tpre=%g tpost=%g\n", flag, t, w, k, tpre, tpost)
    g = g + w*k
    tpre = t
    k = k * factor(tpost - t)
: printf("  new k %g, tpre %g\n", k, tpre)
  }else if (flag == 2) { : postsynaptic spike (after last pre so potentiate)
: printf("Postsyn spike--entry flag=%g t=%g tpost=%g\n", flag, t, tpost)
    tpost = t
    FOR_NETCONS(w1, k1, tp) { : also can hide NET_RECEIVE args
: printf("entry FOR_NETCONS w1=%g k1=%g tp=%g\n", w1, k1, tp)
      k1 = k1*factor(t - tp)
: printf("  new k1 %g\n", k1)
    }
  } else { : flag == 1 from INITIAL block
: printf("entry flag=%g t=%g\n", flag, t)
    WATCH (v > -20) 2
  }
}

