% loading video into project
video=VideoReader('Q1.People Walking Free Stock Footage, Royalty-Free No Copyright Content.mp4');
vidPlayer = vision.DeployableVideoPlayer;

% enabling people detector with YOLOv2 as well as multi-object tracker
pplDetect = yolov2ObjectDetector('tiny-yolov2-coco');

tracker = multiObjectTracker( ...
    'FilterInitializationFcn', @initcvkf, ...
    'AssignmentThreshold', 30, ...
    'ConfirmationThreshold', [3 5]);

% enablish tracking IDs
nextID=1;
pplCount=0;
idSet=[];
gpuDevice(1); % selecting my gpu

frameIndex = 0; % Add frame counter for proper time tracking

while hasFrame(video)
    frame=readFrame(video);
    frameIndex = frameIndex + 1;
    
    % detecting people with YOLO
    [bbox, scores, ~] = detect(pplDetect, frame, ...
                                    'ExecutionEnvironment', 'gpu', 'Threshold', 0.5);

    % converting to using object detection 
    detections=[];
    for i =1:size(bbox,1)
        %use centroid of bbox
        centroid=[bbox(i,1)+bbox(i,3)/2, bbox(i,2)+bbox(i,4)/2];
        detections{i}=objectDetection(frameIndex, centroid);
    end

    % updating the tracker
    confTracks = updateTracks(tracker, detections, frameIndex);

    % assign IDs and count to confirmed tracks and create proper annotations
    if ~isempty(confTracks)
        trackedBboxes=zeros(numel(confTracks),4);
        trackedLabels=strings(numel(confTracks),1);

        for i=1:numel(confTracks)
            trackID=confTracks(i).TrackID;

            %count the new IDs only one time
            if ~ismember(trackID, idSet)
                idSet(end+1)=trackID;
                pplCount=pplCount+1;
            end
            % fetch the state estimate for bounding box
            centroid=confTracks(i).State([1,3]) % this is the x and y position


            % locate the closets detection to get bbox dimensions
            if ~isempty(bbox)
                distances = zeros(size(bbox,1),1);
                for j=1:size(bbox,1)
                    detCentroid=[bbox(j,1)+bbox(j,3)/2, bbox(j,2)+bbox(j,4)/2];
                    distances(j)=norm(centroid-detCentroid);
                end
                [~, closestIdx]=min(distances);

                % use dimensions to center on tracked position
                width=bbox(closestIdx,3);
                height=bbox(closestIdx,4);
                trackedBboxes(i,:)=[centroid(1)-width/2, centroid(2)-height/2, width, height];
            else
                % default the size of bbox if no detections available
                trackedBboxes(i,:)=[centroid(1)-25, centroid(2)-50, 50, 100];
            end

            trackedLabels(i)=sprintf('ID %d', trackID);
        end

        % anontate with the tracked bboxes and labels
        frame=insertObjectAnnotation(frame, 'rectangle', trackedBboxes, trackedLabels);
    end

    % adding total count
    frame=insertText(frame, [10 10], sprintf('Total People: %d', pplCount), ...
                    'FontSize', 14, 'BoxColor', 'red', 'BoxOpacity', 0.7);
    % displaying video
    step(vidPlayer, frame);
end

release(vidPlayer);
