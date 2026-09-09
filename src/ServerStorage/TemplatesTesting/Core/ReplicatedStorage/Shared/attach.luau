return function(part: BasePart, base: BasePart)
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part
    weld.Part1 = base
    weld.Parent = part
    return weld
end