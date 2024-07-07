-- Function to detect architecture
function get_host_arch()
    -- For Windows
    if os.host() == "windows" then
        return os.getenv("PROCESSOR_ARCHITECTURE"):lower()
    end
    
    -- For Unix-like systems (including macOS)
    local arch = io.popen("uname -m"):read("*l")
    return arch:lower()
end

-- Function to determine Deftgt
function get_deftgt()
    local host = os.host()
    local arch = get_host_arch()
    
    if host == "windows" then
        return "T_amd64_win"
    elseif host == "macosx" then
        if arch == "arm64" then
            return "T_arm64_apple"
        else
            return "T_amd64_apple"
        end
    else -- Assume Unix
        if arch == "x86_64" then
            return "T_amd64_sysv"
        elseif arch == "aarch64" or arch == "arm64" then
            return "T_arm64"
        elseif arch == "riscv64" then
            return "T_rv64"
        else
            error("Unsupported Unix architecture: " .. arch)
        end
    end
end

workspace "qbe"
    configurations { "Debug", "Release" }

project "qbe"
    kind "ConsoleApp"
    language "C"
    cdialect "C99"
    targetdir "bin/%{cfg.buildcfg}"
    
    -- Include all source files
    files { "**.c", "**.h" }
    
    -- Generate config.h
    prebuildcommands {
        '{MKDIR} %{cfg.objdir}',
        'echo "#define Deftgt ' .. get_deftgt() .. '" > %{cfg.objdir}/config.h'
    }
    
    -- Add the generated config.h to include paths
    includedirs { "%{cfg.objdir}" }
    
    filter "configurations:Debug"
        defines { "DEBUG" }
        symbols "On"
    
    filter "configurations:Release"
        defines { "NDEBUG" }
        optimize "On"
    
    -- OS-specific settings
    filter "system:windows"
        buildoptions { "/W4" }
        defines { "_CRT_SECURE_NO_WARNINGS", "_WINDOWS_COMPAT" }
    
    filter "system:not windows"
        buildoptions { "-Wall", "-Wextra", "-Wpedantic" }