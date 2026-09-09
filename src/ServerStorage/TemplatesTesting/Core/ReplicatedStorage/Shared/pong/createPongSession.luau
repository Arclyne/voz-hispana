local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ball = require(script.Parent.Ball)
local Paddle = require(script.Parent.Paddle)

export type Pong = {
	ball: Ball.Ball,

	player1: Player,
	paddle1: Paddle.Paddle,
	score1: number,

	player2: Player,
	paddle2: Paddle.Paddle,
	score2: number,

	destroy: () -> (),
}

return function(player1: Player, player2: Player, model: Model): Pong
	local paddle1Part = model:FindFirstChild("Paddle1", true) :: BasePart
	local paddle2Part = model:FindFirstChild("Paddle2", true) :: BasePart
	local ballPart = model:FindFirstChild("Ball", true) :: BasePart
	assert(paddle1Part and paddle1Part:IsA("BasePart"), "[pong] missing Paddle1 BasePart")
	assert(paddle2Part and paddle2Part:IsA("BasePart"), "[pong] missing Paddle2 BasePart")
	assert(ballPart and ballPart:IsA("BasePart"), "[pong] missing Ball BasePart")

	local paddle1 = Paddle.new(model, paddle1Part, player1)
	local paddle2 = Paddle.new(model, paddle2Part, player2)
	local ball = Ball.new(model, ballPart, paddle1, paddle2)

	return {
		ball = ball,

		player1 = player1,
		paddle1 = paddle1,
		score1 = 0,

		player2 = player2,
		paddle2 = paddle2,
		score2 = 0,

		destroy = function()
			paddle1:destroy()
			paddle2:destroy()
			ball:destroy()
		end,
	}
end
