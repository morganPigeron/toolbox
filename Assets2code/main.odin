package asset2code

import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import "core:path/filepath"

encode_result :: struct {
	result: string,
	ok:     bool,
}

main :: proc() {

	context.logger = log.create_console_logger()

	//Tracking allocator
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)
	reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
		leaks := false
		for key, value in a.allocation_map {
			fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
			leaks = true
		}
		mem.tracking_allocator_clear(a)
		return leaks
	}
	defer reset_tracking_allocator(&tracking_allocator)
	//Tracking allocator end

	if len(os.args) != 2 {
		fmt.println("usage: <path to asset>")
		return
	}

	asset_path := os.args[1]

	extension := filepath.ext(asset_path)

	result: encode_result
	defer delete(result.result)

	switch extension {
	case ".ttf":
		result = font_encode(asset_path)
		break
	case ".png":
		result = image_encode(asset_path)
		break
	}

	fmt.printfln("%v", result.result)
}