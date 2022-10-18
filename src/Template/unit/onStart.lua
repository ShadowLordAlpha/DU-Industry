

coroutinesTable  = {}
--all functions here will become a coroutine
MyCoroutines = {
    function()
        for i=0, 10 do
            system.print("function 1 --- "..i)
            coroutine.yield(coroutinesTable[1])--start with index 1 and so on
        end
    end,
    function()
        for i=0, 10 do
            system.print("function 2 --- "..i)
            coroutine.yield(coroutinesTable[2])--the second fonction yiel is with index 2
        end
    end
}

function initCoroutines()
    for _,f in pairs(MyCoroutines) do
        local co = coroutine.create(f)
        table.insert(coroutinesTable, co)
    end
end

initCoroutines()

runCoroutines = function()
    for i,co in ipairs(coroutinesTable) do
        if coroutine.status(co) == "dead" then
            coroutinesTable[i] = coroutine.create(MyCoroutines[i])
        end
        if coroutine.status(co) == "suspended" then
            assert(coroutine.resume(co))
        end
    end
end

MainCoroutine = coroutine.create(runCoroutines)
