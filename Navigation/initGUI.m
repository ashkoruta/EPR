function initGUI
global f f_manual f_automatic f_title f_robotPosTable f_BoardMap f_Video...
    f_textTask f_currentTask f_textRobotPos f_textLibrary f_dismantle ...
    f_controlPanel f_taskPanel f_snowCollection f_dumpsnow ...
    f_dumpdebris f_clearTree f_releaseTree f_liftTree f_clearRoof ...
    f_boardPanel f_textSubTask f_currentSubTask ...
    f_GPScorrection currentPos currentTask currentSubTask counter mode Ctask...
    command_Index countCollectSnow f_textDisplay f_currentDisplay ...
    currentDisplay xPos yPos Phi serialConnection serialData xPosInit yPosInit PhiInit...
    GPS_X GPS_Y GPS_Phi s1 achievePosMt collectSnow dumpSnow dumpDebris achievePosTree...
    dumpTree removeTree achievePosRoof clearRoofLeft f_clearRoofRight f_clearRoofLeft...
    clearRoofRight

delete(instrfind);
%Try starting a serial connection with the Arduino
try
    serialConnection = serial('COM4');  %Use Arduino IDE to see which com port the Arduino UNO is using
    set(serialConnection, 'BaudRate', 115200); %Set the baud rate on the computer and Arduino to be the same
    fopen(serialConnection); %Try opening the serial connection
    display('Successfully connected to Arduino over Serial!');
    pause(1); %Wait for the Arduino to resete
    flushinput(serialConnection);  %Throw away the startup gibberish
    
    %If connecting over Serial throws an error, this catch section will run
catch
    %Tell the user that Serial did not work
    display('Serial connection could not be established. Make sure the Arduino is plugged in and on the right port (check in Arduino IDE).');
    return; %Quit the program
end


%Flush the serial buffer before starting the infinite loop
flushinput(serialConnection);
%Read and discard any incomplete line
incompleteRead = fscanf(serialConnection, '%s');
%Initialize serialData
serialData = '';

%  Create and then hide the UI as it is being constructed.
f = figure('Visible','off','Position',[250,50,1100,700]);
set(f,'toolbar','none');
set(f,'MenuBar','None');


%  Construct the components.

%Building the title and the two figures
f_title = uicontrol('Style','text','String','EPR Team',...
    'FontSize',14,'FontWeight','bold','Position',[500,660,100,30]);
f_BoardMap = axes('Units','Pixels','Position',[30,190,600,500]);
f_Video = axes('Units','Pixels','Position',[600,220,500,450]);

%Building the panel for Robot feedback
f_boardPanel = uipanel('Title','','Position',[.03 .02 .28 .28]);
f_textTask = uicontrol('Parent',f_boardPanel,'Style','text','String',...
    'Current Task : ','FontSize',10,'Position',[20,150,60,40]);
f_currentTask = uicontrol('Parent',f_boardPanel,'Style','text','String',currentTask,...
    'FontSize',11,'ForegroundColor','b','Position',[80,160,200,20]);
f_textSubTask = uicontrol('Parent',f_boardPanel,'Style','text','String',...
    'Current SubTask : ','FontSize',10,'Position',[10,105,80,40]);
f_currentSubTask = uicontrol('Parent',f_boardPanel,'Style','text','String',currentSubTask,...
    'FontSize',11,'ForegroundColor','r','Position',[80,115,200,20]);
f_textDisplay = uicontrol('Parent',f_boardPanel,'Style','text','String',...
    'Robot Feedback : ','FontSize',10,'Position',[10,60,80,40]);
f_currentDisplay = uicontrol('Parent',f_boardPanel,'Style','text','String',currentDisplay,...
    'FontSize',11,'ForegroundColor','k','Position',[80,70,200,20]);
f_textRobotPos = uicontrol('Parent',f_boardPanel,'Style','text','String',...
    'Robot Position :','FontSize',10,'Position',[10,15,80,40]);
f_robotPosTable = uitable(f,'Parent',f_boardPanel,'Data',currentPos,...
    'ColumnName',{'X (m)','Y(m)','Phi(deg)'},...
    'RowName',[],...
    'Position',[90,10,182,55]);

%Building the panel for Task Scheduling
f_taskPanel = uipanel('Title','','Position',[.32 .02 .50 .28]);
f_textLibrary = uicontrol('Parent',f_taskPanel,'Style','text','String','Task Library ',...
    'FontSize',12,'Position',[200,170,120,20]);
f_dismantle = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'Dismantle Mt Simmons','Position',[30,120,140,40],...
    'Callback',{@f_dismantle_Callback});
f_snowCollection = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'Collect Snow','Position',[200,130,80,20],...
    'Callback',{@f_collectSnow_Callback});
f_dumpsnow = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'DumpSnow','Position',[300,130,80,20],...
    'Callback',{@f_dumpSnow_Callback});
f_dumpdebris = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'DumpDebris','Position',[400,130,80,20],...
    'Callback',{@f_dumpDebris_Callback});

f_clearTree = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'Clear Tree','Position',[30,70,140,40],...
    'Callback',{@f_clearTree_Callback});
f_liftTree = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'Lift Tree','Position',[200,80,80,20],...
    'Callback',{@f_liftTree_Callback});
f_releaseTree = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'Release Tree','Position',[300,80,80,20],...
    'Callback',{@f_releaseTree_Callback});

f_clearRoof = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'Clear Roof','Position',[30,20,140,40],...
    'Callback',{@f_clearRoof_Callback});
f_clearRoofLeft = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'Clear Roof Left','Position',[200,30,80,20],...
    'Callback',{@f_clearRoofLeft_Callback});
f_clearRoofRight = uicontrol('Parent',f_taskPanel,'Style','pushbutton','String',...
    'Clear Roof Right','Position',[300,30,80,20],...
    'Callback',{@f_clearRoofRight_Callback});

