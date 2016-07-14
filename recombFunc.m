function R = recombFunc(recombType,rateConstants)

%     'recombFunc' produces a 3x1 vector 'R' that contains the rate constant
%     coefficients of the recombination expression. The recombination
%     mechanism to try (and thus the terms of 'R' that are equal ot zero) is
%     determined by the tag 'recombType'.
% 
%     Description of input arguments:
%     'recombType' = a character variable that describes the user-specified
%       recombination model to try.
%     'rateConstants' = 3x1 vector that containts the rate constant
%       coefficients that describe SRH, radiative, and Auger recombination,
%       respectively.
% 
%     Created:       February 5, 2016, Jeremy R. Poindexter.
%     Last modified: July 14, 2016, Jeremy R. Poindexter.


% Set all to zero at outset:
[k1, k2, k3] = deal(0);

% Dialog box to pick options: (there are seven:)


switch recombType
    case 'A'    % SRH recombination only
        k1 = rateConstants(1);
        
    case 'B'    % radiative recombination only
        k2 = rateConstants(2);
        
    case 'C'    % Auger recombination only
        k3 = rateConstants(3);
        
    case 'D'    % SRH + radiative
        k1 = rateConstants(1);
        k2 = rateConstants(2);
        
    case 'E'    % SRH + Auger
        k1 = rateConstants(1);
        k3 = rateConstants(3);
        
    case 'F'    % radiative + Auger
        k2 = rateConstants(2);
        k3 = rateConstants(3);
        
    case 'G'    % SRH + radiative + Auger
        k1 = rateConstants(1);
        k2 = rateConstants(2);
        k3 = rateConstants(3);
        
    otherwise
        error('Please select a valid recombination type.')
end

R = [k1; k2; k3];

end