# Prevent multiple includes
if (TARGET dawn_native)
	return()
endif()

include(FetchContent)

FetchContent_Declare(
	dawn
	#GIT_REPOSITORY https://dawn.googlesource.com/dawn
	#GIT_TAG        chromium/5715
	#GIT_SHALLOW ON

	# Manual download mode, even shallower than GIT_SHALLOW ON
	DOWNLOAD_COMMAND
		cd ${FETCHCONTENT_BASE_DIR}/dawn-src &&
		git init &&
		git pull --depth=1 https://dawn.googlesource.com/dawn chromium/5715 &&
		git reset --hard FETCH_HEAD
)

FetchContent_GetProperties(dawn)
if (NOT dawn_POPULATED)
	FetchContent_Populate(dawn)

	find_package(PythonInterp 3 REQUIRED)

	message(STATUS "Running fetch_dawn_dependencies:")
	execute_process(
		COMMAND ${PYTHON_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/tools/fetch_dawn_dependencies.py"
		WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/_deps/dawn-src"
	)

	set(DAWN_BUILD_SAMPLES OFF)
	set(TINT_BUILD_TINT OFF) # TODO
	set(TINT_BUILD_SAMPLES OFF)
	set(TINT_BUILD_DOCS OFF)
	set(TINT_BUILD_TESTS OFF)
	set(TINT_BUILD_FUZZERS OFF)
	set(TINT_BUILD_SPIRV_TOOLS_FUZZER OFF)
	set(TINT_BUILD_AST_FUZZER OFF)
	set(TINT_BUILD_REGEX_FUZZER OFF)
	set(TINT_BUILD_BENCHMARKS OFF)
	set(TINT_BUILD_TESTS OFF)
	set(TINT_BUILD_AS_OTHER_OS OFF)
	set(TINT_BUILD_REMOTE_COMPILE OFF)

	add_subdirectory(${dawn_SOURCE_DIR} ${dawn_BINARY_DIR})
endif ()

set(AllDawnTargets
	core_tables
	dawn_common
	dawn_glfw
	dawn_headers
	dawn_native
	dawn_platform
	dawn_proc
	dawn_utils
	dawn_wire
	dawncpp
	dawncpp_headers
	emscripten_bits_gen
	enum_string_mapping
	extinst_tables
	webgpu_dawn
	webgpu_headers_gen
)

set(AllGlfwTargets
	glfw
	update_mappings
)

foreach (Target ${AllDawnTargets})
	if (TARGET ${Target})
		set_property(TARGET ${Target} PROPERTY FOLDER "External/Dawn")
	endif()
endforeach()

foreach (Target ${AllGlfwTargets})
	if (TARGET ${Target})
		set_property(TARGET ${Target} PROPERTY FOLDER "External/GLFW3")
	endif()
endforeach()

# This is likely needed for other targets as well
# TODO: Notify this upstream
target_include_directories(dawn_utils PUBLIC "${CMAKE_BINARY_DIR}/_deps/dawn-src/src")
