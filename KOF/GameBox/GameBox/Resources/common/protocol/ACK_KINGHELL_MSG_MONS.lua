
require "common/AcknowledgementMessage"

-- [44640]怪物信息块 -- 阎王殿 

ACK_KINGHELL_MSG_MONS = class(CAcknowledgementMessage,function(self)
	self.MsgID = Protocol.ACK_KINGHELL_MSG_MONS
	self:init()
end)

-- {怪物id}
function ACK_KINGHELL_MSG_MONS.getMonsId(self)
	return self.mons_id
end

-- {怪物类型,见CONST_KINGHELL_*}
function ACK_KINGHELL_MSG_MONS.getType(self)
	return self.type
end

-- {0：已经挑战；1：正在挑战 2：不可挑战}
function ACK_KINGHELL_MSG_MONS.getState(self)
	return self.state
end

-- {状态(0：单挑失败1：单挑胜利)}
function ACK_KINGHELL_MSG_MONS.getIsDant(self)
	return self.is_dant
end
