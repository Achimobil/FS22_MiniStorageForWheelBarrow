
print("FS22_PrivateScriptsInTesting: Silo mit Autostart geht jetzt auch wenn multiple filltypes möglich sind")

ShowOnlyInSilo = {}
function ShowOnlyInSilo:toggleLoading()
	if not self.isLoading then
		local fillLevels = self.source:getAllFillLevels(g_currentMission:getFarmId())
		local fillableObject = self.validFillableObject
		local fillUnitIndex = self.validFillableFillUnitIndex
		local firstFillType = nil
		local validFillLevels = {}
		local numFillTypes = 0

		for fillTypeIndex, fillLevel in pairs(fillLevels) do
			if (self.fillTypes == nil or self.fillTypes[fillTypeIndex]) and fillableObject:getFillUnitAllowsFillType(fillUnitIndex, fillTypeIndex) then
				validFillLevels[fillTypeIndex] = fillLevel

				if firstFillType == nil and fillLevel > 0 then
					firstFillType = fillTypeIndex
				end

				numFillTypes = numFillTypes + 1
			end
		end

		if not self.autoStart and numFillTypes > 1 then
			local startAllowed = true
			local controlledVehicle = g_currentMission.controlledVehicle

			if controlledVehicle.getIsActiveForInput ~= nil then
				startAllowed = controlledVehicle:getIsActiveForInput(true)
			end

			if startAllowed then
				local text = string.format("%s", self.source:getName())

				g_gui:showSiloDialog({
					title = text,
					fillLevels = validFillLevels,
					callback = self.onFillTypeSelection,
					target = self,
					hasInfiniteCapacity = self.hasInfiniteCapacity
				})

				if GS_IS_MOBILE_VERSION then
					local rootVehicle = fillableObject.rootVehicle

					if rootVehicle.brakeToStop ~= nil then
						rootVehicle:brakeToStop()
					end
				end
			end
		else
			self:onFillTypeSelection(firstFillType)
		end
	else
		self:setIsLoading(false)
	end
end


LoadTrigger.toggleLoading = Utils.overwrittenFunction(LoadTrigger.toggleLoading, ShowOnlyInSilo.toggleLoading)