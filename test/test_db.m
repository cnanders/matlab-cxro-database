%%  Add dependencies

% cFile = mfilename('fullpath');
% [cDirThis, cName, cExt] = fileparts(cFile);
% addpath(genpath(fullfile(cDirThis, '..', 'src')));

% ABOVE code doing a really weird path 
% /private/var/folders/4v/_r1gz89s6ds20p_1j7348r6c0000gn/T/Editor_ukltv

addpath(genpath(fullfile(pwd, '..', 'src')));

db = cxro.db();
info = db.getInfoFromSymbol('be')

return


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

%% Test
eV = cxro.dbStatic.getEV([13.5, 6.75]*1e-9);
cxro.dbStatic.plotAbsorptionLengthOfAllEmentsAtSpecificEnergy(eV);

%% %Test
eV = cxro.dbStatic.getEV([13.5]*1e-9);
cxro.dbStatic.plotIndexOfAllEmentsAtSpecificEnergy(eV);

%% Test
cxro.dbStatic.plotDeltaBetaOfElement();



