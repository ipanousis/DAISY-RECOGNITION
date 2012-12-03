function [results] = rotscale(rot,scale)

%
% Function to test rotation and scale capability of DAISY
%
% Tests will use 5 points on the image and measure the
% matching rate.
%
% 1) Rotation
% - will show match rate wrt. rot difference between template and target
%
% 2) Scale
%
% - will show match rate wrt. scale difference between template and target
% - have to do 2 scenarios; one across scales using a smallest scaled
% template (256x)
% - and one using the largest scaled template (1280x)
%
% Then maybe a matrix of these tests can be done.
%
% Conclusions from these tests will include scale-rotation capability
% of the DAISY descriptor which will indicate what granularity may be
% required to use for the matching between template and target when
% searching. This may determine the set of configurations to test for.
% Depending on the degree of variation in match rate between different
% settings of template and target.
%

% rotation
%
% picked points from rotation = 0: 
%
if rot

    points = [[91,214];[203,521];[543,399];[434,71];[139,210]];

    template = 'test-data/rot-scale/sscasino-rot-000.0.png';
    templateSize = [576,640];
    templateD = loadDaisy(template,templateSize);

    angleDiff = 22.5;
    targetName = 'test-data/rot-scale/sscasino-rot-%05.1f.png';
    targetSizes = [[576,640];[777,812];[860,860];[812,777];[640,576];[812,777];[860,860];[777,812];[576,640];[777,812];[860,860];[812,777];[640,576];[812,777];[860,860]];

    rotationMatchRates = zeros([size(points,1),4]);

    for rot=0:7
        thisAngle = angleDiff * rot;
        target = sprintf(targetName,thisAngle);
        disp(target);
        targetSize = targetSizes(rot+1,:);
        targetD = loadDaisy(target,targetSize);

        for p=1:size(points,1)

            point = points(p,:);

            %
            % match the points
            % get match rate = make sure the match is the correct one and then get
            % the match rate for it (the perc wrt all points)
            %

            [matches best] = matchLayer(templateD,targetD,0,point);

            figure,imshow(matches)

            rotationMatchRates(p,:) = [point thisAngle matchRate];

        end
    end

    save('rotationResults.mat','rotationMatchRates');
end
    

% scale
%
% 2 scenarios
%
if scale
    
    points = [[91,214];[203,521];[543,399];[434,71];[139,210]];
    pointsA = round(points * (256/640));  % because points are from 640x576
    pointsB = round(points * (1280/640));

    templateA = 'test-data/rot-scale/scasino-scale-0256.png';
    templateB = 'test-data/rot-scale/scasino-scale-1280.png';
    templateSize = [576,640];
    templateA = loadDaisy(templateA,[230 256]);
    templateB = loadDaisy(templateB,[1152 1280]);

    scaleDiff = 128;
    targetName = 'test-data/rot-scale/scasino-scale-%04d.png';

    scaleMatchRatesA = zeros([size(points,1),4]);
    scaleMatchRatesB = zeros([size(points,1),4]);

    for scale=1:9

        thisScale = 256 + (scale-1) * scaleDiff;
        target = sprintf(targetName,thisScale);
        targetSize = [round(1152 * (thisScale/1280)),thisScale];
        targetD = loadDaisy(target,targetSize);

        for p=1:size(points,1)

            pointA = pointsA(p,:);
            pointB = pointsB(p,:);

            %
            % match the points
            % get match rate = make sure the match is the correct one and then get
            % the match rate for it (the perc wrt all points)
            %

            [matches best] = matchLayer(templateA,targetD,0,pointA);

            scaleMatchRatesA(p,:) = [point thisScale best(3)];

            [matches best] = matchLayer(templateB,targetD,0,pointB);

            figure,imshow(matches)

            scaleMatchRatesB(p,:) = [point thisScale best(3)];

        end
    end
    
    save('scaleMatchRates.mat','scaleMatchRatesA','scaleMatchRatesB');
end


end