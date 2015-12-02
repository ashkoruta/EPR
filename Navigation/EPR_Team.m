function EPR_Team

clc
clear all

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
    readyToClearRoof clearRoofRight roofCleaned s1 achievePosRoof...
    f_clearRoofRight f_clearRoofLeft   ScoopCommand count


%Create the GUI and initialise the variables
initVar();
initGUI();
count = 1;

% %Create the connexion between GPS signal and the Robot
% serverIP ='192.168.1.212'; %Use for testing with the 2.12 servers
% s1 = tcpip(serverIP,2121,'NetworkRole','Client');
% fopen(s1);

%Select the plot on the left
axes(f_BoardMap);

%Plot the Robot Trajectory and the Robot on the BoardMap
hold on
imshow(BoardMapData);
plot(xPos, yPos, '.');
robotBlob = patch(scaleFactor.*[robotXCenter-robotSize robotXCenter-robotSize ...
    robotXCenter robotXCenter+robotSize robotXCenter+robotSize], ...
    scaleFactor.*[robotYCenter-robotSize robotYCenter+robotSize robotYCenter+ ...
    1.5*robotSize robotYCenter+robotSize robotYCenter-robotSize], blobColor);
rotate(robotBlob, [0,0,1], Phi, [scaleFactor.*robotXCenter,scaleFactor.*robotYCenter, 0]);
hold off

%Choose the right plot and show the video from the Kinect
axes(f_Video);
imshow(VideoFeedData);

%Make the UI visible and run the program
while (1)
    %If the window is closed, exit the loop
    if ~ishghandle(f)
        break;
    end
    
    try
        %Keep reading and processing until the buffer is almost empty
        while (counterserial>50 ||serialConnection.BytesAvailable > 12)
            %Get a line of format: actual,desired\n from the Serial buffer
            serialData = fscanf(serialConnection, '%s');
            %Break the line into actual and desired
            splitData = strsplit(serialData, ',');
            %Get actual and desired data as numbers instead of strings
            newxPos = str2double(splitData(1));
            newyPos = str2double(splitData(2));
            newAngle = (180/pi)*str2double(splitData(3));
            newStatus = str2double(splitData(4));
            %ScoopCommand = (splitData(5));
            %Drop the first elements of the data vectors
            xPos(1) = [];
            yPos(1) = [];
            %             newxPos = xPosInit + newxPos;
            %             newyPos = yPosInit + newyPos;
            
            %Append the new values to the _mdata vectors
            xPos = [xPos newxPos];
            yPos = [yPos newyPos];
            Phi = [Phi newAngle];
            
            counterserial = 0;
            if(count == 1)
            disp(ScoopCommand);
            count = 0;
            end
        end
        
        counterserial = counterserial +1;
        
        %Compute the new position of the robot
        robotXCenter = xPosInit - yPos(end);
        robotYCenter = yPosInit - xPos(end);
        
        %Update current position of the robot on the UI
        currentPos = [xPos(end),yPos(end),Phi(end)];
        set(f_robotPosTable,'Data',currentPos);
        
        
        %Refresh the plot of the Board Map only after 1000 count or in
        %manual mode.
        if(counter>1 || strcmp(mode, 'manual'))
            cla(f_BoardMap);
            axes(f_BoardMap);
            hold on
            imshow(BoardMapData);
            plot(scaleFactor.*(xPosInit - yPos), scaleFactor.*(yPosInit-xPos), '.');
            robotBlob = patch(scaleFactor.*[robotXCenter-robotSize robotXCenter-robotSize ...
                robotXCenter robotXCenter+robotSize robotXCenter+robotSize], ...
                scaleFactor.*[robotYCenter-robotSize robotYCenter+robotSize robotYCenter+ ...
                1.5*robotSize robotYCenter+robotSize robotYCenter-robotSize], blobColor);
            rotate(robotBlob, [0,0,1], -Phi(end)-180, [scaleFactor.*robotXCenter,scaleFactor.*robotYCenter, 0]);
            hold off
            
            
            counter = 0;
            
        else
            counter = counter +1;
        end
        
        set(f,'Name','2.12 EPR Team');% Assign the GUI a name to appear in the window title.
        set(f,'Visible','on');% Make the GUI visible.
        drawnow
        
        %Logic for handling 'Automatic' mode operation
        
        %Task n°1 Dismantling Mt Simmons
        if (strcmp(mode,'automatic'))
            if(Ctask == 0)
                %Display on the GUI the current task
                if(~strcmp(currentTask,'Robot Standby'))
                    currentTask = 'Robot Standby';
                    set(f_currentTask, 'String', currentTask);
                end
                
                %Display on the GUI the current task
                if(~strcmp(currentSubTask,'Robot Standby'))
                    currentSubTask = 'Robot Standby';
                    set(f_currentSubTask, 'String', currentSubTask);
                end
                
                %Display on the GUI the current task
                if(~strcmp(currentDisplay,'Robot Standby'))
                    currentDisplay = 'Robot Standby';
                    set(f_currentDisplay, 'String', currentDisplay);
                end
            end
            %Automatic Dismantling of Mt Simmons
            if(Ctask == 1)
                ExcecuteTask1(newxPos, newyPos, newAngle);
            end
            
            %Stop Task 1 and move to Task 2
            if(countCollectSnow >4)
                countCollectSnow = 1;
                Ctask =2;
            end
            
            %Automatic Tree removal
            if(Ctask == 2)
                ExcecuteTask2(newxPos, newyPos, newAngle)
            end
            
            if(Ctask ==3)
                ExcecuteTask3(newxPos, newyPos, newAngle)
            end
            
        end
    catch
        %         display('Bad Serial Data:');
        %         display(serialData);
    end
end
%Close the serial connection
fclose(serialConnection);
delete(serialConnection);
% %close GPS connexion
% fclose(s1);

display('Serial Connection gracefully closed!');

end



