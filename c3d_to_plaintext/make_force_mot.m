function make_force_mot(filename,forces,time)
% Creates motion file for OpenSim with external forces applied to the hand
%
% Inputs:
% filename: the name of the motion file, without the extension
% forces: an 3 x n or n x 3 matrix of forces, 
% n the number of frames
% time: a 1xn or nx1 vector of time values. 

[nrows,ncolumns]=size(forces);
if ncolumns~=3
    forces=forces';
    nrows = ncolumns;
end

if size(time,2)~=1, time = time'; end
if size(time,1)~=nrows
    disp('The time vector does not have the same length as the force data.');
    return;
end

zeropos = zeros(size(forces,1),3); % applied to the COM of the hand
data = [time forces zeropos];  

% create motion file
% the header of the motion file is:
%
% <motion name>
% nRows=x
% nColumns=y
% endheader
% time varnames

varnames = 'time  hand_force_vx  hand_force_vy  hand_force_vz  hand_force_px  hand_force_py  hand_force_pz';
varstr = '%f  %f  %f  %f  %f  %f  %f\n';

fid = fopen(filename,'wt');
fprintf(fid,'%s\n',filename);
fprintf(fid,'%s%i\n','nRows=',nrows);
fprintf(fid,'%s\n','nColumns=7');
fprintf(fid,'%s\n','endheader');
fprintf(fid,'%s\n',varnames);
fprintf(fid,varstr,data');
fclose(fid);
