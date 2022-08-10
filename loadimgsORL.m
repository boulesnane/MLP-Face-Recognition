function loadimgsORL()

ORL = fullfile(pwd, 'ORL');  % Original ORL database contains .pgm files
ORLimgs = fullfile(pwd, 'ORLimgs'); % New folder that will contain the .jpg images
class_dirs = dir(ORL); % Get all files and folser in ORL database
class_index = find([class_dirs.isdir]); % each elements in ORL folder have an index number

for c = 1:length(class_index) % for all sub-folder in the ORL folder
    
    % List images
    image_files = dir(fullfile(ORL, ['s' num2str(c)])); % get all .pgm files in the s folders
    image_index = find(~[image_files.isdir]); % each elements in s folder have an index number
    if(~isempty(image_index)) 
        for i = 1:10 % For each person in the sub folder
            image_name = image_files(image_index(i)).name; % get the image name
            image_path = fullfile(ORL, ['s' num2str(c)], image_name); % get the image path
            current_image = imread(image_path); %read the current image
            imwrite(current_image,[ORLimgs '//' num2str(c)  '_' num2str(i) '.jpg']) % save the image in the ORLimgs folder
        end
    end
end
end