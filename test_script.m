%% TO DO
    % figure out fit module
    % plot with fit line
    % get actual photo using g3, calibrate

%% determine general trend:
    % iterate through exposures (go to some folder, dir folder = list of file names)
        % for each of 6 photos taken:
            % record mean value and standard deviation
    % graph mean values vs log(exposure time)

exposures = {'0,001', '0,01', '1', '5', '10', '50', '100'};
exposure_nums = [0.001, 0.01, 1, 5, 10, 50, 100];
extname = 'primary';
extension = '/*.fit';

rows = 582;
cols = 752;

bias = zeros(1, 7);
ctr = 1;

for subfolder = exposures
    
    subfolder_name = strcat('/Users/chloeliau/Documents/MATLAB/20161019_ENGR 96B Calibration/dark_flat/dark/', char(subfolder));
    
    picture_names = dir(strcat(subfolder_name, extension));
        
    picture_data = zeros(rows, cols);
    for picture = picture_names'
        fieldname = 'name';
        picture_filename = strcat(subfolder_name, '/', picture.(fieldname));
        picture_data = picture_data + fitsread(picture_filename, extname);
    end
    mean_picture = picture_data ./ length(picture_names);
    
    bias(ctr) = mean(mean(mean_picture));
    ctr = ctr + 1;
    
end
disp(bias);
% shift log(exposure_nums) rightward to have all positive values for curve
% fitting
log_exposure = log(exposure_nums) + (ones(1, 7) .* double(7));

%% generate master for each exposure:
% iterate through exposures
    % for each of 6 photos taken:
        % take mean of each pixel (array) (sum, /6 at end)
% write mean to new fits file
% graph mean values vs log(exposure time)
bias_matrix = zeros(rows, cols);
counted = false;
for subfolder = exposures
    
    subfolder_name = strcat('/Users/chloeliau/Documents/MATLAB/20161019_ENGR 96B Calibration/dark_flat/dark/', char(subfolder));
    
    picture_names = dir(strcat(subfolder_name, extension));
        
    picture_data = zeros(rows, cols);
    for picture = picture_names'
        fieldname = 'name';
        picture_filename = strcat(subfolder_name, '/', picture.(fieldname));
        picture_data = picture_data + fitsread(picture_filename, extname);
    end
    mean_picture = picture_data ./ length(picture_names);
    if counted == false
        bias_matrix = mean_picture;
        counted = true;
    end
    
    % make surface
    figure
    h = surf(mean_picture);
    set(h,'LineStyle','none');
    zlabel('brightness');
    ylabel('y');
    xlabel('x');
    
    filename = char(strcat(subfolder, '_master.fit'));
    fitswrite(mean_picture, filename);
    
end

%% calibration for flat frames:

subfolder_name = strcat('/Users/chloeliau/Documents/MATLAB/20161019_ENGR 96B Calibration/dark_flat');

picture_names = dir(strcat(subfolder_name, extension));
picture_data = zeros(rows, cols);

for picture = picture_names'
    fieldname = 'name';
    picture_filename = strcat(subfolder_name, '/', picture.(fieldname));
    picture_data = picture_data + fitsread(picture_filename, extname);
end
mean_picture = picture_data ./ length(picture_names);

figure
h = surf(mean_picture);
set(h,'LineStyle','none');

left = uint8(rows/2 - rows/4);
right = uint8(rows/2 + rows/4);
up = uint8(cols/2 - cols/4);
down = uint8(cols/2 + cols/4);

mean_picture_center = mean_picture(left:right, up:down);
flat_average = mean(mean(mean_picture_center));

flat_calibration_matrix = flat_average ./ mean_picture;

figure
h = surf(flat_calibration_matrix);
set(h,'LineStyle','none')
zlabel('normalized calibration coefficient');
%% calibrate actual picture:
% find corresponding curve fit value
% flat average / (flat_x,y) (raw - dark)
% flat_calibration_matrix * (raw - dark)

% raw: read in image
% flat_calibration_matrix * (raw - dark corresponding to exposure)
% raw_path = ('/Users/chloeliau/Documents/MATLAB/20161019_ENGR 96B Calibration/dark_flat/raw.fit');
% raw = fitsread(raw_path, 'primary');

% dark: read in dark (note: change to reading in matrix?)
% dark_path = ('/Users/chloeliau/Documents/MATLAB/20161019_ENGR 96B Calibration/0,001_master.fits');
% dark = fitsread(dark_path, 'primary');
% calibrated_raw = flat_calibration_matrix * (raw - dark);
% filename = calibrated_raw.fit;
% fitswrite(calibrated_raw, filename);