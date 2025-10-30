filename = "DN1/naloga1_1.txt";
delimiter = ";";
headerlines = 2; 
podatki = importdata(filename, delimiter, headerlines);

t = podatki.data;
