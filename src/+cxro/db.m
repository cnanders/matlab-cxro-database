classdef db < handle
    
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        
            
        files % list of chemcial data files, ordered by atomic number, z
        elementsDataRaw
        stElements = [] % list of structures for elements 1-92 ordered by z
        cDirThis
        
    end
    
    methods
        
        function this = db()
            
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
    
            this.cDirThis = cDirThis;
            this.importElementsDataFile();
            this.populateFilesSortedByZ();
                        
        end
        
        
        % Returns structure containing: symbol, atomic number, atomic mass, and
        % name from chemical sysmbol
        % Atomic mass is the mass of an atom of a chemical element expressed in
        % atomic mass units. It is approximately equivalent to the number of 
        % protons and neutrons in the atom (the mass number) or to the average 
        % number allowing for the relative abundances of different isotopes.
        % @return {double 1x1}
        function st  = getInfoFromSymbol(this, symbol)
            
            index = find(strcmpi(this.elementsDataRaw{2}, symbol));
            st.symbol = symbol;
            st.z = double(this.elementsDataRaw{3}(index));
            st.name = this.elementsDataRaw{1}{index};
            st.atomicMass = double(this.elementsDataRaw{4}(index));
           
        end
        
        
        
        
    end
    
    
    methods (Access = private)
        
        % Reads elements.txt data file into memory 
        
        function importElementsDataFile(this)
            
            
            fid = fopen(fullfile(this.cDirThis, '..', '..', 'data', 'elements.txt'));
            this.elementsDataRaw = textscan(fid, '%s\t%s\t%d\t%d');
            fclose(fid);
            
        end
        
        
        % Creates a list of structures, one per element.  Each structure
        % contains z, name, symbol, atomicMass
        function populateElementInfo(this)
             
        end
        
        % Sets the private files property
        
        function populateFilesSortedByZ(this)
            
            files = dir(fullfile(this.cDirThis, '..', '..', 'data', '*.nff'));
            
            % Add z property to each strcuture in the list to allow sorting
            % by this property since we want ordered by z

            for n = 1: length(files)

                %path = fullfile(files(n).folder, files(n).name); 
                %[symbol, z, eV, f1, f2] = cxro.db.getDataFromFile(path);      

                [pathstr, name, ext] = fileparts(files(n).name);
                info = this.getInfoFromSymbol(name);
                files(n).z = info.z;

            end

            % Now order by z

            T = struct2table(files); % convert the struct array to a table
            sortedT = sortrows(T, 'z'); % sort the table by 'DOB'
            this.files = table2struct(sortedT); % change it back to struct array if necessary
            
        end

        
    end
    
        
        
           
    
    methods (Static)
        
        
        
        
        % Returns wavelength in m
        % @param {double 1x1} eV - photon energy (eV)
        function [wav] = getWav(eV)
            
            nmeV = 1239.8; % photon energy in nm*eV units 
            wav = nmeV./eV * 1e-9;
        end
        
        function plotAbsorptionCrossSection()
            

            % Dependencies

            cFilter = fullfile(this.cDirThis, '..', '..', 'data', '*.nff');
            [cFile, cPath] = uigetfile(cFilter, 'Choose a data file');

            [symbol, z, eV, f1, f2] = cxro.db.getDataFromFile(fullfile(cPath, cFile));
        
            wav = cxro.db.getWav(eV);
            val = cxro.db.getAbsorptionCrossSection(eV, f2);
            
            figure
            plot(wav/1e-9, val);
            xlabel('wav (nm)');
            ylabel('absorption cross section (cm^2)');
            title(sprintf('%s absorption cross section', symbol));

            
        end
        
        function [symbol, z] = getHeaderFromFile(path)
              
            
            fid = fopen(path);
            ceOut = textscan(fid,'%s Z=%f', 1, 'Delimiter',',');
            fclose(fid);
            
            symbol = regexprep(ceOut{1}{1}, '\W', '');
            z = ceOut{2};
            
        end
        
        % 
        
        function [symbol, z, eV, f1, f2] = getDataFromFile(path)
            
            
            [symbol, z] = cxro.db.getHeaderFromFile(path);
            
            A = readmatrix(...
                path, ...
                'FileType', 'delimitedtext'...
            );
            
        
            eV = A(:,1);
            f1 = A(:,2);
            f2 = A(:,3);
            
        end
        
        
        
        function plotAbsLengthOfElement()
            

            % Dependencies

            cFilter = fullfile(this.cDirThis, '..', '..', 'data', '*.nff');
            [cFile, cPath] = uigetfile(cFilter, 'Choose a data file');

            [symbol, z, eV, f1, f2] = cxro.db.getDataFromFile(fullfile(cPath, cFile));
            
            info = cxro.db.getInfoFromSymbol(symbol);
            wav = cxro.db.getWav(eV);
            val = cxro.db.getAbsorptionLength(z, eV, f2); % cm
                        
            figure
            loglog(wav/1e-9, val*1e4);
            xlabel('wav (nm)');

