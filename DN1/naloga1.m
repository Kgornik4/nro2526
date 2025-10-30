fid = fopen('naloga1_1.txt', 'r');
fgetl(fid); % preskoči prvo vrstico (ime)
druga = fgetl(fid); % preskoči drugo vrstico (info o številu vrstic)
st_vrstic = sscanf(druga, 'stevilo preostalih  vrstic: %d; stevilo podatkov v vrstici: %d');

t = zeros(st_vrstic(1), 1); % pripravi prazen vektor ustrezne dolžine
for i = 1:st_vrstic(1)
    t(i) = str2double(fgetl(fid));
end
fclose(fid);
