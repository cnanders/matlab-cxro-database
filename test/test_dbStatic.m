%%  Add dependencies

% cThisFile = mfilename('fullpath');
% [cDirThis, cName, cExt] = fileparts(cFile);
% addpath(genpath(fullfile(cDirThis, '..', 'src')));

addpath(genpath(fullfile(pwd, '..', 'src')));

%% Test converting eV to nm

cxro.dbStatic.getWav([92, 91])

%% Test readign a file and plotting
cxro.dbStatic.plotAbsorptionCrossSection()

%% Test converting atomic number Z (#protons in nucleus) to density
cxro.dbStatic.getDensity(6) % 2.267

%% Test converting atomic number Z (#protons in nucleus) to density
cxro.dbStatic.getDensity(11) % Sodium 0.968

%% Test converting atomic number Z (#protons in nucleus) to molar mass
cxro.dbStatic.getMolarMass(13) % Aluminum 26.89 g/mol

%% Test converting atomic number Z (#protons in nucleus) to molar mass
cxro.dbStatic.getMolarMass(51) % Antimony 121.8 g/mol

%% Test plotting absorption length vs. wav
cxro.dbStatic.plotAbsLengthOfElement()

%% Test plot all
cxro.dbStatic.plotAll()

%% Test plot all
cxro.dbStatic.plotAll2()

%% Test get z from atomic number
cxro.dbStatic.getZFromSymbol('be')
cxro.dbStatic.getZFromSymbol('o')
