function nm = hypDisplayName(nm, doAbbrev)
    if nargin < 2
        doAbbrev = false;
    end
    if ~doAbbrev
        if strcmpi(nm, 'minimal-firing')
            nm = 'Minimal Firing';
        elseif strcmpi(nm, 'minimal-deviation')
            nm = 'Minimal Deviation';
        elseif strcmpi(nm, 'persistent-strategy')
            nm = 'Persistent Strategy';
        elseif strcmpi(nm, 'fixed-distribution')
            nm = 'Fixed Distribution';
        elseif strcmpi(nm, 'int-data')
            nm = 'Data, first mapping';
        elseif strcmpi(nm, 'pert-data')
            nm = 'Data, second mapping';
        end
        nm(1) = upper(nm(1));
    else
        if strcmpi(nm, 'minimal-firing')
            nm = 'MF';
        elseif strcmpi(nm, 'minimal-deviation')
            nm = 'MD';
        elseif strcmpi(nm, 'uncontrolled-uniform')
            nm = 'UU';
        elseif strcmpi(nm, 'uncontrolled-empirical')
            nm = 'UE';
        elseif strcmpi(nm, 'persistent-strategy')
            nm = 'PS';
        elseif strcmpi(nm, 'fixed-distribution')
            nm = 'FD';
        end
    end
end
