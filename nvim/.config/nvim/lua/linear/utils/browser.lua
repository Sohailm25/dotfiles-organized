local Browser = {}

function Browser.open_url(url)
  local cmd
  
  if vim.fn.has("mac") == 1 then
    cmd = { "open", url }
  elseif vim.fn.has("unix") == 1 then
    cmd = { "xdg-open", url }
  else
    cmd = { "start", url }
  end
  
  vim.fn.jobstart(cmd, {
    detach = true,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.notify("Browser error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
      end
    end,
  })
end

return Browser