function spikes = latentsToSpikes(latents, decoder, addNoise, doGenerative)
% generate spikes s.t. the model from spikes to latents recreates the
%   present latents
% 
    if nargin < 3
        addNoise = false;
    end
    if nargin < 4
        doGenerative = false;
    end

    if isfield(decoder.FactorAnalysisParams, 'spikeRot')
        latents = latents/decoder.FactorAnalysisParams.spikeRot;
    end
    L = decoder.FactorAnalysisParams.L;
    ph = decoder.FactorAnalysisParams.ph;
    mu = decoder.spikeCountMean;
    sigma = decoder.spikeCountStd;

%     top = (L*L'+diag(ph));
%     ((L'*inv(top))*U)' = U'*(L'*inv(top))' = U'*(top'\L) = Z'
%     U = latents*(L\top');
%     U = latents*(L + diag(ph)/L')';

    if doGenerative
        % note that the generative model for spikes is:
        U = latents*L';
        %   but this won't result in the decoded latents from those spikes
        %   being identical to the latents we have here...
    else
        L = L + diag(ph)/L';
        U = latents*L';
    end
    
    if addNoise
        nse = mvnrnd(zeros(size(U,2),1), ph', size(U,1));
        U = U + nse;
    end
    
    spikes = bsxfun(@plus, U*diag(sigma), mu);

end
