% --------------------------------------------------------------------------------
% Method : conversion_wrapper
%
% Description : Wrapper to export .txt files from Agilent "*.CH" files; ECD and FID
% data. The wrapper itself gathers information on a specified folder which
% contains ECD and FID data. To import Agilent data and export .txt/.nc files,
% subroutines are called, see "called function(s)".
%
% Created : 2017-03, F.Obersteiner, florian.obersteiner@kit.edu
%
% Modifications: 
%   added netcdf export 2017-04
%   added explanations on variables to modify 2017-08
%
conv_version = 1.3; % housekeeping parameter... update if modify code.
% --------------------------------------------------------------------------------
%
% --------------------------------------------------------------------------------
% called function(s): 
%       ImportAgilent, from Chromatography Toolbox by James Dillon, 
%       export_chdata_to_txt
%       export_chdata_to_netcdf
% --------------------------------------------------------------------------------
%
% --------------------------------------------------------------------------------
% modify the following variables...
% => 
% "path" -> folder that contains subfolders which contain .D
% Chemstation folders, i.e. \folder\subfolders1-n\measurement1-n.D
path = 'E:\temp\chemstation\';
% "out_dir_remove" -> part of the path that will be removed...
out_dir_remove = 'chemstation';
% "out_dir_replacement" -> string that will replace the removed part
out_dir_replacement = 'netcdf';
% "ext_ecd" -> filename of ECD binary data
ext_ecd = 'ECD2B.CH';
% "ext_fid" -> filename of FID binary data
ext_fid = 'FID1A.CH';
% "ecd_exp_folder" -> name of folder that will hold converted ECD data.
% Leave blank ('') to not create a subfolder.
ecd_exp_folder = '__exported_ecd_data';
% "fid_exp_folder" -> name of folder that will hold converted FID data.
% Leave blank ('') to not create a subfolder.
fid_exp_folder = '__exported_fid_data';
% "exp_log_folder" -> name of folder that will hold the export logfile.
% Leave blank ('') to not create a subfolder.
exp_log_folder = '__export_log';
% <=

% master loop: all flights etc.
infstruct = dir(path);
folders = {infstruct().name};
vd_masterpaths = string(path) + string(folders(3:end));

for k=1:numel(vd_masterpaths)
    %
    % prompt path containing flight data
    msg=string(k)+" of "+string(numel(vd_masterpaths))+" - "+vd_masterpaths(k)+ " - " + datestr(now);
    t=timer('TimerFcn',@(~,~)disp(msg),'StartDelay',2);
    start(t)

    dir_name = char(vd_masterpaths(k)); 
    dir_content = dir(dir_name);

    % get string array of .d folders in path
    all_files = string({dir_content().name}); % convert cell array to string array
    w_match = contains(all_files, '.d', 'IgnoreCase', true); % t/f array of matches, .d folders
    w_ix = uint32(find(w_match)); % indices of matches

    % generate string array of data paths and search for .ch files
    folder_basenames = all_files(w_ix);
    data_paths = string(dir_name)+ "\" +folder_basenames+ "\";
    n_paths = numel(data_paths);

    w_ecd_data = zeros(1, n_paths, 'uint32');
    w_fid_data = zeros(1, n_paths, 'uint32');

    ext_ecd = 'ECD2B.CH'; % generate ECD data path string array
    fnames_ecd = data_paths+string(ext_ecd);

    ext_fid = 'FID1A.CH'; % generate FID data path string array
    fnames_fid = data_paths+string(ext_fid);

    dir_name=strrep(dir_name,out_dir_remove,out_dir_replacement);
    
    %
    % write an output logfile with info on missing data
    dir_out_log = fullfile(dir_name, exp_log_folder);
    mkdir (dir_out_log);
    file = string(dir_out_log)+ "\export_log.txt"; 
    file_id = fopen(file, 'w');
    fprintf(file_id, '%s\r\n', "*** ECD / FID .ch to netcdf ***");
    fprintf(file_id, '%s\r\n', "beginning netcdf export: "+string(datetime('now')));
    for i=1:n_paths % check for .ch files
        if exist(char(fnames_ecd(i)), 'file') > 0
            w_ecd_data(i)=1;
        else
            fprintf(file_id, '%s\r\n', "missing ecd data: "+string(data_paths(i)));
        end

        if exist(char(fnames_fid(i)), 'file') > 0
            w_fid_data(i)=1;
        else
            fprintf(file_id, '%s\r\n', "missing fid data: "+string(data_paths(i)));
        end
    end


    % redefine paths; continue with valid paths only
    w_ecd_data = uint32(find(w_ecd_data)); 
    w_fid_data = uint32(find(w_fid_data));

    vd_paths_ecd = data_paths(w_ecd_data);
    fnames_ecd = fnames_ecd(w_ecd_data);

    vd_paths_fid = data_paths(w_fid_data);
    fnames_fid = fnames_fid(w_fid_data);

    n_files_ecd = numel(vd_paths_ecd);
    n_files_fid = numel(vd_paths_fid);

    % generate output folders
    dir_out_ecd = fullfile(dir_name, ecd_exp_folder);
    dir_out_fid = fullfile(dir_name, fid_exp_folder);
    mkdir (dir_out_ecd);
    mkdir (dir_out_fid);

    %
    % actual data processing!
    %
    % import .ch file, export .nc file
    %
    % loop through ecd files...

    formatOut = 'dd.mm.yyyy HH:MM:SS';

    for i=1:n_files_ecd 
        fname=folder_basenames(w_ecd_data(i))+ "_ECD_";   
        data_folder = vd_paths_ecd(i);   
        info=dir(char(fnames_ecd(i)));
        data_creation=info.datenum; % datenum: Matlab internal date, float number
        data=ImportAgilent_mod(char(fnames_ecd(i)));  
    %     ex=ECDFID_ch_to_txt(data, data_folder, date_creation, ...
    %                         dir_out_ecd, fname, conv_version);   
        ex=ECDFID_ch_to_netcdf(data, data_folder, data_creation, ...
                               dir_out_ecd, fname, conv_version);
    end

    % loop through fid files...
    for j=1:n_files_fid
        fname=folder_basenames(w_fid_data(j))+ "_FID_";    
        data_folder = vd_paths_fid(j);    
        info=dir(char(fnames_fid(j)));
        data_creation=info.datenum;
        data=ImportAgilent_mod(char(fnames_fid(j)));    
    %     ex=ECDFID_ch_to_txt(data, data_folder, data_creation, ...
    %                         dir_out_fid, fname, conv_version);
        ex=ECDFID_ch_to_netcdf(data, data_folder, data_creation, ...
                               dir_out_fid, fname, conv_version);
    end


    fprintf(file_id, '%s\r\n', dir_out_ecd);
    fprintf(file_id, '%s\t%s\r\n', string(i), " ECD files");
    fprintf(file_id, '%s\r\n', dir_out_fid);
    fprintf(file_id, '%s\t%s\r\n', string(j), " FID files");
    fprintf(file_id, '%s\r\n', "export done: "+string(datetime('now')));
    fclose(file_id);


end

msg = msgbox('Agilent .ch to useful format: Conversion done.');