
require "common/RequestMessage"

-- (手动) -- [39550]购买文牒 -- 英雄副本 

REQ_HERO_PLATE_BUY = class(CRequestMessage,function(self)
	self.MsgID = Protocol.REQ_HERO_PLATE_BUY
	self:init()
end)

function REQ_HERO_PLATE_BUY.serialize(self, writer)
	writer:writeInt16Unsigned(self.count)  -- {文牒数量}
end

function REQ_HERO_PLATE_BUY.setArguments(self,count)
	self.count = count  -- {文牒数量}
end

-- {文牒数量}
function REQ_HERO_PLATE_BUY.setCount(self, count)
	self.count = count
end
function REQ_HERO_PLATE_BUY.getCount(self)
	return self.count
end
