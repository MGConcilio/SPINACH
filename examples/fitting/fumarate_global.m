% Simultaneous fitting of 1H and 13C NMR spectra of a slightly
% asymmetric fumarate diester.
%
% Calculation time: minutes
%
% g.pileio@soton.ac.uk
% g.stevanato@soton.ac.uk
% i.kuprov@soton.ac.uk

function fumarate_global()

% Load experimental data
load('fumarate_1h.mat'); axis_expt_h=axis_hz; spec_expt_h=data_expt;
load('fumarate_13c.mat'); axis_expt_c=axis_hz; spec_expt_c=data_expt;

% Normalize the data
spec_expt_h=spec_expt_h/max(spec_expt_h); 
spec_expt_c=spec_expt_c/max(spec_expt_c); 

% Set the guess
guess=[-0.0325    0.0300    0.0040   -0.0030   70.9989   -2.7853 ...
      166.6826   15.6814    0.0366    0.0242   10.4768    5.4905];

% Set optimizer options
options=optimset('Display','iter','MaxIter',5000,'MaxFunEvals',Inf,...
                 'DiffMinChange',1e-6,'FinDiffType','central',...
                 'UseParallel',true);

% Run the optimisation
answer=fminunc(@(x)errfun(axis_expt_h,axis_expt_c,spec_expt_h,spec_expt_c,x),guess,options);

% Display the result
disp(answer);

end

% Least squares error function
function err=errfun(axis_expt_h,axis_expt_c,spec_expt_h,spec_expt_c,params)

% Silence Spinach
sys.output='hush';
sys.disable={'hygiene'};

% Absorb parameters
c_shift_1=params(1);
c_shift_2=params(2);
h_shift_1=params(3);
h_shift_2=params(4);
j_cc=params(5);
j_ch_far=params(6);
j_ch_near=params(7);
j_hh=params(8);
a_h=params(9);
a_c=params(10);
lw_h=params(11);
lw_c=params(12);

% Spin system
sys.isotopes={'1H','13C','13C','1H'};

% Magnet field
sys.magnet=2*pi*500.101412e6/spin('1H');

% Chemical shifts
inter.zeeman.scalar={h_shift_1 c_shift_1 c_shift_2 h_shift_2};

% Scalar couplings
inter.coupling.scalar={0.0   j_ch_near   j_ch_far  j_hh;
                       0.0   0.0         j_cc      j_ch_far;
                       0.0   0.0         0.0       j_ch_near;
                       0.0   0.0         0.0       0.0};

% Basis set
bas.formalism='zeeman-hilb';
bas.approximation='none';

% Spinach housekeeping
spin_system=create(sys,inter);
spin_system=basis(spin_system,bas);

% Sequence parameters - 1H
parameters_h.spins={'1H'};
parameters_h.rho0=state(spin_system,'L+','1H');
parameters_h.coil=state(spin_system,'L+','1H');
parameters_h.decouple={};
parameters_h.offset=0;
parameters_h.sweep=600;
parameters_h.npoints=1024;
parameters_h.zerofill=4096;
parameters_h.axis_units='Hz';

% Sequence parameters - 13C
parameters_c.spins={'13C'};
parameters_c.rho0=state(spin_system,'L+','13C');
parameters_c.coil=state(spin_system,'L+','13C');
parameters_c.decouple={};
parameters_c.offset=0;
parameters_c.sweep=600;
parameters_c.npoints=1024;
parameters_c.zerofill=4096;
parameters_c.axis_units='Hz';

% Simulation
fid_h=liquid(spin_system,@acquire,parameters_h,'nmr');
fid_c=liquid(spin_system,@acquire,parameters_c,'nmr');

% Apodization
fid_h=apodization(fid_h,'exp-1d',lw_h);
fid_c=apodization(fid_c,'exp-1d',lw_c);

% Fourier transform
spec_theo_h=a_h*real(fftshift(fft(fid_h,parameters_h.zerofill)));
spec_theo_c=a_c*real(fftshift(fft(fid_c,parameters_c.zerofill)));

% Axis unification and interpolation
axis_theo_h=sweep2ticks(parameters_h.offset,parameters_h.sweep,parameters_h.zerofill);
axis_theo_c=sweep2ticks(parameters_c.offset,parameters_c.sweep,parameters_c.zerofill);
spec_theo_h=interp1(axis_theo_h,spec_theo_h,axis_expt_h,'pchip'); axis_theo_h=axis_expt_h;
spec_theo_c=interp1(axis_theo_c,spec_theo_c,axis_expt_c,'pchip'); axis_theo_c=axis_expt_c;

% Plotting
subplot(2,1,1); plot(axis_expt_h,spec_expt_h,'ro'); hold on;
plot(axis_theo_h,spec_theo_h); hold off; axis([-300 300 -0.1 1.1]);
subplot(2,1,2); plot(axis_expt_c,spec_expt_c,'ro'); hold on;
plot(axis_theo_c,spec_theo_c); hold off; axis([-300 300 -0.1 1.1]); drawnow;

% Error functional
err=norm(spec_expt_h-spec_theo_h)^2+norm(spec_expt_c-spec_theo_c)^2;

end

