function fitOutput = fitPL(fitThis,timeData,PLdata)
% % function fitPL(fitThis,weights)

% I'll worry about weights later; they're not that important right now.

% (from Raf's code)
% P = model parameters. Exact parameter set depends on pump
%       Delta:      P = [tau, SRV, thick, alpha, R, difu, N, ~,     ~,  h, tShift, PLshift]
%       Square:     P = [tau, SRV, thick, alpha, R, difu, N, ~,     T,  h, tShift, PLshift]
%       Gaussian:   P = [tau, SRV, thick, alpha, R, difu, N, sigma, T,  h, tShift, PLshift]


% % DefaultParams = [1E9 1E9*1E12 1E9*1E12^2,...
DefaultParams = [1E7 0 0,...
    0,...      %# SRV [4]
    0.25,...     %# D [5]
    1E12,...     %# nBack [6]
    1E4,...      %# alpha [7]
    0.3,...      %# reflection [8]
    1000,...     %# thickness [9]
    1,...        %# sigma
    1,...        %# T
    0,...        %# timeShift
    0,...        %# PLshift
    1E-25];      %# PL normalization factor
lb = [0 0 0 0 1E-10 0 0 0 0.1 0 0 0 0 0];
ub = [Inf Inf Inf Inf 1E10 Inf Inf 1 1E20 Inf Inf Inf Inf Inf];

% % lb = [0 0 0 0 0.25 0 0 0 0.1 0 0 0 0 0];
% % ub = [Inf Inf Inf 1E8 Inf Inf Inf 1 1E20 Inf Inf Inf Inf Inf];
% % lb = [];
% % ub = [];


ParamsNames = {'SRH coefficient (s^{-1})', 'radiative coefficient',...
    'Auger coefficient', 'SRV (cm/s)', 'D (cm^2/s)', 'nBack (cm^{-3})',...
    'alpha (cm^{-1})', 'reflection', 'thickness (nm)', 'sigma', 'T',...
    'timeShift', 'PLshift', 'PL normalization factor'};

% '1' = fitThis; '0' = don't fitThis (i.e., fix this parameter)
% % fitThis = [1 0 0 ...     %# recombination coefficients
% %     0 ...      %# SRV
% %     0 ...      %# D
% %     0 ...      %# nBack
% %     0 ...      %# alpha
% %     0 ...      %# reflection
% %     0 ...      %# thickness
% %     0 ...      %# sigma
% %     0 ...      %# T
% %     0 ...      %# timeShift
% %     0 ...      %# PLshift
% %     0];        %# PL normalization factor
% % fitThis = ones(14,1);
fitThis = logical(fitThis);
PLfitParams = DefaultParams;
NewParams = DefaultParams;

genType = 'delta';
injectType = 'low';

%%% for timeData later, need prompts to select ONLY the data to be fitted from the broader data



opts = optimoptions('lsqcurvefit','Display','iter-detailed','FunValCheck','on','TolX',1E-10,...
    'TolFun',1E-10,'MaxFunEvals',1000,'Diagnostics','on','FiniteDifferenceType','forward');

[PLcalcParams,resnorm,residual,exitflag,output,lambda,jacobian] = ...
    lsqcurvefit(@PLfunc,PLfitParams(fitThis),timeData,PLdata,lb(fitThis),ub(fitThis),opts);



NewParams(fitThis) = PLcalcParams;

fprintf('FITTING RESULTS:\n-------------------\n')
for zz = find(fitThis)
    fprintf('%35s = \t%1.4g\n',ParamsNames{zz},NewParams(zz))
    if zz == 1
        fprintf('%35s = \t%1.4g\n', 'SRH lifetime', 1/NewParams(zz));
    end
end


fitOutput = struct;
fitOutput.NewParams = NewParams;
fitOutput.resnorm = resnorm;
fitOutput.residual = residual;
fitOutput.exitflag = exitflag;
fitOutput.output = output;
fitOutput.lambda = lambda;
fitOutput.jacobian = jacobian;


    function PLfuncOut = PLfunc(PLfuncParams,tData)
        
% %         weights = ones(length(tData));        %# hard-coded weighting values
% %         tWindow = [tData(1) tData(end)];
        

        PLfitParams(fitThis) = PLfuncParams;
        
        PLfuncOut = nSolve(PLfitParams,tData,genType,injectType);
        
% %         PLfuncOut = PLfuncOut.*sqrt(weights);
        
        
        
    end




end