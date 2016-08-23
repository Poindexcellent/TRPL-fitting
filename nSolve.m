function [PLcalcOut,DeltaN] = nSolve(Params,tData,fitTypes)

%     PLcalcOut.m calculates the excess carrier concentration in a film using
%     the central finite difference method. It acceses different recombination,
%     generation, and diffusion functions, which must be in the same directory.
% 
%     Description of input arguments:
%     'Params' = a list of fitting parameters (passed from fitPL.m).
%     'tData' = the time vector over which to calculate the PL. This should be
%       the same range as the actual data.
%     'fitTypes' = a 1x4 cell matrix of strings, each of which specify
%       parameters for the generation, diffusion, and recombination functions
%       (plus injection dependence).
% 
%     Due to the way the 'time window' works currently, the data needs to be
%     VERY well aligned with t = 0 and the laser pulse.
% 
%     Created:          February 5, 2016, Jeremy R. Poindexter.
%     Last modified:    July 13, 2016, Jeremy R. Poindexter.

%%

%%% 0. **Author's notes:
%     - Revisit / test different boundary conditions for SRV
%     - Consider applying injection dependence to SRV
%     - Continue troubleshooting non-convergence of fitting PL normalization
%     factor


%%% 0-opt. Optional step to override 'DefaultParams' (useful for debugging):
%{
DefaultParams = [8.48E6 4.1E-9 0E7*1E-12^2,...
    0,...      %# SRV [4]
    0.256,...  %# D [5]
    1E12,...   %# nBack [6]
    4.75E4,...    %# alpha [7]
    0.146,...    %# reflection [8]
    1000,...   %# thickness [9]
    1,...      %# sigma
    1,...      %# T
    0,...      %# timeShift
    0,...      %# PLshift
    1E-25];    %# PL normalization factor [14]
Params = DefaultParams;
%}


%%% 1. Read in parameter values from function input:
rCoeffs     = [Params(1) Params(2) Params(3)];   % recombination coefficients
SRV         = Params(4);       % surface recombination velocity (cm/s)
diffValIn   = Params(5);       % diffusivity (cm^2/s)
nBack       = Params(6);       % background carrier concentration (cm^{-3})
alpha       = Params(7);       % absorption coefficient (cm^{-1})
reflection  = Params(8);       % reflection
thickness   = Params(9);       % film thickness (nm)
% % normFactor  = Params(14);  % PL normalization factor. Currently not fit.

genType     = fitTypes{1};
diffType    = fitTypes{2};
recombType  = fitTypes{3};
injectType  = fitTypes{4};


%%% 1-opt. Optional step to override parameters (useful for debugging):
%{
% % rCoeffs = [1E9 1E9*1E12 1E9*1E12^2];     %# optional hard-coded recombination coefficients
% % SRV = 1E4;                               %# optional hard-coded SRV (cm/s)
% % nBack = 1E12;                            %# optional hard-coded background carrier concentration (cm^{-3})
% % thickness = 1000;                        %# optional hard-coded thickness (nm)
% % 
% % genType = 'delta';                       %# optional hard-coded generation profile type
% % injectType = 'low';                      %# optional hard-coded injection dependence type
%}


%%% 2.Initialize thickness mesh for finite element array:
yMesh = 20;                          %# hard-coded y mesh size
dy = thickness/yMesh;                %# thickness increment to step by (nm)
depthVect = (0:dy:thickness)';       % film depth vector (nm)
numYPts = length(depthVect);
dY = dy/1E7;                         % convert to cm
meshFactor = 0.2;                    %# hard-coded "mesh factor" (set <0.25)


%%% 3. Determine diffusivity, from which time mesh is initialized: 
Dcalc = diffFunc(diffType,diffValIn,nBack,injectType);
dt = meshFactor*dY^2/Dcalc*1E9;     % time increment to step by (ns)
timeVect = tData(1):dt:tData(end);  % time vector (ns)

%%% **(do I?) NEED AN OPTION HERE TO INTERPOLATE THE 'TIME' VECTOR
%%% APPROPRIATELY ACCORDING TO THE VALUE OF 'dt'

