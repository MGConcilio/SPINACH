% An example of the SIFTER sequence.
%
% Calculation time: minutes.
%
% alice.bowen@chem.ox.ac.uk
% Asif Equbal <asifequbal3@gmail.com>

function sifter_nitroxide_powder()

% Magnet field
sys.magnet=0.33;

% System specification
sys.isotopes={'E','E','14N','14N'};

% Zeeman interactions
inter.zeeman.eigs=cell(1,4);
inter.zeeman.euler=cell(1,4);
inter.zeeman.eigs{1,1}=[2.0087 2.0058 2.0018];
inter.zeeman.eigs{1,2}=[2.0087 2.0058 2.0018];
inter.zeeman.euler{1,1}=[0 0 0];
inter.zeeman.euler{1,2}=[0 0 0];

% Coordinates for inter-electron DD
inter.coordinates={[0 0 0]; [0 0 20]; []; [] };

% Hyperfine couplings
inter.coupling.eigs=cell(4,4);
inter.coupling.euler=cell(4,4);
inter.coupling.eigs{1,3}=[19.8977 20.1780 102.8516]*1e6;
inter.coupling.eigs{2,4}=[19.8977 20.1780 102.8516]*1e6;
inter.coupling.euler{1,3}=[0 0 0];
inter.coupling.euler{2,4}=[0 0 0];

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='none';
bas.longitudinals={'14N'};

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Set the sequence parameters
parameters.spins={'E'};
parameters.rho0=state(spin_system,'Lz','E');
parameters.coil=state(spin_system,'L+','E');
parameters.pulse_opy=(operator(spin_system,'L+','E')-...
                      operator(spin_system,'L-','E'))/2i; % Y pulse
parameters.pulse_opx=(operator(spin_system,'L+','E')+...
                      operator(spin_system,'L-','E'))/2;  % X pulse
parameters.offset=0;
parameters.npoints=200;
parameters.timestep=8e-9;
parameters.grid='rep_2ang_3200pts_sph';

% Simulation
fid=powder(spin_system,@sifter,parameters,'esr');

% Plotting
figure(); subplot(1,2,1); surf(imag(fid));
subplot(1,2,2); plot(diag(imag(fid))); kgrid;

end

