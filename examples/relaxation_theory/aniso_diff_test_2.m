% Relaxation superoperator calculation for an anisotropically shielded
% two-spin system with an anisotropic rotational diffusion tensor.
%
% Calculation time: seconds
%
% i.kuprov@soton.ac.uk

function aniso_diff_test_2()

% Magnet field (Tesla)
sys.magnet=2*pi*950.33e6/spin('1H');

% Isotopes
sys.isotopes={'1H','13C'};

% Chemical shift tensors (ppm)
inter.zeeman.eigs={[10.0  20.0  30.0];
                   [40.0  50.0  60.0]};
inter.zeeman.euler={[0.0  pi/4  0.0];
                    [0.0  pi/4  0.0]}; 
               
% Scalar couplings (Hz)
inter.coupling.scalar=cell(2,2);
inter.coupling.scalar{1,2}=145.0;
                
% Difusion tensor eigenvalues
D=[2.16e8 2.35e8 7.45e8];

% Relaxation theory
inter.relaxation={'redfield'};
inter.equilibrium='zero';
inter.rlx_keep='labframe';
inter.tau_c={1./(6*D)};

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='none';

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Relaxation superoperator
R=relaxation(spin_system);
disp(full(R));

end