%             loglog(eV, val*1e4);
%             xlabel('eV');
            ylabel('absorption length (um)');
            title(sprintf('%s, %s, %s absorption length', ...
                info.name, ...
                info.symbol, ...
                info.z));
            
        end
        
        % Returns absorption cross section in units of m^2
        % @param {double 1x1} eV - photon energy in eV
        % @param {double 1x1} f2 - atomic scattering factor
        % see: http://gisaxs.com/index.php/Absorption_length#Related_forms
        function sigma = getAbsorptionCrossSection(eV, f2)
            
            % atomic photoabsorption cross-section
            % Where λ is the x-ray wavelength, 
            % re is the classical electron radius.
            r0 = 2.82e-15; % m
            lambda = cxro.db.getWav(eV);
            sigma = 2*r0*lambda.*f2;% m^2;
            sigma = sigma * 100 * 100; %cm^2
            
        end
        
        
        % Returns attenuation coefficient in units of (1/cm)
        % the characteristic inverse-distance for attenuation 
        % see: http://gisaxs.com/index.php/Absorption_length#Related_forms
        function val = getAttenuationCoefficient(z, eV, f2)
            
            % val = density * Na * abs_cross_section / atomic_molar_mass  
            
            % UNITS
            % density (g/cm3) [at room temp] 
            % Na is the Avogadro constant, 6.02214076×10^23 (atoms/mol)
            % atomic molar mass (g / mol)
            % g/cm3 * atoms/mol * cm2 * mol/g = units of atoms/cm

            
            % 1 mole of a substance is the mass of Na particles of the 
            % substance
            % 12 grams of Carbon 12 contains Na atoms 
            % 16 grams of Oxygen contains za atoms
            
            density = cxro.db.getDensity(z); % g/cm3
            ma = cxro.db.getMolarMass(z);
            xsec = cxro.db.getAbsorptionCrossSection(eV, f2);
            Na = 6.02214076e23;
            
            
            val = (density .* Na .* xsec) ./ ma;
            
                       
        end
        
        % Returns absorption length in cm (the distance over which the intensity
        % falls to 1/e)
        function l = getAbsorptionLength(z, eV, f2)
            l = 1./cxro.db.getAttenuationCoefficient(z, eV, f2);
        end
        
        % Returns density in g/cm3.  
        % Doesn't work well for noble gasses
        function density = getDensity(z)
            
            densities = [8.988E-05,1.785E-04,.534,1.848,2.34,2.2, ... 
      1.2506E-03,1.429E-03,1.696E-03,8.999E-04,.971,1.738, ...
      2.6989,2.33,2.2,2.05,3.214E-03,1.7837E-03,.862,1.55, ...
      2.989,4.54,6.11,7.19,7.3,7.874,8.9,8.902,8.96,7.133,6.095, ... 
      5.323,5.73,4.5,3.12,3.733E-03,1.532,2.54,4.457,6.506,8.57, ...
      10.22,11.5,12.41,12.41,12.02,10.5,8.65,7.31,7.3,6.691, ...
      6.24,4.93,5.887E-03,1.873,3.5,6.166,6.771,6.7,6.9,7.0,7.5, ...
      5.253,7.898,8.234,8.54,8.781,9.045,9.314,6.7,9.835,13.31, ...
      16.654,19.3,21.02,22.57,22.42,21.45,19.32,13.546,11.85, ...
      11.35,9.747,9.32,0.,.00973,0.,5.,10.07,11.72,15.37,18.92]; % g/cm3
            
            density = densities(z);
            
        end
        
        % Returns molar mass in g/mol
        function mass = getMolarMass(z)
            
            masses = [1.00794,4.002602,6.941,9.012182,10.811,12.0107, ...
     14.00674,15.9994,18.9984032,20.1797,22.989770,24.305,26.981538, ...
     28.0855,30.973761,32.066,35.4527,39.948,39.0983,40.078,44.955910, ...
     47.867,50.9415,51.9961,54.938049,55.845,58.9332,58.6934,63.546, ...
     65.39,69.723,72.61,74.92160,78.96,79.904,83.8,85.4678,87.62, ...
     88.90585,91.224,92.90638,95.94,98.,101.07,102.9055,106.42,107.8682, ...
     112.411,114.818,118.71,121.760,127.6,126.90447,131.29,132.90545, ...
     137.327,138.9055,140.116,140.90765,144.24,145.,150.36,151.964, ...
     157.25,158.92534,162.5,164.93032,167.26,168.93421,173.04,174.967, ...
     178.49,180.9479,183.84,186.207,190.23,192.217,195.078,196.96655, ...
     200.59,204.3833,207.2,208.98038,209.,210.,222.,223.,226.0254, ...
     227.0278,232.0381,231.03588,238.0289];
 
            mass = masses(z);
        end
        
        
        function plotAll()
            
            
            files = dir(fullfile(this.cDirThis, '..', '..', 'data', '*.nff'));
            
