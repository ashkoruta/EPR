function MoveToSnowTruck(newxPos, newyPos, newAngle)
global readyToDumpSnow command_X command_Y...
    command_Phi newCommand command_Index currentDisplay f_currentDisplay...
    serialConnection newStatus GPS_X GPS_Y GPS_Phi

%Set the waypoints commands to the robot
if(newCommand == 1)
    %Call a function that outputs the commands to Go to
    %Snow truck through a way point
    command_X = [1.2];
    command_Y = [0.15];
    command_Phi = [45];
    
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
        if(~strcmp(currentDisplay,'Reached Snow Dumping Point'))
            currentDisplay = 'Reached Snow Dumping Point';
            set(f_currentDisplay,'String',currentDisplay);
        end
        readyToDumpSnow = 1; %Start Filtering Motion to Dump Snow
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