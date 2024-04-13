% Ultrafast DOSY for two coupled spins with additional complications
% like DD and CSA relaxation, and spatial flow.
%
% Calculation time: minutes on NVidia Tesla A100, much longer on CPU
%
% Ludmilla Guduff
% Jean-Nicolas Dumez
% Ilya Kuprov

function ufdosy_2spin()

% Spin system
sys.isotopes={'1H','1H'};

% Interactions
sys.magnet=14.1;
inter.zeeman.scalar={6.5,7.5};
inter.coupling.scalar{1,2}=15;
inter.coupling.scalar{2,2}=0;
inter.zeeman.eigs{1}=[-10 -10 20];
inter.zeeman.euler{1}=[0 0 0];
inter.zeeman.eigs{2}=[-10 -10 20];
inter.zeeman.euler{2}=[0 pi/2 0];
inter.coordinates={[0 0 0]; [0 0 2.5]};

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='none';

% Relaxation theory
inter.relaxation={'redfield'};
inter.tau_c={1.0e-9};
inter.rlx_keep='secular';
inter.equilibrium='zero';

% Algorithmic options
sys.disable={'pt'};
sys.enable={'greedy','gpu'};

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Assumptions
spin_system=assume(spin_system,'nmr');

% Sample geometry
parameters.dims=0.015;    % m
parameters.npts=3000;
parameters.deriv={'period',7};

% Relaxation phantom
parameters.rlx_ph={ones(parameters.npts,1)};
parameters.rlx_op={relaxation(spin_system)};

% Initial and detection state phantoms
parameters.rho0_ph={ones(parameters.npts,1)};
parameters.rho0_st={state(spin_system,'Lz','1H','cheap')};
parameters.coil_ph={ones(parameters.npts,1)};
parameters.coil_st={state(spin_system,'L+','1H','cheap')};

% Diffusion and flow
parameters.u=1e-4*ones(parameters.npts,1);
parameters.diff=8e-10;      % m^2/s

% Acquisition parameters
parameters.spins={'1H'};
parameters.td=0.100;      % s
parameters.deltat=1.5e-6; % s
parameters.npoints=128;
parameters.nloops=256;
parameters.Ga=0.52;       % T/m 
parameters.offset=3600;   % Hz

% Encoding parameters
parameters.pulsenpoints=1000; 
parameters.smfactor=0.1;
parameters.Te=0.0015;     % s
parameters.Tau=0.0016;    % s
parameters.BW=110000;     % Hz
parameters.Ge=0.2535;     % T/m 
parameters.chirptype='smoothed';

% Simulation
fid=imaging(spin_system,@spendosy,parameters);

% Processing
squarespectrum=fftshift(fft(fid,[],1),1);
squarespectrum=fftshift(fft(squarespectrum,[],2),2);

% Plotting
npoints2=size(squarespectrum,2);
magnet_mhz=(1e-6*sys.magnet*spin(parameters.spins{1})/(2*pi));
SWconv=1/(2*parameters.npoints*parameters.deltat)/magnet_mhz;
ppm_axis=(-npoints2/2:npoints2/2-1)/npoints2*SWconv+parameters.offset/magnet_mhz;
FOV=1/(parameters.deltat)*2*pi/(spin(parameters.spins{1})*parameters.Ga);
npoints=size(squarespectrum,1); dispaxis=FOV*(-npoints/2:npoints/2-1)/npoints;
figure(); imagesc(ppm_axis,1000*dispaxis,abs(squarespectrum));
xlabel('chemical shift / ppm'); ylabel('FOV / mm');

end 

