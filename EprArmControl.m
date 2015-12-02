L1 = 220; % the longest link of 4-bar linkage
L2 = 210; % the length of second link from 4-bar linkage tip to scoop attachment
% ... all other constants should go here

%% initialiaze the motors and whole communication
%unloadlibrary('dynamixel'); % possible leftovers from previous runs
diary arm.log; % start the logging
COM = 8;
res = Dynamixels.connect(COM, 4);
if res < 0
    error('Cant connect to dynamixels');
end
Dynamixels.enableTorques();
if ~Dynamixels.wasSuccess()
    error('Torque enable failure');
end
Kinematics = ArmKinematics(L1, L2); % initialize the object for deriving arm kinematics

%%
testLoop(Kinematics, Dynamixels)
















