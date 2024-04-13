% 13C NMR spectrum of static alanine powder. Protons are assumed 
% to be decoupled.
%
% Calculation time: seconds
%
% i.kuprov@soton.ac.uk

function static_powder_ala()

% Spin system properties (PCM DFT calculation)
[sys,inter]=g2spinach(gparse('../standard_systems/alanine.log'),...
                     {{'C','13C'},{'N','15N'}},[182.1 264.5],[]);
% Magnet field
sys.magnet=14.1;

% Basis set
bas.formalism='sphten-liouv';
bas.approximation='none';
bas.longitudinals={'15N'};
bas.projections=+1;

% Algorithmic options
sys.tols.inter_cutoff=5.0;
sys.tols.prox_cutoff=4.0;
sys.disable={'trajlevel'};

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Experiment setup
parameters.sweep=5e4;
parameters.npoints=128;
parameters.zerofill=512;
parameters.offset=15000;
parameters.spins={'13C'};
parameters.decouple={};
parameters.axis_units='ppm';
parameters.invert_axis=1;
parameters.grid='rep_2ang_6400pts_sph';
parameters.rho0=state(spin_system,'L+','13C','cheap');
parameters.coil=state(spin_system,'L+','13C','cheap');
parameters.verbose=0;

% Simulation
fid=powder(spin_system,@acquire,parameters,'nmr');

% Apodization
fid=apodization(fid,'exp-1d',6);

% Fourier transform
spectrum=fftshift(fft(fid,parameters.zerofill));

% Plotting
figure(); plot_1d(spin_system,real(spectrum),parameters);

end

