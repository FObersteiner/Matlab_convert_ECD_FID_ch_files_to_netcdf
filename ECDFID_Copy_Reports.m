% --------------------------------------------------------------------------------
% Method : ECDFID_Copy_Reports
%
% Description : Creates copies of report.txt files in .d folders of ChemStation
%               evaluation. Copies are saved as "report.old" in folders of 
%               netcdf evaluation
%
% Created : 2017-04, F.Obersteiner, florian.obersteiner@kit.edu
%

path = 'F:\Caribic_Data\GHGGC_Data\';
infstruct = dir(path);
folders = {infstruct().name};
vd_masterpaths = string(path) + string(folders(3:end));

for k=1:numel(vd_masterpaths)
    
    msg=string(k)+" of "+string(numel(vd_masterpaths))+" - "+vd_masterpaths(k)+ " - " + datestr(now);
    t=timer('TimerFcn',@(~,~)disp(msg),'StartDelay',1);
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

    w_report = zeros(1, n_paths, 'uint32');
    ext_rep = 'Report.txt';
    ext_transf = 'Report.old';
    fnames_rep = data_paths+string(ext_rep);
    fnames_transf = strrep(fnames_rep, ext_rep, ext_transf);
    fnames_transf = strrep(fnames_transf, 'GHGGC_Data', 'GHGGC_Data_netcdf');
    
    dir_name = strrep(dir_name, 'GHGGC_Data', 'GHGGC_Data_netcdf'); 
    dir_out_log = fullfile(dir_name, '__export_log');

    file = string(dir_out_log)+ "\report_transfer_log.txt"; 
    file_id = fopen(file, 'w');
    fprintf(file_id, '%s\r\n', "*** copy report.txt to report.old ***");
    fprintf(file_id, '%s\r\n', "beginning transfer: "+string(datetime('now')));
    
    for i=1:n_paths % check for .ch files
        if exist(char(fnames_rep(i)), 'file') > 0
            w_report(i)=1;
        else
            fprintf(file_id, '%s\r\n', "missing report file: "+string(data_paths(i)));
        end
    end
    
    %
    %
    % redefine paths; continue with valid paths only
    w_report = uint32(find(w_report)); 
    vd_paths_rep = data_paths(w_report);
    fnames_rep = fnames_rep(w_report);
    fnames_transf = fnames_transf(w_report);
    n_files_rep = numel(vd_paths_rep);

    %
    %
    for i=1:n_files_rep
        % generate output folder
        [pathstr,name,ext] = fileparts(char(fnames_transf(i))) ;
        pathstr = string(pathstr) + "\" ;
        mkdir(char(pathstr)) ;
        % copy file
        copyfile(char(fnames_rep(i)), char(fnames_transf(i)));
    end
    %
    %
    
    fprintf(file_id, '%s\r\n', dir_name);
    fprintf(file_id, '%s\t%s\r\n', string(i), " report files");
    fprintf(file_id, '%s\r\n', "transfer done: "+string(datetime('now')));
    fclose(file_id);

end