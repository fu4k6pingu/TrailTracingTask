function region = point2Region(point, threshold)
    
    x = point(1)-((threshold-1)/2):point(1)+((threshold-1)/2);
    y = point(2)-((threshold-1)/2):point(2)+((threshold-1)/2);
    region = CombVec(x, y)';
    
end