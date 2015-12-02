% 2.12 Dynamixel interface code
% Zack Bright - zbright@mit.edu
% Steven Keyes - srkeyes@mit.edu
% Oct. 2015
%
% This class represents a set of Dynamixel servos connected to the computer

classdef Dynamixels
    properties (Constant)
        % Dynamixel library constants
%         ERRBIT_VOLTAGE     = 1;
%         ERRBIT_ANGLE       = 2;
%         ERRBIT_OVERHEAT    = 4;
%         ERRBIT_RANGE       = 8;
%         ERRBIT_CHECKSUM    = 16;
%         ERRBIT_OVERLOAD    = 32;
%         ERRBIT_INSTRUCTION = 64;
        
        COMM_TXSUCCESS     = 0;
        COMM_RXSUCCESS     = 1;
        COMM_TXFAIL        = 2;
        COMM_RXFAIL        = 3;
        COMM_TXERROR       = 4;
        COMM_RXWAITING     = 5;
        COMM_RXTIMEOUT     = 6;
        COMM_RXCORRUPT     = 7;
                        
        % robot setup is as follows
        % top view:
        %      | - arm here
        %      tilt motor (id#4)
        % bottom left(id#3) - bottom right (id#1)
        % side view:
        % "back of right bottom motor" ---- tilt --- scoop
        BottomRightMotorId = 1;
        BottomLeftMotorId = 3;
        TiltMotorId = 4;
        % 1unit = 0.114rpm = 0.0019 1/s for rotational speed
        Wunit = 0.0019;
    end
    methods (Static)
        function res = wasSuccess()
            result = calllib('dynamixel','dxl_get_result');
            if result == Dynamixels.COMM_TXSUCCESS
                res = 1;
            elseif result == Dynamixels.COMM_RXSUCCESS
                res = 1;
            elseif result == Dynamixels.COMM_TXFAIL
                display('Serial sending error');
                res = 0;
            elseif result == Dynamixels.COMM_RXFAIL
                display('Serial receiving error');
                res = 0;
            elseif result == Dynamixels.COMM_TXERROR
                display('Instruction packet is wrong');
                res = 0;
            elseif result == Dynamixels.COMM_RXWAITING
                display('Waiting for smth');
                res = 0;
            elseif result == Dynamixels.COMM_RXTIMEOUT
                display('Not responding');
                res = 0;
            elseif result == Dynamixels.COMM_RXCORRUPT
                display('Bad packet');
                res = 0;
            end
        end
        function enableTorques()
            P_TORQUE_ENABLE = 24;
            calllib('dynamixel','dxl_write_word', Dynamixels.TiltMotorId, P_TORQUE_ENABLE, 1);
            calllib('dynamixel','dxl_write_word', Dynamixels.BottomLeftMotorId, P_TORQUE_ENABLE, 1);
            calllib('dynamixel','dxl_write_word', Dynamixels.BottomRightMotorId, P_TORQUE_ENABLE, 1);
        end
        % method to connect to the dongle and identify its servos
        % returns a list of the IDs of all the servos
        function res = connect(COM, Baud)
            loadlibrary('dynamixel','dynamixel.h')
            display('Library loaded');
            % 1 is success, 0 is failure in lib...
            % return negative values for any error goddamnit!
            res = -1 + calllib('dynamixel','dxl_initialize', COM, Baud);
            display('Dxl initialized. '); display(res);
        end
        function angle = angleFromPosition(Id, pos)
            motorAngle = (pos/4095)*2*pi;
            if Id == Dynamixels.BottomRightMotorId || Id == Dynamixels.BottomLeftMotorId
                angle = 3*pi/2 - motorAngle;
            else % tilt is different
                % if tilt motor faces us (looking from the right, see
                % above) tilt angle = motor - 184 (mechanical misalignment)
                % if the orientation of MX-64 is diff, then
                % angle = 184 - motor
                angle = motorAngle - 184*pi/180;
            end
        end
        function pos = positionFromAngle(Id, angle)
            % motor angle is different from kinematic one because of
            % physical setup
            if Id == Dynamixels.BottomRightMotorId || Id == Dynamixels.BottomLeftMotorId
                motor = 3*pi()/2 - angle;
            else
                motor = angle + 184*pi/180;
            end
            % convert angle in radians to angle in Dynamixel values (0-4095)
            pos = round(motor * 4095 / (2*pi));
        end
        function res = isValidAngle(Id, angle)
            res = 1;
            if Id == Dynamixels.BottomRightMotorId
                if angle <= 0 || angle >= pi
                    res = 0;
                    display('E-Dyn: Check your values');
                    disp(Id); disp(angle);
                    return;
                end
            elseif Id == Dynamixels.BottomLeftMotorId
                if angle <= -pi/2 || angle >= pi/2
                    res = 0;
                    display('E-Dyn: Check your values');
                    disp(Id); disp(angle);
                    return;
                end
            else % tilt motor
                % VERY IMPORTANT - CAN BREAK MOTOR IF VIOLATE THIS
                if angle <= -(pi - 54*pi/180) || angle >= 135*pi/180
                    res = 0;
                    display('E-Dyn: Check your values');
                    disp(Id); disp(angle);
                    return;
                end
            end
        end
        % set the position of a single servo -- range 0 to 4095, centered
        % at 2047
        function res = setGoalAngle(Id, angle)
            % check that angle is valid
            res = 0;
            if ~Dynamixels.isValidAngle(Id, angle)
                display('E-Dyn: wrong angle fed');
                res = -1;
                return;
            end
            Pos = Dynamixels.positionFromAngle(Id, angle);
            % this is the Register on the Servo that corresponds to the goal pos
            P_GOAL_POSITION = 30;
            % write it
            calllib('dynamixel','dxl_write_word', Id, P_GOAL_POSITION, Pos);
        end
        function res = setGoalSpeed(Id, speed)
            res = 0;
            units = speed / Dynamixels.Wunit;
            if units > 600 % constrain the speed to safe 1 rps
                display('E-Speed: value too large');
                res = -1;
                return;
            end
            P_GOAL_SPEED = 32;
            calllib('dynamixel','dxl_write_word', Id, P_GOAL_SPEED, units);
        end
        function pos = getCurrentPosition(Id)
            % this is the Register on the Servo that corresponds to the current pos
            P_CURRENT_POSITION = 36;
            % read it
            pos = calllib('dynamixel','dxl_read_word', Id, P_CURRENT_POSITION);
        end
        function angle = getCurrentAngle(Id)
            pos = Dynamixels.getCurrentPosition(Id);
            angle = Dynamixels.angleFromPosition(Id, pos);
        end
        function res = isMoving(Id)
            % determine if motor is moving right now
            P_MOVING = 46;
            res = calllib('dynamixel','dxl_read_word', Id, P_MOVING);
        end
        function res = areMoving()
            if Dynamixels.isMoving(Dynamixels.BottomRightMotorId)
                res = 1;
                return;
            end
            if Dynamixels.isMoving(Dynamixels.BottomLeftMotorId)
                res = 1;
                return;
            end
            res = 0;
        end
        function res = setArmConfig(ac)
            [t1, t2, tilt, w1, w2, wtilt] = ac.getConfig();
            % adjust the tilt first
            res = 0;
            Dynamixels.setGoalSpeed(Dynamixels.TiltMotorId, wtilt);
            if res < 0 || ~Dynamixels.wasSuccess()
                display('E-Dyn: tilt motor failure');
                res = -1;
                return;
            end
            Dynamixels.setGoalAngle(Dynamixels.TiltMotorId, tilt);
            if res < 0 || ~Dynamixels.wasSuccess()
                display('E-Dyn: tilt motor failure');
                res = -1;
                return;
            end
            % set the speeds for motors
            res = Dynamixels.setGoalSpeed(Dynamixels.BottomRightMotorId, w1);
            if res < 0 || ~Dynamixels.wasSuccess()
                display('E-Dyn: bottom right motor speed failure');
                res = -1;
                return;
            end
            res = Dynamixels.setGoalSpeed(Dynamixels.BottomLeftMotorId, w2);
            if res < 0 || ~Dynamixels.wasSuccess()
                display('E-Dyn: bottom left motor speed failure');
                res = -1;
                return;
            end
            % and then positions
            res = Dynamixels.setGoalAngle(Dynamixels.BottomRightMotorId, t1);
            if res < 0 || ~Dynamixels.wasSuccess()
                display('E-Dyn: bottom right motor failure');
                res = -1;
                return;
            end
            res = Dynamixels.setGoalAngle(Dynamixels.BottomLeftMotorId, t2);
            if res < 0 || ~Dynamixels.wasSuccess()
                display('E-Dyn: bottom left motor failure');
                res = -1;
                return;
            end
        end
        function ac = getArmConfig()
            th1 = Dynamixels.getCurrentAngle(Dynamixels.BottomRightMotorId);
            th2 = Dynamixels.getCurrentAngle(Dynamixels.BottomLeftMotorId);
            phi = Dynamixels.getCurrentAngle(Dynamixels.TiltMotorId);
            ac = ArmConfiguration(th1, th2, phi);
        end
        function disconnect()
            calllib('dynamixel','dxl_terminate');
            unloadlibrary('dynamixel');
        end    
end
end