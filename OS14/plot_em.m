% EM.413 OS14 Question 1 Decision Aid
% Allows manipulation and visualization of Contianment (Performance) PDFs for OS14 Q1

% Define the X-axis: Containment Area from 0 to 30,000 sq meters
x = linspace(0, 30000, 1000);

%% -- DECISION 2: INSERTION METHOD CONTAINMENT -- %%

% -- Option 1: Containerized Guided Drone 
% Beta Dist: Highly accurate (sub-500m) with active propulsion to fight wind, but expensive. Bounds: 24k to 26k
% Parameters for Beta(α,β) scaled to [a1,b1]
alpha1 = 8; beta1 = 2;
a1 = 24000; b1 = 26000;
% Normalize x into [0,1] for the beta PDF
x_norm1 = (x - a1) / (b1 - a1); 
% Treat values outside the interval as missing for the scaled density
x_norm1(x_norm1 < 0 | x_norm1 > 1) = NaN; 
% Compute scaled beta PDF on original x units (divide by scaling width)
y1 = betapdf(x_norm1, alpha1, beta1) / (b1 - a1); 

% -- Option 2: Precision Guided Parafoil
% Beta Dist: Good GPS steering and lower cost, but passive gliding increases wind drift risk. Bounds: 22k to 26k
alpha2 = 5; beta2 = 2;
a2 = 22000; b2 = 26000;
x_norm2 = (x - a2) / (b2 - a2);
x_norm2(x_norm2 < 0 | x_norm2 > 1) = NaN; 
y2 = betapdf(x_norm2, alpha2, beta2) / (b2 - a2);

% -- Option 3: Ramp Extraction / Airbag 
% Normal Dist: Very cheap and simple, but unguided drop creates massive footprint uncertainty. Mu=14k, Sig=4k
mu3 = 14000; sigma3 = 4000;
y3 = normpdf(x, mu3, sigma3);

% -- Plotting D2 
figure(1);
plot(x, y1, 'b', 'LineWidth', 2, 'DisplayName', 'Guided Drone (Beta)'); hold on;
plot(x, y2, 'r', 'LineWidth', 2, 'DisplayName', 'Parafoil (Beta)');
plot(x, y3, 'g', 'LineWidth', 2, 'DisplayName', 'Airbag (Normal)');
title('Containment Area PDFs (D2: Insertion Method)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax = gca; ax.XAxis.Exponent = 0; ax.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

% -- D2 Math Correction Printout 
fprintf('\n--- CORRECTED D2 Containment Statistics (Update your table!) ---\n');
mu_std1 = alpha1 / (alpha1 + beta1);
var_std1 = (alpha1 * beta1) / ((alpha1 + beta1)^2 * (alpha1 + beta1 + 1));
fprintf('Option 1 (Drone):    Mu = %.0f m^2 | Sigma = %.0f m^2\n', a1 + (mu_std1 * (b1 - a1)), sqrt(var_std1 * (b1 - a1)^2));
mu_std2 = alpha2 / (alpha2 + beta2);
var_std2 = (alpha2 * beta2) / ((alpha2 + beta2)^2 * (alpha2 + beta2 + 1));
fprintf('Option 2 (Parafoil): Mu = %.0f m^2 | Sigma = %.0f m^2\n', a2 + (mu_std2 * (b2 - a2)), sqrt(var_std2 * (b2 - a2)^2));
fprintf('Option 3 (Airbag):   Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', mu3, sigma3);

%% -- DECISION 7: COMMUNICATIONS CONTAINMENT -- %%

% -- Option 1: Per-Robot SATCOM
% Beta Dist: Highly reliable, minor canopy masking risk. Bounds: 22k to 26k
alpha4 = 8; beta4 = 2;
a4 = 22000; b4 = 26000;
x_norm4 = (x - a4) / (b4 - a4);
x_norm4(x_norm4 < 0 | x_norm4 > 1) = NaN;
y4 = betapdf(x_norm4, alpha4, beta4) / (b4 - a4);

% -- Option 2: Ground C2 Node (Localized RF) 
% Triangular Dist: Susceptible to terrain masking. 
% Min (a) = 12k, Mode (c) = 24k, Max (b) = 26k

% Define triangular membership breakpoints (left, peak, right)
a_tri = 12000; c_tri = 24000; b_tri = 26000;
% Preallocate output vector matching input x
y5 = zeros(size(x));
% Compute increasing side where x between left and peak
idx1 = (x >= a_tri & x <= c_tri);
y5(idx1) = 2 * (x(idx1) - a_tri) / ((b_tri - a_tri) * (c_tri - a_tri)); % Upward slope
% Compute decreasing side where x between peak and right
idx2 = (x > c_tri & x <= b_tri);
y5(idx2) = 2 * (b_tri - x(idx2)) / ((b_tri - a_tri) * (b_tri - c_tri)); % Downward slope

% -- Option 3: Airborne Relay Node 
% Beta Dist: Excellent LOS, but UAS refuel/loiter gaps. Bounds: 18k to 26k
alpha6 = 5; beta6 = 2;
a6 = 18000; b6 = 26000;
x_norm6 = (x - a6) / (b6 - a6);
x_norm6(x_norm6 < 0 | x_norm6 > 1) = NaN;
y6 = betapdf(x_norm6, alpha6, beta6) / (b6 - a6);

% -- Plotting D7 
figure(2);
plot(x, y4, 'Color', [0.00, 0.25, 0.45], 'LineWidth', 2.5, 'DisplayName', 'Per-Robot SATCOM (Beta)'); hold on;
plot(x, y5, 'Color', [0.85, 0.33, 0.10], 'LineWidth', 2.5, 'DisplayName', 'Ground Node RF (Triangular)');
plot(x, y6, 'Color', [0.00, 0.60, 0.65], 'LineWidth', 2.5, 'DisplayName', 'Airborne Relay (Beta)');
title('Containment Area PDFs (D7: Communications)');
xlabel('Containment Area (m^2)'); ylabel('Probability Density');
legend('Location', 'NorthWest'); grid on; xlim([0 30000]);
ax2 = gca; ax2.XAxis.Exponent = 0; ax2.YAxis.Exponent = 0;
xtickformat('%,.0f'); ytickformat('%.5f'); 

% -- D7 Math Printout --
fprintf('--- D7 Containment Statistics (For Table) ---\n');
mu_std4 = alpha4 / (alpha4 + beta4);
var_std4 = (alpha4 * beta4) / ((alpha4 + beta4)^2 * (alpha4 + beta4 + 1));
fprintf('Option 1 (SATCOM):   Mu = %.0f m^2 | Sigma = %.0f m^2\n', a4 + (mu_std4 * (b4 - a4)), sqrt(var_std4 * (b4 - a4)^2));
fprintf('Option 2 (Ground):   Mu = %.0f m^2 | Sigma = %.0f m^2 (Note: Tri mean is (a+b+c)/3)\n', (a_tri+b_tri+c_tri)/3, sqrt((a_tri^2+b_tri^2+c_tri^2 - a_tri*b_tri - a_tri*c_tri - b_tri*c_tri)/18));
mu_std6 = alpha6 / (alpha6 + beta6);
var_std6 = (alpha6 * beta6) / ((alpha6 + beta6)^2 * (alpha6 + beta6 + 1));
fprintf('Option 3 (Airborne): Mu = %.0f m^2 | Sigma = %.0f m^2\n\n', a6 + (mu_std6 * (b6 - a6)), sqrt(var_std6 * (b6 - a6)^2));