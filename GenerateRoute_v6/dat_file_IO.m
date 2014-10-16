C = {'Atkins',32,77.3,'M';'Cheng',30,99.8,'F';'Lam',31,80.2,'M'};
fileID = fopen('celldata.dat','w');
formatSpec = '%s %d %2.1f %s\n';

[nrows,ncols] = size(C);
for row = 1:nrows
    fprintf(fileID,formatSpec,C{row,:});
end
fclose(fileID);
type celldata.dat