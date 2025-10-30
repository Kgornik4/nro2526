%           NALOGA 1

filename = "DN1/naloga1_1.txt";
delimiter = ";";
headerlines = 2; 
podatki = importdata(filename, delimiter, headerlines);

t = podatki.data;

%           NALOGA 2

fileID = fopen("DN1/naloga1_2.txt");

prvaVrstica = fgetl(fileID);                   
steviloVrednosti = str2double(prvaVrstica);    

P = zeros(steviloVrednosti, 1);                

for i = 1:steviloVrednosti
    trenutnaVrstica = fgetl(fileID);          
    trenutnaVrednost = str2double(trenutnaVrstica); 
    P(i) = trenutnaVrednost;                   
end
fclose(fileID);

plot(t, P, 'red', 'LineWidth', 2);             
xlabel('t [s]');
ylabel('P [W]');
title('graf P(t)');

%           NALOGA 3

integral_trap = 0;
for i = 1:length(t)-1
    dt = t(i+1) - t(i);
    integral_trap = integral_trap + (P(i) + P(i+1)) * dt / 2;
end

fprintf('Integral po lastni trapezni metodi: %.6f\n', integral_trap);

integral_trapz = trapz(t, P);
fprintf('Integral po trapz: %.6f\n', integral_trapz);
