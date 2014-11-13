function [flag] = callADASRP()
%#########################################################################
%This program is used to call the ADASRP ford-Plugin software
%input:
%pointsVector: [origin latitude,origin longitude; dest latitude,dest longitude; via points latitude,via points longitude]

%Author: Xipeng Wang
%Contact: xipengw1990@gmail.com
%Date: 8/20/2014
%#########################################################################


try
    system(['Route.exe 127.0.0.1 6543 -o ' Origin ' ' Dest]);
catch me
    flag = 0;
    return;
end 
flag = 1;
end

