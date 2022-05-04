local M = {}

function M.Schedule(interval, func, params)
    CSTimers.inst:Add(interval, 0, func, params)
    return func
end

function M.ScheduleOnce(interval, func, params)
    CSTimers.inst:Add(interval, 1, func, params)
    return func
end

function M.ScheduleNextFrame(func)
    M.ScheduleOnce(0, func)
end

function M.Unschedule(handler)
    CSTimers.inst:Remove(handler)
end

function M.Clear()
    CSTimers.inst:ClearAll()
end

Timer = M