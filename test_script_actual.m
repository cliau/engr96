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

for picture = picture_names(1:2, :)'
    fieldname = 'name';
    picture_filename = strcat(subfolder_name, picture.(fieldname));
    disp(picture_filename);
    picture_data = fitsread(picture_filename, extname);
    calibrated_picture = picture_data - dark_image_lib(1);

    figure
    imshow(calibrated_picture, [0, 10000]);
    figure
    imshow(picture_data, [0, 9300]);
end
