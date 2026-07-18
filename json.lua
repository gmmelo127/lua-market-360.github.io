local json = {}

local function skip_whitespace(str, pos)
    while true do
        local c = str:sub(pos, pos)

        if c == " " or c == "\t" or c == "\r" or c == "\n" then
            pos = pos + 1
        else
            break
        end
    end

    return pos
end


local function parse_string(str, pos)

    pos = pos + 1 -- pula "

    local result = ""

    while pos <= #str do

        local c = str:sub(pos, pos)

        if c == '"' then
            return result, pos + 1
        end

        if c == "\\" then

            local nextChar = str:sub(pos + 1, pos + 1)

            if nextChar == "n" then
                result = result .. "\n"

            elseif nextChar == "r" then
                result = result .. "\r"

            elseif nextChar == "t" then
                result = result .. "\t"

            elseif nextChar == '"' then
                result = result .. '"'

            elseif nextChar == "\\" then
                result = result .. "\\"

            else
                result = result .. nextChar
            end

            pos = pos + 2

        else

            result = result .. c
            pos = pos + 1

        end

    end

    return nil, pos
end


local parse_value


local function parse_array(str, pos)

    local result = {}

    pos = pos + 1
    pos = skip_whitespace(str, pos)

    if str:sub(pos, pos) == "]" then
        return result, pos + 1
    end


    while true do

        local value
        value, pos = parse_value(str, pos)

        if value == nil then
            return nil
        end

        table.insert(result, value)

        pos = skip_whitespace(str, pos)

        local c = str:sub(pos, pos)

        if c == "]" then
            return result, pos + 1
        end

        if c ~= "," then
            return nil
        end

        pos = skip_whitespace(str, pos + 1)

    end

end


local function parse_object(str, pos)

    local result = {}

    pos = pos + 1
    pos = skip_whitespace(str, pos)


    if str:sub(pos, pos) == "}" then
        return result, pos + 1
    end


    while true do

        local key

        key, pos = parse_string(str, pos)

        if key == nil then
            return nil
        end


        pos = skip_whitespace(str, pos)


        if str:sub(pos, pos) ~= ":" then
            return nil
        end


        pos = skip_whitespace(str, pos + 1)


        local value

        value, pos = parse_value(str, pos)

        if value == nil then
            return nil
        end


        result[key] = value


        pos = skip_whitespace(str, pos)


        local c = str:sub(pos, pos)


        if c == "}" then
            return result, pos + 1
        end


        if c ~= "," then
            return nil
        end


        pos = skip_whitespace(str, pos + 1)

    end

end



local function parse_number(str, pos)

    local start = pos

    while str:sub(pos,pos):match("[%d%+%-%e%E%.]") do
        pos = pos + 1
    end


    local number = tonumber(str:sub(start, pos - 1))

    return number, pos

end



function parse_value(str, pos)

    pos = skip_whitespace(str, pos)

    local c = str:sub(pos,pos)


    if c == "{" then

        return parse_object(str, pos)


    elseif c == "[" then

        return parse_array(str, pos)


    elseif c == '"' then

        return parse_string(str, pos)


    elseif c == "-" or c:match("%d") then

        return parse_number(str, pos)


    elseif str:sub(pos,pos+3) == "true" then

        return true, pos + 4


    elseif str:sub(pos,pos+4) == "false" then

        return false, pos + 5


    elseif str:sub(pos,pos+3) == "null" then

        return nil, pos + 4

    end


    return nil

end



function json.decode(str)

    local result, pos = parse_value(str, 1)

    return result

end


return json
