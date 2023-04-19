local M = {}

function M.run_command(command)
    vim.fn.jobstart(command, {
        on_stdout = function(_, _, _)
            vim.schedule(function() print("Running: " .. command) end)
        end,
        on_exit = function(_, code, _)
            vim.schedule(function()
                if code == 0 then
                    print("Command " .. command .. " succesfully executed")
                else
                    print("Command " .. command .. " execution failed")
                end
            end)
        end,
        stderr_buffered = true -- Enable buffering for stderr
    })
end

function M.has_command(command)
    local cmd = io.popen("command -v " .. command):read("*a")
    return cmd ~= ""
end

return M
