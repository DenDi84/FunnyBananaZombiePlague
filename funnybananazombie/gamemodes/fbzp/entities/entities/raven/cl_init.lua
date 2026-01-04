include( "shared.lua" );


function ENT:Draw()
   self:DrawModel();
   for k,v in pairs( self:GetChildren() ) do
   	v:SetNoDraw( true );
   	for _,val in pairs( v:GetChildren() ) do
   		val:SetNoDraw( true );
   	end
   end
end