include( "shared.lua" );

local round = {};

function ENT:Think()
	round.type = self:GetNWString("round.type", 0);
	round.name = self:GetNWString("round.name", 0);
	round.time = self:GetNWInt("round.time", 0);

	if ( !IsEmpty( round.type ) and round.type != 0 ) then
		local time = GetMinuteFromSec(round.time);
		if (!IsEmpty(mainmenu)) then
			mainmenu:SetData( "TimerBlock", time.source );
			mainmenu:SetData( "RoundNameBlock", round.name );
			mainmenu.html:Call( [[SetLevel(']]..LocalPlayer():GetNWInt("exp", 0)..[[')]] );
		end
	end
	self:SetNextClientThink( CurTime() + 1 );
	return true;
end