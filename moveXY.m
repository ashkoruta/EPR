function res = moveXY(ak, xd, yd)
    if ~ak.inWorkspace(xd, yd)
        res = -1;
        display('E-Kin: not in workspace');
        return;
    end
    [th1, th2, tilt, res] = ak.findThetas(xd,yd);
    if res < 0
        display('E-Kin: cant proceed with straight movement');
        return;
    end
    % No need to control speed. It doesn't work anyway
    % Use constant angular speed instead. It's rather smooth and pretty
    % straight (pieces of circles are pretty straight for our link lengths 
    % relative to distance travelled in XY plane
    w1 = 0.08; 
    w2 = 0.08; 
    wtilt = 0.08;
    % TODO choose the speeds
    acNew = ArmConfiguration(th1, th2, tilt);
    acNew.w1 = w1;
    acNew.w2 = w2;
    acNew.wtilt = wtilt;
    res = Dynamixels.setArmConfig(acNew);
    if res < 0
        Display('E-Dyn: arm config setup failed');
        return;
    end
end