numTPts = length(timeVect);
dT = dt/1E9;                             % convert to seconds


%%% 4. Initialize main-equation values for finite element analysis:
% 4a. Excess carrier concentration, 'DeltaN':
DeltaN = zeros(numYPts,numTPts);

% 4b. Generation function vector:
beamParams = [532 0.5 200E3 80^2*pi/4];     %# hard-coded inputs to 'genFunc'
% % alpha = 1E4;                            %# optional hard-coded value
generation = genFunc(genType,reflection,alpha,beamParams,depthVect,timeVect);

% 4c. Diffusivity matrix:
D = zeros(numYPts,numTPts);

% 4d. Recombination function:
recombCoeffs = recombFunc(recombType,rCoeffs);


%%% 5. Calculate the excess carrier concentration as a function of (x,t):
% 5a. Initialize values if generation type is delta function
if strcmpi(genType,'delta')
    DeltaN(:,1) = generation(:,1) - nBack;
end

% 5a-opt. Display a waitbar to show calculation progress (useful if debugging)
% % wb_ = waitbar(0, 'Calculating excess carrier concentration...',...
% %     'name', 'nSolve.m progress');

% Time loop:
for jj = 2:numTPts
% %     waitbar(jj/numTPts)
    
    % Depth loop:
    for kk = 2:(numYPts-1)
        % Calculate the recombination term:
        recombination = DeltaN(kk,jj-1).^(1:3)*recombCoeffs;

        % Determine the diffusion coefficient:
        D(kk,jj) = diffFunc(diffType,diffValIn,DeltaN(kk,jj-1),injectType);
        
        % Calculate the excess carrier concentration:
        DeltaN(kk,jj) = DeltaN(kk,jj-1) + dT*(D(kk,jj)/(dY^2)*...
            (DeltaN(kk-1,jj-1) - 2*DeltaN(kk,jj-1) + DeltaN(kk+1,jj-1)) ...
            + generation(kk,jj) - recombination);
    end
    
    % Apply boundary conditions:
    % ** May want to make SRV a function of n later on
    
    %{ Raf's method, using 'centered' value of n for injection dependence %}
% %     DeltaN(1,jj)     = DeltaN(3, jj) - (2*dY*SRV./D(2,jj))*DeltaN(2,jj);
% %     DeltaN(end,jj)   = DeltaN(end-2, jj) - ...(2*dY*SRV./D(end-1,jj))*DeltaN(end-1,jj);
    
    %{ My simplified version: %}
% %     DeltaN(1,jj)     = DeltaN(2, jj) - (dY*SRV./D(2,jj))*DeltaN(2,jj);
% %     DeltaN(end,jj)   = DeltaN(end-1, jj) - ...
% %         (dY*SRV./D(end-1,jj))*DeltaN(end-1,jj);
    
    % My more complicated (but more accurate?) version:
    DeltaN(1,jj)     = (DeltaN(2, jj) + dY*SRV/D(2,jj)*nBack)/...
        (1 + dY*SRV/D(2,jj));
    DeltaN(end,jj)   = (DeltaN(end-1, jj) + dY*SRV/D(end-1,jj)*nBack)...
        /(1 + dY*SRV/D(end-1,jj)); 
    
end

% % delete(wb_)


%%% 6. Calculate PL(t) from the excess carrier concentration:
% Account for film reabsorption:
reabsorpVectdY = exp(-alpha*depthVect/1E7)*dY;

% Calculate PL normalization factor
normFactor = 1/((DeltaN(:,1)').^2*reabsorpVectdY);
% % normFactor = 1E-25;        %# optional hard-coded normalization factor

PLcalc = normFactor*((DeltaN').^2)*reabsorpVectdY;
PLcalcOut = interp1(timeVect,PLcalc,tData,'linear','extrap');


%%% 6-opt. Optional helpful testing:
%{
nSolveTest;

figure;
semilogy(tData,PLcalcOut);
grid on
hold on
semilogy(timeData,PLdata,'o','color',[0.7 0.7 0.7],'MarkerSize',2)
%}

end