%Building the panel for robot control
f_controlPanel = uipanel('Title','','Position',[.83 .02 .15 .28]);
f_manual = uicontrol('Parent',f_controlPanel,'Style','pushbutton','String',...
    'Manual','Position',[30,145,100,40],...
    'Callback',{@f_manual_Callback});
f_automatic = uicontrol('Parent',f_controlPanel,'Style','pushbutton','String'...
    ,'Automatic','Position',[30,80,100,40],...
    'Callback',{@f_automatic_Callback});
f_GPScorrection = uicontrol('Parent',f_controlPanel,'Style','pushbutton','String'...
    ,'GPScorrection','Position',[30,15,100,40],...
    'Callback',{@f_GPScorrection_Callback});

set([f,f_manual,f_automatic,f_title,f_robotPosTable,f_BoardMap,f_Video,...
    f_textTask,f_currentTask,f_textRobotPos,f_textLibrary,f_dismantle,...
    f_controlPanel,f_taskPanel,f_snowCollection,f_dumpsnow,...
    f_dumpdebris,f_clearTree,f_releaseTree,f_liftTree,f_clearRoof,...
    f_clearRoofLeft,f_clearRoofRight,f_boardPanel,f_textSubTask,f_currentSubTask,...
    f_GPScorrection,f_textDisplay,f_currentDisplay],'Units','normalized');





    function f_manual_Callback(source,eventdata)
        disp('manual');
        mode = 'manual';
        try
            set(f,'KeyPressFcn',@keypressfcn)
            disp('it worked?')
        catch
            disp('it did not work')
        end
        
    end

    function f_automatic_Callback(source,eventdata)
        disp('automatic');
        mode = 'automatic';
    end

    function f_GPScorrection_Callback(source,eventdata)
        global command_X command_Y command_Phi
        disp('GPScorrection');
        if(~strcmp(currentSubTask,'Correting GPS'))
            currentSubTask = 'Correting GPS';
            set(f_currentSubTask, 'String', currentSubTask);
        end
        
%         [GPS_X, GPS_Y, GPS_Phi, timestamp] = getVals(s1);
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

    function f_dismantle_Callback(source,eventdata)
        disp('dismantle');
        Ctask = 1;
        achievePosMt = 0;
    end

    function f_collectSnow_Callback(source,eventdata)
        disp('collectSnow');
        Ctask = 1;
        achievePosMt = 1;
        collectSnow = 1;
    end

    function f_dumpSnow_Callback(source,eventdata)
        disp('dumpSnow');
        Ctask = 1;
        achievePosMt = 1;
        dumpSnow = 1;
    end

    function f_dumpDebris_Callback(source,eventdata)
        disp('dumpDebris');
        Ctask = 1;
        achievePosMt = 1;
        dumpDebris = 1;
    end

    function f_clearTree_Callback(source,eventdata)
        disp('clearTree');
        Ctask = 2;
    end

    function f_liftTree_Callback(source,eventdata)
        disp('liftTree');
        Ctask = 2;
        achievePosTree = 1;
        removeTree = 1;
    end

    function f_releaseTree_Callback(source,eventdata)
        disp('releaseTree');
        Ctask = 2;
        achievePosTree = 1;
        dumpTree = 1;
    end

    function f_clearRoof_Callback(source,eventdata)
        disp('clearRoof');
        Ctask = 3;
    end

    function f_clearRoofLeft_Callback(source,eventdata)
        disp('clearRoofLeft');
        Ctask = 3;
        achievePosRoof = 1;
        clearRoofLeft = 1;
        clearRoofRight = 0;
    end

    function f_clearRoofRight_Callback(source,eventdata)
        disp('clearRoofRight');
        Ctask = 3;
        achievePosRoof = 1;
        clearRoofLeft = 0;
        clearRoofRight = 1;
    end

    function keypressfcn(varargin)
        global command_X command_Y command_Phi
        key = get(gcbf,'CurrentKey');
        k = .3;
        switch key
            case'uparrow'
                command_X = xPos(end) +k*cos((Phi(end))*pi/180);
                command_Y = yPos(end) +k*sin((Phi(end))*pi/180);
                disp('uparrow')
                fwrite(serialConnection,num2str(command_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Phi));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(0));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Phi));
                fwrite(serialConnection,'\n');
                
                
                
            case'downarrow'
                command_X = xPos(end) -k*cos((Phi(end))*pi/180);
                command_Y = yPos(end) -k*sin((Phi(end))*pi/180);
                disp('downarrow')
                fwrite(serialConnection,num2str(command_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Phi));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(0));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Phi));
                fwrite(serialConnection,'\n');
                
                
            case 'leftarrow'
                disp('leftarrow')
                command_Phi = Phi(end) + 45;
                fwrite(serialConnection,num2str(command_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Phi));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(0));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Phi));
                fwrite(serialConnection,'\n');
                
                
            case 'rightarrow'
                disp('rightarrow')
                command_Phi = Phi(end) - 45;
                fwrite(serialConnection,num2str(command_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Phi));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(0));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Phi));
                fwrite(serialConnection,'\n');
            case 'r'
                disp('turnaround')
                command_Phi = Phi(end) - 180;
                fwrite(serialConnection,num2str(command_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Phi));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(0));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Phi));
                fwrite(serialConnection,'\n');
                
            case 'p'
                disp('90 turn positive')
                command_Phi = Phi(end) + 90;
                fwrite(serialConnection,num2str(command_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(command_Phi));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(0));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_X));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Y));
                fwrite(serialConnection,',');
                fwrite(serialConnection,num2str(GPS_Phi));
                fwrite(serialConnection,'\n');
        end
        
    end
end