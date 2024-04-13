% A shorthand for making all elements of a cell array complex.
% Syntax:
%                        A=inflate(A)
%
% Parameters:
%
%    A   -  a cell array of polyadics
%
% Outputs
%
%    A   -  a cell array of matrices
%
% i.kuprov@soton.ac.uk
%
% <https://spindynamics.org/wiki/index.php?title=cell/complex.m>

function A=complex(A)

% Inflate element by element
for n=1:numel(A)
    A{n}=complex(A{n});
end

end

% It is not your paintings I like, it
% is your painting. 
%
% Albert Camus
