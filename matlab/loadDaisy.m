function [data] = loadDaisy(img,opt1)
    daisyLength = 200;
    
    if nargin > 1
        dims = opt1;
    else
        dims = [640,832];
    end
    
    pddims = dims;
    disp(pddims);

    d1=fopen(strcat(img,'.bdaisy'),'rb');
    fread(d1,[4],'float32');

    boundaryOffset = 0; % 15 + 1 so to take away multiple of 4
    
    Daisy1=fread(d1,[pddims(1),pddims(2) * daisyLength],'float32');
    data=zeros(pddims(1)-boundaryOffset*2,pddims(2)-boundaryOffset*2,daisyLength);
    
    for r=1:size(data,1)
       for c=1:size(data,2)
          offset=(r-1+boundaryOffset)*pddims(2)*daisyLength+(c-1+boundaryOffset)*daisyLength+1;
          data(r,c,:)=Daisy1(offset:offset+daisyLength-1);
       end
    end
end
