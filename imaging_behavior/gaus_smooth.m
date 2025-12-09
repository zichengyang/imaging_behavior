function data = gaus_smooth(times, range, sigma)     %¸ßË¹Æ½»¬

number_of_times = length(times);

data = zeros(size(range));

for i = 1:number_of_times

    data = gaussmf(range,[sigma, times(i)]) + data; 
    
end

data = data/(sigma*(pi*2)^0.5);
