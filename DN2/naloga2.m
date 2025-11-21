% DN 2

fid = fopen('vozlisca_temperature_dn2_8.txt', 'r');

opts = delimitedTextImportOptions("NumVariables", 3);
opts.DataLines = [5 Inf];            
opts.Delimiter = ',';                
opts.VariableNames = ["x","y","T"];
opts.VariableTypes = ["double","double","double"];
opts.ConsecutiveDelimitersRule = "join";
opts.EmptyLineRule = "read";

data = readmatrix('vozlisca_temperature_dn2_8.txt', opts);

x = data(:,1);
y = data(:,2);
T = data(:,3);

tx = 0.403;
ty = 0.503;

tic;
F = scatteredInterpolant(x, y, T, 'linear');
T_interp = F(tx, ty);
cas_scattered = toc;

fprintf('Temperatura v točki (%.3f, %.3f) = %.4f °C\n', tx, ty, T_interp);

fid = fopen('vozlisca_temperature_dn2_8.txt','r');
fgetl(fid);
Nx = str2double(regexp(fgetl(fid),'\d+','match'));
Ny = str2double(regexp(fgetl(fid),'\d+','match'));
fclose(fid);

x_unique = unique(x);
y_unique = unique(y);

T_grid = reshape(T, [Nx, Ny])';

tic;
F_grid = griddedInterpolant({y_unique, x_unique}, T_grid, 'linear');
T_grid_interp = F_grid(ty, tx);
cas_gridded = toc;

fprintf('GRIDDEDINTERPOLANT: Temperatura v točki (%.3f, %.3f) = %.4f °C\n', tx, ty, T_grid_interp);

% BILINEARNA FUNKCIJA

celice_file = 'celice_dn2_8.txt';
celice = readmatrix(celice_file, 'NumHeaderLines', 2, 'Delimiter', ',');

Nc = size(celice,1); 

T_bilinear = NaN;
tic;
for i = 1:Nc
    ids = celice(i,:); 

    T11_id = ids(1);
    T21_id = ids(2);
    T22_id = ids(3);
    T12_id = ids(4);

    x_min = x(T11_id);
    y_min = y(T11_id);
    x_max = x(T21_id);
    y_max = y(T12_id); 

    if tx >= x_min && tx <= x_max && ty >= y_min && ty <= y_max
        
        T11 = T(T11_id);
        T21 = T(T21_id);
        T22 = T(T22_id);
        T12 = T(T12_id);

        K1 = ((x_max - tx)/(x_max - x_min))*T11 + ((tx - x_min)/(x_max - x_min))*T21;
        K2 = ((x_max - tx)/(x_max - x_min))*T12 + ((tx - x_min)/(x_max - x_min))*T22;
        T_bilinear = ((y_max - ty)/(y_max - y_min))*K1 + ((ty - y_min)/(y_max - y_min))*K2;
        break
    end
end
cas_bilinearne = toc;

if isnan(T_bilinear)
    error('Točka ni znotraj nobene celice!');
end

fprintf('BILINEARNA INTERPOLACIJA: Temperatura v točki (%.3f, %.3f) = %.4f °C\n', tx, ty, T_bilinear);

fprintf('\nScatteredInterpolant: %.4f s\nGriddedInterpolant: %.4f s\nBilinearna interpolacija: %.4f s\n', ...
    cas_scattered, cas_gridded, cas_bilinearne);

[T_max, idx_max] = max(T);
x_max = x(idx_max);
y_max = y(idx_max);

fprintf('\nNajvečja temperatura v vozliščih: %.4f °C\n', T_max);
fprintf('Koordinate vozlišča: x = %.4f, y = %.4f\n', x_max, y_max);
