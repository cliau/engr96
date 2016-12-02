load('test_workspace.mat');
%% reading in dark images
exposures = {'30', '60', '120', '180'};
exposure_nums = str2double(exposures);

rows = 582;
cols = 752;

dark_image_lib = zeros(rows, cols, length(exposures));

disp(length(exposures));

extname = 'primary';
extension = '/*.fit';

astro_body = 'm_objects/'; % moon, solar

ctr = 1;

for subfolder = exposures
    
    subfolder_name = strcat('./actual_images/', astro_body, 'DARK_images/', char(subfolder));
    
    picture_names = dir(strcat(subfolder_name, extension));
    
    picture_data = zeros(rows, cols);
    for picture = picture_names'
        fieldname = 'name';
        picture_filename = strcat(subfolder_name, '/', picture.(fieldname));
        picture_data = picture_data + fitsread(picture_filename, extname);
    end
    mean_picture = picture_data ./ length(picture_names);
    
    dark_image_lib(:, :, ctr) = mean_picture;
    ctr = ctr + 1;
end
%% processing images: subtracting before/after

subfolder_name = strcat('./actual_images/', astro_body, 'M57/');
disp(subfolder_name);
picture_names = dir(strcat(subfolder_name, '*.fit'));
disp(picture_names);

for picture = picture_names(1:1, :)'
    fieldname = 'name';
    picture_filename = strcat(subfolder_name, picture.(fieldname));
    disp(picture_filename);
    picture_data = fitsread(picture_filename, extname);
    calibrated_picture = flat_calibration_matrix .* (picture_data - dark_image_lib(1));

%     figure
%     imshow(calibrated_picture, [0, 10000]);
%     figure
%     imshow(picture_data, [0, 9300]);
   
    showimage(picture_data, [], 0.05, 99.95);
    title('uncalibrated');
    figure
    h = histogram(log(picture_data));
    title('uncalibrated picture');
    disp('asdf');
    disp(max(max((picture_data))));
    showimage(calibrated_picture, [], 0.05, 99.95);
    title('calibrated');
    figure
    h = histogram(log(calibrated_picture));
    title('calibrated picture');
    disp('asdf2');
    disp(max(max((calibrated_picture))));
%     figure
%     h = surf(calibrated_picture);
%     set(h,'LineStyle','none');
end

function showimage(image, arg, lower_pctg, higher_pctg)
    image_line = reshape(image, 1, []);
    if ~exist(arg,'var')
     % third parameter does not exist, so default it to something
        arg = 'auto';
    end
    if strcmp(arg, 'log')
        figure
        log_image = log(image_line);
        lower_bound = prctile(log_image, lower_pctg);
        upper_bound = prctile(log_image, higher_pctg);
        imshow(log(image), [lower_bound, upper_bound]);
    else
        figure
        lower_bound = prctile(image_line, lower_pctg);
        upper_bound = prctile(image_line, higher_pctg);
        imshow(image, [lower_bound, upper_bound]);
    end
    
end
