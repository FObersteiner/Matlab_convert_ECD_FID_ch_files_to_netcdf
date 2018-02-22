% --------------------------------------------------------------------------------
% Function : ECDFID_ch_to_txt
%
% Description : Exports Agilent FID and ECD data to txt format.
%
% Created : 2017-03, F.Obersteiner, florian.obersteiner@kit.edu
%
% Modifications: 2017-04, added file enumeration based on .d folder name
%
% --------------------------------------------------------------------------------
%
function [ errmsg ] = ECDFID_ch_to_txt( data, data_folder, data_creation, ...
                                        dir_out, fname, version )
errmsg = 'no error';

% gather some info from "data"...
inst='undefined';
if contains(fname, 'ecd', 'IgnoreCase', true)
    inst='ECD';
elseif contains(fname, 'fid', 'IgnoreCase', true)
    inst='FID';
end
   
% find the file number and generate a filename
num_suffix = ".d";
suffix_pos = strfind(lower(string(fname)), num_suffix);
f_num = extractBetween(string(fname), (suffix_pos-3), (suffix_pos-1));
file = string(dir_out)+ "\" +string(fname)+f_num+".txt"; % generate filename
file_id = fopen(file, 'w'); % open a txt file for write


% write header
hdr_format='%s\t%s\r\n';
fprintf(file_id, hdr_format, 'data_origin:', data_folder);
fprintf(file_id, hdr_format, 'conv_vers:', string(version));
fprintf(file_id, hdr_format, 'instrument:', inst);
fprintf(file_id, hdr_format, 'timestamp:', string(data.method.date));
fprintf(file_id, hdr_format, 'sample_name:', string(data.sample.name));
fprintf(file_id, hdr_format, 'sample_descr:', string(data.sample.description));
fprintf(file_id, hdr_format, 'sequence:', string(data.sample.sequence));
fprintf(file_id, hdr_format, 'replicate:', string(data.sample.replicate));
fprintf(file_id, hdr_format, 'method:', string(data.method.name));
fprintf(file_id, hdr_format, 'operator:', string(data.method.operator));

% write col header
fprintf(file_id, hdr_format, 'time', 'intensity_cts');

% write data
dat_format='%f\t%f\r\n';
for i=1:numel(data.time)
    fprintf(file_id, dat_format, data.time(i), data.tic(i));
end

fclose(file_id); % close file

end

