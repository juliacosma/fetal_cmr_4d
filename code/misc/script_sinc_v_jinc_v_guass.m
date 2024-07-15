
x = linspace(-5,5,1001) * pi;

jinc = @(x) 2*besselj(1,x)./x.*(x~=0) + ones(size(x)).*(x==0);  % Based on https://github.com/johndgiese/matlab/blob/master/jinc.m

gaussAlpha = 8.35;
guassStd   = (numel(x)-1)/(2*gaussAlpha);


plot(x/pi,sinc(x/pi),x/pi,jinc(x),x/pi,gausswin(numel(x),gaussAlpha))
xlabel('\pi')
legend('sinc','jinc',sprintf('Gauss (\\alpha=%g)',gaussAlpha))
grid on
