import cell
from neuron import h


# n -> Number of neurons per layer
# ln -> Number of layers
def create_std_layer(n, ln):
    cells = []
    for i in range(n):
        cells.append(cell.BallAndStick(str(ln) + "-" + str(i)))
    return cells


def create_std_net(layers_list):
    net_cells = []
    for index, cell_num in enumerate(layers_list):
        net_cells.append(create_std_layer(cell_num, index))
    return [net_cells, connect_ini_net(net_cells)]


def connect_ini_net(network):
    netcons = []
    syns = []
    total_layers_num = len(network)
    for index, layer in enumerate(network):
        if index < total_layers_num - 1:
            for cell in layer:
                for cell_next in network[index + 1]:
                    syn = h.ExpSynSTDP(cell_next.dend(0.5))
                    syn.tau = 0.1
                    syn.e = 0
                    syn.d = 0.0053
                    syn.p = 0.0096
                    syn.taud = 34
                    syn.taup = 16.8

                    nc = h.NetCon(cell.soma(0.5)._ref_v, syn, sec=cell.soma)
                    nc.weight[0] = 0.1
                    nc.delay = 2
                    netcons.append(nc)
                    syns.append(syn)
    return [syns, netcons]

