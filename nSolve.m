function PLcalcOut = nSolve(Params,tData,genType,injectType)


% This function calculates the excess carrier concentration in a film using the central finite difference method. It
% acceses different recombination, generation, and diffusion functions, which must be in the same directory.
%
% Description of input arguments:


% time = a vector specifying the time over which the data should be fitted [ns].

% thickness = the thickness of the film (nm).

% 'rCoeffs' = recombination coefficients (k1, k2, k3).
%
% nBack = background carrier concentration
%
% genType = a string to specify type of generation function to use.
%
% injectType = a string to toggle injection dependence.

% Due to the way the 'time window' works currently, the data needs to be VERY well aligned with t = 0 and the laser
% pulse.


% Important hard-coded values are indicated in the script with a hashtag (#) in the corresponding comment.

% Created February 5, 2016, Jeremy R. Poindexter.
% Last modified March 18, 2016, Jeremy R. Poindexter.

%%
% % DefaultParams = [1E7 0 0,...
% %     0,...      %# SRV [4]
% %     0.25,...      %# D [5]
% %     1E12,...      %# nBack [6]
% %     1E4,...      %# alpha [7]
% %     0.3,...      %# reflection [8]
% %     1000,...      %# thickness [9]
% %     1,...      %# sigma
% %     1,...      %# T
% %     0,...      %# timeShift
% %     0,...      %# PLshift
% %     1E-25];    %# PL normalization factor [14]  
% % Params = DefaultParams;


rCoeffs     = [Params(1) Params(2) Params(3)];   % recombination coefficients
SRV         = Params(4);       % surface recombination velocity (cm/s)
diffValIn   = Params(5);       % diffusivity (cm^2/s)
nBack       = Params(6);       % background carrier concentration (cm^{-3})
alpha       = Params(7);       % absorption coefficient (cm^{-1})
reflection  = Params(8);       % reflection
thickness   = Params(9);       % film thickness (nm)
normFactor  = Params(14);      % PL normalization factor

% % rCoeffs = [1E9 1E9*1E12 1E9*1E12^2];     %# optional hard-coded recombination coefficients
% % SRV = 1E4;                               %# optional hard-coded SRV (cm/s)
% % nBack = 1E12;                            %# optional hard-coded background carrier concentration (cm^{-3})
% % thickness = 1000;                        %# optional hard-coded thickness (nm)
% % 
% % genType = 'delta';                       %# optional hard-coded generation profile type
% % injectType = 'low';                      %# optional hard-coded injection dependence type

yMesh = 20;                                  %# hard-coded y mesh size
dy = thickness/yMesh;                        %# thickness increment to step by (nm)
depthVect = (0:dy:thickness)';              % depth vector
numYPts = length(depthVect);
dY = dy/1E7;                            % convert to cm

meshFactor = 0.2;                         %# hard-coded "mesh factor"
Dcalc = diffFunc('p-type',diffValIn,nBack,injectType);
dt = meshFactor*dY^2/Dcalc*1E9;                        %# (optional?) hard-coded time increment to step by (ns)
timeVect = tData(1):dt:tData(end);                       %# (optional?) hard-coded time (ns)


%%% (do I?) NEED AN OPTION HERE TO INTERPOLATE THE 'TIME' VECTOR APPROPRIATELY ACCORDING TO THE VALUE OF 'dt'

numTPts = length(timeVect);
dT = dt/1E9;                             % convert to seconds

%%% Define the matrix for excess carrier concentration, DeltaN:
DeltaN = zeros(numYPts,numTPts);

%%% Define the generation function vector:
beamParams = [532 0.5 200E3 100^2*pi/4];             %# hard-coded values for beam parameters
% % alpha = 1E4;                                         %# optional hard-coded value for absorption coefficient (cm^(-1))
generation = genFunc(genType,reflection,alpha,beamParams,depthVect,timeVect);   %# pass generation type to this function


%%% Define a matrix to store diffusivity coefficients:
D = zeros(numYPts,numTPts);
% % D(:,1) = Dcalc;     %# optional(?) fix for diffusivity error
% % D(1,:) = Dcalc;     %# optional(?) fix for diffusivity error
% % D(end,:) = Dcalc;   %# optional(?) fix for diffusivity error

%%% Define the recombination function:
recombCoeffs = recombFunc('A',rCoeffs);    %# pass recombination type to this function
numR = length(recombCoeffs);

%%%%%% don't forget about the background carrier concentration, 'nBack', when you apply boundary conditions.


% initialize values if generation type is delta function
if strcmpi(genType,'delta')
    DeltaN(:,1) = generation(:,1) - nBack;
end

%%% Start up a waitbar to display the progress of the calculation
% % wb_ = waitbar(0, 'Calculating excess carrier concentration...', 'name', 'nSolve.m progress');

for jj = 2:numTPts
    
% %     waitbar(jj/numTPts)
    
    % Maybe some stuff? Dunno yet
    
    %%% THINK ABOUT THIS, JER. IT DOESN'T MAKE SENSE TO CALCULATE THE POINT IN FRONT BEFORE IT'S DEFINED...
    %%%... BUT I'M NOT. EVERY 'DeltaN' TERM TO THE RIGHT OF THE EQUALS SIGN HAS AN INDEX OF (jj-1).
    for kk = 2:(numYPts-1)
        recombination = DeltaN(kk,jj-1).^(1:numR)*recombCoeffs;     % Define recombination function
        D(kk,jj) = diffFunc('p-type',diffValIn,DeltaN(kk,jj-1),injectType);           % Define the diffusion coeffient (with injection-level dependence)
        %# pass diffusion type to this function
        
        DeltaN(kk,jj) = DeltaN(kk,jj-1) + dT*(D(kk,jj)/(dY^2)*(DeltaN(kk-1,jj-1) - 2*DeltaN(kk,jj-1) + DeltaN(kk+1,jj-1)) ...
            + generation(kk,jj) - recombination);
        
    end
    
    
    
    % Apply boundary conditions:
    
    %{Raf's method, using 'centered' value of n for injection dependence %}
    %%% may want to make SRV a function of n later on
    % %     DeltaN(1,jj)     = DeltaN(3, jj) - (2*dY*SRV./D(2,jj))*DeltaN(2,jj);
    % %     DeltaN(end,jj)   = DeltaN(end-2, jj) - (2*dY*SRV./D(end-1,jj))*DeltaN(end-1,jj);
    
    % My simplified version:
    % %     DeltaN(1,jj)     = DeltaN(2, jj) - (dY*SRV./D(2,jj))*DeltaN(2,jj);
    % %     DeltaN(end,jj)   = DeltaN(end-1, jj) - (dY*SRV./D(end-1,jj))*DeltaN(end-1,jj);
    
    % My more complicated (but more accurate?) version:
    DeltaN(1,jj)     = (DeltaN(2, jj) + dY*SRV/D(2,jj)*nBack)/(1 + dY*SRV/D(2,jj));
    DeltaN(end,jj)   = (DeltaN(end-1, jj) + dY*SRV/D(end-1,jj)*nBack)/(1 + dY*SRV/D(end-1,jj));
    
    
    
    
    
end

% % delete(wb_)


%%% Calculate the PL from Delta_n:

reabsorpVectdY = exp(-alpha*depthVect/1E7)*dY;      % account for film reabsorption
normFactor = 1/((DeltaN(:,1)').^2*reabsorpVectdY);      %# hard-coded normalization factor
% % normFactor = 1E-25;                                 %# hard-coded normalization factor

PLcalc = normFactor*((DeltaN').^2)*reabsorpVectdY;
PLcalcOut = interp1(timeVect,PLcalc,tData,'linear','extrap');

% % nSolveTest;

% % figure;
% % semilogy(tData,PLcalcOut);
% % grid on



end