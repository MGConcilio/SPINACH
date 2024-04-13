% A MAS DNP simulation performed as described in Fred Mentink-
% Vigier's paper (Spinach rotation conventions are different):
%
%         http://dx.doi.org/10.1016/j.jmr.2015.07.001
%
% Steady state DNP simulation for a powder.
%
% Calculation time: minutes
%
% i.kuprov@soton.ac.uk

function cross_effect_mas_powder()

% Magnet field
sys.magnet=9.394;

% Spin specification
sys.isotopes={'E','E','1H'};

% Interactions
inter.zeeman.eigs{1}=[2.0094  2.0060  2.0017];
inter.zeeman.euler{1}=[0.00 0.00 0.00];
inter.zeeman.eigs{2}=[2.0094  2.0060  2.0017];
inter.zeeman.euler{2}=pi*[107 108 124]/180;
inter.zeeman.eigs{3}=[0.00 0.00 0.00];
inter.zeeman.euler{3}=[0.00 0.00 0.00];
inter.coupling.eigs=cell(3,3);
inter.coupling.euler=cell(3,3);
inter.coupling.eigs{1,2}=[23.0e6 -11.5e6 -11.5e6];
inter.coupling.euler{1,2}=pi*[0.00 135 0.00]/180;
inter.coupling.eigs{1,3}=[1.5e6 -0.75e6 -0.75e6];
inter.coupling.euler{1,3}=[0.00 0.00 0.00];

% Relaxation parameters
inter.relaxation={'nottingham'};
inter.nott_r1e=1/0.3e-3;
inter.nott_r1n=1/4.0;
inter.nott_r2e=1/1.0e-6;
inter.nott_r2n=1/0.2e-3;
inter.temperature=100;
inter.equilibrium='dibari';
inter.rlx_keep='secular';

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='none';

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Experiment parameters
parameters.spins={'E'};
parameters.rate=12.5e3;
parameters.axis=[sqrt(2/3) 0 sqrt(1/3)];
parameters.max_rank=800;
parameters.mw_pwr=2*pi*0.85e6;
parameters.mw_frq=-263.366e9;
parameters.mw_time=1.0;
parameters.grid='rep_2ang_100pts_sph';
parameters.coil=state(spin_system,'Lz','1H');
parameters.verbose=0;

% Run the MAS DNP simulation
answer=masdnp(spin_system,parameters);
disp(['Steady state DNP enhancement: ' num2str(answer)]);

end

