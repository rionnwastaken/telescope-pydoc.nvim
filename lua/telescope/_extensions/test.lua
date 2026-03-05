local a = {}

local function b(t)

    t['hey'] = "hello"
end

b(a)

print( vim.inspect(a) )
