function  [cursorShow] = CheckIfMouseIsClosetoCenter(Movement_dis,params,window,x_mouse,y_mouse,cursorShow)
cursorShow = false;
if Movement_dis <= params.searchingdistance
    cursorShow = true;
end
    
end







