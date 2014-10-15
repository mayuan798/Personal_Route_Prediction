function [coRoute,linkList,TMCnames,indicator,viaPoints]=findRoute(trip,desktopPath)
%#########################################################################
%This function is find the coRoute and linkList from a recorded trips
%Input:
%       tirp: Ford recorded trip, .mat file
%       desktopPath: The desktop path of the user, who open the ADASRP software.

%Output:
%       coRoute: 1:Longitude 2:Latitude 3:Numerical link ID 4:road type 5:?
%               6:ExpectedSpeed(mph) 7:lane number 8:Traffic light(0:NO 1:Yes) 9:Permenant link ID 10:FC
%       linkList: 1:linkID  2:linkID(Hex) 3:RoadName 4:FC(0~4)(function class,4 is local;0 is major intercity highways;)
%               5:ExpectedSpeed(kmh) 6:lane number 7:Height 8:Length 9:Traffic light
%       TMCnames: TMC code of each link in the linkList.
%       indicator:  0:Trip is too short or ..., can not be used
%                   1:find the co-route successfully.
%                   2: calling ADASRP fordPluin has problem
%                   3: Cannot find match route


%Author: Xipeng Wang
%Contact: xipengw1990@gmail.com
%Date: 08/20/2014
%#########################################################################

%% Initialize globle variables
pointOutlierThreshold=40;
loopCnt = 1;
maxLoopCnt = 2;
viaPoints = [];
viaPointsLocation = [];

%% Check trip data
% check data points, if the data point less than 500, filter out it
if(length(trip.Location.Time)<500)
    indicator = 0;
    coRoute=[];linkList=[];TMCnames=[];
    return;
end
% check record time, if the recorded time less than 10 minutes, filter out it
if((trip.Location.Time(end))<10*60)
    indicator = 0;
    coRoute=[];linkList=[];TMCnames=[];
    return;
end
%% Pre-process trip, filter our low speed point
speedThrehold = 3;
tempIdx = (trip.Movement.GPSSpeed > speedThrehold);
tripTrace = [trip.Location.Latitude(tempIdx),trip.Location.Longitude(tempIdx)];

% [tempIdx,tempValue] = min(find(trip.Accuracy.Accuracy(tempIdx) == 0));
% tripTrace = [tripTrace(1,:);tripTrace(tempIdx:end,:)];

% debug code
%tripTrace(1:30,:) = [];
%
Origin = [tripTrace(1,1),tripTrace(1,2)];
Dest = [tripTrace(end,1),tripTrace(end,2)];

for i = 50:150:length(tripTrace);
    viaPoints = [viaPoints;tripTrace(i,1),tripTrace(i,2)];
    viaPointsLocation = [viaPointsLocation;i];
end
pointsVector = [Origin;Dest;viaPoints];
tempFlag=callADASRP(pointsVector);
if(tempFlag == 0)
    indicator = 2;
    coRoute=[];linkList=[];TMCnames=[];
    return;
else
    [coRoute, TMCnames, linkList] = routeXMLparser([desktopPath 'route.xml']);
    fprintf(['This is the ' num2str(loopCnt) 'th matching process \n']);
    [newRoute,addViapointsLocation,indicatorMatch] = Matching([tripTrace(:,2),tripTrace(:,1)],coRoute,pointOutlierThreshold);
    if(indicatorMatch==1)
        %fprintf(['This is the ' num2str(loopCnt) 'th clearing co-route process \n']);
        %[coRoute, TMCnames, linkList] = clearRedundantLinks( coRoute, TMCnames, linkList,desktopPath);
        %[coRoute, TMCnames, linkList] = FinalClean(coRoute,TMCnames,linkList);
        viaPoints = [tripTrace(viaPointsLocation,1),tripTrace(viaPointsLocation,2)];
        indicator = 1;
        fprintf('Successfully matched');
        return;
    elseif(indicatorMatch==2)
        indicator = 3;
        coRoute=[];linkList=[];TMCnames=[];
        viaPoints = [];
        return;
    else
        viaPointsLocation = unique(sort([viaPointsLocation;addViapointsLocation]));
        %viaPointsLocation(viaPointsLocation<10) = [];
        [viaPointsLocation] = clearViapointsInSameLinks(viaPointsLocation,tripTrace,desktopPath);
        pointsVector = [Origin;Dest;[tripTrace(viaPointsLocation,1),tripTrace(viaPointsLocation,2)]];
        tempFlag=callADASRP(pointsVector);
        [coRoute, TMCnames, linkList] = routeXMLparser([desktopPath 'route.xml']);
        while(1)
            coRoute = newRoute;
            %fprintf(['This is the ' num2str(loopCnt) 'th clearing co-route process \n']);
            %[coRoute, TMCnames, linkList] = clearRedundantLinks(coRoute, TMCnames, linkList,desktopPath);
            
            if(tempFlag==0)
                indicator = 2;
                coRoute=[];linkList=[];TMCnames=[];
                viaPoints = [];
                return;
            end
            fprintf(['This is the ' num2str(loopCnt+1) 'th matching process \n']);
            [newRoute,addViapointsLocation,indicatorMatch] = Matching([tripTrace(:,2),tripTrace(:,1)],coRoute,pointOutlierThreshold);
            viaPointsLocation = unique(sort([viaPointsLocation;addViapointsLocation]));
            %viaPointsLocation(viaPointsLocation<10) = [];
            [ viaPointsLocation ] = clearViapointsInSameLinks(viaPointsLocation,tripTrace,desktopPath);
            pointsVector = [Origin;Dest;[tripTrace(viaPointsLocation,1),tripTrace(viaPointsLocation,2)]];
            tempFlag=callADASRP(pointsVector);
            [coRoute, TMCnames, linkList] = routeXMLparser([desktopPath 'route.xml']);
            if(indicatorMatch==1)
                fprintf('Successfully matched');
                indicator = 1;
                coRoute = newRoute;
                %[coRoute, TMCnames, linkList] = clearRedundantLinks(coRoute, TMCnames, linkList,desktopPath);
                %[coRoute, TMCnames, linkList] = FinalClean(coRoute,TMCnames,linkList);
                viaPoints = [tripTrace(viaPointsLocation,1),tripTrace(viaPointsLocation,2)];
                return;
            end
            if(loopCnt>=maxLoopCnt)
                indicator = 1;
                fprintf('Loop end \n');
                %[coRoute, TMCnames, linkList] = clearRedundantLinks(coRoute, TMCnames, linkList,desktopPath);
                %[coRoute, TMCnames, linkList] = FinalClean(coRoute,TMCnames,linkList);
                viaPoints = [tripTrace(viaPointsLocation,1),tripTrace(viaPointsLocation,2)];
                return;
            end
            loopCnt = loopCnt+1;
            
        end
        
    end
end

end





