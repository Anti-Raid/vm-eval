DARKLUA_PATH = ${PWD}/darklua

# If on windows, use darklua.exe
ifeq ($(OS),Windows_NT)
	DARKLUA_PATH = ${PWD}/darklua.exe
endif

bundle:
	${DARKLUA_PATH} process init.luau output.luau
