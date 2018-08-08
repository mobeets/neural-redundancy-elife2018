function ix = getMonkeyDateFilter(dts, mnks)
% gets dts mask for all monkey names present in mnks
    
    if isa(dts, 'cell') % if not already an array of numbers
        dts = cellfun(@str2num, dts);
    end
    ixJ = dts <= 20130101;
    ixL = ~ixJ & dts <= 20160101;
    ixN = ~ixJ & ~ixL;    
    
    % make mask
    ix = false(size(dts));
    if isempty(mnks) || isempty(mnks{1})
        % if empty, return true for all
        ix = ~ix;
        return;
    end
    ms = cellfun(@(m) m(1), mnks);
    if any(ismember(ms, 'J'))
        ix = ix | ixJ;
    end
    if any(ismember(ms, 'L'))
        ix = ix | ixL;
    end
    if any(ismember(ms, 'N'))
        ix = ix | ixN;
    end
end
