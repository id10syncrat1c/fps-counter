local WINDOW_MS = 5000
local GRAPH_INTERVAL_MS = 100
local GRAPH_MAX_SAMPLES = 60

local previousFrameTime = nil
local frameSamples = {}
local graphSamples = {}
local lastGraphSample = 0

local currentFps = 0
local currentFrameTime = 0
local averageFps = 0
local lowFps = 0

local function resetStats()
  frameSamples = {}
  graphSamples = {}
  previousFrameTime = nil
  lastGraphSample = 0
  currentFps = 0
  currentFrameTime = 0
  averageFps = 0
  lowFps = 0
end

local function addGraphSample(value)
  graphSamples[#graphSamples + 1] = value
  if #graphSamples > GRAPH_MAX_SAMPLES then
    table.remove(graphSamples, 1)
  end
end

function script:init()
  resetStats()
end

function script:enterCity()
  resetStats()
end

function script:leaveCity()
  resetStats()
end

function script:update()
  local now = Runtime.getTime()

  if previousFrameTime == nil then
    previousFrameTime = now
    return
  end

  local delta = now - previousFrameTime
  previousFrameTime = now

  if delta <= 0 then
    return
  end

  currentFrameTime = delta
  currentFps = 1000 / delta

  frameSamples[#frameSamples + 1] = {
    time = now,
    delta = delta
  }

  local cutoff = now - WINDOW_MS
  while #frameSamples > 0 and frameSamples[1].time < cutoff do
    table.remove(frameSamples, 1)
  end

  local totalTime = 0
  local slowestFps = nil

  for i = 1, #frameSamples do
    local sample = frameSamples[i]
    totalTime = totalTime + sample.delta

    local sampleFps = 1000 / sample.delta
    if slowestFps == nil or sampleFps < slowestFps then
      slowestFps = sampleFps
    end
  end

  if totalTime > 0 then
    averageFps = (#frameSamples * 1000) / totalTime
    lowFps = slowestFps or 0
  end

  if now - lastGraphSample >= GRAPH_INTERVAL_MS then
    addGraphSample(currentFps)
    lastGraphSample = now
  end
end

function script:overlay()
  local screenWidth, screenHeight = Drawing.getSize()
  local panelWidth = 196
  local panelHeight = 112
  local margin = 12
  local x = screenWidth - panelWidth - margin
  local y = margin

  Drawing.reset()

  Drawing.setAlpha(0.84)
  Drawing.setColor(12, 15, 20)
  Drawing.drawRect(x, y, panelWidth, panelHeight)

  Drawing.setAlpha(1)
  Drawing.setColor(235, 240, 245)
  Drawing.drawText("FPS COUNTER", x + 10, y + 8)

  if currentFps > 0 then
    Drawing.setColor(125, 230, 160)
    Drawing.drawText(string.format("%.0f", currentFps), x + 10, y + 25)

    Drawing.setColor(190, 200, 210)
    Drawing.drawText(string.format("%.1f ms", currentFrameTime), x + 70, y + 29)
    Drawing.drawText(string.format("AVG  %.1f", averageFps), x + 10, y + 49)
    Drawing.drawText(string.format("LOW  %.1f", lowFps), x + 105, y + 49)
  else
    Drawing.setColor(190, 200, 210)
    Drawing.drawText("OPEN A CITY", x + 10, y + 29)
    Drawing.drawText("Waiting for frame samples", x + 10, y + 49)
  end

  local graphX = x + 10
  local graphY = y + 73
  local graphWidth = panelWidth - 20
  local graphHeight = 27

  Drawing.setColor(55, 65, 75)
  Drawing.drawRect(graphX, graphY, graphWidth, 1)

  if #graphSamples > 1 then
    local scaleMax = 60

    for i = 2, #graphSamples do
      local previousValue = graphSamples[i - 1]
      local value = graphSamples[i]

      local x0 = graphX + ((i - 2) / (GRAPH_MAX_SAMPLES - 1)) * graphWidth
      local x1 = graphX + ((i - 1) / (GRAPH_MAX_SAMPLES - 1)) * graphWidth
      local y0 = graphY + graphHeight - (math.min(previousValue, scaleMax) / scaleMax) * graphHeight
      local y1 = graphY + graphHeight - (math.min(value, scaleMax) / scaleMax) * graphHeight

      Drawing.setColor(95, 205, 145)
      Drawing.drawLine(x0, y0, x1, y1, 2)
    end
  end

  Drawing.reset()
end
