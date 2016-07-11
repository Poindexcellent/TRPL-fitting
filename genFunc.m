function G = genFunc(genType,ref,alpha,beamParams,depthVect,timeVect)

% genFunc produces a vector 'genFuncOut' that is the calculated generation (at the illumination wavelength) as a
% function of depth, specified by 'YPts'.

% ref = reflectance at wavelength of interest
% alpha = absorption coefficient at wavelength of interest (cm^-1)

% beamParams = a 1x4 vector of the following parameters: 
% 1) wavelength = wavelength of incident beam (nm)
% 2) power = measured power of beam (uW)
% 3) pulseRate = pulse rate of incident beam (Hz)
% 4) beamArea = area of beam (um^2)

% Output, G, is in photons/(cm^3).

% Created February 5, 2016, Jeremy R. Poindexter.
% Last modified February 19, 2016, Jeremy R. Poindexter.


%%% Define some constants:
h = 6.626E-34;      % Planck's constant (J-s)
c = 2.9979E8;       % speed of light (m/s)


%%% Calculate light flux from power, pulse rate, wavelength, and area:
wavelength  = beamParams(1);
power       = beamParams(2);
pulseRate   = beamParams(3);
beamArea    = beamParams(4);

alpha2 = alpha/1E7;  % convert alpha to nm^-1
beamArea = beamArea/(1E8);      % convert to cm^2 from um^2

TPts = length(timeVect);
YPts = length(depthVect);


energyPerPulse = (power*1E-6)/pulseRate;                    % (J)
photonFlux = energyPerPulse*(wavelength*1E-9/(h*c))/beamArea;    % (photons/(cm^2))


G = zeros(YPts,TPts);

switch lower(genType)
    case 'delta'
        for aa = 1:YPts
            %%% MAYBE FIX DEFINITION FOR DELTA FUNCTION BASED ON WHAT RAF DOES IN numFC?
            G(aa,1) = photonFlux*(alpha)*(1-ref)*exp(-alpha2*depthVect(aa));
        end

    case 'square'
        %% SECTION INCOMPLETE
        
                for aa = 1:YPts
            
            
            for bb = 1:TPts
                
                %%% USE 'timeVect(bb)' HERE SOMEWHERE
                G = photonFlux*alpha*(1-ref)*exp(-alpha*x);
                
            end
            
        end
        
    case 'Gaussian'
        %% SECTION INCOMPLETE
                for aa = 1:YPts
            
            
            for bb = 1:TPts
                
                
                G = photonFlux*alpha*(1-ref)*exp(-alpha*x);
                
            end
            
        end
end



end