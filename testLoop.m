function testLoop(ak, d)
while 1
    mode = input('Do you want to use inverse kinematics? Y/N/Q ', 's');
    if mode == 'Y' || mode == 'y'
        x = input('x:');
        y = input('y:');
        moveXY(ak, x, y);
    elseif mode == 'Q' || mode == 'q'
        break; % end the loop
    else
        th1 = input('theta1,deg:');
        th1 = th1*pi()/180; % convert to radians
        th2 = input('theta2,deg:');
        th2 = th2*pi()/180;
        phi = input('tilt,deg:');
        phi = phi*pi/180;
        ac = ArmConfiguration(th1, th2, phi);
        ac.w1 = 0.08;
        ac.w2 = 0.08;
        ac.wtilt = 0.08;
        res = d.setArmConfig(ac);
        if res < 0
            display('ERROR: motor command error');
            continue;
        end
    end
end
display('Dont forget to check errors');
Dynamixels.disconnect();
display('See ya!');
end