%             zs = zeros(size(files));
%             symbols = cell(size(files));
            
            hFig = figure
            hAxes = axes(hFig);
            
            symbols = cell(0);
            
            
            for n = 1: length(files)
                
                path = fullfile(files(n).folder, files(n).name); 
                [symbol, z, eV, f1, f2] = cxro.db.getDataFromFile(path);
                
                
                wav = cxro.db.getWav(eV);
                vals = cxro.db.getAbsorptionLength(z, eV, f2); % cm
                symbols{n} = sprintf('%1.0f %s', z, symbol); % store for legend
                
                if (cxro.db.getIsGasAtRoomTemp(z) || cxro.db.getIsLiquidAtRoomTemp(z)) 
                    continue
                end
                
                    
                try
                plot3(hAxes, z*ones(size(eV)), wav/1e-9, vals*1e4);
                hold(hAxes, 'on');

                catch mE
                    mE
                end
                
            end
            
            set(hAxes, 'yscale', 'log');
            set(hAxes, 'zscale', 'log');
            
            xlabel(hAxes, 'z');
            ylabel(hAxes, 'wav (nm)')
            zlabel(hAxes, 'absorption length (um)');
            
            %{
            set(hAxes, 'xlabel', 'z');
            set(hAxes, 'ylabel', 'wav (nm)');
            set(hAxes, 'zlabel', 'absorption length (um)')
            %}
            
            legend(hAxes, symbols)
            
        end
        
        
        function plotAll2()
            
            % files = dir(fullfile(pwd, '..', 'data', '*.nff'));
%             [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
%             files = dir(fullfile(cDirThis, '..', '..', 'data', '*.nff'));
%             
            files = cxro.db.getDataFilesSortedByZ(); 
            
            
%             zs = zeros(size(files));
%             symbols = cell(size(files));
            
            hFig = figure;
            hAxes = axes(hFig);
            
            symbols = cell(0);
            
            lines = []; % storage for output of plot
            
            
            for n = 1: length(files)
                
                path = fullfile(files(n).folder, files(n).name); 
                [symbol, z, eV, f1, f2] = cxro.db.getDataFromFile(path);
                info = cxro.db.getInfoFromSymbol(symbol);
                
                if (cxro.db.getIsGasAtRoomTemp(z) || cxro.db.getIsLiquidAtRoomTemp(z)) 
                    continue
                end
                
                wav = cxro.db.getWav(eV);
                vals = cxro.db.getAbsorptionLength(z, eV, f2); % cm
                displayName = sprintf('%1.0f %s', z, info.name); % store for legend
                symbols{end+1} = displayName;
                
                hue = z/92; 
                saturation = 1;
                value  = 1;
                color = hsv2rgb([hue, saturation, value]); % rgb
      
                try
                    lines(end+1) = semilogy(hAxes, wav/1e-9, vals*1e4, '-', ...
                        'Color', color, ...
                        'DisplayName', displayName ...
                    );
                    hold(hAxes, 'on');
                catch mE
                    mE
                end
                
                
            end
            
            %set(hAxes, 'yscale', 'log');
            %set(hAxes, 'zscale', 'log');
            
            set(hAxes, 'xlim', [11 14]);
            xlabel(hAxes, 'wav (nm)')
            ylabel(hAxes, 'absorption length (um)');
            
            %{
            set(hAxes, 'xlabel', 'z');
            set(hAxes, 'ylabel', 'wav (nm)');
            set(hAxes, 'zlabel', 'absorption length (um)')
            %}
            
            % legend(hAxes, symbols, 'NumColumns', 3)
            legend(lines, 'NumColumns', 3);
            
        end
        
        % Returns true if provied atomic number is a gas at room temp
        function lOut = getIsGasAtRoomTemp(z)
            zs = [1 2 7 8 9 10 17 18 36 54 86];
            lOut = ~isempty(find(zs==z));
        end
        
        % Returns true if provied atomic number is a liquid at room temp
        % bromine, mercury
        function lOut = getIsLiquidAtRoomTemp(z)
            zs = [35 80];
            lOut = ~isempty(find(zs==z));
        end
            
    end
end

