function panguDir()
    @load_preference("panguDir", nothing)
end

function javasdkDir()
    @load_preference("javasdkDir", nothing)
end

# Only to be run once and for all
function setup(; panguDir=nothing, jdkDir=nothing)
    if panguDir !== nothing
        panguDir = replace(normpath(panguDir), '\\' => '/')
        if panguDir[end] != '/'
            panguDir = panguDir*"/"
        end
        @set_preferences!("panguDir" => panguDir)
    else
        @error "A valid PANGU directory shall be provided."
    end
    if jdkDir !== nothing
        # Can be downloaded from: https://www.oracle.com/java/technologies/downloads/, x64 Compressed Archive for Windows
        @set_preferences!("javasdkDir" => replace(normpath(jdkDir), '\\' => '/'))
    else
        @error "A valid Java SDK directory shall be provided. The SDK can be downloaded as 'x64 Compressed Archive for Windows' from: https://www.oracle.com/java/technologies/downloads/"
    end
end
