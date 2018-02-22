% --------------------------------------------------------------------------------
% Function : ECDFID_ch_to_netcdf
%
% Description : Exports Agilent FID and ECD data to netcdf format.
%
% Created : 2017-04, F.Obersteiner, florian.obersteiner@kit.edu
%
% Modifications: 
%
% --------------------------------------------------------------------------------
%
function [ errmsg ] = ECDFID_ch_to_netcdf( data, data_folder, data_creation, ...
                                           dir_out, fname, conv_version )
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
file = string(dir_out)+ "\" +string(fname)+f_num+".nc"; % generate filename

ncid = netcdf.create(char(file), 'NETCDF4'); % create the file... 'NOCLOBBER',

dimID_y = netcdf.defDim(ncid, 'ydata', numel(data.tic)); % Define the dimensions of ydata variable.
varID_y = netcdf.defVar(ncid, 'ydata', 'double', dimID_y); % Define ydata variable in the file.

% define some global info.
varID_ts_cdf = netcdf.getConstant('GLOBAL'); % time stamp of cdf file creation
varID_origin = netcdf.getConstant('GLOBAL');
varID_cvers = netcdf.getConstant('GLOBAL');
varID_inst = netcdf.getConstant('GLOBAL');
varID_ts_ch = netcdf.getConstant('GLOBAL'); % time stamp of channel (.ch) file creation
varID_ts_CS = netcdf.getConstant('GLOBAL'); % time stamp of ChemStation
varID_sname = netcdf.getConstant('GLOBAL');
varID_descr = netcdf.getConstant('GLOBAL');
varID_seq = netcdf.getConstant('GLOBAL');
varID_rep = netcdf.getConstant('GLOBAL');
varID_mthd = netcdf.getConstant('GLOBAL');
varID_op = netcdf.getConstant('GLOBAL');


netcdf.endDef(ncid); % Leave define mode and enter data mode to write data. 

netcdf.putVar(ncid, varID_y, data.tic); % Write data to variable. 

netcdf.reDef(ncid); % Re-enter define mode.

netcdf.putAtt(ncid, varID_y, 't_max', max(data.time)); % Create an attribute t_max associated with ydata.

formatOut = 'dd.mm.yyyy HH:MM:SS';
netcdf.putAtt(ncid, varID_ts_cdf, 'cdf_created', datestr(now, formatOut)); % add more info...
netcdf.putAtt(ncid, varID_origin, 'data_origin', char(data_folder));
netcdf.putAtt(ncid, varID_cvers, 'conv_vers', conv_version);
netcdf.putAtt(ncid, varID_inst, 'instrument', inst);
netcdf.putAtt(ncid, varID_ts_ch, 'ch_file_created', datestr(data_creation, formatOut));
netcdf.putAtt(ncid, varID_ts_CS, 'chemstation_start', data.method.date);
netcdf.putAtt(ncid, varID_sname, 'sample_name', data.sample.name);
netcdf.putAtt(ncid, varID_descr, 'sample_descr', data.sample.description);
netcdf.putAtt(ncid, varID_seq, 'sequence', int32(data.sample.sequence));
netcdf.putAtt(ncid, varID_rep, 'replicate', int32(data.sample.replicate));
netcdf.putAtt(ncid, varID_mthd, 'method', data.method.name);
netcdf.putAtt(ncid, varID_op, 'operator', data.method.operator);


netcdf.close(ncid); % Close the file. 


end