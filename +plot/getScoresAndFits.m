function [S,F] = getScoresAndFits(fitsName, dts)
%
    if nargin < 2
        dts = {};
    end
    fitsDir = fullfile('data', 'fits', fitsName);
    if ~exist(fitsDir, 'dir')
        S = []; F = []; return;
    end
    
    fnms = dir(fullfile(fitsDir, '*_scores.mat'));
    F = [];
    S = [];
    for ii = 1:numel(fnms)
        fnm = fnms(ii).name;
        if ~isempty(dts) && ~any(ismember(dts, strrep(fnm, '_scores.mat', '')))
            continue;
        end
        X = load(fullfile(fitsDir, fnm));
        S = [S X.S];
        if nargout > 1
            fnm = strrep(fnm, '_scores', '_fits');
            X = load(fullfile(fitsDir, fnm));
            F = [F X.F];
        end        
    end
end
