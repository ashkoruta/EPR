function DumpSnow()
global readyToDumpSnow dumpSnow dumpDebris

% if(newScoopCommand == 1)
%     CommandScoop(); %Give the position of the scoop regarding the TruckPosition
%     newScoopCommand = 0;
% end
% ReachPositionDump();
% if(reachedPositionDump == 1)
%     if(FilterOpen == 0)
%         ReleaseFilter();
%     end
%     CommandShake(shakercount); %Give the shaking order
%     if(shakerCount>3)
%         reachedPositionDump = 0;
%     end
% end
% ShakeScoop();
% if(shakerCount>3 && shakingDone == 1)
disp('Open Scoop');
fwrite(serialConnection,'O');
fwrite(serialConnection,'\n');
pause(5);

readyToDumpSnow = 0;
dumpSnow = 0;
dumpDebris = 1;
% end
end

