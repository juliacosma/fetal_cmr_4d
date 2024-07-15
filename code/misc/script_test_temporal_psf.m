%  double ReconstructionCardiac4D::CalculateTemporalWeight( double cardphase0, double cardphase, double dt, double rr, double alpha )
%     {
%         double angdiff, dtrad, sigma, temporalweight;
%         
%         // Angular Difference
%         angdiff = CalculateAngularDifference( cardphase0, cardphase );
%         
%         // Temporal Resolution in Radians
%         dtrad = 2 * PI * dt / rr;
%         
%         // Temporal Weight
%         if (_is_temporalpsf_gauss) {
%             // Gaussian
%             sigma = dtrad / 2.355;  // sigma = ~FWHM/2.355
%             temporalweight = exp( -( angdiff * angdiff ) / (2 * sigma * sigma ) );
%         }
%         else {
%             // Sinc
%             temporalweight = sinc( PI * angdiff / dtrad ) * wintukey( angdiff, alpha );
%         }
%         
%         return temporalweight;
%     }
%     

angdiff = linspace(-pi,pi,1001);

tr = 5.72;

narm = 7;

dt = tr * narm;

rr = 462;

alpha = 0.3;

dtrad = 2 * pi * dt / rr;

sigma = dtrad / 2.355;  % sigma = ~FWHM/2.355
temporal_weight_gauss = @(angdiff) exp( -( angdiff .* angdiff ) / (2 * sigma * sigma ) );

temporal_weight_sinc = @(angdiff) sinc( angdiff / dtrad ) .* wintukey( angdiff, alpha );

acquisition_window = @(angdiff) 1 * abs(angdiff)<dtrad/2;

plot(angdiff/pi,acquisition_window(angdiff),angdiff/pi,temporal_weight_gauss(angdiff),angdiff/pi,temporal_weight_sinc(angdiff))

xlabel('\Delta\theta (\pi rad.)')

legend( sprintf('acquisition window (\\Deltat = %.3f \\pi rad.)',dtrad/pi), 'tPSF_{sinc}', sprintf('tPSF_{Guassian} (\\sigma = %.3f \\pi rad., FWHM = %.3f \\pi rad.)',sigma/pi,2.355*sigma/pi),'Location','SouthWest' )

function w = wintukey( angdiff, alpha )
    w = ( 1 + cos( ( abs( angdiff ) - pi * ( 1 - alpha ) ) / alpha ) ) / 2;
    w( abs( angdiff ) < pi * ( 1 - alpha ) ) = 1;
end

