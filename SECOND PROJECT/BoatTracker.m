close all, clear all;

video = VideoReader('movie\2015-04-22-18-22-35_tase.avi');
frame_start = 9680;
frame_end = 10940;
total_frames = frame_end - frame_start;

frame = frame_start;
step = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These thresholds are "created" by us manually thru experimentation
% current best values are [90 20]

% minimum value for a pixel to be active (we assume the boat is white, so this value shouldn't be low)
Tm = 90; 
% difference between MAX and MIN: we assume the boat is white so this value should be "small"
Td = 20; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dilate_strel = strel('disk', 5);
blob_max_area = 900;
isolation_threshold = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initializing_buffer = true;
frame_count = 1;
blobs_buffer = cell(1,10);
distance_interval = 30;
area_interval = 80;
validity_threshold = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PLEASE NOTE THAT ALL RGB VALUES ARE IN [0, 255] RANGE!

figure;

% FOR EACH FRAME
while(frame < frame_end)
    % GET THE FRAME
    img = read(video, frame);
    [height, width, nChannels] = size(img);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%-------------- VESSEL DETECTION --------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ACTIVE PIXEL BINARIZATION

    % GET EACH CHANNEL
    img_R = img(:,:,1);
    img_G = img(:,:,2);
    img_B = img(:,:,3);
    
    % INITIALIZE BW IMAGE
    BW = zeros(height, width);
    
    % FOR EACH PIXEL
    for x=1:height
        for y=1:width
            % GET THE HIGHEST AND LOWEST VALUE OF ALL COMPONENTS
            R = img_R(x,y); G = img_G(x,y); B = img_B(x,y);
            max_c = max([R,G,B]);
            min_c = min([R,G,B]);
            
            % IF CONDITION IS SATISFIED PIXEL IS ACTIVE ( = 1)
            if( max_c > Tm && (max_c - min_c) < Td)
                BW(x,y) = 1;
            end
            
        end
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%--------------- SPATIAL VALIDATION ---------------%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % REMOVE BIG BLOBS

    BW = imdilate(BW, dilate_strel); 
    
    [lb num] = bwlabel(BW);
    
    blobs_props = regionprops(lb,'Centroid', 'Area', 'FilledImage');
    blobs_count = size(blobs_props, 1);
    
    
    
    blob_indices = find([blobs_props.Area] < blob_max_area);
    
    BW_culled = zeros(size(BW));
    BW_aux = zeros(size(BW));
  
    for n = 1:size(blob_indices,2)
        BW_aux = zeros(size(BW));
        BW_aux = BW_aux + (lb == blob_indices(n));
        BW_culled = BW_culled + BW_aux;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % REMOVE BLOBS THAT TOUCH BOUNDARIES
    
    BW_cleared = imclearborder(BW_culled);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % SHOW ONLY ISOLATED BLOBS
    
    [lb num] = bwlabel(BW_cleared);
    blobs_props = regionprops(lb, 'Centroid');
    blobs_count = size(blobs_props, 1);
    
    isolated_blobs = []; % contains indices
    
    % for each blob...
    for n=1:blobs_count
        dist = realmax; % start with distance = infinity
        for i=1:blobs_count
            if(n ~= i)
                points = [blobs_props(n).Centroid(1), blobs_props(n).Centroid(2); blobs_props(i).Centroid(1), blobs_props(i).Centroid(2)];
                dist_aux = pdist(points, 'euclidean');
                
                % replace dist if it's smaller than the current one
                if(dist_aux < dist)
                    dist = dist_aux;
                end
            end
        end
        
        if(dist > isolation_threshold)
            isolated_blobs = [isolated_blobs ; n];
        end
        
    end
    
    isolated_blobs = transpose(isolated_blobs);
    
    BW_spatial = zeros(size(BW_cleared));
    BW_aux = zeros(size(BW_cleared));
  
    for n = 1:size(isolated_blobs,2)
        BW_aux = zeros(size(BW_cleared));
        BW_aux = BW_aux + (lb == isolated_blobs(n));
        BW_spatial = BW_spatial + BW_aux;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%--------------- TEMPORAL VALIDATION ---------------%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% As a start, we'll store the past 10 frames
% To conclude that it's indeed the same blob, we'll simply check if the
% centroid is more or less the same and if the area is more or less the
% same

% ALGORITHM
%
% if not 10 frames passed
%   store this frame (centroid and area)
%   continue;
%
% else
%
% for each past frame
%
% for all blobs of current frame
%   for all blobs of past frame
%       if both blobs' centroids are near
%           if similar area
%               increment counter (for that blob)

% if counter > threshold
%   accept blob
%
% remove oldest frame
% store this frame
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [lb num] = bwlabel(BW_spatial);
    blobs_props = regionprops(lb, 'Centroid', 'Area');
    blobs_count = size(blobs_props, 1);
    
    aux_buffer = zeros(0,3);

    % IF WE DONT HAVE 10 FRAMES TO WORK WITH, START COLLECTING UNTIL WE
    % HAVE 10 STORED
    if(initializing_buffer)
        for n=1:blobs_count
            blob_stats = [blobs_props(n).Centroid(1), blobs_props(n).Centroid(2), blobs_props(n).Area];
            aux_buffer = cat(1, aux_buffer, blob_stats);
        end
        blobs_buffer{1,frame_count} = aux_buffer;
        if(frame_count < 10)
            frame_count = frame_count + 1;
        else
            initializing_buffer = false;
        end
        
        % SHOW BW
        imshow(BW_spatial);
        drawnow;
        
    % IF WE DO HAVE 10 STORED FRAMES, START DOING TEMPORAL VALIDATION
    else
        blob_validities = zeros(1,blobs_count);
        for f=1:10
            for b = 1:blobs_count
                past_blobs_count = size((blobs_buffer{1,f}),1);
                for p = 1:past_blobs_count
                    % if centroids are near...
                    points = [blobs_props(b).Centroid(1), blobs_props(b).Centroid(2); blobs_buffer{1,f}(p,1), blobs_buffer{1,f}(p,2)];
                    dist = pdist(points, 'euclidean');
                    if(dist <= distance_interval)
                        area_current = blobs_props(b).Area;
                        area_past = blobs_buffer{1,f}(p,3);
                        area_diff = abs(area_current - area_past);
                        if(area_diff <= area_interval)
                            blob_validities(1,b) = blob_validities(1,b) + 1;
                        end
                    end
                end
            end
        end
        
        % if blob validity > D
        valid_blobs = [];
        for b = 1:blobs_count
            if(blob_validities(1,b) >= 5)
                valid_blobs = [valid_blobs ; b];
            end
        end
        
        BW_final = zeros(size(BW_spatial));
        BW_aux = zeros(size(BW_spatial));
        
        for n = 1:size(valid_blobs,1)
            BW_aux = zeros(size(BW_spatial));
            BW_aux = BW_aux + (lb == valid_blobs(n));
            BW_final = BW_final + BW_aux;
        end
        
        [lb num] = bwlabel(BW_final);
        final_props = regionprops(lb, 'BoundingBox');
        
        % SHOW BW
        imshow(BW_final);
        for i = 1:size(final_props,1)
            rectangle('Position', final_props(i).BoundingBox, 'EdgeColor', 'y');
        end
        drawnow;
        
        % REMOVE OLDEST
        blobs_buffer(:,1) = [];
        % ADD NEWEST
        new_cell = cell(1);
        for n=1:blobs_count
            blob_stats = [blobs_props(n).Centroid(1), blobs_props(n).Centroid(2), blobs_props(n).Area];
            aux_buffer = cat(1, aux_buffer, blob_stats);
        end
        new_cell{1,1} = aux_buffer;
        blobs_buffer = horzcat(blobs_buffer, new_cell);
    end
    
    
    frame = frame + step;
end







