local AttributeHandler = {}

function AttributeHandler:GetAttribute(hum: Humanoid, Attribute: string)
	return hum:GetAttribute(Attribute)
end

function AttributeHandler:SetAttribute(hum: Humanoid, Attribute: string, value: boolean?)
	return hum:SetAttribute(Attribute, value)
end

return AttributeHandler
