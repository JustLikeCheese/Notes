-- 读取文件
local function read_file(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
end

-- 写入文件
local function write_file(path, content)
    local file = io.open(path, "w+")
    if not file then return nil end
    file:write(content)
    file:close()
end

-- 获取文件名称
local function get_filename(str)
    local idx = str:match(".+()%.%w+$")
    if idx then
        return str:sub(1, idx - 1)
    else
        return str
    end
end

-- 获取文件后缀
local function get_extension(str) return str:match(".+%.(%w+)$") end

-- 指定存放文件夹
local DIRECTORY = nil

-- 处理图片路径
local function replace_src(content)
    local sources = {}
    local pattern = '<img%s+src="(.-)"(.-)>'
    for source, attrs in string.gmatch(content, pattern) do
        table.insert(sources, source)
        io.write(#sources .. ". 找到图片标签: " .. source ..
                     " (space/name)  ")
        local choice = io.read()
        if choice == "" then
            io.write("已跳过\n")
        else
            -- 替换 content
            local new_path =  (DIRECTORY or "") .. choice .. "." .. get_extension(source)
            os.execute("curl -o " .. new_path .. " " .. source)
            content = string.gsub(content, '<img%s+src="' ..  source .. '"' ..
                                      attrs .. '>',
                                  '<img src="' .. new_path .. '"' .. attrs .. '>')
        end
    end
    return content
end

-- 指定存放文件夹
DIRECTORY = "images/readme2/"

while true do
    io.write("请输入要处理的文件(不用 .md 后缀)：")
    local input_file = io.read()
    if input_file == "" then break end
    input_file = input_file .. ".md"
    local filename = get_filename(input_file) or ""
    local extension = get_extension(input_file) or ""
    if filename == "" then break end
    local content = read_file(input_file)
    if content == nil then error("读取文件失败") end
    write_file(string.format("%s.out.%s", filename,
                             extension), replace_src(content))
end
