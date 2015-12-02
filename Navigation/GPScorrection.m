function GPScorrection()
global command_X command_Y command_Phi s1 GPS_X GPS_Y GPS_Phi...
    command_Index serialConnection
disp('GPScorrection');

%         [GPS_X, GPS_Y, GPS_Phi, timestamp] = getVals(s1);
%
%         A=GPS_X;
%
%         GPS_X = GPS_Y + 1.15;
%         GPS_Y = -A + 1.73;
%         GPS_Phi = GPS_Phi*180/pi -90;
GPS_X = 0.50;
GPS_Y = 0.15;
GPS_Phi = 50;

fwrite(serialConnection,num2str(command_X(command_Index)));
fwrite(serialConnection,',');
fwrite(serialConnection,num2str(command_Y(command_Index)));
fwrite(serialConnection,',');
fwrite(serialConnection,num2str(command_Phi(command_Index)));
fwrite(serialConnection,',');
fwrite(serialConnection,num2str(1));
fwrite(serialConnection,',');
fwrite(serialConnection,num2str(GPS_X));
fwrite(serialConnection,',');
fwrite(serialConnection,num2str(GPS_Y));
fwrite(serialConnection,',');
fwrite(serialConnection,num2str(GPS_Phi));
fwrite(serialConnection,'\n');

disp('GPS correction sent');
end