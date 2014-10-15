function [newRoute,addViapointsLocation,indicator] = Matching(tripData,routeData,threhold)
%#########################################################################
%This program is used to check if the trip and route is matched or not
%input:
    %tripData 1:logtitude 2:latitude
    %routeData 1:logtitude 2:latitude 
%Output:
    %indicator: 0: some parts are matched 1: matched 2:totally no match 

%Author: Xipeng Wang
%Contact: xipengw1990@gmail.com
%Date: 8/20/2014
%#########################################################################

roadW = 15E-3;%roadWidth
routeShPdist = zeros(length(routeData(:,1))-1,1);
minDist = zeros(length(routeData(:,1))-1,1);
maxDist = zeros(length(routeData(:,1))-1,1);
for i=1:length(routeData(:,1))-1
    routeShPdist(i) = pos2dist(routeData(i,1),routeData(i,2),routeData(i+1,1),routeData(i+1,2));
    maxDist(i) = 2*sqrt(roadW^2 + (routeShPdist(i)/2)^2);
    minDist(i) = sqrt(roadW^2+(routeShPdist(i))^2);
end
DistCell = cell(1,length(tripData(:,1)),1);
RouteLabel = zeros(length(routeData(:,1))-1,1);
label = zeros(length(tripData(:,1)),1);
for i=1:length(DistCell)
    tempDist = [];
    for j=1:length(routeData(:,1))
        tempDist = [tempDist;pos2dist(tripData(i,1),tripData(i,2),routeData(j,1),routeData(j,2))];
    end
    RouteLabel(((tempDist(1:end-1) + tempDist(2:end)) - maxDist)<=0)=1;
    RouteLabel(tempDist<roadW)=1;
    if((sum(((tempDist(1:end-1) + tempDist(2:end)) - maxDist)<=0)+sum(tempDist<roadW))~=0)
           label(i) = 1; 
    end
    DistCell{i} = tempDist;
end
newRoute = routeData(RouteLabel==1,:);
if(sum(label)==0)
    indicator = 2; %totally no match
    addViapointsLocation = [];
    newRoute=[];
    return;
else
    if(sum(label~=1)>threhold)
        indicator = 0;
        tempIdx = (find(label==0));  %find not matched trip points;
        addViapointsLocation=chooseAddViapointsLocation(tempIdx);
    else
        newRoute = routeData;
        addViapointsLocation = [];
        indicator = 1;
    end
end
end

