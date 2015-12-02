function initVar

global currentPos currentTask currentSubTask xPos yPos Phi mode...
    counter Ctask achievePosMt collectSnow command_X command_Y command_Phi...
    newCommand command_Index countCollectSnow BoardMapData...
    currentDisplay robotSize scaleFactor robotXCenter robotYCenter ...
    blobColor VideoFeedData newStatus readyToCollect DumpSnow...
    ReadyToDumpSnow DumpDebris ReadyToDumpDebris achievePosTree...
    removeTree readyToLift readyToReleaseTree dumpTree readyToClear...
    xPosInit yPosInit PhiInit counterserial clearRoofLeft readyToClearRoof...
    clearRoofRight roofCleaned GPS_X GPS_Y GPS_Phi achievePosRoof



scaleFactor = 591.395; %The scale factor between the Plot and Reality
windowWidth = 1000; %Memory of the robot: the number of location points to keep
robotSize = 0.1768; %This is an actual-size robot, in meters
xPos = linspace(0, 0, windowWidth*3); %x coordinate pointing right of the robot
yPos = linspace(0, 0, windowWidth*3); %y coordinate pointing down of the robot
Phi = linspace(0, 0, windowWidth*3); %Orientation Phi of the Robot from axis x towards y

%Position the Robot at the starting point
xPosInit = 3.246;
yPosInit = 2.083;
PhiInit = 0;
xPos(end) = 0;
yPos(end) = 0;
Phi = 0;

%Drawing variables for the robot on the plot
robotXCenter = xPos(end);
robotYCenter = yPos(end);
blobColor = 'green';

%Display on GUI variables
BoardMapData = imread('BoardScale1-20.jpg'); %Board configuration map
VideoFeedData = imread('ball3ft.jpg'); %Video Feed from the Kinect
currentPos = [0 0 0]; %Position of the Robot
currentTask = 'Robot Initializing';
currentSubTask = 'Robot Initializing';
currentDisplay = 'Robot Initializing';
counter = 0; %refreshing rate of the plot in automatic mode
counterserial = 0;

%Automatic Loop variables
mode = 'automatic'; %choosing the mode of the robot manual/automatic
Ctask = 0; %Task selection: 1 for Mt Simmons, 2 for tree removal and 3 for cleaning the roof
command_X = 0; %Command X coordinate to send to Arduino
command_Y = 0; %Command Y coordinate to send to Arduino
command_Phi = 0; %Command robot orientation to send to Arduino
command_Index = 0; %Commands reading flag
achievePosMt = 0; %Achieved Mt Simmons area position asked from the command
newStatus = 0; % Received something from the Arduino
newCommand = 0; %Does the robot has a position command to follow
countCollectSnow = 1; %counter for number of time we collect the snow
collectSnow = 0; %Use the manipulator to scoop snow and debris
readyToCollect = 0; %Flag to have the robot wait to have the good orientation 
                    %and position regarding the debris before scooping them
DumpSnow = 0; %Start snow dumping procedure
ReadyToDumpSnow = 0; %Flag to have the robot wait to have the good orientation 
                    %and position regarding the truck before dumping snow
DumpDebris = 0; %Start debris dumping procedure
ReadyToDumpDebris = 0;%Flag to have the robot wait to have the good orientation 
                    %and position regarding the truck before dumping debris
achievePosTree = 0; %Achieved Tree area position asked from the command
removeTree = 0; %Tree removal procedure flag
readyToLift = 0; %Lifting Tree procedure flag
dumpTree = 0; %Dumping the tree procedure flag
readyToReleaseTree = 0; %Releasing tree on the side procedure flag
readyToClear = 0; %Flag for clearing the path in front of us in case the basic procedure failed
achievePosRoof = 0; %Achieved Roof area position asked from the command
clearRoofLeft = 0; %Flag to start cleaning the left part of the roof
readyToClearRoof = 0;%Flag to clean the roof with the scoop
clearRoofRight = 0; %Flag to start cleaning the right part of the roof
roofCleaned = 0; %Flag to go back to standby position
GPS_X=0;
GPS_Y=0;
GPS_Phi=0;
end