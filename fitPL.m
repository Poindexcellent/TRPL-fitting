function fitOutput = fitPL(fitThis,timeData,PLdata,fitTypes)

%     fitPL.m provides the framework for a fitting routine to fit PL
%     data to solve for the excess carrier concentration (contained within
%     subfunction 'nSolve').

%     Created:          March 18, 2016, Jeremy R. Poindexter.
%     Last modified:    July 13, 2016, Jeremy R. Poindexter.


%%

%%% 0. **Author's notes:
%     - Add weights (step 6)
%     - Complete reporting of radiative and Auger lifetime components
%     - fix errors in fitPL when trying to fit for k2 and k3 recombination
%     coefficients


%%% 1. Assign default parameters, which are used if not specified by the user:
% **I will need to bring this to one level higher in the functions, i.e. to
% ModelTRPL, once I have better GUI-style parameter selection.

DefaultParams = [1E7 1E7*1E-12 0*1E1*(1E-12)^2,...
    1,...        %# SRV [4]
    0.256,...    %# D [5]
    1E12,...     %# nBack [6]
    1E4,...      %# alpha [7]
    0.3,...      %# reflection [8]
    1000,...     %# thickness [9]
    1,...        %# sigma [10]
    1,...        %# T [11]
    0,...        %# timeShift [12]
    0,...        %# PLshift [13]
    1E-25];      %# PL normalization factor [14]
lb = [0 0 0 0 0 0 0 0 0.1 0 0 0 0 0];
ub = [Inf Inf Inf Inf Inf Inf Inf 1 1E20 Inf Inf Inf Inf Inf];

ParamsNames = {'SRH coefficient (s^{-1})',...
    'radiative coefficient (s^{-1}cm^3)',...
    'Auger coefficient (s^{-1}cm^6)', 'SRV (cm/s)', 'D (cm^2/s)',...
    'nBack (cm^{-3})', 'alpha (cm^{-1})', 'reflection', 'thickness (nm)',...
    'sigma', 'T', 'timeShift', 'PLshift', 'PL normalization factor'};


%%% 1-opt. Optional step to override 'fitThis' (useful for debugging):
%{
% For 'fitThis', '1' = fit this parameter; '0' = do not fit this parameter.
fitThis = [1 0 0 ...     %# recombination coefficients
    0 ...      %# SRV
    1 ...      %# D
    0 ...      %# nBack
    0 ...      %# alpha
    0 ...      %# reflection
    0 ...      %# thickness
    0 ...      %# sigma
    0 ...      %# T
    0 ...      %# timeShift
    0 ...      %# PLshift
    0];        %# PL normalization factor
% % fitThis = ones(14,1);
%}


%%% 2. Additional variable declarations:
fitThis = logical(fitThis);
PLfitParams = DefaultParams;
NewParams = DefaultParams;


%%% 2-opt. Optional variable declarations:
%{
fitTypes{1} = 'delta';
fitTypes{2} = 'p-type';
fitTypes{3} = 'A';
fitTypes{4} = 'low';
%}

%%% 3. Define options for fitting, then perform fitting (using 'lsqcurvefit').
opts = optimoptions('lsqcurvefit','Display','iter-detailed',...
    'FunValCheck','off','TolX',1E-10,'TolFun',1E-10,'MaxFunEvals',1000,...
    'Diagnostics','on','FiniteDifferenceType','forward',...
    'TypicalX',PLfitParams(fitThis));

[PLcalcParams,resnorm,residual,exitflag,output,lambda,jacobian] = ...
    lsqcurvefit(@PLfunc,PLfitParams(fitThis),timeData,PLdata,...
    lb(fitThis),ub(fitThis),opts);


%%% 4. Update the new parameters, and display the results:
NewParams(fitThis) = PLcalcParams;

fprintf('FITTING RESULTS:\n-------------------\n')
for zz = find(fitThis)
    fprintf('%35s = \t%1.4g\n',ParamsNames{zz},NewParams(zz))
% %     % Report any lifetimes (if they were fitting parameters):
% %     % **complete for radiative and Auger components
% %     if zz == 1
% %         fprintf('%35s = \t%1.4g\n', 'SRH lifetime (ns)', 1/NewParams(zz)*1E9);
% %     end
% %     
end


%%% 5. Return the results:
fitOutput = struct;
fitOutput.NewParams = NewParams;
fitOutput.resnorm = resnorm;
fitOutput.residual = residual;
fitOutput.exitflag = exitflag;
fitOutput.output = output;
fitOutput.lambda = lambda;
fitOutput.jacobian = jacobian;


%%% 6. Define the 'PLfunc' sub-function:
    function PLfuncOut = PLfunc(PLfuncParams,tData)
        
% %         weights = ones(length(tData));        %# hard-coded weighting values
% %         tWindow = [tData(1) tData(end)];
        
        % Fit only the 'fitThis' parameters:
        PLfitParams(fitThis) = PLfuncParams;
        
        % Call 'nSolve':
        [PLfuncOut,~] = nSolve(PLfitParams,tData,fitTypes);
        
% %         PLfuncOut = PLfuncOut.*sqrt(weights);
        
        
        
    end




end