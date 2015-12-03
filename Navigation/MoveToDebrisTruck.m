function MoveToDebrisTruck(newxPos, newyPos, newAngle)
global readyToDumpDebris collectSnow dumpDebris command_X command_Y...
    command_Phi newCommand command_Index currentDisplay f_currentDisplay...
    serialConnection newStatus

%Set the waypoints commands to the robot
if(newCommand == 1)
    %If no debris in the scoop go back Mt Simmons to scoop more snow else
    %go to the debris truck
    
    if(DetectDebris())
        %Call a function that outputs the commands to Go to
        %Snow truck through a way point
        command_X = [1.25];
        command_Y = [0.20];
        command_Phi = [-30];
        wayBack = 0; %variable to choose to go to debris truck or Mt Simmons
    else
        %Call a function that outputs the commands to Go to
        %Mount Simmons through a way point
        command_X = [1.3];
        command_Y = [0.15];
        command_Phi = [0];
        wayBack = 1;  %variable to choose to go to debris truck or Mt Simmons
        
        %Display on the GUI the state of the robot
        if(~strcmp(currentDisplay,'Going Back To Mt Simmons'))
            currentDisplay = 'Going Back To Mt Simmons';
            set(f_currentDisplay, 'String', currentDisplay);
        end
    end
    
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
        if(wayBack == 0)
            if(~strcmp(currentDisplay,'Reached Debris Dumping Point'))
                currentDisplay = 'Reached Debris Dumping Point';
                set(f_currentDisplay, 'String', currentDisplay);
            end
            readyToDumpDebris = 1; %Start Tilting Motion to Dump Debris
        else
            if(~strcmp(currentDisplay,'Reached Mt Simmons'))
                currentDisplay = 'Reached Mt Simmons';
                set(f_currentDisplay, 'String', currentDisplay);
            end
            collectSnow = 1; %Start Collecting Snow procedure
            dumpDebris = 0; %End Dump Debris Procedure
        end
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