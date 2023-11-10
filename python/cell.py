from neuron import h


class Cell:
    # def __init__(self, gid, x, y, z, theta):
    def __init__(self, gid):
        self._gid = gid
        self._setup_morphology()
        self.all = self.soma.wholetree()
        self._setup_biophysics()

        # 3D orientation
        # self.x = self.y = self.z = 0
        # h.define_shape()
        # self._rotate_z(theta)
        # self._set_position(x, y, z)

    def __repr__(self):
        return '{}[{}]'.format(self.nrn_type, self._gid)


"""
# Default model with 1 soma and 1 dendrite
# [Soma] o- [Dend]
"""
class BallAndStick(Cell):
    nrn_type = 'BallAndStick'

    def _setup_morphology(self):
        self.soma = h.Section(name='soma', cell=self)
        self.dend = h.Section(name='dend', cell=self)
        self.dend.connect(self.soma)
        self.soma.L = self.soma.diam = 12.6157  # Soma length & diameter
        self.dend.L = 200  # Dendrite length
        self.dend.diam = 1  # Dendrite diameter

    def _setup_biophysics(self):
        for sec in self.all:
            sec.Ra = 100  # Axial resistance in Ohm * cm
            sec.cm = 1  # Membrane capacitance in micro Farads / cm^2
        self.soma.insert('hh')
        for seg in self.soma:
            seg.hh.gnabar = 0.12  # Sodium conductance in S/cm2
            seg.hh.gkbar = 0.036  # Potassium conductance in S/cm2
            seg.hh.gl = 0.0003  # Leak conductance in S/cm2
            seg.hh.el = -54.3  # Reversal potential in mV
        # Insert passive current in the dendrite
        self.dend.insert('pas')
        for seg in self.dend:
            seg.pas.g = 0.001  # Passive conductance in S/cm2
            seg.pas.e = -65  # Leak reversal potential mV
