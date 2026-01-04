FONT = {};
FONT.data = {};

function FONT:Create(name)
	surface.CreateFont( name, self.data );
	print("CreateFont: "..name);
end
function FONT:Init()
	self.data = {};
	self:font():extended():weight():blursize():scanlines():antialias():underline():italic():strikeout():symbol():rotary():shadow():additive():outline();
	return self;
end
function FONT:font( value )
	self.data.font = value;
	return self;
end
function FONT:extended( value )
	self.data.extended = value or true;
	return self;
end
function FONT:size( value )
	self.data.size = value or 10;
	return self;
end
function FONT:weight( value )
	self.data.weight = value or 500;
	return self;
end
function FONT:blursize( value )
	self.data.blursize = value or 0;
	return self;
end
function FONT:scanlines( value )
	self.data.scanlines = value or 0;
	return self;
end
function FONT:antialias( value )
	self.data.antialias = value or true;
	return self;
end
function FONT:underline( value )
	self.data.underline = value or false;
	return self;
end
function FONT:italic( value )
	self.data.italic = value or false;
	return self;
end
function FONT:strikeout( value )
	self.data.strikeout = value or false;
	return self;
end
function FONT:symbol( value )
	self.data.symbol = value or false;
	return self;
end
function FONT:rotary( value )
	self.data.rotary = value or false;
	return self;
end
function FONT:shadow( value )
	self.data.shadow = value or false;
	return self;
end
function FONT:additive( value )
	self.data.additive = value or true;
	return self;
end
function FONT:outline( value )
	self.data.outline = value or false;
	return self;
end

FONT:Init()
	:size(60)
	:font( "CloseCaption_Bold" )
	:Create("Number");

FONT:Init()
	:size(60)
	:font( "CloseCaption_Bold" )
	:blursize(6)
	:Create("NumberBlur");

FONT:Init()
	:size(30)
	:font( "CloseCaption_Bold" )
	:Create("NumberMini");

FONT:Init()
	:size(30)
	:blursize(5)
	:font( "CloseCaption_Bold" )
	:Create("NumberMiniBlur");

FONT:Init()
	:size(20)
	:shadow(true)
	:Create("TextMini");