function [ matches, best ] = matchLayer(daisyTemp,daisyTarg,pyramidLayer,point)

    %
    % DAISY INPUT
    %
    daisyLength=200;
    dimsTemp=size(daisyTemp); % template
    dimsTarg=size(daisyTarg); % frame
    
    regionPetals = 8;
    totalPetals = 25;
    petalRanges = [1 regionPetals+1; regionPetals+2 regionPetals*2+1; regionPetals*2+2 regionPetals*3+1];
    gradients = 8;
    
    padding = 0;
    spacings = [1 2 4];
    gridSpacing = 1;
    boundaryOffset = 16;
    
    if pyramidLayer > 0 then % else do descriptor matching
        gridSpacing = spacings(pyramidLayer);
    end
    
    daisyTemp = daisyTemp(1:dimsTemp(1),1:dimsTemp(2),:);
    daisyTarg = daisyTarg(1:dimsTarg(1)-padding,1:dimsTarg(2)-padding,:);
    
    totalMatchDistance = zeros([size(daisyTarg,1) / gridSpacing,size(daisyTarg,2) / gridSpacing]);
    matchDistance = zeros(size(totalMatchDistance));
    
    tic;
    
    %
    % Multiple template descriptors
    %
    %for templateRow = 1:size(daisyTemp,1)
    %    for templateCol = 1:size(daisyTemp,2)
    %allDistances = zeros(size(matchDistance));
    %allDistances = zeros([32*(size(daisyTemp,2)-30),size(matchDistance,1),size(matchDistance,2)]);
    %templateRow = 3*(size(daisyTemp,1)/4);
    %templateCol = round((size(daisyTemp,2)/11)*i);
    
    %
    % Single template descriptor
    %
    templateRow = point(1) - boundaryOffset;
    templateCol = point(2) - boundaryOffset;
    if pyramidLayer > 0
        descT = daisyTemp(templateRow,templateCol,(petalRanges(pyramidLevel,1)-1)*gradients+1:petalRanges(pyramidLevel,2)*gradients);
    else
        descT = daisyTemp(templateRow,templateCol,:);
    end

    for row = 1:size(daisyTarg,1) / gridSpacing
        for col = 1:size(daisyTarg,2) / gridSpacing
            if pyramidLayer > 0
                desc = daisyTarg((row-1)*gridSpacing+1,(col-1)*gridSpacing+1,(petalRanges(pyramidLevel,1)-1)*gradients+1:petalRanges(pyramidLevel,2)*gradients);
            else
                desc = daisyTarg(row,col,:);
            end
            matchDistance(row,col) = sum(abs(desc-descT)) / sum(descT);
        end
    end
    
    %
    %allDistances = allDistances + matchDistance./max(max(matchDistance));
    %allDistances((r-16)*size(daisyTemp,2)+c-16+1,:,:) = matchDistance./max(max(matchDistance));
    %
    
    matchDistance = matchDistance ./ max(max(matchDistance));
    perc=1-matchDistance;
    
    %
    %totalMatchDistance = totalMatchDistance+matchDistance;
    %
    
    toc;
    
%
% mark and show the high match rates on the RGB image as green
%          
%             places=find(perc>=0.8);
%             placeRows=(floor(places/size(perc,2))-1)*gridSpacing+1;
%             placeCols=(mod(places,size(perc,2))-1)*gridSpacing+1;
%             
%             img=imread('test-data/targets/frame-2627.png');
%             img=img(17:gridSpacing:17+543,17:gridSpacing:17+735,:);
%             img1=img(:,:,1);
%             img2=img(:,:,2);
%             img3=img(:,:,3);
%             img1(places)=0;
%             img2(places)=255;
%             img3(places)=0;
%             img(:,:,1)=img1;
%             img(:,:,2)=img2;
%             img(:,:,3)=img3;
%    
%             disp([templateRow,templateCol]);
%             f=figure(1); image(perc*50); set(f,'Position',[128,128,800,600]); saveas(f,'target-2627/pyramidMatch_PERC_descriptor.png','png');
%             f=figure(2); hist(perc); set(f,'Position',[128,128,800,600]); saveas(f,'target-2627/pyramidMatch_PERCHIST_descriptor.png','png');
%             f=figure(3); imshow(img); set(f,'Position',[128,128,800,600]); saveas(f,'target-2627/pyramidMatch_descriptor.png','png');
%             close all;
     
    matches = perc;
    %matches = allDistances;
    [mx,mxRows] = max(matches);
    [mx,mxCol] = max(mx);
    best = [mxRows(mxCol),mxCol,mx];
    
end