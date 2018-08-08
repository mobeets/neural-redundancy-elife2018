function errs = getScoreArray(S, fldNm, dtInds, hypInds)
% given score object S, returns an array of scores of type fldNm
%   optional: selects subset of dates or hypotheses
% 
    obj = cell2mat({S.scores}');
    errs = reshape([obj.(fldNm)], size(obj));
    if nargin > 2 && ~isempty(dtInds)
        errs = errs(dtInds,:);
    end
    if nargin > 3 && ~isempty(hypInds)
        errs = errs(:,hypInds);
    end
end
