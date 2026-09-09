local VideoPlayer = {}
VideoPlayer.__index = VideoPlayer

function VideoPlayer.new(screen: SurfaceGui)
	return setmetatable({
		screen = screen,
	}, VideoPlayer)
end

function VideoPlayer:play(sequence: { string })
	self:stop()
	self.playing = task.spawn(function()
		while true do
			for _, id in sequence do
				self.current = self.screen:FindFirstChild(id)
				self.current.Playing = true
				self.current.Visible = true
				self.current.Ended:Wait()
				self.current.Playing = false
				self.current.Visible = false
				self.current.TimePosition = 0
			end
		end
	end)
end

function VideoPlayer:preload(sequence: { string })
	for _, id in sequence do
		local video = Instance.new("VideoFrame")
		video.Name = id
		video.Size = UDim2.fromScale(1, 1)
		video.Video = id
		video.Visible = false
		video.Parent = self.screen
		-- HACK: force roblox to preload the video
		video.Playing = true
		video.Playing = false
	end
end

function VideoPlayer:preloadArray(array: { { string } })
	for _, sequence in array do
		self:preload(sequence)
	end
end

function VideoPlayer:pause()
	if self.current then
		self.current:Pause()
	end
end

function VideoPlayer:resume()
	if self.current then
		self.current:Play()
	end
end

function VideoPlayer:stop()
	if self.playing and coroutine.status(self.playing) == "suspended" then
		task.cancel(self.playing)
		self.playing = nil
	end

	if self.current then
		self.current = nil
	end

	for _, frame in self.screen:GetChildren() do
		frame.Visible = false
		frame.Playing = false
		frame.TimePosition = 0
	end
end

function VideoPlayer:hide()
	if self.current then
		self.current.Visible = false
	end
end

function VideoPlayer:show()
	if self.current then
		self.current.Visible = true
	end
end

return VideoPlayer
