function MoveToMtSimmons(newxPos, newyPos, newAngle)
global currentSubTask achievePos collectSnow command_X command_Y...
    command_Phi newCommand command_Index currentDisplay f_currentSubTask...
    serialConnection f_currentDisplay xPos yPos newStatus Phi GPS_X GPS_Y...
    GPS_Phi

%Display on the GUI the current sub task
if(~strcmp(currentSubTask,'Moving to Mt Simmons'))
    currentSubTask = 'Moving to Mt Simmons';
    set(f_currentSubTask, 'String', currentSubTask);
    newCommand = 1; %Set the position commands to the Robot
end

%Set the waypoints commands to the robot
if(newCommand == 1)
    %Call a function that outputs the commands to Go to
      %Mount Simmons through a way point
    %     command_X = [1.3];
    %     command_Y = [0.15];
    %     command_Phi = [0];
    command_X = [1.3];
    command_Y = [0.15];
    command_Phi = [90];
    
    command_Index = 0; %Start looking from the beginning of the Commands
    newCommand = 0; %Command set won't go back in that loop
    command_update = 0; %Send the command to Arduino
end

%If the position of the Robot has changed regarding its encoders update the
%waypoint to follow.
if (newStatus == 1)
    pause(0.1);
    if command_Index < length(command_X)
        command_Index = command_Index + 1;
        command_update = 1;
    else
       %GPScorrection();
       if(~strcmp(currentDisplay,'Reached Mt Simmons'))
            currentDisplay = 'Reached Mt Simmons';
            set(f_currentDisplay, 'String', currentDisplay);
        end
        achievePos = 1; %We arrived at the snow collection area
        collectSnow = 1; %Start Collecting Snow procedure
    end
end

%Send the new waypoint/command to the Arduino to follow
if  (command_update == 1)
    disp('command_sent');
    disp(command_Index);
    fwrite(serialConnection,num2str(command_X(command_Index)));
    fwrite(serialConnection,',');
    fwrite(serialConnection,num2str(command_Y(command_Index)));
    fwrite(serialConnection,',');
    fwrite(serialConnection,num2str(command_Phi(command_Index)));
    fwrite(serialConnection,',');
    fwrite(serialConnection,num2str(0));
    fwrite(serialConnection,',');
    fwrite(serialConnection,num2str(GPS_X));
    fwrite(serialConnection,',');
    fwrite(serialConnection,num2str(GPS_Y));
    fwrite(serialConnection,',');
    fwrite(serialConnection,num2str(GPS_Phi));
    fwrite(serialConnection,'\n');
    command_update = 0;
    pause(1);
end

end