function [latents, beta] = convertRawSpikesToRawLatents(dec, sps, ~)
% converts spikes to latents under the FA model
%   note that spikes are assumed to be z-scored prior to applying FA
% 
    if isempty(sps)
        latents = [];
        return;
    end

    L = dec.FactorAnalysisParams.L; % LL' = shared variance
    ph = dec.FactorAnalysisParams.ph; % = private variance
    sigmainv = diag(1./dec.spikeCountStd'); % std dev per channel
    if isfield(dec.FactorAnalysisParams, 'spikeRot')
        % rotate, if necessary, from orthonormalization
        R = dec.FactorAnalysisParams.spikeRot;
    else
        R = eye(size(L,2));
    end
    beta = L'/(L*L'+diag(ph));
    beta = R'*beta*sigmainv';
    mu = dec.spikeCountMean'; % mean per channel
    u = bsxfun(@plus, sps, -mu); % normalize (subtract off mean)
    latents = u'*beta';
end
