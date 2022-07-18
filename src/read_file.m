% read_data

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% Dependencies

cFilter = fullfile(cDirThis, '..', 'data', '*.nff');
[cFile, cPath] = uigetfile(cFilter, 'Choose a data file');


A = readmatrix(...
    fullfile(cPath, cFile), ...
    'FileType', 'delimitedtext'...
);

% A(:, 1) Energy (eV)
% A(:, 2) f1
% A(:, 3) f2

%{

The atomic photoabsorption cross section, mu_a, may be readily obtained
from the values of f_2 using the relation,

			mu_a = 2*r_0*lambda*f_2 

where r_0 is the classical electron radius, and lambda is the wavelength.
The index of refraction for a material with N atoms per unit volume
is calculated by,

		n = 1 - N*r_0*(lambda)^2*(f_1+if_2)/(2*pi).

%}

r0 = 2.82e-15; %m

% E (eV) = 1239.8 / l (nm) 


