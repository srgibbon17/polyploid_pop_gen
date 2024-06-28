% for the HE2 case under selection-mutation balance

syms g00 g01 g10 g11 s h1 h2 h3 mu

% assumptions on the parameters of the model; theoretical bounds
assume(g00>=0 & g00<=1);
assume(g10>=0 & g10<=1);
assume(g01>=0 & g01<=1);
assume(g11>=0 & g11<=1);
assume(s>=0 & s<=1);
assume(h1>=0 & h1<=1);
assume(h2>=0 & h2<=1);
assume(h3>=0 & h3<=1);
assume(mu>=0 & mu<=1);

% equations to parameterize relative fitnesses
wbar = (1-2*s*(h1*(g00*g10+g00*g01)+h2*(g00*g11+g01*g10)+h3*(g01*g11+g10*g11))-s*(h2*(g01^2+g10^2)+g11^2));
w0 = 1/wbar;
w1 = (1-s*h1)/wbar;
w2 = (1-s*h2)/wbar;
w3 = (1-s*h3)/wbar;
w4 = (1-s)/wbar;

% equations for selection
sel_g00 = g00^2*w0+g00*g01*w1+g00*g10*w1+(1/2)*g01*g10*w2+(1/2)*g00*g11*w2;
sel_g10 = g00*g10*w1+g10^2*w2+(1/2)*g01*g10*w2+(1/2)*g00*g11*w2+g10*g11*w3;
sel_g01 = g00*g01*w1+g01^2*w2+(1/2)*g01*g10*w2+(1/2)*g00*g11*w2+g01*g11*w3;
sel_g11 = (1/2)*g01*g10*w2+(1/2)*g00*g11*w2+g01*g11*w3+g10*g11*w3+g11^2*w4;

% equations for mutation
mut_g00 = sel_g00*(1-mu)^2 - g00 == 0;
mut_g01 = sel_g00*mu*(1-mu) + sel_g01*(1-mu) - g01 == 0;
mut_g10 = sel_g00*mu*(1-mu) + sel_g10*(1-mu) - g10 == 0;
mut_g11 = sel_g00*mu^2 + sel_g01*mu + sel_g10*mu + sel_g11 - g11 == 0;

mut_eqn_set = [mut_g00, mut_g01, mut_g10, mut_g11];

for i = 1:length(mut_eqn_set)
    % removes g11 from the equation by replacing it with 1-(g00+g01+g10)
    mut_eqn_set(i) = subs(mut_eqn_set(i), g11, 1-(g00+g01+g10));
end

iterations = 7;


h1_val = .25;
h2_val = .5;
h3_val = .75;

g00_values_array = zeros(1, iterations^2);
g01_values_array = zeros(1, iterations^2);
g10_values_array = zeros(1, iterations^2);
s_values_array = zeros(1, iterations^2);
mu_values_array = zeros(1, iterations^2);

mu_init_val = 1e-6;
mu_step_size = 1e-3;
s_step_size = 1e-3;
for i = 1:iterations
    s_init_val = 1e-6;
    for j = 1:iterations
    
        s_values_array((i-1)*iterations+j) = s_init_val;
        mu_values_array((i-1)*iterations+j) = mu_init_val;

        [g00_value, g01_value, g10_value] = numeric_solver(mut_eqn_set(1), mut_eqn_set(2), mut_eqn_set(3), mu, mu_init_val, s, s_init_val, h1, h1_val, h2, h2_val, h3, h3_val, g00, g01, g10);

        for k = 1:length(g00_value)
            if g00_value(k) > 0 && g00_value(k) <= 1
                g00_values_array((i-1)*iterations+j) = g00_value(k);
            end
        end

        for k = 1:length(g01_value)
            if g01_value(k) > 0 && g01_value(k) <= 1
                g01_values_array((i-1)*iterations+j) = g01_value(k);
            end
        end

        for k = 1:length(g10_value)
            if g10_value(k) > 0 && g10_value(k) <= 1
                g10_values_array((i-1)*iterations+j) = g10_value(k);
            end
        end
        
        s_init_val = s_init_val + s_step_size;
        
    end
    mu_init_val = mu_init_val + mu_step_size;
end


q_values_array = (2*g00_values_array + g01_values_array + g10_values_array)/2;

figure

scatter3(s_values_array, mu_values_array, q_values_array)

xscale log

title('Allele Frequency vs. Selection and Mutation')
zlabel('q (ancestral allele frequency)')
ylabel('mu')
xlabel('s (selection coefficient)')


function [g00_value, g01_value, g10_value] = numeric_solver(mut_g00_eqn, mut_g01_eqn, mut_g10_eqn, mu, mut_value, s, sel_value, h1, h1_value, h2, h2_value, h3, h3_value, g00, g01, g10)

    g00_eqn = subs(mut_g00_eqn, mu, mut_value);
    g00_eqn = subs(g00_eqn, s, sel_value);
    g00_eqn = subs(g00_eqn, h1, h1_value);
    g00_eqn = subs(g00_eqn, h2, h2_value);
    g00_eqn = subs(g00_eqn, h3, h3_value);

    g01_eqn = subs(mut_g01_eqn, mu, mut_value);
    g01_eqn = subs(g01_eqn, s, sel_value);
    g01_eqn = subs(g01_eqn, h1, h1_value);
    g01_eqn = subs(g01_eqn, h2, h2_value);
    g01_eqn = subs(g01_eqn, h3, h3_value);

    g10_eqn = subs(mut_g10_eqn, mu, mut_value);
    g10_eqn = subs(g10_eqn, s, sel_value);
    g10_eqn = subs(g10_eqn, h1, h1_value);
    g10_eqn = subs(g10_eqn, h2, h2_value);
    g10_eqn = subs(g10_eqn, h3, h3_value);

    [g00_value, g01_value, g10_value] = vpasolve([g00_eqn, g01_eqn, g10_eqn], [g00, g01, g10]);

end