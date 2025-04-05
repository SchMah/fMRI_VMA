 function Rot_Deg = VisualFB_Matrix(params)

Rot_Deg = zeros (params.n_blcks,params.n_Trials_blck);
for i = 1 : params.n_blcks
   Rot_Deg(i, :) = params.rotation(i);
end
 end