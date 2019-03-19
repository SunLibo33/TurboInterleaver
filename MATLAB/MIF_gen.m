function [] = MIF_gen(filename, values, word_size, ram_size)
%%  MIF_gen - A Matlab Utility
%   copy/pasted from: 
%       http://fpgasite.blogspot.com/2017/09/mifgen-matlab-utility.html

    %-------------------------------------------
    % Generate Parameters
    if (nargin<4)
        word_size   = 8;      % Can be 8, 16, 32, etc. 
    end
    if (nargin<3)
        ram_size    = 768;     % In words
    end

    %-------------------------------------------
    % values vector checking
    if (length(unique(values))<=2) % binary vector - convert to byte-wide
        assert(length(values)<=(word_size*ram_size), 'too large vector');
        values(word_size*ram_size) = 0;
        values = reshape(values, 8, length(values)/8)';
        for i = 1:8
            values(:,i) = values(:,i)*2^(8-i);
        end
        values = sum(values,2);
        assert (all(values>=0) && all(values<256), 'internal error');
    end
    assert ((length(values)*8) <= (word_size*ram_size),'too many values for memory size');
    if ((length(values)*8) < (word_size*ram_size))
        values(word_size*ram_size/8) = 0;
    end

    %-------------------------------------------
    % Open mif file for write
    fileID = fopen(filename, 'w');
    fprintf( fileID, '%s\n', '-- Generated by mif_gen Matlab script');
    fprintf( fileID, '%s\n\n', '-- FPGA SITE - https://fpgasite.blogspot.com');
    fprintf( fileID, '%s%d%s\n', 'WIDTH=', word_size, ';');
    fprintf( fileID, '%s%d%s\n\n', 'DEPTH=', ram_size, ';');
    fprintf( fileID, '%s\n', 'ADDRESS_RADIX=HEX;');
    fprintf( fileID, '%s\n\n', 'DATA_RADIX=HEX;');
    fprintf( fileID, '%s\n', 'CONTENT BEGIN;');

    % data format
    fdata = int2str(word_size/4);
    faddr = int2str(log2(ram_size)/4);
    format_str = strcat('    %0', faddr, 'X  :  %02X');
    for i = 2:(word_size/8)
        format_str = strcat(format_str,'%02X');
    end
    format_str = strcat(format_str,';\n');

    % write values to file
    idx = 0;
    for ii=1:ram_size
     fprintf( fileID, format_str, idx, values(idx*(word_size/8)+1:(idx+1)*(word_size/8)));
     idx = idx+1;
    end
    fprintf( fileID, '%s\n', 'END;');
    fclose( fileID);

end