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

function get_configH()
    return "#define Deftgt " .. get_deftgt()
end

workspace "qbe"
    configurations { "Debug", "Release" }

project "qbe"
    kind "ConsoleApp"
    language "C"
    cdialect "C99"
    targetdir "bin/%{cfg.buildcfg}"
    
    -- Generate config.h
    ok, err = os.writefile_ifnotequal( get_configH(), "config.h" )
    if( not ok ) then
        print( "Failed to remake config.h file!" )
        print( err )
    end
    
    -- Include all source files
    files { "*.c", "*.h" }
    files { "compat/*.c", "compat/*.h" }
    files { "amd64/*.c", "amd64/*.h" }
    files { "arm64/*.c", "arm64/*.h" }
    files { "rv64/*.c", "rv64/*.h" }
    
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