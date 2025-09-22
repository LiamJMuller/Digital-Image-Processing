% loading video into project
video=VideoReader('Q1.People Walking Free Stock Footage, Royalty-Free No Copyright Content.mp4');
vidPlayer = vision.DeployableVideoPlayer;

% enabling people detector with library as well as multi-object tracker
%pplDetect=vision.PeopleDetector('ClassificationModel', 'UprightPeople_96x48');
pplDetect = yolov4ObjectDetector("tiny-yolov4-coco");

tracker = multiObjectTracker('FilterInitializationFcn', @initKalmanFilter, ...
                            'AssignmentThreshold', 30, ...
                            'ConfirmationThreshold', [3 5], ...
                            'LostThreshold', 10);

% enablish tracking IDs
nextID=1;
pplCount=0;
idSet=[];
gpuDevice(1); % selecting my gpu

while hasFrame(video)
    originalFrame=readFrame(video);
    % use GPU to accelerate processing
    %%frame = gpuArray(originalFrame)
    % detecting people
    %%bbox=peopleDetector(frame);
    % yolov4
    [bbox, scores, ~] = detect(detector, originalFrame, ...
                                    'ExecutionEnvironment', 'gpu', 'Threshold', 0.5);

    % converting to using object detection 
    detections=[];
    for i =1:size(bbox,1)
        %use centroid of bbox
        centroid=[bbox(i,1)+bbox(i,3)/2, bbox(i,2)+bbox(i,4)/2];
        detections{i}=objectDetection(video.CurrentTime, centroid);
    end

    % updating the tracker
    confTracks=tracker(detections);
    % assign IDs and count
    labels = strings(1, numel(confTracks));
    for i =1:numel(confTracks)
        trackID=confTracks(i).trackID;
        %count the new IDs only one time
        if ~ismember(trackID, idSet)
            idSet(end+1)=trackID;
            pplCount=pplCount+1;
        end
        % annotating with ID
        labels(i)=sprintf('ID %d', trackID);
    end

    % annotate bouding boxes
    if ~ismempty(bbox)
        frame=insertObjectAnnotation(frame, 'rectangle', bbox, labels);
    end

    % adding total count
    frame=insertText(frame, [10 10], sprintf('Total People: %d', pplCount), ...
                    'FontSize', 14, 'BoxColor', 'red', 'BoxOpacity', 0.7);
    % displaying video
    step(vidPlayer, frame);
end

release(vidPlayer);
