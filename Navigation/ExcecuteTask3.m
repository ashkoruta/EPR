function ExcecuteTask3(newxPos, newyPos, newAngle)

global f f_manual f_automatic f_title f_robotPosTable f_BoardMap f_Video...
    f_textTask f_currentTask f_textRobotPos f_textLibrary f_dismantle ...
    f_controlPanel f_taskPanel f_snowCollection f_dumpsnow ...
    f_dumpdebris f_clearTree f_releaseTree f_liftTree f_clearRoof ...
    f_alignRoof f_clearSnow f_boardPanel f_textSubTask f_currentSubTask ...
    f_restPos f_textDisplay f_currentDisplay currentPos xPos yPos Phi mode...
    counter Ctask achievePosMt collectSnow command_X command_Y command_Phi...
    newCommand command_Index countCollectSnow currentTask currentSubTask...
    currentDisplay robotSize scaleFactor robotXCenter robotYCenter BoardMapData...
    blobColor VideoFeedData newStatus readyToCollect dumpSnow dumpDebris...
    readyToDumpSnow readyToDumpDebris achievePosTree removeTree readyToLift...
    readyToReleaseTree dumpTree readyToClear serialConnection...
    serialData xPosInit yPosInit PhiInit counterserial clearRoofLeft...
    readyToClearRoof clearRoofRight roofCleaned achievePosRoof

%Display on the GUI the current task
if(~strcmp(currentTask,'Clear Roof'))
    currentTask = 'Clear Roof';
    set(f_currentTask, 'String', currentTask);
    achievePosRoof = 0;
end

%Move to Mt Simmons Collecting Snow Area
if(achievePosRoof == 0)
    MoveToRoof(newxPos, newyPos, newAngle);
  
else
    if(clearRoofLeft == 1)
        %Display on the GUI the current sub task
        if(~strcmp(currentSubTask,'Clear Left Roof'))
            currentSubTask = 'Clear Left Roof';
            set(f_currentSubTask, 'String', currentSubTask);
            readyToClearRoof = 0; %Wait to have the good orientation to clear the snow
            newCommand = 1; %Set the position commands to the Robot
        end
        
        if(readyToClearRoof == 0)
            %Orientate the robot in front of the left part of the roof
            RoofLeftRobotOrientation(newxPos, newyPos, newAngle);
        else
            %Clear the snow from the roof
            ClearRoofLeft()
        end
    end
    
    if(clearRoofRight == 1)
        %Display on the GUI the current sub task
        if(~strcmp(currentSubTask,'Clear Right Roof'))
            currentSubTask = 'Clear Right Roof';
            set(f_currentSubTask, 'String', currentSubTask);
            readyToClearRoof = 0; %Wait to have the good orientation to collect snow
            newCommand = 1; %Set the position commands to the Robot
        end
        
        if(readyToClearRoof == 0)
            %Orientate the robot in front of the left part of the roof
            RoofRightRobotOrientation(newxPos, newyPos, newAngle);
        else
            %Clear the snow from the roof
            ClearRoofRight()
        end
    end
    
    if(roofCleaned == 1)
        %Display on the GUI the current feedback from the robot
        if(~strcmp(currentSubTask,'Roof is cleaned'))
            currentSubTask = 'Roof is cleaned';
            set(f_currentSubTask, 'String', currentSubTask);
            newCommand = 1; %Set the position commands to the Robot
        end
        %Move back the robot from the house
        MoveBack(newxPos, newyPos, newAngle);
    end
    
end
end