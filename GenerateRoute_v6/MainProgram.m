%#########################################################################
%This program is used to generate route information from a recorded trip.
%Route information includes link and shape point info

%Author: Xipeng Wang
%Contact: xipengw1990@gmail.com
%Date: 8/20/2014
%#########################################################################
%%
clear;clc;
folderPath='C:\Users\Xipeng1990\Documents\Z_IntelligenceSysLab\GSRA2014\RoutePrediction\GenerateRoutePrograms\GenerateRoute_v6\tempData';
DirF = dir(folderPath);
len=length(DirF);
for i=3:len
    %try
    %[filename, pathname, filterindex] = uigetfile('*.mat', 'Pick a MATLAB code file');
    filename = DirF(i).name;
    fprintf(['Processing file:' filename '\n']);
    load([folderPath '\' DirF(i).name]);
    log = trip.Location.Longitude;
    lat = trip.Location.Latitude;
    if(length(log)~=length(lat))
        continue;
    end
    %%
    [coRoute,linkList,TMCnames,indicator,viaPoints] = findRoute(trip,'C:\Users\Xipeng1990\Desktop\');
    %%
    log = trip.Location.Longitude;
    lat = trip.Location.Latitude;
    kmlGen('route', coRoute);
    rdType = ones(size(log));
    speed = zeros(size(log));
    rdType = ones(size(log));
    %speed = double(trip.Movement.GPSSpeed);
    %rdType(speed>45) = 3;
    %rdType(speed<=45) =1;
    tripRoute = [log,lat,speed,rdType];
    kmlGen('trip',tripRoute);
    %%
    h=figure(i);
    %%
    hold on;
    plot(coRoute(:,1),coRoute(:,2),'*r');
    plot(tripRoute(:,1),tripRoute(:,2));
    plot(viaPoints(:,2),viaPoints(:,1),'*k');
    legend('CoRoute','Recorded Trip');
    xlabel('longitude');
    ylabel('latitude');
    %%
    save(['./saveData/' filename(1:end-12) '.mat'],'coRoute','linkList','TMCnames','trip');
    saveas(h,['./saveData/' filename(1:end-12)]);
    %catch me
    %   fprintf([filename 'running occurs problem']);
    %end
    %%
end