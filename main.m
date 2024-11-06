%% by Ali Bahrami Fard
% alibt1313@gmail.com
% DC STATE ESTIMATION
clc;
clear;
format short g;
%% inputs

%{
    IMPORTANT NOTE : when you enter the values of every data, it should be
    as same as the given examples in the book.
    meaning that P21 is NOT the same as P12 or X12 is NOT the same as X21
    (only in declairing them.) |:

    the order is also important. :(
%}

% 1.from bus    2.to bus    3.R     4.X
% should be in per unit
%{
    as mentioned in the note the from bus and to bus should be the same as
    the given examples in the book.
%}
line_data = [1,2,0,0.05917;
             1,5,0,0.22304;
             2,3,0,0.19797;
             2,4,0,0.17632;
             2,5,0,0.17388;
             3,4,0,0.17103;
             4,5,0,0.04211;
             4,7,0,0.20912;
             4,9,0,0.20912;
             5,6,0,0.25202;
             6,11,0,0.1989;
             6,12,0,0.25581;
             6,13,0,0.13027;
             7,8,0,0.17615;
             7,9,0,0.11001;
             9,10,0,0.0845;
             9,14,0,0.27038;
             10,11,0,0.19207;
             12,13,0,0.19988;
             13,14,0,0.34802;];

% the bus number that is the slack
slack_bus = 1;

% base value of the power in MW
s_base_mw = 100;

% accuracy value of each meter in MW
accuracy_mw = 3;

% the constant value of sigma
sigma = 3;

% converting sigma to PU
sigma_mw = accuracy_mw / sigma;
sigma_pu = sigma_mw / s_base_mw;

% 1.from bus    2.to bus    3.P  (enter in PU)
%{
    as mentioned in the note the from bus and to bus should be the same as
    the given examples in the book.
%}
power_information =[1,2,1.4784;
                    1,5,0.7116;
                    2,3,0.7001;
                    2,4,0.5515;
                    2,5,0.4097;
                    3,4,-0.2419;
                    4,5,-0.6175;
                    4,7,0.2836;
                    4,9,0.1655;
                    5,6,0.4279;
                    6,11,0.0763;
                    6,12,0.0761;
                    6,13,0.1725;
                    7,8,0.00;
                    7,9,0.2836;
                    9,10,0.0577;
                    9,14,0.0964;
                    10,11,-0.0323;
                    12,13,0.0151;
                    13,14,0.0526;];

power_information(:,3) = power_information(:,3) * 1.05;


% 1.from bus    2.to bus
%{
    as mentioned in the note the from bus and to bus should be the same as
    the given examples in the book.
    the order is also important.
%}
meter_location = [1,2;
                  1,5;
                  2,3;
                  2,4;
                  2,5;
                  3,4;
                  4,5;
                  4,7;
                  4,9;
                  5,6;
                  6,11;
                  6,12;
                  6,13;
                  7,8;
                  7,9;
                  9,10;
                  9,14;
                  10,11;
                  12,13;
                  13,14;];

number_of_meters = length(meter_location);

%% calculation of Xbus
%{
    calculating the X bus in order to calculate the H matrix
    first we convert the reactances to admitance then convert them to
    reactance again.

    we do the because it's easier to calculate the diagonal values of the
    matrix.
%}

% getting the number of buses (including the slack bus)
number_of_bus = max(max(line_data(:,2)), max(line_data(:,1)));

% getting all the reactances
all_x = line_data(:,4);

% creating the X bus matrix
x_bus = zeros(number_of_bus, number_of_bus);

% adding the none diagonal values to the X bus matrix
for l=1:length(line_data(:,4))
    x_bus(line_data(l,1), line_data(l,2)) = all_x(l);
    x_bus(line_data(l,2), line_data(l,1)) = x_bus(line_data(l,1), line_data(l,2));
end

% converting the diagonal values to admitance to sum them up
for n=1:number_of_bus
    for c=1:length(line_data(:,4))
        if line_data(c,1) == n || line_data(c,2) == n
            z = 1 / line_data(c,4);
            x_bus(n,n) = x_bus(n,n) + z;
        end
    end
end

% converting the diagonal values back to reactance
for i=1:length(x_bus(1,:))
    for x=1:length(x_bus(:,1))
        if i == x
            x_bus(i,x) = 1 / x_bus(i,x);
        end
    end
end

%% calculation of H matrix
% creating the H matrix (excluding the slack bus)
H = zeros(number_of_meters, number_of_bus - 1);
for i=1:number_of_meters
    % getting the line that the meter is installed on like : [1,2]
    current_meter_bus = meter_location(i,:);

    % getting the reactance value of the line that the meter is installed
    % on
    current_x = x_bus(current_meter_bus(1,1), current_meter_bus(1,2));
    
    %{
        checking if the meters location is not coressponding with the slack
        bus.
        if it's not then we calculate it and then put it in the same and
        reverse location as the meters location in the H matrix.     
    %}
    if current_meter_bus(1,1) ~= slack_bus && current_meter_bus(1,2) ~= slack_bus
            H(i,current_meter_bus(1,1)) = 1 / current_x;
            H(i,current_meter_bus(1,2)) = -1 * (1 / current_x);
    end
    
    %{
        if one of the locations is the same as the slack bus then we
        calculate it and put it in the location of the H matrix that is not
        the same as the slack bus.
        
        if its the second location (recieving) then we only divide it be
        one, other wise we divide it by one and then multiply it by -1
    %}
    if current_meter_bus(1,2) == slack_bus
       H(i,current_meter_bus(1,1)) = 1 / current_x;
    end

    if current_meter_bus(1,1) == slack_bus
       H(i,current_meter_bus(1,2)) = -1 * (1 / current_x);
    end
    
    %{
        sometimes the meter is connected on the bus itself not between the
        buses.
        in this case we check if the first location (sending) and the
        second location (recieving) are the same but they are not slack.
        first we get previus location and then we get it's reactance value
        from X bus.
        then we set it in the correct spots in the H matrix.
        and finally we do the same thing for the slack bus.
    %}
    if current_meter_bus(1,1) == current_meter_bus(1,2)
        if current_meter_bus(1,1) ~= slack_bus && current_meter_bus(1,2) ~= slack_bus
            z = current_meter_bus(1,1) -1;
            x2 = x_bus(z,current_meter_bus(1,2));
            H(i,z) = -1 * (1 / x2);
            H(i,current_meter_bus(1,2)) = 1 * (1 / current_x);
        end
    end
    
    if current_meter_bus(1,1) == current_meter_bus(1,2)
        if current_meter_bus(1,1) == slack_bus && current_meter_bus(1,2) == slack_bus
            z = current_meter_bus(1,1) -1;
            x2 = x_bus(z,current_meter_bus(1,2));
            H(i,z) = -1 * (1 / x2);
            H(i,current_meter_bus(1,2)) = 1 * (1 / current_x);
        end
    end
end

%{
    sometimes it also includes the slack bus in the H matrix.
    in here we remove the slack column if it happens
%}
if length(H(1,:)) > (number_of_bus - 1)
    H(:,slack_bus) = [];
end

H_transpose = transpose(H);

%% calculation of R matrix
R = zeros(number_of_meters, number_of_meters);
for i=1:length(R(:,1))
    for x=1:length(R(1,:))
        if i == x
            R(i,i) = sigma_pu ^ 2;
        end
    end
end

R(2,2) = 10e-6;
R(6,6) = 10e-6;
R(1,1) = 10e-6;
R(10,10) = 10e-6;
R(4,4) = 10e-6;
R_inverse = inv(R);

%% calculation of Xest
X_est = inv((H_transpose * R_inverse * H)) * H_transpose * R_inverse * power_information(:,3);

%% calculation of Zest
Z_est  = H * X_est;

%% calculation of J
J_x = 0;
for i=1:length(Z_est)
   J_x = J_x + (((power_information(i,3) - Z_est(i))^2) / (sigma_pu ^ 2));
end

%% printing the results
fprintf('====================================================================================================================================\n|                                                             Results                                                              |\n====================================================================================================================================\n');

fprintf('\t\t---------------------------------------------------- Matrix H ----------------------------------------------------\n\t\t\t');
fprintf([repmat('%.2f\t\t', 1, size(H, 2)) '\n\t\t\t'], H');

fprintf('\n\t\t----------------------------------------------- Matrix H transpose -----------------------------------------------\n\t\t\t');
fprintf([repmat('%.2f\t\t', 1, size(H_transpose, 2)) '\n\t\t\t'], H_transpose');

fprintf('\n\t\t---------------------------------------------------- Matrix R ----------------------------------------------------\n\t\t\t');
fprintf([repmat('%.5f\t\t', 1, size(R, 2)) '\n\t\t\t'], R');

fprintf('\n\t\t------------------------------------------------ Matrix R inverse ------------------------------------------------\n\t\t\t');
fprintf([repmat('%.1f\t\t', 1, size(R_inverse, 2)) '\n\t\t\t'], R_inverse');

fprintf('\n\t\t--------------------------------------------------- Matrix Xest --------------------------------------------------\n\t\t\t');
fprintf([repmat('%.3f\t\t', 1, size(X_est, 2)) '\n\t\t\t'], X_est');

fprintf('\n\t\t--------------------------------------------------- Matrix Zest --------------------------------------------------\n\t\t\t');
fprintf([repmat('%.3f\t\t', 1, size(Z_est, 2)) '\n\t\t\t'], Z_est');

fprintf('\n\t\t------------------------------------------------------- J(x) -----------------------------------------------------\n');
fprintf('\t\t\t%.3f\n',J_x);
