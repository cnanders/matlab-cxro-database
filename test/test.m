%%  Add dependencies

% cThisFile = mfilename('fullpath');


files = dir(fullfile(pwd, '..', 'data', '*.nff'));

% Add z property to each strcuture in the list

for n = 1: length(files)
    
    %path = fullfile(files(n).folder, files(n).name); 
    %[symbol, z, eV, f1, f2] = cxro.db.getDataFromFile(path);      
    
    [pathstr, name, ext] = fileparts(files(n).name);
    files(n).z = cxro.db.getZFromSymbol(name);
    
end

% Now order by z

T = struct2table(files); % convert the struct array to a table
sortedT = sortrows(T, 'z'); % sort the table by 'DOB'
filesSorted = table2struct(sortedT); % change it back to struct array if necessary
